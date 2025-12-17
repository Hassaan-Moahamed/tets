library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MIPS_TOP is
    port( clk, reset : in std_ulogic );
end MIPS_TOP;

architecture MIPS_ARCH of MIPS_TOP is

-- ============================================================
-- Component Declarations
-- ============================================================
component PC is
port(I1: in std_ulogic_vector(31 downto 0);
     O1: out std_ulogic_vector(31 downto 0);
     C1, clk: in std_ulogic);
end component;

component IM is
generic(N: integer);
port(I1: in std_ulogic_vector(31 downto 0);
     O1: out std_ulogic_vector(31 downto 0));
end component;

component REG is
port(I1, I2, I3: in std_ulogic_vector(4 downto 0);
     I4: in std_ulogic_vector(31 downto 0);
     C1, CLK: in std_ulogic;
     O1, O2: out std_ulogic_vector(31 downto 0));
end component;

component SE is
port(I1: in std_ulogic_vector(15 downto 0);   
     O1: out std_ulogic_vector(31 downto 0));
end component;

component ADDER is
port(I1, I2: in std_ulogic_vector(31 downto 0);   
     O1: out std_ulogic_vector(31 downto 0));
end component;

component DATAMEM is
port(I1, I2: in std_ulogic_vector(31 downto 0);
     C1, C2, clk: in std_ulogic;
     O1: out std_ulogic_vector(31 downto 0));
end component;

component SL is
generic(N, M: integer);
port(I1: in std_ulogic_vector((N-1) downto 0);
     O1: out std_ulogic_vector((M-1) downto 0));
end component;

component ALU is
port(I1, I2: in std_ulogic_vector(31 downto 0);
     C1: in std_ulogic_vector(2 downto 0);
     O1: out std_ulogic_vector(31 downto 0);
     O2: out std_ulogic);
end component;

component MUX is
generic(N: integer);
port(I1, I2: in std_ulogic_vector((N-1) downto 0);
     C1: in std_ulogic;  
     O1: out std_ulogic_vector((N-1) downto 0));
end component;

component ALUC is
port(I1: in std_ulogic_vector(2 downto 0);
     I2: in std_ulogic_vector(5 downto 0);
     O1: out std_ulogic_vector(2 downto 0));
end component;

component CONTROL is
port(I1: in std_ulogic_vector(5 downto 0);
     O1, O2, O3, O4, O5, O7, O8, O9: out std_ulogic;   
     O6: out std_ulogic_vector(2 downto 0));
end component;

component IFID is
port(I1, I2: in std_ulogic_vector(31 downto 0);   
     O1, O2: out std_ulogic_vector(31 downto 0);
     C1, clk: in std_ulogic);
end component;

component IDEX is
port(I1, I2, I3, I4: in std_ulogic_vector(31 downto 0);
     I5, I6, IA1: in std_ulogic_vector(4 downto 0);
     I7, I8, I9, I10, I11, I12, I13, I14: in std_ulogic;
     I15: in std_ulogic_vector(2 downto 0);
     O1, O2, O3, O4: out std_ulogic_vector(31 downto 0);
     O5, O6, OA1: out std_ulogic_vector(4 downto 0);
     O7, O8, O9, O10, O11, O12, O13, O14: out std_ulogic;
     O15: out std_ulogic_vector(2 downto 0);
     C1, clk: in std_ulogic);
end component;

component EXMEM is
port(I1, I2, I3: in std_ulogic_vector(31 downto 0);
     I5: in std_ulogic_vector(4 downto 0);
     I8, I9, I10, I12, I13, I14, I15: in std_ulogic;
     O1, O2, O3: out std_ulogic_vector(31 downto 0);
     O5: out std_ulogic_vector(4 downto 0);
     O8, O9, O10, O12, O13, O14, O15: out std_ulogic;
     C1, clk: in std_ulogic);
end component;

