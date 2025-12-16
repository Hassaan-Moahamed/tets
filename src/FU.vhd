--***********************
--*   Forwarding Unit   *
--*  we can forward the data to where we need it
--***********************
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FU is
port(I1, I2, I3, I4: in std_ulogic_vector(4 downto 0);
     C1, C2: in std_ulogic;
     O1, O2: out std_ulogic_vector(1 downto 0));
end FU;

architecture FU1 of FU is
    signal D1, D2, D3, D4: std_ulogic_vector(4 downto 0) := (others => '0');
    signal D5, D6: std_ulogic := '0';
    signal R1, R2: std_ulogic_vector(1 downto 0) := (others => '0');
begin
    D1 <= I1;  -- Write Address from EX/MEM (earlier instruction)  RD
    D2 <= I2;  -- Write Address from MEM/WB (older instruction)		 RD
    D3 <= I3;  -- Rs (source register 1) for current inst
    D4 <= I4;  -- Rt (source register 2)  for current inst
    D5 <= C1;  -- RegWrite from EX/MEM
    D6 <= C2;  -- RegWrite from MEM/WB
    
    -- CRITICAL: Forward path for source 1 (Rs)
    -- Priority: EX/MEM (most recent) > MEM/WB > No forward
    -- MUST check that source register is not R0
    R1 <= "10" when D5 = '1' and D1 /= "00000" and D3 /= "00000" and D3 = D1 else
          "01" when D6 = '1' and D2 /= "00000" and D3 /= "00000" and D3 = D2 else
          "00";
    
    -- CRITICAL: Forward path for source 2 (Rt)
    -- Priority: EX/MEM (most recent) > MEM/WB > No forward
    -- MUST check that source register is not R0
    R2 <= "10" when D5 = '1' and D1 /= "00000" and D4 /= "00000" and D4 = D1 else
          "01" when D6 = '1' and D2 /= "00000" and D4 /= "00000" and D4 = D2 else
          "00";
    
    O1 <= R1;  -- Forward control for Rs
    O2 <= R2;  -- Forward control for Rt
     
end FU1;
