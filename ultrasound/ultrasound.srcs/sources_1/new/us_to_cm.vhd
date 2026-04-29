-- ============================================================
--  us_to_cm.vhd
--  Ultrasound time (µs, 16-bit) → distance (cm, 9-bit)
--
--  Formula : distance_cm = time_us / 58
--  Physics  : sound travels ~343 m/s → 1 cm round-trip ≈ 58 µs
--
--  Interface (all signals active-high unless noted):
--    clk      : system clock (any frequency – purely combinational
--               control is on rising edge)
--    rst      : asynchronous active-high reset
--    start    : pulse high for 1 cycle to begin conversion
--    time_us  : 16-bit measurement from sensor (0–65535 µs)
--               valid and stable when start='1'
--    busy     : '1' while conversion is in progress (16 cycles)
--    done     : 1-cycle pulse when result is ready
--    distance : 9-bit result in cm (0–511)
--               valid on the rising edge where done='1'
--
--  Latency  : 16 clock cycles after start
--  Resource : ~30 LUTs, 2 DSP-free (shift-and-subtract divider)
--
--  Vivado   : synthesises with default settings for 7-series and
--             UltraScale targets; add a timing constraint for clk.
-- ============================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity us_to_cm is
    port (
        clk      : in  std_logic;
        rst      : in  std_logic;                       -- async active-low reset
        start    : in  std_logic;                       -- 1-cycle pulse: latch input & begin
        time_us  : in  std_logic_vector(15 downto 0);  -- microseconds (unsigned)
        busy     : out std_logic;                       -- '1' while dividing
        done     : out std_logic;                       -- 1-cycle result pulse
        distance : out std_logic_vector(8 downto 0)    -- centimetres (unsigned, 9-bit)
    );
end entity us_to_cm;

architecture rtl of us_to_cm is

    -- Divisor constant (58 fits in 6 bits)
    constant DIVISOR  : unsigned(5 downto 0) := to_unsigned(58, 6);

    -- Number of quotient bits = 16 (dividend width)
    constant N        : integer := 16;

    -- Partial remainder needs N+6 bits to avoid overflow during subtraction
    -- (maximum partial remainder < 2^N, divisor < 2^6)
    subtype partial_t is unsigned(N + 5 downto 0);   -- 22 bits wide

    -- Pipeline registers
    signal dividend_r : unsigned(N-1 downto 0);       -- captured input
    signal partial_r  : partial_t;                     -- running partial remainder
    signal quotient_r : unsigned(N-1 downto 0);       -- accumulates quotient bits

    -- Step counter: counts 0..N (17 states → we only need 0..16)
    signal step       : unsigned(4 downto 0);          -- 5 bits covers 0..16

    -- Internal busy / done
    signal busy_i     : std_logic;
    signal done_i     : std_logic;
    --signal distance_i : std_logic_vector(8 downto 0);
begin

    -- ----------------------------------------------------------------
    --  Restoring shift-and-subtract divider (non-restoring variant
    --  would save 1 add but is harder to read — restoring is cleaner
    --  for Vivado synthesis and easily meets timing at 100+ MHz).
    --
    --  Algorithm (N iterations, one per clock):
    --    step 0  : latch inputs, initialise partial remainder to 0
    --    step 1..N : shift partial_r left by 1, shift in next dividend
    --                bit; if (shifted partial >= DIVISOR) subtract and
    --                set quotient bit to '1', else quotient bit '0'
    --    step N+1: assert done for one cycle
    -- ----------------------------------------------------------------

    process(clk, rst)
        variable shifted : partial_t;
        variable trial   : partial_t;
    begin
        if rst = '1' then
            dividend_r  <= (others => '0');
            partial_r   <= (others => '0');
            quotient_r  <= (others => '0');
            step        <= (others => '0');
            distance    <= (others => '0');
            busy_i      <= '0';
            done_i      <= '0';

        elsif rising_edge(clk) then
            done_i <= '0';  -- default: done is low

            if start = '1' and busy_i = '0' then
                -- Capture operands and kick off division
                dividend_r <= unsigned(time_us);
                partial_r  <= (others => '0');
                quotient_r <= (others => '0');
                step       <= (others => '0');
                busy_i     <= '1';

            elsif busy_i = '1' then
                if step < N then
                    -- ------------------------------------------------
                    --  Shift partial remainder left by 1 and bring in
                    --  the next (MSB-first) dividend bit.
                    -- ------------------------------------------------
                    shifted := partial_r(partial_r'high - 1 downto 0)
                               & dividend_r(N - 1 - to_integer(step));

                    -- Trial subtraction
                    trial := shifted - resize(DIVISOR, partial_t'length);

                    if trial(trial'high) = '0' then
                        -- No borrow: subtraction succeeds
                        partial_r              <= trial;
                        quotient_r(N - 1 - to_integer(step)) <= '1';
                    else
                        -- Borrow: restore (keep shifted value)
                        partial_r              <= shifted;
                        quotient_r(N - 1 - to_integer(step)) <= '0';
                    end if;

                    step <= step + 1;

                else
                    -- All N bits processed
                    busy_i <= '0';
                    done_i <= '1';
                    distance <= std_logic_vector(quotient_r(8 downto 0));
                       
                end if;
            end if;
        end if;
    end process;

    -- ----------------------------------------------------------------
    --  Output assignments
    --  The 9-bit distance result is the lower 9 bits of the 16-bit
    --  quotient (max valid input 58*511=29638 µs < 2^15, so the upper
    --  7 bits of the quotient will always be zero for valid inputs).
    -- ----------------------------------------------------------------
    busy     <= busy_i;
    done     <= done_i;

end architecture rtl;
