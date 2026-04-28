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
               btnu      : in  STD_LOGIC;
               btnd      : in  STD_LOGIC;
               hcechopin : in  STD_LOGIC;
               hctrigpin : out STD_LOGIC;
               seg       : out std_logic_vector(6 downto 0);
               an        : out std_logic_vector(7 downto 0);
               dp        : out std_logic
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
               echo_time : out std_logic_vector(15 downto 0);
               start_conv : out std_logic
               );
    end component HC_SR04_CTL;
    
    component us_to_cm is
        port (
            clk      : in  std_logic;
            rst      : in  std_logic;                       -- async active-low reset
            start    : in  std_logic;                       -- 1-cycle pulse: latch input & begin
            time_us  : in  std_logic_vector(15 downto 0);  -- microseconds (unsigned)
            busy     : out std_logic;                       -- '1' while dividing
            done     : out std_logic;                       -- 1-cycle result pulse
            distance : out std_logic_vector(8 downto 0)    -- centimetres (unsigned, 9-bit)
        );
    end component us_to_cm;
    
    component bin_to_bcd is
        port (
            bin : in  std_logic_vector(8 downto 0);
            bcd : out std_logic_vector(11 downto 0)  -- (11:8) hundreds, (7:4) tens, (3:0) ones
        );
    end component bin_to_bcd;
    
    component display_driver is
        Port ( clk : in STD_LOGIC;
               rst : in STD_LOGIC;
               data : in STD_LOGIC_VECTOR (15 downto 0);
               seg : out STD_LOGIC_VECTOR (6 downto 0);
               anode : out STD_LOGIC_VECTOR (3 downto 0));
    end component display_driver;

    
    signal sig_start        : std_logic;
    signal sig_start_conv   :std_logic;
    signal sig_time         : std_logic_vector(15 downto 0);
    signal sig_dist         : std_logic_vector(8 downto 0);
    signal sig_bcd          : std_logic_vector(11 downto 0); 
    
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
            echo_time => sig_time, 
            start_conv => sig_start_conv
        ); 
        
    us_to_cm_inst : us_to_cm
        port map (
            clk       => clk,
            rst       => btnd,
            start     => sig_start_conv,
            busy      => open,
            done      => open,
            time_us   => sig_time,
            distance  => sig_dist
        );     
        
     bin_to_bcd_inst: bin_to_bcd
        port map(
            bin => sig_dist, --sig_time(8 downto 0)
            bcd => sig_bcd
        );   
     
     display_driver_inst: display_driver
        Port map(   clk => clk,
                    rst => btnd,
                    data(11 downto 0) => sig_bcd(11 downto 0),
                    data(15 downto 12) => b"0000",
                    seg => seg,
                    anode => an(3 downto 0)
        );    
     
     --sig_dist <= b"1_1111_1111";
     
     
     an(7 downto 4) <= b"1111";
     dp <= '1';
    
end Behavioral;
