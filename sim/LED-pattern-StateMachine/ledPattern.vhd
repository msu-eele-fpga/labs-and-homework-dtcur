library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity led_patterns is
  generic (
    system_clock_period : time := 20 ns
  );
  port (
    clk             : in std_ulogic;
    rst             : in std_ulogic;
    push_button     : in std_ulogic;
    switches        : in std_ulogic_vector(3 downto 0);
    hps_led_control : in boolean;
    base_period     : in unsigned(7 downto 0);
    led_reg         : in std_logic_vector (7 downto 0);
    led             : out std_ulogic_vector(7 downto 0)
  );
end entity;

architecture pattern of led_patterns is
  type State_Type is (idle, NewPattern, ledPatternOut);
  signal next_state, current_state : State_Type := idle;

  --Clock divider signals
  signal clock_enable_1s, clock_enable_baseRate         : boolean;
  signal clock_1s_done, base_rate_done, enable_1s_delay : boolean;

  signal Half_base_period_integer, Quarter_base_period_integer, Eighth_base_period_integer, Twice_base_period_integer, Sixteenth_base_period_integer : integer;
  signal Half_divider_done, Quarter_divider_done, Eighth_divider_done, Twice_divider_done, Sixteenth_divider_done                                    : boolean;

  -- Base Rate calcualtion signals
  signal base_period_integer, base_period_fractional : integer;
  --LED mode integer
  signal SwitchInputRegister, LEDMode : integer range 0 to 15;
  --Internal LED patterns registers to hold the always running patterns
  signal LEDPattern0Register, LEDPattern1Register, LEDPattern2Register, LEDPattern3Register, LEDPattern4Register : unsigned(6 downto 0);
  --Internal LED 7 signal 
  signal LEDBIT7 : std_ulogic := '0';
  --Clock divider component. Creates a 1 clock pulse boolean done when completed counting for the specified number of clock cycles.
  component clock_divider
    port (
      count  : in integer;
      clk    : in std_ulogic;
      enable : in boolean;
      done   : out boolean
    );
  end component;
