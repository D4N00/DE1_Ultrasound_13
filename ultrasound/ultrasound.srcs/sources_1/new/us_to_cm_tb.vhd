-- ============================================================
--  Testbench  (simulate in Vivado simulator or ModelSim)
-- ============================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity us_to_cm_tb is
end entity us_to_cm_tb;

architecture sim of us_to_cm_tb is

    signal clk_s      : std_logic := '0';
    signal rst_s    : std_logic := '0';
    signal start_s    : std_logic := '0';
    signal time_us_s  : std_logic_vector(15 downto 0) := (others => '0');
    signal busy_s     : std_logic;
    signal done_s     : std_logic;
    signal dist_s     : std_logic_vector(8 downto 0);

    constant CLK_PERIOD : time := 10 ns;  -- 100 MHz

    -- Convenience: drive one conversion and print result
    procedure do_conversion (
        constant t_us    : in  integer;
        signal   clk     : in  std_logic;
        signal   start   : out std_logic;
        signal   time_us : out std_logic_vector(15 downto 0);
        signal   busy    : in  std_logic;
        signal   done    : in  std_logic;
        signal   dist    : in  std_logic_vector(8 downto 0)
    ) is
    begin
        time_us <= std_logic_vector(to_unsigned(t_us, 16));
        wait until rising_edge(clk);
        start <= '1';
        wait until rising_edge(clk);
        start <= '0';
        -- Wait for done
        wait until done = '1' and rising_edge(clk);
        report "time_us=" & integer'image(t_us)
             & "  distance_cm=" & integer'image(to_integer(unsigned(dist)))
             & "  expected=" & integer'image(t_us / 58);
    end procedure;

begin

    -- DUT instantiation
    DUT : entity work.us_to_cm
        port map (
            clk      => clk_s,
            rst      => rst_s,
            start    => start_s,
            time_us  => time_us_s,
            busy     => busy_s,
            done     => done_s,
            distance => dist_s
        );

    -- Clock generation
    clk_s <= not clk_s after CLK_PERIOD / 2;

    -- Stimulus
    process
    begin
        rst_s <= '1';
        wait for 3 * CLK_PERIOD;
        rst_s <= '0';
        wait for 2 * CLK_PERIOD;

        -- Test vectors: time_us / 58 = expected_cm
        do_conversion(  58, clk_s, start_s, time_us_s, busy_s, done_s, dist_s);  -- 1 cm
        do_conversion( 116, clk_s, start_s, time_us_s, busy_s, done_s, dist_s);  -- 2 cm
        do_conversion( 580, clk_s, start_s, time_us_s, busy_s, done_s, dist_s);  -- 10 cm
        do_conversion(2900, clk_s, start_s, time_us_s, busy_s, done_s, dist_s);  -- 50 cm
        do_conversion(5800, clk_s, start_s, time_us_s, busy_s, done_s, dist_s);  -- 100 cm
        do_conversion(29638,clk_s, start_s, time_us_s, busy_s, done_s, dist_s);  -- 511 cm (max)

        wait for 10 * CLK_PERIOD;
        report "Simulation complete." severity note;
        std.env.stop;
    end process;

end architecture sim;