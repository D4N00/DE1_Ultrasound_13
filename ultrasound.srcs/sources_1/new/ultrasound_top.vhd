library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ultrasound_top is
        Port ( clk       : in  STD_LOGIC;
               rst       : in  STD_LOGIC;
               btnu      : in  STD_LOGIC;
               btnd      : in  STD_LOGIC;
               hcechopin : in  STD_LOGIC;
               hctrigpin : out STD_LOGIC;
               seg       : out std_logic_vector(6 downto 0);
               an        : out std_logic_vector(3 downto 0);
               dp        : out std_logic; 
               );
                                            
end ultrasound_top;

architecture Behavioral of ultrasound_top is
    
    component debounce is
        Port ( clk       : in  STD_LOGIC;
               rst       : in  STD_LOGIC;
               btn_in    : in  STD_LOGIC;
               btn_state : out STD_LOGIC;
               btn_press : out STD_LOGIC);
    end component debounce;

   component HC_SR04_CTL is
        Port ( clk       : in  STD_LOGIC;
               rst       : in  STD_LOGIC;
               start     : in  STD_LOGIC;
               echo      : in STD_LOGIC;
               trig      : out STD_LOGIC;
               echo_time : out std_logic_vector(15 downto 0)
               );
    end component HC_SR04_CTL;
    
    
    signal sig_start : std_logic;
    signal sig_time  : std_logic_vector(15 downto 0);

begin

    debounce_inst : debounce
        port map (
            clk       => clk,
            rst       => btnd,
            btn_in    => btnu,
            btn_press => sig_start,
            btn_state => open
        );
        
    HC_SR04_CTL_inst : HC_SR04_CTL
        port map (
            clk       => clk,
            rst       => btnd,
            start     => sig_start,
            trig      => hctrigpin,
            echo      => hcechopin,
            echo_time => sig_time
        ); 
    
    dp <= '1';
    
end Behavioral;
