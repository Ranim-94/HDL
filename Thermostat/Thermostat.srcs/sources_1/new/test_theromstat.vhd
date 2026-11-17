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
         sw_cool      : in bit;
         sw_heat      : in bit; 
         temp_disp    : out bit_vector(6 downto 0);
         ac, furnace  : out bit);
end component;

-- Declare stimulus as internal signals
-- Inputs
signal temp_current, temp_desired : bit_vector(6 downto 0);
signal select_disp                : bit;
signal sw_cool,sw_heat            : bit;

-- Output port 
signal temp_disp                  : bit_vector(6 downto 0);
signal ac,furnace                 : bit;

begin

-- Design is instantiated
UUT: thermo_en port map ( temp_current => temp_current,
                          temp_desired => temp_desired,
                          select_disp  => select_disp,
                          sw_cool      => sw_cool,
                          sw_heat      =>  sw_heat,
                          temp_disp    => temp_disp,
                          ac           => ac,
                          furnace      => furnace);

-- Stimulus is applied
process
begin

-- ========================= 1) Testing display functionality =========================

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

  -- ========================= 2) Testing AC and Furnace functionalities =========================
  
  -- 2.1) Start when output (AC and Furnace) is "ON"
  -- is "ON" when conditions are met; that is switch and temp conditions are respected

  -- 2.1.a) start with Furnance mode:  cold mode -> turn on the heater
  
  -- (temp_current < temp_desired)
  temp_current <= "0000000"; temp_desired <= "1111111";
  sw_heat <= '1'; -- switch Frunace ON
  
  wait for 10 ns;

  assert furnace = '1' and ac = '0'
    report "2.1.a) failed: furnace should be ON" severity error;

  -- 2.1.b) test if AC is ON  when conditions are met : temp and switch
  
  -- AC <=>(temp_current > temp_desired)
  temp_current <= "1111111"; temp_desired <= "0000000";
  
  sw_cool <= '1'; -- switch for AC is ON
  sw_heat <= '0'; -- turn off back the heat switch 
  -- because in 2.1.a) it was ON

  wait for 10 ns;

    assert furnace = '0' and ac = '1'
      report "2.1.b) failed: AC should be ON" severity error;

    -- 2.1.c) ON to OFF transition test
    -- while the AC is ON from 2.1.b) , suppose I slide sw_cool to off
    -- AC should turn OFF even if the temp conditions are true
    -- !!! This test is important, since it hilight my implementation
    -- mistake why (ifs) alone without else or some default assignment is not enough

    sw_cool <= '0'; -- turn OFF the AC

    wait for 10 ns;
    assert furnace = '0' and ac = '0'
      report "2.1.c) failed: AC should be Off" severity error;

  -- 2.2) Testing OFF output: temp true but switches are off
  -- Description: suppose that temp conditions are met, 
  -- but swithes are not pressed ON, 'AC' or 'Furnace' should not trun ON by themeselve 
  -- except if I press the switches
  
  -- for all 2.2.x) cases, switches are off 
  sw_heat <= '0'; sw_cool <= '0';

  -- start changing the temp 

  -- 2.2.a) AC (temp_curr > temp_desired)
  temp_current <= "1111111"; temp_desired <= "0000000";

  wait for 10 ns;

  assert furnace = '0' and ac = '0'
      report "2.2.a) failed: AC and Furnace should be off" severity error;

  -- 2.2.b) Furnace (temp_curr < temp_desired)
  temp_current <= "0000000"; temp_desired <= "1111111";

  wait for 10 ns;

  assert furnace = '0' and ac = '0'
      report "2.2.b) failed: AC and Furnace should be off" severity error;

  
  -- 2.3) Testing OFF output (2nd combination): switches are true but temp off
  -- Description: suppose temp conditions are not met, but
  -- we start sliding the switches, AC or Furnace should not turn ON
  -- even if we press the switches

  --2.3.a) AC case
  sw_cool <= '1'; -- we slide the AC switch

  sw_heat <= '0'; -- make sure that furnace is off

  -- temp conditions (false one => temp_curr < temp_desired)
  temp_current <= "0000000"; temp_desired <= "1111111";

  wait for 10 ns;

  assert furnace = '0' and ac = '0'
      report "2.3.a) failed: AC and Furnace should be off" severity error;

  -- 2.3.b) Furnace case
  sw_heat <= '1'; -- slide on the Furnace switch
  sw_cool <= '0'; -- make sure that AC is off

  -- temp coditions (false one => temp_curr > temp_desired)
  temp_current <= "1111111"; temp_desired <= "0000000";

  wait for 10 ns;

  assert furnace = '0' and ac = '0'
      report "2.3.b) failed: AC and Furnace should be off" severity error;


  -- 2.4) Edge case: both temp are equal;
  temp_current <= "1111111"; temp_desired <= "1111111";

  wait for 10 ns;

  wait; -- End testing 

end process;

end TEST;-- end architecture TEST
