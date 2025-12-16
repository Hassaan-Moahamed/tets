

library ieee;                              
use ieee.std_logic_1164.all;               
use ieee.numeric_std.all;                  


entity EXMEM is
port(
     -- 32-bit data from EX stage
     I1, I2, I3 : in std_ulogic_vector(31 downto 0);  -- ALU result, forwarded data, branch address

     -- Destination register number
     I5 : in std_ulogic_vector(4 downto 0);           -- Write register (Rd or Rt after RegDst)

     -- Control signals coming from EX stage
     I8, I9, I10, I12, I13, I14, I15 : in std_ulogic;  -- Jump, Branch, MemtoReg, MemRead, MemWrite, RegWrite, Extra control

     -- 32-bit outputs to MEM stage
     O1, O2, O3 : out std_ulogic_vector(31 downto 0); -- Registered EX data

     -- Registered destination register
     O5 : out std_ulogic_vector(4 downto 0);          -- Write register number

     -- Control outputs to MEM/WB stages
     O8, O9, O10, O12, O13, O14, O15 : out std_ulogic;-- Forwarded control signals

     -- Control + clock
     C1, clk : in std_ulogic                           -- C1 = enable (stall), clk = clock
);
end EXMEM;


architecture EXMEM1 of EXMEM is


signal D1, D2, D3 : std_ulogic_vector(31 downto 0) := (others => '0'); -- EX data registers
signal D5         : std_ulogic_vector(4 downto 0)  := (others => '0'); -- Destination register
signal D8, D9, D10, D12, D13, D14, D15, D17 : std_ulogic := '0';       -- Control bits + enable

begin

    -- Enable signal from hazard unit
    D17 <= C1;


    pc : process(clk)
    begin
        -- Rising edge + enable
        if (clk = '1' and clk'event and D17 = '1') then

   
            D1 <= I1;    -- ALU result
            D2 <= I2;    -- Value to write to memory (store data)
            D3 <= I3;    -- Branch target address

   
            D5 <= I5;    -- Register to be written in WB

 
            D8  <= I8;   -- Jump
            D9  <= I9;   -- Branch
            D10 <= I10;  -- MemtoReg
            D12 <= I12;  -- MemRead
            D13 <= I13;  -- MemWrite
            D14 <= I14;  -- RegWrite
            D15 <= I15;  -- Additional control / flag
        end if;
    end process;


    O1 <= D1;   -- ALU result to data memory / WB
    O2 <= D2;   -- Store data to memory
    O3 <= D3;   -- Branch address

    O5 <= D5;   -- Destination register number

    O8  <= D8;  -- Jump control
    O9  <= D9;  -- Branch control
    O10 <= D10; -- MemtoReg
    O12 <= D12; -- MemRead
    O13 <= D13; -- MemWrite
    O14 <= D14; -- RegWrite
    O15 <= D15; -- Extra control signal

end EXMEM1;

