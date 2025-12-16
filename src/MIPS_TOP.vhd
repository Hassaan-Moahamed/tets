library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MIPS_TOP is
end MIPS_TOP;

architecture MIPS_ARCH of MIPS_TOP is

-- Component Declarations
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

-- Signal Declarations
signal clk: std_ulogic := '0';
signal FOUR: std_ulogic_vector(31 downto 0) := "00000000000000000000000000000100";

-- IF Stage signals
signal INSTR0, INSTR1, SUM0, INSTR_ADDRESS, PCIN, SUM1: std_ulogic_vector(31 downto 0) := (others => '0');
signal JUMP_ADDRESS: std_ulogic_vector(31 downto 0) := (others => '0');

-- ID Stage signals
signal CONSTANT_VALUE0: std_ulogic_vector(31 downto 0) := (others => '0');
signal READDATA1, READDATA2, WRITEDATA: std_ulogic_vector(31 downto 0) := (others => '0');
signal RegDst0, Jump0, Branch0, MemRead0, MemtoReg0, MemWrite0, ALUSrc0, RegWrite0: std_ulogic := '0';
signal ALUOp0: std_ulogic_vector(2 downto 0) := (others => '0');

-- ID/EX Stage signals
signal SUM2, D1, D2, CONSTANT_VALUE1: std_ulogic_vector(31 downto 0) := (others => '0');
signal D3, D4, RS, RT, RD: std_ulogic_vector(4 downto 0):= (others => '0');
signal RegDst, Jump1, Branch1, MemRead1, MemtoReg1, MemWrite1, ALUSrc, RegWrite1: std_ulogic := '0';
signal ALUOp, ALUCTRL: std_ulogic_vector(2 downto 0) := (others => '0');
signal D11, D12, D5: std_ulogic_vector(31 downto 0) := (others => '0');
signal EN1, EN2: std_ulogic_vector(1 downto 0) := (others => '0');

-- EX Stage signals
signal DATA_ADDRESS0: std_ulogic_vector(31 downto 0) := (others => '0');
signal WR_ADDRESS0: std_ulogic_vector(4 downto 0) := (others => '0');
signal D6, D7: std_ulogic_vector(31 downto 0) := (others => '0');
signal Z0: std_ulogic := '0';

-- EX/MEM Stage signals
signal BRANCH_ADDRESS, DATA_ADDRESS, DATA_WRITE: std_ulogic_vector(31 downto 0) := (others => '0');
signal WR_ADDRESS1: std_ulogic_vector(4 downto 0) := (others => '0');
signal Jump2, Branch2, MemRead, MemtoReg2, MemWrite, RegWrite2, Z1: std_ulogic := '0';

-- MEM Stage signals
signal D8: std_ulogic_vector(31 downto 0) := (others => '0');
signal BRANCH_TAKEN: std_ulogic := '0';

-- MEM/WB Stage signals
signal D9, D10: std_ulogic_vector(31 downto 0) := (others => '0');
signal WR_ADDRESS: std_ulogic_vector(4 downto 0) := (others => '0');
signal MemtoReg, RegWrite: std_ulogic := '0';

-- PC control signals
signal PC_AFTER_BRANCH: std_ulogic_vector(31 downto 0) := (others => '0');

-- Always enabled (no stalls)
constant PCEnable: std_ulogic := '1';
constant IFIDEnable: std_ulogic := '1';

