--psano s pomoci claude
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bin_to_bcd is
    port (
        bin : in  std_logic_vector(8 downto 0);
        bcd : out std_logic_vector(11 downto 0)  -- (11:8) hundreds, (7:4) tens, (3:0) ones
    );
end entity;

architecture rtl of bin_to_bcd is
begin
    process(bin)
        variable b   : unsigned(8  downto 0);
        variable hun : unsigned(3  downto 0);
        variable ten : unsigned(3  downto 0);
        variable one : unsigned(3  downto 0);
    begin
        b   := unsigned(bin);
        hun := (others => '0');
        ten := (others => '0');
        one := (others => '0');

        for i in 8 downto 0 loop
            -- Add 3 if digit >= 5
            if hun >= 5 then hun := hun + 3; end if;
            if ten >= 5 then ten := ten + 3; end if;
            if one >= 5 then one := one + 3; end if;

            -- Shift left: MSB of b feeds into ones, carry bubbles up
            hun := hun(2 downto 0) & ten(3);
            ten := ten(2 downto 0) & one(3);
            one := one(2 downto 0) & b(i);
        end loop;

        bcd <= std_logic_vector(hun & ten & one);
    end process;
end architecture;