component MEMWB is
port(I1, I2: in std_ulogic_vector(31 downto 0);
     I3: in std_ulogic_vector(4 downto 0);
     I10, I14: in std_ulogic;
     O1, O2: out std_ulogic_vector(31 downto 0);
     O3: out std_ulogic_vector(4 downto 0);
     O10, O14: out std_ulogic;
     C1, clk: in std_ulogic);
end component;

component FU is
port(I1, I2, I3, I4: in std_ulogic_vector(4 downto 0);
     C1, C2: in std_ulogic;
     O1, O2: out std_ulogic_vector(1 downto 0));
end component;

component MUX3 is
generic(N: integer);
port(I1, I2, I3: in std_ulogic_vector((N-1) downto 0);
     C1: in std_ulogic_vector(1 downto 0);  
     O1: out std_ulogic_vector((N-1) downto 0));
end component;

-- ============================================================
-- Signal Declarations
-- ============================================================

-- Constants
signal FOUR: std_ulogic_vector(31 downto 0) := X"00000004";

-- IF Stage Signals
signal PC_in, PC_out, PC_plus_4: std_ulogic_vector(31 downto 0);
signal InstructionMemOut: std_ulogic_vector(31 downto 0);
signal JUMP_ADDRESS: std_ulogic_vector(31 downto 0);

-- IF/ID Pipeline Register Signals
signal IF_ID_PC_plus_4, IF_ID_Instruction: std_ulogic_vector(31 downto 0);
signal IF_ID_Instruction_Actual: std_ulogic_vector(31 downto 0);

-- ID Stage Signals
signal ReadData1, ReadData2, WriteData: std_ulogic_vector(31 downto 0);
signal SignExtend_out: std_ulogic_vector(31 downto 0);
signal RegDst, Jump, Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite: std_ulogic;
signal ALUOp: std_ulogic_vector(2 downto 0);
signal Control_Flow_Change: std_ulogic;

-- ID/EX Pipeline Register Signals
signal ID_EX_PC_plus_4: std_ulogic_vector(31 downto 0);
signal ID_EX_ReadData1, ID_EX_ReadData2: std_ulogic_vector(31 downto 0);
signal ID_EX_SignExtend: std_ulogic_vector(31 downto 0);
signal ID_EX_Rs, ID_EX_Rt, ID_EX_Rd: std_ulogic_vector(4 downto 0);
signal ID_EX_RegDst, ID_EX_Jump, ID_EX_Branch: std_ulogic;
signal ID_EX_MemRead, ID_EX_MemtoReg, ID_EX_MemWrite: std_ulogic;
signal ID_EX_ALUSrc, ID_EX_RegWrite: std_ulogic;
signal ID_EX_ALUOp: std_ulogic_vector(2 downto 0);

-- EX Stage Signals
signal Forward_A, Forward_B: std_ulogic_vector(1 downto 0);
signal MUX_A_out, MUX_B_out: std_ulogic_vector(31 downto 0);
signal ALU_Src_B: std_ulogic_vector(31 downto 0);
signal ALU_Result: std_ulogic_vector(31 downto 0);
signal ALU_Zero: std_ulogic;
signal ALU_Control: std_ulogic_vector(2 downto 0);
signal Write_Reg_Addr: std_ulogic_vector(4 downto 0);
signal Branch_Target: std_ulogic_vector(31 downto 0);
signal SignExtend_Shifted: std_ulogic_vector(31 downto 0);

-- EX/MEM Pipeline Register Signals
signal EX_MEM_Branch_Target: std_ulogic_vector(31 downto 0);
signal EX_MEM_ALU_Result: std_ulogic_vector(31 downto 0);
signal EX_MEM_WriteData: std_ulogic_vector(31 downto 0);
signal EX_MEM_Write_Reg: std_ulogic_vector(4 downto 0);
signal EX_MEM_Jump, EX_MEM_Branch, EX_MEM_Zero: std_ulogic;
signal EX_MEM_MemRead, EX_MEM_MemtoReg, EX_MEM_MemWrite: std_ulogic;
signal EX_MEM_RegWrite: std_ulogic;

