--*   .Arithmetic                           *
--*   . 000000 => add                       *
--*   . 000001 => subtract                  *
--*                                         *
--*   .Logical                              *
--*   . 000010 => and                       *
--*   . 010 => logical I (and)              *
--*   . 011 => logical I (or)               *
--*   . 100 => logical I (sl)               *
--*   . 101 => logical I (sr)               *
--*   . 110 => conditional branch           *
--*   . 111 => unconditional jump           *
--*   . others => none                      *
--*                                         *
--* --Instruction code-(R type -> funct)--- *
--*                                         *
--*   .Arithmetic                           *
--*   . 000000 => add                       *
--*   . 000001 => subtract                  *
--*                                         *
--*   .Logical                              *
--*   . 000010 => and                       *
--*   . 000011 => or                        *
--*   . 000100 => nor                       *
--*******************************************
--*   ALU Control Unit                      *
--*******************************************
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALUC is
port(I1: in std_ulogic_vector(2 downto 0);
     I2: in std_ulogic_vector(5 downto 0);
     O1: out std_ulogic_vector(2 downto 0));
end ALUC;

architecture ALUC1 of ALUC is
    signal D1: std_ulogic_vector(2 downto 0) := (others => '0');
    signal D2: std_ulogic_vector(5 downto 0) := (others => '0');
    signal R1: std_ulogic_vector(2 downto 0) := (others => '0');
begin
    D1 <= I1; -- ALUOp from control unit
    D2 <= I2; -- funct field from instruction
    
    -- ALU operation decode
    R1 <= "000" when D1="000" and D2="000000" else  -- R-type: add
          "001" when D1="000" and D2="000001" else  -- R-type: subtract
          "010" when D1="000" and D2="000010" else  -- R-type: and
          "011" when D1="000" and D2="000011" else  -- R-type: or
          "100" when D1="000" and D2="000100" else  -- R-type: nor
          "000" when D1="001" else                  -- I-type: memory (add for address calc)
          "010" when D1="010" else                  -- I-type: andi
          "011" when D1="011" else                  -- I-type: ori
          "101" when D1="100" else                  -- I-type: sll
          "110" when D1="101" else                  -- I-type: srl
          "001" when D1="110" else                  -- Branch: subtract (for beq)
          "000";                                    -- Default: add (ADDED)
    
    O1 <= R1;
    
end ALUC1;