-- ============================================================
--  us_to_cm.vhd
--  Ultrasound time (µs, 16-bit) → distance (cm, 9-bit)
--
--  Formula : distance_cm = time_us / 58 
--  Physics  : sound travels ~343 m/s → 1 cm round-trip ≈ 58 µs
--
--  Interface (all signals active-high unless noted):
--    clk      : system clock 
--    rst      : reset input
--    start    : pulse high for 1 cycle to begin conversion
--    time_us  : 16-bit measurement from sensor (0–65535 µs)
--    busy     : '1' while conversion is in progress
--    done     : 1-cycle pulse when result is ready
--    distance : 9-bit result in cm (0–511)
--         
--   generated with the help of Claude 
--      
-- ============================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity us_to_cm is
    port (
        clk      : in  std_logic;
        rst      : in  std_logic;                       
        start    : in  std_logic;                       
        time_us  : in  std_logic_vector(15 downto 0);  -- microseconds (unsigned, 16-bit)
        busy     : out std_logic;                       
        done     : out std_logic;                       
        distance : out std_logic_vector(8 downto 0)    -- centimetres (unsigned, 9-bit)
    );
end entity us_to_cm;

architecture rtl of us_to_cm is
    
    constant DIVISOR  : unsigned(5 downto 0) := to_unsigned(58, 6); -- Divisor constant (58 fits in 6 bits)
    constant N        : integer := 16;              -- Number of quotient bits = 16 (dividend width)
    subtype partial_t is unsigned(N + 5 downto 0);   

    signal dividend_r : unsigned(N-1 downto 0);     -- captured input
    signal partial_r  : partial_t;                  -- running partial remainder
    signal quotient_r : unsigned(N-1 downto 0);     -- accumulates quotient bits
    signal step       : unsigned(4 downto 0);       -- 5 bits covers 0..16
    signal busy_i     : std_logic;
    signal done_i     : std_logic;

begin

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
            done_i <= '0';

            if start = '1' and busy_i = '0' then
                dividend_r <= unsigned(time_us);
                partial_r  <= (others => '0');
                quotient_r <= (others => '0');
                step       <= (others => '0');
                busy_i     <= '1';

            elsif busy_i = '1' then
                if step < N then

                    shifted := partial_r(partial_r'high - 1 downto 0)
                               & dividend_r(N - 1 - to_integer(step));

                    trial := shifted - resize(DIVISOR, partial_t'length);

                    if trial(trial'high) = '0' then
                        partial_r              <= trial;
                        quotient_r(N - 1 - to_integer(step)) <= '1';
                    else
                        partial_r              <= shifted;
                        quotient_r(N - 1 - to_integer(step)) <= '0';
                    end if;

                    step <= step + 1;

                else
                    busy_i <= '0';
                    done_i <= '1';
                    distance <= std_logic_vector(quotient_r(8 downto 0));
                       
                end if;
            end if;
        end if;
    end process;

    busy     <= busy_i;
    done     <= done_i;

end architecture rtl;
