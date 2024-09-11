library ieee;
use ieee.std_logic_1164.all;

entity vending_machine is
  port (
        clk     : in std_ulogic;
        rst     : in std_ulogic;
        nickel  : in std_ulogic;
        dime    : in std_ulogic;
        dispense  : out std_ulogic;
        amount    : out natural range 0 to 15
      );
end entity vending_machine;

architecture VM_arch of vending_machine is
      -- Declare state types
      type State_Type is (zero_cents, five_cents, ten_cents, fifteen_cents);
      signal next_state, current_state    : State_Type := zero_cents;
      -- Declare internal tracker of money
      signal MoneyTracker     : natural := 0;
begin
      --Synchronous state memory for where to go. Changing states only allowed on rising edge of clock
      STATE_MEMORY : process (clk, rst)
      begin
            if ( rst = '1') then 
                  current_state <= zero_cents;
            elsif (rising_edge(clk)) then 
                  current_state <= next_state;
            end if;
      end process;
      --NEXT state logic to control which state to move to from the current state
      --Combinational logic.
      --Controls internal money tracker
      NEXT_STATE_LOGIC : process (current_state, nickel, dime)
      begin
            case (current_state) is 
                  when zero_cents => if    (dime = '1') then 
                                          next_state <= ten_cents;
                                     elsif (nickel = '1') then 
                                          next_state <= five_cents;
                                     else 
                                          next_state <= zero_cents;
                                     end if;
                  
                  when five_cents => if    (dime = '1') then 
                                          next_state <= fifteen_cents;
                                     elsif (nickel = '1') then 
         				  next_state <= ten_cents;
                                     else 
                                          next_state <= five_cents;
                                     end if;

  
                  when ten_cents => if    (nickel = '1' or dime = '1') then 
                                          next_state <= fifteen_cents;
                                    else
                                          next_state <= ten_cents;
                                    end if;
	
                  when fifteen_cents => next_state <= zero_cents;

                  when others => next_state <= current_state;
                                    
            end case;
      end process;

      --OUTPUT Logic to both display for current amount inserted and if dispense
      --Combinational logic
      OUTPUT_LOGIC : process (current_state)
      begin
   
            --Determine dispense signal based on current state
            case(current_state) is 
                  when zero_cents     =>   dispense <= '0';
						amount <= 0;
                  				
		  when five_cents         =>  dispense <= '0';
                                     		amount <= amount + 5;


                  when ten_cents      =>  dispense <= '0';
                                              amount <= 10;
                  when fifteen_cents      =>    dispense <= '1';
						amount <= 15;
                                                
                  when others             => 	dispense <= '0';
            end case;
      end process;

end architecture;