-- MEM Stage Signals
signal Mem_Read_Data: std_ulogic_vector(31 downto 0);
signal Branch_Taken, PC_Src: std_ulogic;
signal PC_Branch_or_Seq: std_ulogic_vector(31 downto 0);

-- MEM/WB Pipeline Register Signals
signal MEM_WB_Mem_Data: std_ulogic_vector(31 downto 0);
signal MEM_WB_ALU_Result: std_ulogic_vector(31 downto 0);
signal MEM_WB_Write_Reg: std_ulogic_vector(4 downto 0);
signal MEM_WB_MemtoReg, MEM_WB_RegWrite: std_ulogic;

-- PC Control
constant PCEnable: std_ulogic := '1';
constant IFIDEnable: std_ulogic := '1';

begin

-- ============================================================
-- Control Signal Assignments
-- ============================================================
Control_Flow_Change <= Branch_Taken or Jump;
Branch_Taken <= EX_MEM_Branch and EX_MEM_Zero;
PC_Src <= Branch_Taken;

-- ============================================================
-- INSTRUCTION FETCH (IF) STAGE
-- ============================================================

-- Program Counter
PCOUNTER: PC port map(
    I1 => PC_in,
    O1 => PC_out,
    C1 => PCEnable,
    clk => clk
);

-- PC + 4 Adder
ADD_PC_4: ADDER port map(
    I1 => PC_out,
    I2 => FOUR,
    O1 => PC_plus_4
);

-- Instruction Memory
INSTR_MEM: IM generic map(N => 128)
              port map(
    I1 => PC_out,
    O1 => InstructionMemOut
);

-- PC Source MUX (Branch or Sequential)
MUX_PC_Branch: MUX generic map(N => 32)
                   port map(
    I1 => PC_plus_4,
    I2 => EX_MEM_Branch_Target,
    C1 => PC_Src,
    O1 => PC_Branch_or_Seq
);

-- Jump address calculation
JUMP_ADDRESS <= IF_ID_PC_plus_4(31 downto 28) & IF_ID_Instruction(25 downto 0) & "00";

-- PC Jump MUX (Jump overrides branch/sequential)
MUX_PC_Jump: MUX generic map(N => 32)
                 port map(
    I1 => PC_Branch_or_Seq,
    I2 => JUMP_ADDRESS,
    C1 => Jump,
    O1 => PC_in
);

-- ============================================================
-- IF/ID PIPELINE REGISTER
-- ============================================================
IF_ID_REG: IFID port map(
    I1 => PC_plus_4,
    I2 => InstructionMemOut,
    O1 => IF_ID_PC_plus_4,
    O2 => IF_ID_Instruction_Actual,
    C1 => IFIDEnable,
    clk => clk
);

-- Pipeline Flush: Insert NOP when control flow changes
IF_ID_Instruction <= X"FC000000" when Control_Flow_Change = '1' else IF_ID_Instruction_Actual;

-- ============================================================
-- INSTRUCTION DECODE (ID) STAGE
-- ============================================================

-- Control Unit
Control_Unit: CONTROL port map(
    I1 => IF_ID_Instruction(31 downto 26),  -- Opcode
    O1 => RegDst,      -- RegDst
    O2 => Jump,        -- Jump
    O3 => Branch,      -- Branch
    O4 => MemRead,     -- MemRead
    O5 => MemtoReg,    -- MemtoReg
    O7 => MemWrite,    -- MemWrite
    O8 => ALUSrc,      -- ALUSrc
    O9 => RegWrite,    -- RegWrite
    O6 => ALUOp        -- ALUOp
);

