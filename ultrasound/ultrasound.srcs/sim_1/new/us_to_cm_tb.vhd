--------------
--generovane pomoci calude
--------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_us_to_cm is
end tb_us_to_cm;

architecture tb of tb_us_to_cm is

    component us_to_cm
        port (clk      : in std_logic;
              rst      : in std_logic;
              start    : in std_logic;
              time_us  : in std_logic_vector (15 downto 0);
              busy     : out std_logic;
              done     : out std_logic;
              distance : out std_logic_vector (8 downto 0));
    end component;

    signal clk      : std_logic;
    signal rst      : std_logic;
    signal start    : std_logic;
    signal time_us  : std_logic_vector (15 downto 0);
    signal busy     : std_logic;
    signal done     : std_logic;
    signal distance : std_logic_vector (8 downto 0);

    constant TbPeriod : time := 10 ns;
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    dut : us_to_cm
    port map (clk      => clk,
              rst      => rst,
              start    => start,
              time_us  => time_us,
              busy     => busy,
              done     => done,
              distance => distance);

    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';
    clk <= TbClock;

    stimuli : process
    begin
        start   <= '0';
        time_us <= (others => '0');

        rst <= '1';
        wait for 20 ns;
        rst <= '0';
        wait for 10 ns;

        -- 58 us = 1 cm
        time_us <= std_logic_vector(to_unsigned(58, 16));
        start <= '1'; wait for TbPeriod; start <= '0';
        wait until done = '1'; wait for TbPeriod;

        -- 580 us = 10 cm
        time_us <= std_logic_vector(to_unsigned(580, 16));
        start <= '1'; wait for TbPeriod; start <= '0';
        wait until done = '1'; wait for TbPeriod;

        -- 2900 us = 50 cm
        time_us <= std_logic_vector(to_unsigned(2900, 16));
        start <= '1'; wait for TbPeriod; start <= '0';
        wait until done = '1'; wait for TbPeriod;

        TbSimEnded <= '1';
        wait;
    end process;

end tb;

configuration cfg_tb_us_to_cm of tb_us_to_cm is
    for tb
    end for;
end cfg_tb_us_to_cm;