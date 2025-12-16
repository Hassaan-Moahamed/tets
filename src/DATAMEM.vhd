
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DATAMEM is
port(I1: in std_ulogic_vector(31 downto 0);   -- Address
     I2: in std_ulogic_vector(31 downto 0);   -- Write Data
     C1: in std_ulogic;                        -- MemWrite
     C2: in std_ulogic;                        -- MemRead
     clk: in std_ulogic;                       -- Clock
     O1: out std_ulogic_vector(31 downto 0)); -- Read Data
end DATAMEM;

architecture DATAMEM1 of DATAMEM is
    -- Memory array: 128 words of 32 bits each
    type MEMORY is array (0 to 127) of std_ulogic_vector(31 downto 0);
    
    -- Initialize memory with test values
    -- CRITICAL: These values are used by all test cases
    signal M1: MEMORY := (
        0 => "00000000000000000000000000000100",  -- Memory[0] = 4 (decimal)
        1 => "00000000000000000000000000000101",  -- Memory[1] = 5 (decimal)
        2 => "00000000000000000000000000000011",  -- Memory[2] = 3 (decimal)
        3 => "00000000000000000000000000001010",  -- Memory[3] = 10 (decimal)
        4 => "00000000000000000000000000000001",  -- Memory[4] = 1 (decimal)
        others => (others => '0')                  -- Rest = 0
    );
    
begin
    
    -- Read operation (combinational for immediate access)
    -- Only reads when MemRead is enabled and address is valid
    O1 <= M1(to_integer(unsigned(I1))) when (C2 = '1' and to_integer(unsigned(I1)) < 128) 
          else (others => '0');
    
    -- Write operation (synchronous on clock edge)
    -- Only writes when MemWrite is enabled and address is valid
    memory_write: process(clk)
    begin
        if rising_edge(clk) then
            if C1 = '1' and to_integer(unsigned(I1)) < 128 then
                M1(to_integer(unsigned(I1))) <= I2;
            end if;
        end if;
    end process;
    
end DATAMEM1;