begin

  ------------------------ Calculate base rate clock divider and fractional dividers -------------------------------------------------------------------------------------------------------------------------------------------------------
  base_period_integer           <= (to_integer(base_period(7 downto 4)) * 1E9 + to_integer(base_period(3 downto 3)) * 5E8 + to_integer(base_period(2 downto 2)) * 25E7 + to_integer(base_period(1 downto 1)) * 125E6 + to_integer(base_period(0 downto 0)) * 625E5)/20;
  half_base_period_integer      <= base_period_integer / 2;
  Quarter_base_period_integer   <= base_period_integer / 4;
  Eighth_base_period_integer    <= base_period_integer / 8;
  Sixteenth_base_period_integer <= base_period_integer / 16;
  Twice_base_period_integer     <= base_period_integer * 2;
  --------------------- Create clock divider components of type clock_divider one for each clock frequency --------------------------------------------------------------------------------------------------------------------------------
  OneSecondDelay : clock_divider
  port map(
    count  => 5E7,
    clk    => clk,
    enable => enable_1s_delay,
    done   => clock_1s_done
  );
  BaseRate : clock_divider
  port map(
    count  => base_period_integer,
    clk    => clk,
    enable => true,
    done   => base_rate_done
  );
  HalfBaseRate : clock_divider
  port map(
    count  => Half_base_period_integer,
    clk    => clk,
    enable => true,
    done   => Half_divider_done
  );

  QuarterBaseRate : clock_divider
  port map(
    count  => Quarter_base_period_integer,
    clk    => clk,
    enable => true,
    done   => Quarter_divider_done
  );
  EighthBaseRate : clock_divider
  port map(
    count  => Eighth_base_period_integer,
    clk    => clk,
    enable => true,
    done   => Eighth_divider_done
  );

  SixteenthBaseRate : clock_divider
  port map(
    count  => Sixteenth_base_period_integer,
    clk    => clk,
    enable => true,
    done   => Sixteenth_divider_done
  );
  TwiceBaseRate : clock_divider
  port map(
    count  => Twice_base_period_integer,
    clk    => clk,
    enable => true,
    done   => Twice_divider_done
  );

  ---------------------------------------------- Store swtiches value in a register for later use when determining state.
  SwitchInputRegister <= to_integer(unsigned(switches));
  --store LEDbit7 
  led(7) <= LEDBIT7;
  ----------------------------------------------Synchronous state memory for where to go. Changing this state is only allowed on a riseing edge of the clock--------------------------------------------------------------------------------
  STATE_MEMORY : process (clk, rst)
  begin
    --Check first for hardware or software control of the LEDs
    if (hps_led_control) then
      current_state <= idle;
    else
      if (rst = '1') then
        current_state <= idle;
      elsif (rising_edge(clk)) then
        current_state <= next_state;
      else
        current_state <= current_state;
      end if;
    end if;
  end process;

  ---------------------------------------------Next state logic to control which state to move to from the current state ----------------------------------------------------------------------------------------------------------------------
  NEXT_STATE_LOGIC : process (current_state, push_button, clock_1s_done, SwitchInputRegister, LEDMode)
  begin
    case (current_state) is
      when idle =>
        enable_1s_delay <= false;
        if (push_button = '1') then
          next_state <= NewPattern;
        else
          next_state <= idle;
        end if;
      when NewPattern =>
        if (clock_1s_done) then --Check for end of 1s delay
          --Check for potential overflow
          if (SwitchInputRegister > 4) then
            LEDMode <= LEDMode;
          else
            LEDMode <= SwitchInputRegister;
          end if; -- End overlfow check
          next_state <= ledPatternOut;
        else --If not end of 1s delay
          if (enable_1s_delay = false) then
            enable_1s_delay <= true;
          end if;
          next_state <= NewPattern;
        end if;
      when ledPatternOut =>
        enable_1s_delay <= false;
        if (push_button = '1') then
          next_state <= NewPattern;
        else
          next_state <= ledPatternOut;
        end if;
    end case;
  end process;

  ---------------------------------------------Ouput logic to both display the LED patterns and switches on button press-------------------------------------------------------------------------------------------------------------------------
  SWITCHS_AND_7LED_LOGIC : process (current_state, rst, clk, base_rate_done, clock_1s_done, Half_divider_done, Quarter_divider_done, Eighth_divider_done, Twice_divider_done)
  begin
    if (rising_edge(clk)) then
      if (rst = '1') then
        led(6 downto 0) <= "0000000";
		  LEDBIT7 <= '0';
      else
        case(current_state) is
          -------------------- Idle state: default state on start up and after reset. Display pattern 0 as the default pattern
          when idle =>
          --Overwrite the hardware control of the LEDs if software is controling LEDs
          if (hps_led_control) then
            led(6 downto 0) <= to_stdulogicvector(led_reg(6 downto 0));
				LEDBIT7 <= led_reg(7);
          else --Otherwise let the hardware control the LEDs
            --- Start in the pattern 0 as the default pattern per lab
            led(6 downto 0) <= std_ulogic_vector(LEDPattern0Register);
            if (base_rate_done) then
              LEDBIT7 <= not LEDBIT7;
            end if;
          end if;

          ------------------ NewPattern state: Display the value of the switches for mode selection for 1 second then switch states
          when NewPattern =>
          if (base_rate_done) then
            LEDBIT7 <= not LEDBIT7;
          end if;
          led(6 downto 4) <= "000";
          led(3 downto 0) <= switches;

          ------------------ ledPatternOut state: Display the currently selected pattern. Reachable after completing the delay from entering a new mode on the switches
          when ledPatternOut =>

          if (base_rate_done) then
            LEDBIT7 <= not LEDBIT7;
          end if;
          --LED mode switch case
          case(LEDMode) is

            when (0)    => led(6 downto 0)    <= std_ulogic_vector(LEDPattern0Register);
            when (1)    => led(6 downto 0)    <= std_ulogic_vector(LEDPattern1Register);
            when (2)    => led(6 downto 0)    <= std_ulogic_vector(LEDPattern2Register);
            when (3)    => led(6 downto 0)    <= std_ulogic_vector(LEDPattern3Register);
            when (4)    => led(6 downto 0)    <= std_ulogic_vector(LEDPattern4Register);
            when others => led(6 downto 0) <= "1010101";
          end case; -- End LED mode switch case
        end case; -- End current state switch case
      end if;   -- End Reset condition if statement
    else
    end if; -- End clk condition if statement
  end process;

  ----------------------------------------- LED Pattern Processes for calculating the output Pattern ------------------------------------------------------------------------------------------------------------------------------------------------

  LED_PATTERN_0 : process (clk, Half_divider_done)
    variable Half_base_counter_tracker : natural range 0 to 8 := 0;
  begin
    if (rising_edge(clk)) then
      if (Half_divider_done) then
        Half_base_counter_tracker := Half_base_counter_tracker + 1;
        case(Half_base_counter_tracker) is
          when 1 => LEDPattern0Register(6 downto 0) <= "0000000";
          when 2 => LEDPattern0Register(6 downto 0) <= "1000000";
          when 3 => LEDPattern0Register(6 downto 0) <= "0100000";
          when 4 => LEDPattern0Register(6 downto 0) <= "0010000";
          when 5 => LEDPattern0Register(6 downto 0) <= "0001000";
          when 6 => LEDPattern0Register(6 downto 0) <= "0000100";
          when 7 => LEDPattern0Register(6 downto 0) <= "0000010";
          when 8 => LEDPattern0Register(6 downto 0) <= "0000001";
          Half_base_counter_tracker                := 1;
          when others => Half_base_counter_tracker := 1;
        end case;
      end if;
    end if;
  end process;
  LED_PATTERN_1 : process (clk, Quarter_divider_done)
    variable Quarter_base_counter_tracker : natural range 0 to 8 := 0;
  begin
    if (rising_edge(clk)) then
      if (Quarter_divider_done) then
        Quarter_base_counter_tracker := Quarter_base_counter_tracker + 1;
        case(Quarter_base_counter_tracker) is
          when 1 => LEDPattern1Register(6 downto 0) <= "0000000";
          when 2 => LEDPattern1Register(6 downto 0) <= "1100000";
          when 3 => LEDPattern1Register(6 downto 0) <= "0110000";
          when 4 => LEDPattern1Register(6 downto 0) <= "0011000";
          when 5 => LEDPattern1Register(6 downto 0) <= "0001100";
          when 6 => LEDPattern1Register(6 downto 0) <= "0000110";
          when 7 => LEDPattern1Register(6 downto 0) <= "0000011";
          when 8 => LEDPattern1Register(6 downto 0) <= "1000001";
          Quarter_base_counter_tracker                := 1;
          when others => Quarter_base_counter_tracker := 1;
        end case;
      end if;
    end if;
  end process;

  LED_PATTERN_2 : process (clk, Twice_divider_done)
    variable Twice_base_counter_tracker : natural range 0 to 127 := 0;
  begin
    if (rising_edge(clk)) then
      if (Twice_divider_done) then
        Twice_base_counter_tracker := Twice_base_counter_tracker + 1;
        LEDPattern2Register <= to_unsigned(Twice_base_counter_tracker, LEDPattern2Register'length);
      end if;
    end if;
  end process;

  LED_PATTERN_3 : process (clk, Eighth_divider_done)
    variable Eighth_base_counter_tracker : natural range 0 to 127 := 0;
  begin
    if (rising_edge(clk)) then
      if (Eighth_divider_done) then
        Eighth_base_counter_tracker := Eighth_base_counter_tracker - 1;
        LEDPattern3Register <= to_unsigned(Eighth_base_counter_tracker, LEDPattern3Register'length);
      end if;
    end if;
  end process;

  LED_PATTERN_4 : process (clk, Sixteenth_divider_done)
    variable Sixteenth_base_counter_tracker : natural range 0 to 6 := 0;
  begin
    if (rising_edge(clk)) then
      if (Sixteenth_divider_done) then
        Sixteenth_base_counter_tracker := Sixteenth_base_counter_tracker + 1;
        case(Sixteenth_base_counter_tracker) is
          when 1 => LEDPattern4Register(6 downto 0) <= "0001000";
          when 2 => LEDPattern4Register(6 downto 0) <= "0010100";
          when 3 => LEDPattern4Register(6 downto 0) <= "0100010";
          when 4 => LEDPattern4Register(6 downto 0) <= "1000001";
          when 5 => LEDPattern4Register(6 downto 0) <= "0100010";
          when 6 => LEDPattern4Register(6 downto 0) <= "0010100";
          Sixteenth_base_counter_tracker                := 0;
          when others => Sixteenth_base_counter_tracker := 0;
        end case;
      end if;
    end if;
  end process;

end architecture;
