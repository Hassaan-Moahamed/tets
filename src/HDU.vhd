--***************************
--*   Hazard Detection Unit  *
--***************************
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity HDU is
port(I1: in std_ulogic_vector(31 downto 0);
     I2: in std_ulogic_vector(4 downto 0);
     I3: in std_ulogic;
     O1, O2, O3: out std_ulogic);
end HDU;

architecture HDU1 of HDU is
    signal D1, D2, D3: std_ulogic_vector(4 downto 0) := (others => '0');
    signal D4, R1, R2: std_ulogic;
    signal load_hazard: std_ulogic;
begin
    D1 <= I1(25 downto 21); -- Rs (source register 1)
    D2 <= I1(20 downto 16); -- Rt (source register 2)
    D3 <= I2;               -- Rt from ID/EX (destination of load in EX stage)
    D4 <= I3;               -- MemRead signal
    
    -- Detect load-use hazard
    -- Hazard exists when:
    -- 1. Previous instruction is a LOAD (D4 = '1')
    -- 2. Current instruction uses the register being loaded
    -- 3. The register is NOT R0 (R0 is always 0, no hazard possible)
    load_hazard <= '1' when (D1 = D3 or D2 = D3) and D4 = '1' and D3 /= "00000" else '0';
    
    R1 <= load_hazard;      -- Stall signal (insert bubble)
    R2 <= not load_hazard;  -- PC/IFID enable (stall when hazard detected)
    
    O1 <= R1; -- MUXctrl (when '1', insert NOP in ID/EX)
    O2 <= R2; -- PCEnable (when '0', stall PC)
    O3 <= R2; -- IFIDEnable (when '0', stall IF/ID)
    
end HDU1;