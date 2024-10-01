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
    led_reg         : in std_ulogic_vector (7 downto 0);
    led             : out std_ulogic_vector(7 downto 0)
  );
end entity;

architecture pattern of led_patterns is
  type State_Type is (idle, blinkSwitches, ledPatternOut);
  signal next_state, current_state : State_Type := idle;
  --Clock divider signals
  signal clock_enable_1s, clock_enable_baseRate : boolean;
  signal clock_divider_done, base_rate_done     : boolean;

  signal Half_base_period_integer, Quarter_base_period_integer, Eighth_base_period_integer, Twice_base_period_integer : integer;
  signal Half_divider_done, Quarter_divider_done, Eighth_divider_done, Twice_divider_done                             : boolean;
  -- Base Rate calcualtion signals
  signal base_period_integer, base_period_fractional : integer;
  --LED mode integer
  signal LEDMode : integer range 0 to 15;
  component clock_divider
    port (
      count  : in integer;
      clk    : in std_ulogic;
      enable : in boolean;
      done   : out boolean
    );
  end component;
begin

  --Bring switches value into an integer for switch case later
  LEDMode <= to_integer(unsigned(switches));
  --base_period_integer <= to_integer(base_period(7 downto 4)) * 1E9 + to_integer(base_period(3)) * 5E8; -- + to_integer(base_period(2)) * 25E7 + to_integer(base_period(1)) * 125E6 + to_integer(base_period(0)) * 625E5;
  base_period_integer         <= (to_integer(base_period(7 downto 4)) * 1E9 + to_integer(base_period(3 downto 3)) * 5E8 + to_integer(base_period(2 downto 2)) * 25E7 + to_integer(base_period(1 downto 1)) * 125E6 + to_integer(base_period(0 downto 0)) * 625E5)/20;
  half_base_period_integer    <= base_period_integer / 2;
  Quarter_base_period_integer <= base_period_integer / 4;
  Eighth_base_period_integer  <= base_period_integer / 8;
  Twice_base_period_integer   <= base_period_integer * 2;
  --Create clock dividers for 1 second and for slow blinking
  OneSecondDelay : clock_divider

  port map(
    count  => 5E7,
    clk    => clk,
    enable => clock_enable_1s,
    done   => clock_divider_done
  );
  BaseRate : clock_divider
  port map(
    count  => base_period_integer,
    clk    => clk,
    enable => clock_enable_baseRate,
    done   => base_rate_done
  );
  HalfBaseRate : clock_divider
  port map(
    count  => Half_base_period_integer,
    clk    => clk,
    enable => clock_enable_baseRate,
    done   => Half_divider_done
  );

  QuarterBaseRate : clock_divider
  port map(
    count  => Quarter_base_period_integer,
    clk    => clk,
    enable => clock_enable_baseRate,
    done   => Quarter_divider_done
  );
  EighthBaseRate : clock_divider
  port map(
    count  => Eighth_base_period_integer,
    clk    => clk,
    enable => clock_enable_baseRate,
    done   => Eighth_divider_done
  );

  TwiceBaseRate : clock_divider
  port map(
    count  => Twice_base_period_integer,
    clk    => clk,
    enable => clock_enable_baseRate,
    done   => Twice_divider_done
  ); --Synchronous state memory for where to go. Changing this state is only allowed on a riseing edge of the clock
  STATE_MEMORY : process (clk, rst)
  begin
    if (rst = '1') then
      current_state <= idle;
      elsif (rising_edge(clk)) then
      current_state <= next_state;
    end if;
  end process;

  --Next state logic to control which state to move to from the current state 
  NEXT_STATE_LOGIC : process (current_state, switches, push_button, clock_divider_done)
  begin
    case (current_state) is
      when idle =>
        if (push_button = '1') then
          next_state <= blinkSwitches;
        else
          next_state <= idle;
        end if;
      when blinkSwitches =>
        if (clock_divider_done) then
          next_state      <= ledPatternOut;
          clock_enable_1s <= false;
        elsif (clock_enable_1s = false) then
          clock_enable_1s <= true;
        end if;
      when ledPatternOut =>
        clock_enable_1s <= false;
        if (push_button = '1') then
          next_state <= blinkSwitches;
        else
          next_state <= ledPatternOut;
        end if;
    end case;
  end process;



  --Ouput logic to both display the LED patterns and switches on button press
  SWITCHS_AND_7LED_LOGIC : process (current_state, base_rate_done, Half_divider_done, Quarter_divider_done, Eighth_divider_done, Twice_divider_done, rst)
    variable base_counter_tracker         : natural range 0 to 8   := 0;
    variable counter_patterns_tracker     : integer range 0 to 128 := 0;
    variable Half_base_counter_tracker    : natural range 0 to 8   := 0;
    variable Quarter_base_counter_tracker : natural range 0 to 8   := 0;
    variable Eighth_base_counter_tracker  : natural range 0 to 8   := 0;
    variable Twice_base_counter_tracker   : natural range 0 to 8   := 0;
  begin

    if (rst = '1') then
      led(7 downto 0) <= "00000000";
      elsif (rst = '0') then
      case(current_state) is
        when idle =>
        if (base_rate_done) then
          led(7) <= not led(7);
        end if;
        if (clock_enable_baseRate = false) then
          clock_enable_baseRate <= true;
        end if;
        when blinkSwitches =>
        base_counter_tracker := 0;
        if (base_rate_done) then
          led(7)          <= not led(7);
          led(6 downto 4) <= "000";
          led(3 downto 0) <= switches(3 downto 0);
          elsif (clock_enable_baseRate = false) then
          clock_enable_baseRate <= true;
        end if;

        when ledPatternOut =>
        if (base_rate_done) then
          led(7) <= not led(7);
        end
        case(LEDMode) is
          when 0 =>
          if (Half_divider_done) then
            Half_base_counter_tracker := Half_base_counter_tracker + 1;
            case(Half_base_counter_tracker) is
              when 1 => led(6 downto 0) <= "0000000";
              when 2 => led(6 downto 0) <= "1000000";
              when 3 => led(6 downto 0) <= "0100000";
              when 4 => led(6 downto 0) <= "0010000";
              when 5 => led(6 downto 0) <= "0001000";
              when 6 => led(6 downto 0) <= "0000100";
              when 7 => led(6 downto 0) <= "0000010";
              when 8 => led(6 downto 0) <= "0000001";
              Half_base_counter_tracker                := 1;
              when others => Half_base_counter_tracker := 1;
            end case;
          end if;
          when 1 =>
          if (Quarter_divider_done) then
            Quarter_base_counter_tracker := Quarter_base_counter_tracker + 1;
            case(Quarter_base_counter_tracker) is
              when 1 => led(6 downto 0) <= "0000011";
              when 2 => led(6 downto 0) <= "0000110";
              when 3 => led(6 downto 0) <= "0001100";
              when 4 => led(6 downto 0) <= "0011000";
              when 5 => led(6 downto 0) <= "0110000";
              when 6 => led(6 downto 0) <= "1100000";
              when 7 => led(6 downto 0) <= "1000001";
              when 8 => led(6 downto 0) <= "0000011";
              Quarter_base_counter_tracker                := 1;
              when others => Quarter_base_counter_tracker := 1;
            end case;
          end if;
          when 2 =>
          if (Twice_divider_done) then
            Twice_base_counter_tracker := Twice_base_counter_tracker + 1;
            if (Twice_base_counter_tracker = 128) then
              Twice_base_counter_tracker := 0;
            end if;
            led(6 downto 0) <= std_ulogic_vector(to_unsigned(counter_patterns_tracker, 7));
          end if;
          when 3 =>
          if (Eighth_divider_done) then
            counter_patterns_tracker := counter_patterns_tracker - 1;
            if (counter_patterns_tracker = 0) then
              counter_patterns_tracker := 127;
            end if;
            led(6 downto 0) <= std_ulogic_vector(to_unsigned(counter_patterns_tracker, 7));
          end if;
          when 4 =>
          base_counter_tracker := base_counter_tracker + 1;
          case(base_counter_tracker) is
            when 1 => led(6 downto 0) <= "0001000";
            when 2 => led(6 downto 0) <= "0010100";
            when 3 => led(6 downto 0) <= "0100010";
            when 4 => led(6 downto 0) <= "1000001";
            when 5 => led(6 downto 0) <= "0100010";
            when 6 => led(6 downto 0) <= "0010100";
            when 7 => led(6 downto 0) <= "0001000";
            when 8 => led(6 downto 0) <= "0000000";
            base_counter_tracker                := 1;
            when others => base_counter_tracker := 1;
          end case;
          when others => led(6 downto 0) <= "0000000";
        end case;
      end if;
    end case;
  end if;
end process;
end architecture;