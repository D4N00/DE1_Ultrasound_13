-- Testbench automatically generated online
-- at https://vhdl.lapinoo.net
-- Generation date : Wed, 08 Apr 2026 13:39:45 GMT
-- Request id : cfwk-fed377c2-69d65aa1346df

library ieee;
use ieee.std_logic_1164.all;

entity tb_HC_SR04_CTL is
end tb_HC_SR04_CTL;

architecture tb of tb_HC_SR04_CTL is

    component HC_SR04_CTL
        port (clk      : in std_logic;
              rst      : in std_logic;
              start    : in std_logic;
              trig     : out std_logic;
              echo     : in std_logic;
              echo_time : out std_logic_vector (15 downto 0);
              start_conv : out std_logic);
              
    end component;

    signal clk      : std_logic;
    signal rst      : std_logic;
    signal start    : std_logic;
    signal trig     : std_logic;
    signal echo     : std_logic;
    signal echo_time : std_logic_vector (15 downto 0);
    signal start_conv : std_logic;

    constant TbPeriod : time := 10 ns; -- ***EDIT*** Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    dut : HC_SR04_CTL
    port map (clk      => clk,
              rst      => rst,
              start    => start,
              trig     => trig,
              echo     => echo,
              echo_time => echo_time,
              start_conv => start_conv);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- ***EDIT*** Check that clk is really your main clock signal
    clk <= TbClock;

    stimuli : process
    begin
        -- ***EDIT*** Adapt initialization as needed
        start <= '0';
        echo <= '0';

        -- Reset generation
        -- ***EDIT*** Check that rst is really your reset signal
        rst <= '1';
        wait for 1000 ns;
        rst <= '0';
        wait for 1000 ns;
        
        
        start <= '1';
        wait for 1000 ns;
        start <= '0';
        
        wait for 200us;
        
        echo <= '1';
        wait for 250us;
        echo <= '0';
        
        wait for 250us;
        
        -- another measurement
        rst <= '1';
        wait for 100 ns;
        rst <= '0';
        wait for 1000 ns;
        
        start <= '1';
        wait for 100 ns;
        start <= '0';
        
        wait for 200us;
        
        echo <= '1';
        wait for 345us;
        echo <= '0';
        
        wait for 250us;
        
        -- another measurement
        rst <= '1';
        wait for 100 ns;
        rst <= '0';
        wait for 1000 ns;
        
        start <= '1';
        wait for 100 ns;
        start <= '0';
        
        wait for 200us;
        
        echo <= '1';
        wait for 5450us;
        echo <= '0';
        
        wait for 250us;

            
        -- ***EDIT*** Add stimuli here
        wait for 10000 * TbPeriod;

        -- Stop the clock and hence terminate the simulation
        TbSimEnded <= '1';
        wait;
    end process;

end tb;

-- Configuration block below is required by some simulators. Usually no need to edit.

configuration cfg_tb_HC_SR04_CTL of tb_HC_SR04_CTL is
    for tb
    end for;
end cfg_tb_HC_SR04_CTL;