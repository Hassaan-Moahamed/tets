

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
     C1: in std_ulogic;
     CLK: in std_ulogic;  -- ADDED
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
port(I1: in std_ulogic_vector((N-1) downto 0);
     I2: in std_ulogic_vector((N-1) downto 0);
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
port(I1: in std_ulogic_vector((N-1) downto 0);
     I2: in std_ulogic_vector((N-1) downto 0);
     I3: in std_ulogic_vector((N-1) downto 0);
     C1: in std_ulogic_vector(1 downto 0);  
     O1: out std_ulogic_vector((N-1) downto 0));
end component;

component HDU is
port(I1: in std_ulogic_vector(31 downto 0);
     I2: in std_ulogic_vector(4 downto 0);
     I3: in std_ulogic;
     O1, O2, O3: out std_ulogic);   
end component;

-- Signal Declarations
signal clk: std_ulogic := '0';
signal FOUR: std_ulogic_vector(31 downto 0) := "00000000000000000000000000000100";
signal INSTR0, INSTR1, SUM0, INSTR_ADDRESS, PCIN, SUM1, CONSTANT_VALUE0: std_ulogic_vector(31 downto 0) := (others => '0');
signal READDATA1, READDATA2, WRITEDATA, SUM2, D1, D2, CONSTANT_VALUE1, D5: std_ulogic_vector(31 downto 0) := (others => '0');
signal DATA_ADDRESS0, DATA_ADDRESS, D6, D7, BRANCH_ADDRESS, DATA_WRITE: std_ulogic_vector(31 downto 0) := (others => '0');
signal D8, D9, D10, D11, D12: std_ulogic_vector(31 downto 0) := (others => '0');
signal WR_ADDRESS, WR_ADDRESS0, WR_ADDRESS1, D3, D4, RS, RT, RD: std_ulogic_vector(4 downto 0):= (others => '0');
signal RegDst, Jump, Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite: std_ulogic := '0';
signal RegDst0, Jump0, Branch0, MemRead0, MemtoReg0, MemWrite0, ALUSrc0, RegWrite0: std_ulogic := '0';
signal RegDstx, Jumpx, Branchx, MemReadx, MemtoRegx, MemWritex, ALUSrcx, RegWritex: std_ulogic := '0';
signal Jump1, Branch1, MemRead1, MemtoReg1, MemWrite1, RegWrite1: std_ulogic := '0';
signal MemtoReg2, RegWrite2, Z0, Z1, ANDCTRL, MUXCtrl, PCEnable0, PCEnable, IFIDEnable0, IFIDEnable: std_ulogic := '0';
signal ALUOp0, ALUOpx, ALUOp, ALUCTRL: std_ulogic_vector(2 downto 0) := (others => '0');
signal EN1, EN2: std_ulogic_vector(1 downto 0) := (others => '0');
signal MUXHDUIN, MUXHDUOUT: std_ulogic_vector(10 downto 0) := (others => '0');

begin

    -- Clock Generation
    clkGEN: process
    begin
        clk <= '0';
        wait for 50 ns;
        clk <= '1';
        wait for 50 ns;
    end process;

    -- Instruction Fetch Stage
    PC1: PC port map(PCIN, INSTR_ADDRESS, PCEnable, clk);
    ADD1: ADDER port map(INSTR_ADDRESS, FOUR, SUM0);
    IM1: IM generic map(N => 128)
           port map(INSTR_ADDRESS, INSTR0);
    MUX1: MUX generic map(N => 32)
              port map(SUM0, BRANCH_ADDRESS, ANDCTRL, PCIN);

    -- IF/ID Pipeline Register
    IFID1: IFID port map(SUM0, INSTR0, SUM1, INSTR1, IFIDEnable, clk);
    
    -- Instruction Decode Stage
    CONTROL1: CONTROL port map(INSTR1(31 downto 26), RegDstx, Jumpx, Branchx, 
                                MemReadx, MemtoRegx, MemWritex, ALUSrcx, RegWritex, ALUOpx);
    REG1: REG port map(INSTR1(25 downto 21), INSTR1(20 downto 16), WR_ADDRESS, 
                   WRITEDATA, RegWrite, clk, READDATA1, READDATA2);
    SE1: SE port map(INSTR1(15 downto 0), CONSTANT_VALUE0);

    -- Hazard Detection Unit
    MUXHDUIN <= RegDstx&Jumpx&Branchx&MemReadx&MemtoRegx&MemWritex&ALUSrcx&RegWritex&ALUOpx;
    HDU1: HDU port map(INSTR1, RT, MemRead1, MUXCtrl, PCEnable0, IFIDEnable0);
    MUX8: MUX generic map(N => 11)
              port map(MUXHDUIN, "00000000000", MUXCtrl, MUXHDUOUT);

    RegDst0 <= MUXHDUOUT(10);
    Jump0 <= MUXHDUOUT(9);
    Branch0 <= MUXHDUOUT(8);
    MemRead0 <= MUXHDUOUT(7);
    MemtoReg0 <= MUXHDUOUT(6);
    MemWrite0 <= MUXHDUOUT(5);
    ALUSrc0 <= MUXHDUOUT(4);
    RegWrite0 <= MUXHDUOUT(3);
    ALUOp0 <= MUXHDUOUT(2 downto 0);

    -- ID/EX Pipeline Register
    IDEX1: IDEX port map(SUM1, READDATA1, READDATA2, CONSTANT_VALUE0, 
                         INSTR1(20 downto 16), INSTR1(15 downto 11), INSTR1(25 downto 21),
                         RegDst0, Jump0, Branch0, MemRead0, MemtoReg0, MemWrite0, 
                         ALUSrc0, RegWrite0, ALUOp0,
                         SUM2, D1, D2, CONSTANT_VALUE1, D3, D4, RS,
                         RegDst, Jump1, Branch1, MemRead1, MemtoReg1, MemWrite1, 
                         ALUSrc, RegWrite1, ALUOp, '1', clk);
    RT <= D3;
    RD <= D4;

    -- Execution Stage
    ALUC1: ALUC port map(ALUOp, CONSTANT_VALUE1(5 downto 0), ALUCTRL);
    
    -- Forwarding Unit
    FU1: FU port map(WR_ADDRESS1, WR_ADDRESS, RS, RT, RegWrite2, RegWrite, EN1, EN2);
    
    MUX5: MUX3 generic map(N => 32)
               port map(D1, WRITEDATA, DATA_ADDRESS, EN1, D11);
    MUX6: MUX3 generic map(N => 32)
               port map(D2, WRITEDATA, DATA_ADDRESS, EN2, D12);
    MUX2: MUX generic map(N => 32)
              port map(D12, CONSTANT_VALUE1, ALUSrc, D5);
    ALU1: ALU port map(D11, D5, ALUCTRL, DATA_ADDRESS0, Z0);
    MUX7: MUX generic map(N => 5)
              port map(D3, D4, RegDst, WR_ADDRESS0);
    SL2: SL generic map(N => 32, M => 32)
            port map(CONSTANT_VALUE1, D6);
    ADD2: ADDER port map(SUM2, D6, D7);
    
    -- EX/MEM Pipeline Register
    EXMEM1: EXMEM port map(D7, DATA_ADDRESS0, D12, WR_ADDRESS0, 
                           Jump1, Branch1, MemRead1, MemtoReg1, MemWrite1, RegWrite1, Z0,
                           BRANCH_ADDRESS, DATA_ADDRESS, DATA_WRITE, WR_ADDRESS1,
                           Jump, Branch, MemRead, MemtoReg2, MemWrite, RegWrite2, Z1, 
                           '1', clk);
    
    -- Memory Stage
    DM1: DATAMEM port map(DATA_ADDRESS, DATA_WRITE, MemWrite, MemRead, clk, D8);
    ANDCTRL <= Branch and Z1;
    
    -- MEM/WB Pipeline Register
    MEMWB1: MEMWB port map(D8, DATA_ADDRESS, WR_ADDRESS1, MemtoReg2, RegWrite2,
                           D9, D10, WR_ADDRESS, MemtoReg, RegWrite, '1', clk);

    -- Write Back Stage
    MUX4: MUX generic map(N => 32)
              port map(D10, D9, MemtoReg, WRITEDATA);

    PCEnable <= PCEnable0;
    IFIDEnable <= IFIDEnable0;

end MIPS_ARCH;