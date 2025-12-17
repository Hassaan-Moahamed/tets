library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SL is
generic(N, M: integer);
port(I1: in std_ulogic_vector((N-1) downto 0);
     O1: out std_ulogic_vector((M-1) downto 0));
end SL;

architecture SL1 of SL is
    signal D1: unsigned((N-1) downto 0) := (others => '0');
    signal R1: unsigned((M-1) downto 0) := (others => '0');
begin
    D1 <= unsigned(I1);
    
    -- FIXED: When N = M, shift left by 2 (for branch offset)
    R1 <= D1(M-3 downto 0) & "00" when N = M else
          D1 & to_unsigned(0, M-N) when N < M;
    
    O1 <= std_ulogic_vector(R1);
end SL1;