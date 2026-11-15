----------------------------------------------------------------------------------

----------------------------------------------------------------------------------

entity thermo_en is

port(

-- Input : 3 input in total
--  - 2 (7 bit vec) 
--  - and 1 bit
temp_current,temp_desired: in bit_vector(6 downto 0);
select_disp: in bit;
sw_cool,sw_heat: in bit; -- sw for switches

-- output
temp_disp: out bit_vector(6 downto 0);
ac, furnace: out bit

); -- End port

end thermo_en; -- End entity

architecture behav_thermo of thermo_en is

-- Rule: the architecture "Behavioral" must be assoicated to some entity
    -- in this case the entity is "thermo_en"

begin -- start of architecture "behav_thermo"

process(select_disp,
        sw_cool,sw_heat,
        temp_current,temp_desired)
begin 

    if select_disp = '1' then
        temp_disp <= temp_current;

    else
        temp_disp <= temp_desired;

    end if;

    -- ====================== Part 2: AC and Furnace ======================
    -- adding AC and Furnace functionality according to conditions

    ac      <= '0';  -- defaults (must come BEFORE the ifs)
    furnace <= '0';
    -- Note: read i Thermo_Part_2_Notes.md why using default values is necessary
    -- and the ifs alone are not enough    

    -- AC mode
    if sw_cool = '1' and temp_current > temp_desired then
        ac <= '1';
    end if;  -- End AC mode
    
    -- Furnace mode    
    if sw_heat = '1' and temp_current < temp_desired then
        furnace <= '1';
    end if; -- End Furnace mode

    -- Note: special case (edge case): when temparatures are equal
    -- when temp_current = temp_desired, both '>' and '<' are false,
    -- so ac and furnace are already '0' (no special case needed)
    -- that is no extra [if temp_current = temp_desired then ...] is needed
    

     
end process;


end behav_thermo;
