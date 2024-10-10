
# Entity: one_pulse 
- **File**: one_pulse.vhd

## Diagram
![Diagram](one_pulse.svg "Diagram")
## Ports

| Port name | Direction | Type       | Description |
| --------- | --------- | ---------- | ----------- |
| clk       | in        | std_ulogic |             |
| rst       | in        | std_ulogic |             |
| input     | in        | std_ulogic |             |
| pulse     | out       | std_ulogic |             |

## Signals

| Name  | Type       | Description |
| ----- | ---------- | ----------- |
| Latch | std_ulogic |             |

## Processes
- pulse_control: ( clk, rst, input )
