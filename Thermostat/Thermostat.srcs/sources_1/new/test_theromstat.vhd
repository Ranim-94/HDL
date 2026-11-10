----------------------------------------------------------------------------------
-- Test bench for the thermostat system (Report_HDL, section 2.7, fig 2.37)
--
-- Component and port names are adapted to the design in thermostat_src.vhd:
--   TEMP_MUX       -> thermo_en
--   CURRENT_TEMP   -> temp_current
--   DESIRED_TEMP   -> temp_desired
--   DISPLAY_SELECT -> select_disp
--   TEMP_DISPLAY   -> temp_disp
----------------------------------------------------------------------------------

-- Entity has no port map
entity T_TEMPMUX is

end T_TEMPMUX;

architecture TEST of T_TEMPMUX is

-- Design to be tested is declared as a component
component thermo_en
  port ( temp_current : in  bit_vector(6 downto 0);
         temp_desired : in  bit_vector(6 downto 0);
         select_disp  : in  bit;
         temp_disp    : out bit_vector(6 downto 0));
end component;

-- Declare stimulus as internal signals
signal temp_current, temp_desired : bit_vector(6 downto 0);
signal temp_disp                  : bit_vector(6 downto 0);
signal select_disp                : bit;

begin

-- Design is instantiated
UUT: thermo_en port map ( temp_current => temp_current,
                          temp_desired => temp_desired,
                          select_disp  => select_disp,
                          temp_disp    => temp_disp);

-- Stimulus is applied
process
begin
  temp_current <= "0000000";
  temp_desired <= "1111111";
  select_disp  <= '0';
  -- temp_disp = temp_desired
  -- = 7F
  wait for 10 ns;
  select_disp  <= '1';
  -- temp_disp = temp_current
  -- = 00
  wait for 10 ns;
end process;

end TEST;-- end architecture TEST