begin

    -- Clock Generation (100 ns period)
    clkGEN: process
    begin
        clk <= '0';
        wait for 50 ns;
        clk <= '1';
        wait for 50 ns;
    end process;

    -- ============ INSTRUCTION FETCH STAGE ============
    PC1: PC port map(PCIN, INSTR_ADDRESS, PCEnable, clk);
    
    ADD1: ADDER port map(INSTR_ADDRESS, FOUR, SUM0);
    
    IM1: IM generic map(N => 128)
           port map(INSTR_ADDRESS, INSTR0);

    -- ============ IF/ID PIPELINE REGISTER ============
    IFID1: IFID port map(SUM0, INSTR0, SUM1, INSTR1, IFIDEnable, clk);
    
    -- ============ INSTRUCTION DECODE STAGE ============
    CONTROL1: CONTROL port map(
        INSTR1(31 downto 26),  -- Opcode
        RegDst0, Jump0, Branch0, MemRead0, MemtoReg0, 
        MemWrite0, ALUSrc0, RegWrite0, ALUOp0
    );
    
    REG1: REG port map(
        INSTR1(25 downto 21),  -- Rs
        INSTR1(20 downto 16),  -- Rt
        WR_ADDRESS,            -- Write register
        WRITEDATA,             -- Write data
        RegWrite,              -- RegWrite
        clk,
        READDATA1, READDATA2
    );
    
    SE1: SE port map(INSTR1(15 downto 0), CONSTANT_VALUE0);
    
    -- Jump address calculation in ID stage
    -- Format: {PC+4[31:28], instr[25:0], 2'b00}
    -- SUM1 is PC+4 from IF/ID register
    JUMP_ADDRESS <= SUM1(31 downto 28) & INSTR1(25 downto 0) & "00";

    -- ============ ID/EX PIPELINE REGISTER ============
    IDEX1: IDEX port map(
        SUM1, READDATA1, READDATA2, CONSTANT_VALUE0,  -- Data
        INSTR1(20 downto 16), INSTR1(15 downto 11), INSTR1(25 downto 21),  -- Rt, Rd, Rs
        RegDst0, Jump0, Branch0, MemRead0, MemtoReg0, MemWrite0, ALUSrc0, RegWrite0, ALUOp0,  -- Control
        SUM2, D1, D2, CONSTANT_VALUE1,  -- Data outputs
        D3, D4, RS,  -- Register outputs (Rt, Rd, Rs)
        RegDst, Jump1, Branch1, MemRead1, MemtoReg1, MemWrite1, ALUSrc, RegWrite1, ALUOp,  -- Control outputs
        '1', clk
    );
    
    RT <= D3;  -- Rt for forwarding
    RD <= D4;  -- Rd for forwarding

    -- ============ EXECUTION STAGE ============
    ALUC1: ALUC port map(ALUOp, CONSTANT_VALUE1(5 downto 0), ALUCTRL);
    
    -- Forwarding Unit
    FU1: FU port map(WR_ADDRESS1, WR_ADDRESS, RS, RT, RegWrite2, RegWrite, EN1, EN2);
    
    -- Forward data for source 1 (Rs)
    MUX5: MUX3 generic map(N => 32)
               port map(D1, WRITEDATA, DATA_ADDRESS, EN1, D11);
    
    -- Forward data for source 2 (Rt)
    MUX6: MUX3 generic map(N => 32)
               port map(D2, WRITEDATA, DATA_ADDRESS, EN2, D12);
    
    -- ALU source selection (Register or Immediate)
    MUX2: MUX generic map(N => 32)
              port map(D12, CONSTANT_VALUE1, ALUSrc, D5);
    
    -- ALU operation
    ALU1: ALU port map(D11, D5, ALUCTRL, DATA_ADDRESS0, Z0);
    
    -- Write register selection (Rt or Rd)
    MUX7: MUX generic map(N => 5)
              port map(D3, D4, RegDst, WR_ADDRESS0);
    
    -- Branch address calculation (PC+4 + sign_extended_offset<<2)
    SL2: SL generic map(N => 32, M => 32)
            port map(CONSTANT_VALUE1, D6);
    ADD2: ADDER port map(SUM2, D6, D7);
    
    -- ============ EX/MEM PIPELINE REGISTER ============
    EXMEM1: EXMEM port map(
        D7, DATA_ADDRESS0, D12,  -- Branch addr, ALU result, Store data
        WR_ADDRESS0,              -- Write register
        Jump1, Branch1, MemRead1, MemtoReg1, MemWrite1, RegWrite1, Z0,  -- Control + Zero flag
        BRANCH_ADDRESS, DATA_ADDRESS, DATA_WRITE,  -- Outputs
        WR_ADDRESS1,              -- Write register output
        Jump2, Branch2, MemRead, MemtoReg2, MemWrite, RegWrite2, Z1,  -- Control outputs
        '1', clk
    );
    
    -- ============ MEMORY STAGE ============
    DM1: DATAMEM port map(DATA_ADDRESS, DATA_WRITE, MemWrite, MemRead, clk, D8);
    
    -- Branch decision
    BRANCH_TAKEN <= Branch2 and Z1;
    
    -- ============ PC CONTROL LOGIC ============
    -- Priority: Jump > Branch > Sequential
    -- Jump is decided early (in ID), so check it first
    
    -- First: Choose between sequential and branch
    MUX1: MUX generic map(N => 32)
              port map(SUM0, BRANCH_ADDRESS, BRANCH_TAKEN, PC_AFTER_BRANCH);
    
    -- Second: Jump overrides everything (evaluated in ID stage)
    MUX_JUMP: MUX generic map(N => 32)
              port map(PC_AFTER_BRANCH, JUMP_ADDRESS, Jump0, PCIN);
    
    -- ============ MEM/WB PIPELINE REGISTER ============
    MEMWB1: MEMWB port map(
        D8, DATA_ADDRESS,         -- Memory data, ALU result
        WR_ADDRESS1,              -- Write register
        MemtoReg2, RegWrite2,     -- Control
        D9, D10,                  -- Outputs
        WR_ADDRESS,               -- Write register output
        MemtoReg, RegWrite,       -- Control outputs
        '1', clk
    );

    -- ============ WRITE BACK STAGE ============
    MUX4: MUX generic map(N => 32)
              port map(D10, D9, MemtoReg, WRITEDATA);

end MIPS_ARCH;