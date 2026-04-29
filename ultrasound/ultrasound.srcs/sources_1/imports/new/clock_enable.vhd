library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity clock_enable is
    generic( G_MAX: positive :=5);
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           ce : out STD_LOGIC);
end clock_enable;


architecture Behavioral of clock_enable is
    
    -- Internal counter
    signal sig_cnt : integer range 0 to G_MAX-1;

begin

    synchr_process: process(clk) is
    begin
        if rising_edge(clk) then
            ce <= '0'; -- Reset output
            if rst = '1' then     -- High-active reset
                sig_cnt <= 0;     -- Reset internal counter

            elsif sig_cnt = G_MAX-1 then
                ce <= '1';
                sig_cnt <= 0;
            else
                sig_cnt <= sig_cnt+1;
                
            end if;  -- End if for reset/check
        end if;      -- End if for rising_edge
    end process;
    
end Behavioral;
