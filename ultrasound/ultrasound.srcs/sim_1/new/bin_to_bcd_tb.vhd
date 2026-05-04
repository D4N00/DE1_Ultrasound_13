--------------
--generovane pomoci calude
--------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_bin_to_bcd is
end tb_bin_to_bcd;

architecture tb of tb_bin_to_bcd is
    component bin_to_bcd
        port (bin : in  std_logic_vector(8 downto 0);
              bcd : out std_logic_vector(11 downto 0));
    end component;

    signal bin : std_logic_vector(8 downto 0);
    signal bcd : std_logic_vector(11 downto 0);
begin
    dut : bin_to_bcd port map (bin => bin, bcd => bcd);

    process
    begin
    
        bin <= std_logic_vector(to_unsigned(0,   9));
        
        wait for 20 ns;
        
        bin <= std_logic_vector(to_unsigned(50,  9));
        
        wait for 20 ns;
        
        bin <= std_logic_vector(to_unsigned(100, 9));
        
        wait for 20 ns;
        
        bin <= std_logic_vector(to_unsigned(255, 9));
        
        wait for 20 ns;
        
        wait;
        
    end process;
end tb;