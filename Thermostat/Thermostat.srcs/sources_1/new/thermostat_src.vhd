----------------------------------------------------------------------------------

----------------------------------------------------------------------------------

entity thermo_en is

port(

-- Input : 3 input in total
--  - 2 (7 bit vec) 
--  - and 1 bit
temp_current,temp_desired: in bit_vector(6 downto 0);
select_disp: in bit;

-- output
temp_disp: out bit_vector(6 downto 0)

); -- End port

end thermo_en; -- End entity

architecture behav_thermo of thermo_en is

-- Rule: the architecture "Behavioral" must be assoicated to some entity
    -- in this case the entity is "thermo_en"

begin -- start of architecture "behav_thermo"

process(select_disp,
        temp_current,temp_desired)
begin 

    if select_disp = '1' then
        temp_disp <= temp_current;

    else
        temp_disp <= temp_desired;

    end if;


end process;


end behav_thermo;