-- Register File
Register_File: REG port map(
    I1 => IF_ID_Instruction(25 downto 21),  -- Rs
    I2 => IF_ID_Instruction(20 downto 16),  -- Rt
    I3 => MEM_WB_Write_Reg,                 -- Write Register
    I4 => WriteData,                         -- Write Data
    C1 => MEM_WB_RegWrite,                  -- RegWrite
    CLK => clk,
    O1 => ReadData1,
    O2 => ReadData2
);

-- Sign Extend
Sign_Extend: SE port map(
    I1 => IF_ID_Instruction(15 downto 0),
    O1 => SignExtend_out
);

-- ============================================================
-- ID/EX PIPELINE REGISTER
-- ============================================================
ID_EX_REG: IDEX port map(
    -- Data Inputs
    I1 => IF_ID_PC_plus_4,
    I2 => ReadData1,
    I3 => ReadData2,
    I4 => SignExtend_out,
    -- Register Addresses
    I5 => IF_ID_Instruction(20 downto 16),  -- Rt
    I6 => IF_ID_Instruction(15 downto 11),  -- Rd
    IA1 => IF_ID_Instruction(25 downto 21), -- Rs
    -- Control Signals
    I7 => RegDst,
    I8 => Jump,
    I9 => Branch,
    I10 => MemtoReg,
    I11 => ALUSrc,
    I12 => MemRead,
    I13 => MemWrite,
    I14 => RegWrite,
    I15 => ALUOp,
    -- Data Outputs
    O1 => ID_EX_PC_plus_4,
    O2 => ID_EX_ReadData1,
    O3 => ID_EX_ReadData2,
    O4 => ID_EX_SignExtend,
    -- Register Outputs
    O5 => ID_EX_Rt,
    O6 => ID_EX_Rd,
    OA1 => ID_EX_Rs,
    -- Control Outputs
    O7 => ID_EX_RegDst,
    O8 => ID_EX_Jump,
    O9 => ID_EX_Branch,
    O10 => ID_EX_MemtoReg,
    O11 => ID_EX_ALUSrc,
    O12 => ID_EX_MemRead,
    O13 => ID_EX_MemWrite,
    O14 => ID_EX_RegWrite,
    O15 => ID_EX_ALUOp,
    C1 => '1',
    clk => clk
);

-- ============================================================
-- EXECUTION (EX) STAGE
-- ============================================================

-- Forwarding Unit
Forwarding_Unit: FU port map(
    I1 => EX_MEM_Write_Reg,    -- Write register from EX/MEM
    I2 => MEM_WB_Write_Reg,    -- Write register from MEM/WB
    I3 => ID_EX_Rs,            -- Rs
    I4 => ID_EX_Rt,            -- Rt
    C1 => EX_MEM_RegWrite,     -- RegWrite from EX/MEM
    C2 => MEM_WB_RegWrite,     -- RegWrite from MEM/WB
    O1 => Forward_A,           -- Forward control for Rs
    O2 => Forward_B            -- Forward control for Rt
);

-- Forward MUX A (for Rs)
MUX_Forward_A: MUX3 generic map(N => 32)
                    port map(
    I1 => ID_EX_ReadData1,
    I2 => WriteData,
    I3 => EX_MEM_ALU_Result,
    C1 => Forward_A,
    O1 => MUX_A_out
);

-- Forward MUX B (for Rt)
MUX_Forward_B: MUX3 generic map(N => 32)
                    port map(
    I1 => ID_EX_ReadData2,
    I2 => WriteData,
    I3 => EX_MEM_ALU_Result,
    C1 => Forward_B,
    O1 => MUX_B_out
);

-- ALU Source MUX (Register or Immediate)
MUX_ALU_Src: MUX generic map(N => 32)
                 port map(
    I1 => MUX_B_out,
    I2 => ID_EX_SignExtend,
    C1 => ID_EX_ALUSrc,
    O1 => ALU_Src_B
);

-- ALU Control
ALU_Control_Unit: ALUC port map(
    I1 => ID_EX_ALUOp,
    I2 => ID_EX_SignExtend(5 downto 0),
    O1 => ALU_Control
);

