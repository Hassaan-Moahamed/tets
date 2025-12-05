--**********************************************
--*   3-INPUT MULTIPLEXER (for Forwarding)   *
--*                                          *
--*   C1 = 00 => I1 selected (no forward)    *
--*   C1 = 01 => I2 selected (from WB)       *
--*   C1 = 10 => I3 selected (from MEM)      *
--**********************************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MUX3 is
generic(N: integer);
port(I1: in std_ulogic_vector((N-1) downto 0);
     I2: in std_ulogic_vector((N-1) downto 0);
     I3: in std_ulogic_vector((N-1) downto 0);
     C1: in std_ulogic_vector(1 downto 0);  
     O1: out std_ulogic_vector((N-1) downto 0));
end MUX3;

architecture MUX3_1 of MUX3 is
signal D1, D2, D3: std_ulogic_vector((N-1) downto 0) := (others => '0');
signal D4: std_ulogic_vector(1 downto 0) := (others => '0');
signal R1: std_ulogic_vector((N-1) downto 0) := (others => '0');
begin
    D1 <= I1;  -- No forwarding
    D2 <= I2;  -- Forward from WB stage
    D3 <= I3;  -- Forward from MEM stage
    D4 <= C1;  -- Control signal
    
    with D4 select R1 <=
        D1 when "00",  -- No forwarding
        D2 when "01",  -- Forward from WB
        D3 when "10",  -- Forward from MEM
        D1 when others;
    
    O1 <= R1;
end MUX3_1;
