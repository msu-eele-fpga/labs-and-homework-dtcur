onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /led_patterns_tb/clk_tb
add wave -noupdate /led_patterns_tb/rst_tb
add wave -noupdate /led_patterns_tb/button_tb
add wave -noupdate /led_patterns_tb/switches_tb
add wave -noupdate /led_patterns_tb/leds_tb
add wave -noupdate /led_patterns_tb/base_period_tb
add wave -noupdate /led_patterns_tb/duv/base_period_integer
add wave -noupdate -divider {State Variables}
add wave -noupdate /led_patterns_tb/duv/next_state
add wave -noupdate /led_patterns_tb/duv/current_state
add wave -noupdate -divider {1s Delay}
add wave -noupdate /led_patterns_tb/duv/OneSecondDelay/done
add wave -noupdate /led_patterns_tb/duv/OneSecondDelay/enable
add wave -noupdate -divider BasePeriodDivider
add wave -noupdate /led_patterns_tb/duv/base_rate_done
add wave -noupdate /led_patterns_tb/duv/clock_enable_baseRate
add wave -noupdate -divider {LED Output Logic}
add wave -noupdate /led_patterns_tb/duv/LEDMode
add wave -noupdate /led_patterns_tb/duv/SWITCHS_AND_7LED_LOGIC/base_counter_tracker
add wave -noupdate /led_patterns_tb/duv/SWITCHS_AND_7LED_LOGIC/counter_patterns_tracker
add wave -noupdate /led_patterns_tb/duv/base_rate_done
add wave -noupdate /led_patterns_tb/duv/led
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1361352173385 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 349
configure wave -valuecolwidth 118
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits sec
update
WaveRestoreZoom {0 ps} {4199595634500 ps}
