library ieee;
use ieee.std_logic_1164.all;
entity debouncer is
  generic
  (
    clk_period    : time := 20 ns;
    debounce_time : time
  );
  port
  (
    clk       : in std_ulogic;
    rst       : in std_ulogic;
    input     : in std_ulogic;
    debounced : out std_ulogic := '0'
  );
end entity debouncer;

architecture debouncer_arch of debouncer is
  type State_Type is (idle, output_high, output_low);
  signal current_state, next_state : State_Type;

  --Internal signals/registers
  signal done_delay  : boolean;
  signal start_clock : std_ulogic;

  component timed_counter
    generic
    (
      clk_period : time;
      count_time : time
    );
    port
    (
      clk    : in std_ulogic;
      enable : in std_ulogic;
      done   : out boolean
    );
  end component;
begin

  delay_counter : timed_counter
  generic
  map (
  clk_period => clk_period,
  count_time => debounce_time
  )
  port map
  (
    clk    => clk,
    enable => start_clock,
    done   => done_delay
  );

  STATE_MEMORY : process (clk, rst)
  begin
    if (rst = '1') then
      current_state <= idle;
    elsif rising_edge(clk) then
      current_state <= next_state;
    end if;
  end process;

  NEXT_STATE_LOGIC : process (input, done_delay, rst)
  begin
    case(current_state) is
      when idle =>
      if input = '0' then
        next_state  <= idle;
        start_clock <= '0'; -- Start the clock for delaying
      else
        next_state  <= output_high; --Return to idle state -> No inputs
        start_clock <= '1'; -- Disable clock while in idle
      end if;

      when output_high =>
      if done_delay = true then
        if input = '1' then -- If input is still high after completing delay
          next_state  <= output_high;
          start_clock <= '0'; -- Disable counter
        else
          next_state  <= output_low; -- Change to low state
          start_clock <= '1'; --Start counter for low state
        end if;
      end if;
      when output_low =>
      if done_delay = false then -- If still counting do nothing
        start_clock <= start_clock;
      else
        next_state  <= idle; -- If done counting return to idle state
        start_clock <= '0'; -- Disable the counter
      end if;
		when others => next_state <= next_state;

    end case;
  end process;

  OUTPUT_LOGIC : process (current_state, done_delay)
  begin
    if current_state = output_high then
      debounced <= '1';
    else
      debounced <= '0';
    end if;
  end process;

end architecture;