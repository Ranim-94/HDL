


--------------------

-- Simulating an OR gate using VHDL
-- We choose sequential style by using 
-- process, and simulate OR rules

----------------

entity seqx_or is port(
A: in bit ;
B: in bit ;
C: out bit
);

end seqx_or;

architecture behave of seqx_or is

begin 


process(A,B)
begin 

    if A = '1' or B = '1' then
        C <= '1';

    else
        C <= '0';

    end if;


end process;

end behave;