-- SPDX-License-Identifier: MIT
-- Copyright (c) 2024 Ross K. Snider, Trevor Vannoy.  All rights reserved.
----------------------------------------------------------------------------
-- Description:  Top level VHDL file for the DE10-Nano
----------------------------------------------------------------------------
-- Author:       Ross K. Snider, Trevor Vannoy
-- Company:      Montana State University
-- Create Date:  September 1, 2017
-- Revision:     1.0
-- License: MIT  (opensource.org/licenses/MIT)
----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library altera;
use altera.altera_primitives_components.all;

-----------------------------------------------------------
-- Signal Names are defined in the DE10-Nano User Manual
-- http://de10-nano.terasic.com
-----------------------------------------------------------
entity de10nano_top is
  port (
    ----------------------------------------
    --  Clock inputs
    --  See DE10 Nano User Manual page 23
    ----------------------------------------
    --! 50 MHz clock input #1
    fpga_clk1_50 : in    std_logic;
    --! 50 MHz clock input #2
    fpga_clk2_50 : in    std_logic;
    --! 50 MHz clock input #3
    fpga_clk3_50 : in    std_logic;

    ----------------------------------------
    --  Push button inputs (KEY)
    --  See DE10 Nano User Manual page 24
    --  The KEY push button inputs produce a '0'
    --  when pressed (asserted)
    --  and produce a '1' in the rest (non-pushed) state
    ----------------------------------------
    push_button_n : in    std_logic_vector(1 downto 0);

    ----------------------------------------
    --  Slide switch inputs (SW)
    --  See DE10 Nano User Manual page 25
    --  The slide switches produce a '0' when
    --  in the down position
    --  (towards the edge of the board)
    ----------------------------------------
    sw : in    std_logic_vector(3 downto 0);

    ----------------------------------------
    --  LED outputs
    --  See DE10 Nano User Manual page 26
    --  Setting LED to 1 will turn it on
    ----------------------------------------
    led : out   std_logic_vector(7 downto 0);

    ----------------------------------------
    --  GPIO expansion headers (40-pin)
    --  See DE10 Nano User Manual page 27
    --  Pin 11 = 5V supply (1A max)
    --  Pin 29 - 3.3 supply (1.5A max)
    --  Pins 12, 30 GND
    ----------------------------------------
    gpio_0 : inout std_logic_vector(35 downto 0);
    gpio_1 : inout std_logic_vector(35 downto 0);

    ----------------------------------------
    --  Arudino headers
    --  See DE10 Nano User Manual page 30
    ----------------------------------------
    arduino_io      : inout std_logic_vector(15 downto 0);
    arduino_reset_n : inout std_logic
  );
end entity de10nano_top;

architecture de10nano_arch of de10nano_top is

-- Make top file aware of PWM component
component pwm_controller is
    generic (
      CLK_PERIOD   : time;
      W_PERIOD     : integer := 30;
      W_DUTY_CYCLE : integer := 11
    );
    port (
      clk        : in std_logic;
      rst        : in std_logic;
      period     : in unsigned(29 downto 0);
      duty_cycle : in unsigned(10 downto 0);
      output     : out std_logic
    );
  end component pwm_controller;
  
  --Hard coded period and duty cycle registers
  signal HARD_CODED_PERIOD : unsigned(29 downto 0);
  signal HARD_CODED_DUTY_CYCLE : unsigned(10 downto 0);
  --Buffer for visualizing the PWM on the LEDs
  signal pwm_output : std_logic;
begin
--Assign hard coded values
HARD_CODED_PERIOD <= "000000010000000000000000000000";
HARD_CODED_DUTY_CYCLE <= "01000000000";


--Create PWM controller component
pwm_generator : component pwm_controller
    generic map(
      CLK_PERIOD => 20 ns
    )
    port map(
      clk        => fpga_clk1_50,
      rst        => not push_button_n(1),
      period     => HARD_CODED_PERIOD,
      duty_cycle => HARD_CODED_DUTY_CYCLE,
      output     => pwm_output
    );


  -- Add VDHL code to connect the four switches (SW) to four LEDs
	led(3 downto 0) <= sw;
	led(6 downto 4) <= "000";
	gpio_0(3 downto 0) <= sw;
	gpio_0(4) <= pwm_output;
	led(7) <= pwm_output;
end architecture de10nano_arch;