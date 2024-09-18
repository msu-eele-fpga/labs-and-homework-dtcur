library ieee;
use ieee.std_logic_1164.all;

entity async_conditioner is
  port (
    clk          : in std_ulogic;
    rst          : in std_ulogic;
    button_press : in std_ulogic;
    button_pulse : out std_ulogic
  );
end entity;

architecture conditioner of async_conditioner is

  --Declare constants:
  constant debounce_time : time := 1000 ns; --Arbitrary debounce time this corresponds to 5 clock cycles at default clock
  constant clk_period    : time := 20 ns;

  --Signals that will be needed in the conditioner
  signal syncd_noisy_input : std_ulogic := '0';
  signal syncd_clean_input : std_ulogic := '0';
  --Declare components in order of input 

  --1st component needed: Synchronizer
  component synchronizer
    port (
      clk   : in std_logic;
      async : in std_ulogic;
      sync  : out std_ulogic
    );
  end component;

  --2nd component needed: Debouncer
  component debouncer
    generic (
      clk_period    : time := 20 ns;
      debounce_time : time
    );
    port (
      clk       : in std_ulogic;
      rst       : in std_ulogic;
      input     : in std_ulogic;
      debounced : out std_ulogic := '0'
    );
  end component;

  --3rd component needed: One Pulse
  component one_pulse
    port (
      clk   : in std_ulogic;
      rst   : in std_ulogic;
      input : in std_ulogic;
      pulse : out std_ulogic := '0'
    );
  end component;
begin

  --Create the components
  --Synchronizer to get the rising edge of the button to be synchronized for debouncing
  ButtonSynchronizer : synchronizer
  port map
  (
    clk   => clk,
    async => button_press,
    sync  => syncd_noisy_input
  );
  --Debouncer to clean the signal from the synchronizer
  ButtonDebouncer : debouncer
  generic map(
    clk_period    => clk_period,
    debounce_time => debounce_time
  )
  port map(
    clk       => clk,
    rst       => rst,
    input     => syncd_noisy_input,
    debounced => syncd_clean_input
  );
  --One pulse generator to create a single pulse from long pressing the button to allow a human to use the button
  ButtonPulseGenerator : one_pulse
  port map(
    clk   => clk,
    rst   => rst,
    input => syncd_clean_input,
    pulse => button_pulse
  );
end architecture;