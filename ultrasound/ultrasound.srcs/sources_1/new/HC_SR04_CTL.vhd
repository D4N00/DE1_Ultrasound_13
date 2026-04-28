library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity HC_SR04_CTL is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           start : in STD_LOGIC;
           trig : out STD_LOGIC;
           echo : in STD_LOGIC;
           echo_time : out STD_LOGIC_VECTOR (15 downto 0);
           start_conv : out std_logic);
           
end HC_SR04_CTL;

architecture Behavioral of HC_SR04_CTL is
    
    constant CLK_FREQ : integer := 100_000_000;             -- System clock frequency (100 MHz)
    constant trig_count : integer := CLK_FREQ/1000000 * 15;    -- Enter the trigger time here (15us) 

    
    -- FSM state definitions
    type state_type is (IDLE, SEND_TRIG, WAIT_ECHO, CNT_ECHO, SEND_START_CONV);
    signal current_state : state_type;

    signal clock_count : unsigned (15 downto 0); --integer range 0 to 999_999_999;
    
    
begin
    p_measure : process (clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                -- Reset state, outputs, and all internal signals
                current_state     <= IDLE;             -- Start in IDLE state
                trig              <= '0';              -- disable trigger
                echo_time          <= (others => '0');  -- reset distance output
                clock_count       <= (others => '0');                -- reset the counter
                start_conv        <= '0';
                
            else
                case current_state is

                    -- IDLE: Wait for the start signal to trigger measurement
                    when IDLE =>
                        trig <= '0'; -- disable trigger

                        if start = '1' then
                            trig <= '1';                -- trigger the sensor
                            clock_count <= (others => '0');           -- reset the counter
                            current_state <= SEND_TRIG; -- move to SEND_TRIG state
                        end if;

                    -- SEND_TRIG: Trigger the sensor with a 10+us pulse
                    when SEND_TRIG =>
                          
                        if clock_count  >=  trig_count then
                            trig <= '0';                    -- end the trigger pulse
                            clock_count   <= (others => '0');             -- Reset clock count
                            current_state <= WAIT_ECHO;     -- move to WAIT_ECHO state
                        else
                            clock_count <= clock_count + 1; --increment the clock counter
                        end if;   
                        
                        
                    -- WAIT_ECHO: wait until the start of the echo pulse
                    when WAIT_ECHO =>

                        if echo = '1' then
                            clock_count   <= (others => '0');         -- Reset clock count
                            current_state <= CNT_ECHO;  -- move to CNT_ECHO state
                        end if;
                            
                    -- CNT_ECHO: count clock cycle pulses in echo pulse
                    when CNT_ECHO =>
                        
                        if echo = '1' then
                            clock_count <= clock_count + 1; --increment the clock counter   
                        else
                            echo_time <= std_logic_vector(clock_count/(CLK_FREQ/1000000)); -- distance is for now equal to echo round trip time in us
                            clock_count   <= (others => '0');   -- Reset clock count
                            current_state <= SEND_START_CONV;   -- move to SEND_START_CONV state
                            start_conv    <= '1';               -- start the conversion pulse
                            
                        end if; 
                    
                    -- SEND_START_CONV: Trigger the conversion module with a 10+us pulse    
                    when SEND_START_CONV =>  
                          
                        if clock_count  >=  trig_count then
                            start_conv    <= '0';               -- end the conversion pulse
                            clock_count   <= (others => '0');   -- Reset clock count
                            current_state <= IDLE;              -- move to IDLE state
                        else
                            clock_count <= clock_count + 1;     --increment the clock counter
                        end if; 
                        
                    -- Default: In case of an unexpected state, return to IDLE
                    when others =>
                        current_state <= IDLE;

                end case;
            end if;
        end if;
    end process p_measure;

end Behavioral;
