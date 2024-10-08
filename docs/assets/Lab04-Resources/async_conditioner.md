
# Entity: async_conditioner 
- **File**: async_conditioner.vhd

## Diagram
![Diagram](async_conditioner.svg "Diagram")
## Ports

| Port name    | Direction | Type       | Description |
| ------------ | --------- | ---------- | ----------- |
| clk          | in        | std_ulogic |             |
| rst          | in        | std_ulogic |             |
| button_press | in        | std_ulogic |             |
| button_pulse | out       | std_ulogic |             |

## Signals

| Name              | Type       | Description |
| ----------------- | ---------- | ----------- |
| syncd_noisy_input | std_ulogic |             |
| syncd_clean_input | std_ulogic |             |

## Constants

| Name          | Type | Value  | Description |
| ------------- | ---- | ------ | ----------- |
| debounce_time | time | 500 ns |             |
| clk_period    | time | 20 ns  |             |

## Instantiations

- ButtonSynchronizer: synchronizer
- ButtonDebouncer: debouncer
- ButtonPulseGenerator: one_pulse
