

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity IDEX is
port(
     -- 32-bit data signals from ID stage
     I1, I2, I3, I4 : in std_ulogic_vector(31 downto 0); -- PC+4, ReadData1, ReadData2, Immediate

     -- 5-bit register addresses
     I5, I6, IA1   : in std_ulogic_vector(4 downto 0);  -- Rs, Rt, Rd

     -- Control signals (1-bit each)
     I7, I8, I9, I10, I11, I12, I13, I14 : in std_ulogic; -- RegDst, Jump, Branch, MemtoReg, ALUSrc, MemRead, MemWrite, RegWrite

     -- ALU operation control
     I15 : in std_ulogic_vector(2 downto 0); -- ALUOp

     -- 32-bit outputs to EX stage
     O1, O2, O3, O4 : out std_ulogic_vector(31 downto 0); -- Registered versions of I1–I4

     -- 5-bit outputs to EX stage
     O5, O6, OA1    : out std_ulogic_vector(4 downto 0);  -- Registered Rs, Rt, Rd

     -- Control outputs to EX/MEM/WB stages
     O7, O8, O9, O10, O11, O12, O13, O14 : out std_ulogic;

     -- Registered ALUOp
     O15 : out std_ulogic_vector(2 downto 0);

     -- Control + clock
     C1, clk : in std_ulogic                -- C1 = enable (stall control), clk = system clock
);
end IDEX;

architecture IDEX1 of IDEX is

signal D1, D2, D3, D4 : std_ulogic_vector(31 downto 0) := (others => '0'); -- Data registers
signal D5, D6, D16    : std_ulogic_vector(4 downto 0)  := (others => '0'); -- Register numbers
signal D7, D8, D9, D10, D11, D12, D13, D14, D17 : std_ulogic := '0';        -- Control bits
signal D15            : std_ulogic_vector(2 downto 0)  := (others => '0'); -- ALUOp

begin

    -- Enable signal (used to freeze pipeline on stall)
    D17 <= C1;
    pc : process(clk)
    begin

        if (clk = '1' and clk'event and D17 = '1') then

        
            D1  <= I1;     -- PC + 4
            D2  <= I2;     -- ReadData1
            D3  <= I3;     -- ReadData2
            D4  <= I4;     -- Sign-extended immediate


            D5  <= I5;     -- Rs
            D6  <= I6;     -- Rt
            D16 <= IA1;    -- Rd

            D7  <= I7;     -- RegDst
            D8  <= I8;     -- Jump
            D9  <= I9;     -- Branch
            D10 <= I10;    -- MemtoReg
            D11 <= I11;    -- ALUSrc
            D12 <= I12;    -- MemRead
            D13 <= I13;    -- MemWrite
            D14 <= I14;    -- RegWrite

          
            D15 <= I15;    -- ALUOp
        end if;
    end process;

    O1  <= D1;   -- Forward PC+4 to EX stage
    O2  <= D2;   -- Forward ReadData1
    O3  <= D3;   -- Forward ReadData2
    O4  <= D4;   -- Forward Immediate

    O5  <= D5;   -- Forward Rs
    O6  <= D6;   -- Forward Rt
    OA1 <= D16;  -- Forward Rd

    O7  <= D7;   -- RegDst
    O8  <= D8;   -- Jump
    O9  <= D9;   -- Branch
    O10 <= D10;  -- MemtoReg
    O11 <= D11;  -- ALUSrc
    O12 <= D12;  -- MemRead
    O13 <= D13;  -- MemWrite
    O14 <= D14;  -- RegWrite

    O15 <= D15;  -- ALUOp

end IDEX1;