-- Main ALU
Main_ALU: ALU port map(
    I1 => MUX_A_out,
    I2 => ALU_Src_B,
    C1 => ALU_Control,
    O1 => ALU_Result,
    O2 => ALU_Zero
);

-- Write Register MUX (Rt or Rd)
MUX_Write_Reg: MUX generic map(N => 5)
                   port map(
    I1 => ID_EX_Rt,
    I2 => ID_EX_Rd,
    C1 => ID_EX_RegDst,
    O1 => Write_Reg_Addr
);

-- Branch Target Calculation
Shift_Left_Branch: SL generic map(N => 32, M => 32)
                      port map(
    I1 => ID_EX_SignExtend,
    O1 => SignExtend_Shifted
);

ADD_Branch: ADDER port map(
    I1 => ID_EX_PC_plus_4,
    I2 => SignExtend_Shifted,
    O1 => Branch_Target
);

-- ============================================================
-- EX/MEM PIPELINE REGISTER
-- ============================================================
EX_MEM_REG: EXMEM port map(
    -- Data Inputs
    I1 => Branch_Target,
    I2 => ALU_Result,
    I3 => MUX_B_out,           -- Store data
    -- Register Address
    I5 => Write_Reg_Addr,
    -- Control Signals
    I8 => ID_EX_Jump,
    I9 => ID_EX_Branch,
    I10 => ID_EX_MemtoReg,
    I12 => ID_EX_MemRead,
    I13 => ID_EX_MemWrite,
    I14 => ID_EX_RegWrite,
    I15 => ALU_Zero,
    -- Data Outputs
    O1 => EX_MEM_Branch_Target,
    O2 => EX_MEM_ALU_Result,
    O3 => EX_MEM_WriteData,
    -- Register Output
    O5 => EX_MEM_Write_Reg,
    -- Control Outputs
    O8 => EX_MEM_Jump,
    O9 => EX_MEM_Branch,
    O10 => EX_MEM_MemtoReg,
    O12 => EX_MEM_MemRead,
    O13 => EX_MEM_MemWrite,
    O14 => EX_MEM_RegWrite,
    O15 => EX_MEM_Zero,
    C1 => '1',
    clk => clk
);

-- ============================================================
-- MEMORY (MEM) STAGE
-- ============================================================

-- Data Memory
Data_Memory: DATAMEM port map(
    I1 => EX_MEM_ALU_Result,   -- Address
    I2 => EX_MEM_WriteData,    -- Write Data
    C1 => EX_MEM_MemWrite,     -- MemWrite
    C2 => EX_MEM_MemRead,      -- MemRead
    clk => clk,
    O1 => Mem_Read_Data        -- Read Data
);

-- ============================================================
-- MEM/WB PIPELINE REGISTER
-- ============================================================
MEM_WB_REG: MEMWB port map(
    -- Data Inputs
    I1 => Mem_Read_Data,
    I2 => EX_MEM_ALU_Result,
    -- Register Address
    I3 => EX_MEM_Write_Reg,
    -- Control Signals
    I10 => EX_MEM_MemtoReg,
    I14 => EX_MEM_RegWrite,
    -- Data Outputs
    O1 => MEM_WB_Mem_Data,
    O2 => MEM_WB_ALU_Result,
    -- Register Output
    O3 => MEM_WB_Write_Reg,
    -- Control Outputs
    O10 => MEM_WB_MemtoReg,
    O14 => MEM_WB_RegWrite,
    C1 => '1',
    clk => clk
);

-- ============================================================
-- WRITE BACK (WB) STAGE
-- ============================================================

-- Write Back Data MUX
MUX_Write_Back: MUX generic map(N => 32)
                    port map(
    I1 => MEM_WB_ALU_Result,
    I2 => MEM_WB_Mem_Data,
    C1 => MEM_WB_MemtoReg,
    O1 => WriteData
);

end MIPS_ARCH;