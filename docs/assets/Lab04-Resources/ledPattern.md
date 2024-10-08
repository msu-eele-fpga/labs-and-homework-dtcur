
# Entity: led_patterns 
- **File**: ledPattern.vhd

## Diagram
![Diagram](led_patterns.svg "Diagram")
## Generics

| Generic name        | Type | Value | Description |
| ------------------- | ---- | ----- | ----------- |
| system_clock_period | time | 20 ns |             |

## Ports

| Port name       | Direction | Type                           | Description |
| --------------- | --------- | ------------------------------ | ----------- |
| clk             | in        | std_ulogic                     |             |
| rst             | in        | std_ulogic                     |             |
| push_button     | in        | std_ulogic                     |             |
| switches        | in        | std_ulogic_vector(3 downto 0)  |             |
| hps_led_control | in        | boolean                        |             |
| base_period     | in        | unsigned(7 downto 0)           |             |
| led_reg         | in        | std_ulogic_vector (7 downto 0) |             |
| led             | out       | std_ulogic_vector(7 downto 0)  |             |

## Signals

| Name                          | Type                  | Description |
| ----------------------------- | --------------------- | ----------- |
| next_state                    | State_Type            |             |
| current_state                 | State_Type            |             |
| clock_enable_1s               | boolean               |             |
| clock_enable_baseRate         | boolean               |             |
| clock_1s_done                 | boolean               |             |
| base_rate_done                | boolean               |             |
| enable_1s_delay               | boolean               |             |
| Half_base_period_integer      | integer               |             |
| Quarter_base_period_integer   | integer               |             |
| Eighth_base_period_integer    | integer               |             |
| Twice_base_period_integer     | integer               |             |
| Sixteenth_base_period_integer | integer               |             |
| Half_divider_done             | boolean               |             |
| Quarter_divider_done          | boolean               |             |
| Eighth_divider_done           | boolean               |             |
| Twice_divider_done            | boolean               |             |
| Sixteenth_divider_done        | boolean               |             |
| base_period_integer           | integer               |             |
| base_period_fractional        | integer               |             |
| SwitchInputRegister           | integer range 0 to 15 |             |
| LEDMode                       | integer range 0 to 15 |             |
| LEDPattern0Register           | unsigned(6 downto 0)  |             |
| LEDPattern1Register           | unsigned(6 downto 0)  |             |
| LEDPattern2Register           | unsigned(6 downto 0)  |             |
| LEDPattern3Register           | unsigned(6 downto 0)  |             |
| LEDPattern4Register           | unsigned(6 downto 0)  |             |

## Enums


### *State_Type*
| Name          | Description |
| ------------- | ----------- |
| idle          |             |
| NewPattern    |             |
| ledPatternOut |             |


## Processes
- STATE_MEMORY: ( clk, rst )
- NEXT_STATE_LOGIC: ( current_state, push_button, clock_1s_done, SwitchInputRegister, LEDMode )
- SWITCHS_AND_7LED_LOGIC: ( current_state, rst, clk, base_rate_done, clock_1s_done, Half_divider_done, Quarter_divider_done, Eighth_divider_done, Twice_divider_done )
- LED_PATTERN_0: ( clk, Half_divider_done )
- LED_PATTERN_1: ( clk, Quarter_divider_done )
- LED_PATTERN_2: ( clk, Twice_divider_done )
- LED_PATTERN_3: ( clk, Eighth_divider_done )
- LED_PATTERN_4: ( clk, Sixteenth_divider_done )

## Instantiations

- OneSecondDelay: clock_divider
- BaseRate: clock_divider
- HalfBaseRate: clock_divider
- QuarterBaseRate: clock_divider
- EighthBaseRate: clock_divider
- SixteenthBaseRate: clock_divider
- TwiceBaseRate: clock_divider

## State machines

![Diagram_state_machine_0]( fsm_led_patterns_00.svg "Diagram")