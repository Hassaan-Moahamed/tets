--*********************************************************
--*   TESTBENCH FOR MIPS PROCESSOR - FIXED VERSION      *
--*   Tests: Addition of 4 + 5                           *
--*   With detailed reporting and forwarding monitoring  *
--*********************************************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity MIPS_TB is
end MIPS_TB;

architecture TB_ARCH of MIPS_TB is

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
     CLK: in std_ulogic;  -- CLOCK IS A SINGLE BIT!
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

-- Simulation control
signal sim_done: boolean := false;
signal cycle_count: integer := 0;

-- Helper function to convert vector to hex string
function to_hex_string(vec: std_ulogic_vector) return string is
    variable result: string(1 to 8);
    variable nibble: std_ulogic_vector(3 downto 0);
    variable hex_char: character;
begin
    for i in 0 to 7 loop
        nibble := vec(31 - i*4 downto 28 - i*4);
        case nibble is
            when "0000" => hex_char := '0';
            when "0001" => hex_char := '1';
            when "0010" => hex_char := '2';
            when "0011" => hex_char := '3';
            when "0100" => hex_char := '4';
            when "0101" => hex_char := '5';
            when "0110" => hex_char := '6';
            when "0111" => hex_char := '7';
            when "1000" => hex_char := '8';
            when "1001" => hex_char := '9';
            when "1010" => hex_char := 'A';
            when "1011" => hex_char := 'B';
            when "1100" => hex_char := 'C';
            when "1101" => hex_char := 'D';
            when "1110" => hex_char := 'E';
            when "1111" => hex_char := 'F';
            when others => hex_char := 'X';
        end case;
        result(i+1) := hex_char;
    end loop;
    return result;
end function;

begin

    -- Clock Generation (100 ns period)
    clkGEN: process
    begin
        while not sim_done loop
            clk <= '0';
            wait for 50 ns;
            clk <= '1';
            wait for 50 ns;
        end loop;
        wait;
    end process;

    -- Instruction Fetch Stage
    PC1: PC port map(
        I1 => PCIN,
        O1 => INSTR_ADDRESS,
        C1 => PCEnable,
        clk => clk
    );
    
    ADD1: ADDER port map(
        I1 => INSTR_ADDRESS,
        I2 => FOUR,
        O1 => SUM0
    );
    
    IM1: IM generic map(N => 128)
           port map(
               I1 => INSTR_ADDRESS,
               O1 => INSTR0
           );
    
    MUX1: MUX generic map(N => 32)
              port map(
                  I1 => SUM0,
                  I2 => BRANCH_ADDRESS,
                  C1 => ANDCTRL,
                  O1 => PCIN
              );

    -- IF/ID Pipeline Register
    IFID1: IFID port map(
        I1 => SUM0,
        I2 => INSTR0,
        O1 => SUM1,
        O2 => INSTR1,
        C1 => IFIDEnable,
        clk => clk
    );
    
    -- Instruction Decode Stage
    CONTROL1: CONTROL port map(
        I1 => INSTR1(31 downto 26),
        O1 => RegDstx,
        O2 => Jumpx,
        O3 => Branchx,
        O4 => MemReadx,
        O5 => MemtoRegx,
        O6 => ALUOpx,
        O7 => MemWritex,
        O8 => ALUSrcx,
        O9 => RegWritex
    );
    
    -- FIXED: Correct port mapping for REG with CLK as single bit
    REG1: REG port map(
        I1 => INSTR1(25 downto 21),  -- Rs
        I2 => INSTR1(20 downto 16),  -- Rt
        I3 => WR_ADDRESS,             -- Write register
        I4 => WRITEDATA,              -- Write data
        C1 => RegWrite,               -- RegWrite enable
        CLK => clk,                   -- CLOCK (single bit!)
        O1 => READDATA1,              -- Read data 1
        O2 => READDATA2               -- Read data 2
    );
    
    SE1: SE port map(
        I1 => INSTR1(15 downto 0),
        O1 => CONSTANT_VALUE0
    );

    -- Hazard Detection Unit
    MUXHDUIN <= RegDstx&Jumpx&Branchx&MemReadx&MemtoRegx&MemWritex&ALUSrcx&RegWritex&ALUOpx;
    
    HDU1: HDU port map(
        I1 => INSTR1,
        I2 => RT,
        I3 => MemRead1,
        O1 => MUXCtrl,
        O2 => PCEnable0,
        O3 => IFIDEnable0
    );
    
    MUX8: MUX generic map(N => 11)
              port map(
                  I1 => MUXHDUIN,
                  I2 => "00000000000",
                  C1 => MUXCtrl,
                  O1 => MUXHDUOUT
              );

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
    IDEX1: IDEX port map(
        I1 => SUM1,
        I2 => READDATA1,
        I3 => READDATA2,
        I4 => CONSTANT_VALUE0,
        I5 => INSTR1(20 downto 16),
        I6 => INSTR1(15 downto 11),
        IA1 => INSTR1(25 downto 21),
        I7 => RegDst0,
        I8 => Jump0,
        I9 => Branch0,
        I10 => MemtoReg0,
        I11 => ALUSrc0,
        I12 => MemRead0,
        I13 => MemWrite0,
        I14 => RegWrite0,
        I15 => ALUOp0,
        O1 => SUM2,
        O2 => D1,
        O3 => D2,
        O4 => CONSTANT_VALUE1,
        O5 => D3,
        O6 => D4,
        OA1 => RS,
        O7 => RegDst,
        O8 => Jump1,
        O9 => Branch1,
        O10 => MemtoReg1,
        O11 => ALUSrc,
        O12 => MemRead1,
        O13 => MemWrite1,
        O14 => RegWrite1,
        O15 => ALUOp,
        C1 => '1',
        clk => clk
    );
    
    RT <= D3;
    RD <= D4;

    -- Execution Stage
    ALUC1: ALUC port map(
        I1 => ALUOp,
        I2 => CONSTANT_VALUE1(5 downto 0),
        O1 => ALUCTRL
    );
    
    -- Forwarding Unit
    FU1: FU port map(
        I1 => WR_ADDRESS1,
        I2 => WR_ADDRESS,
        I3 => RS,
        I4 => RT,
        C1 => RegWrite2,
        C2 => RegWrite,
        O1 => EN1,
        O2 => EN2
    );
    
    MUX5: MUX3 generic map(N => 32)
               port map(
                   I1 => D1,
                   I2 => WRITEDATA,
                   I3 => DATA_ADDRESS,
                   C1 => EN1,
                   O1 => D11
               );
    
    MUX6: MUX3 generic map(N => 32)
               port map(
                   I1 => D2,
                   I2 => WRITEDATA,
                   I3 => DATA_ADDRESS,
                   C1 => EN2,
                   O1 => D12
               );
    
    MUX2: MUX generic map(N => 32)
              port map(
                  I1 => D12,
                  I2 => CONSTANT_VALUE1,
                  C1 => ALUSrc,
                  O1 => D5
              );
    
    ALU1: ALU port map(
        I1 => D11,
        I2 => D5,
        C1 => ALUCTRL,
        O1 => DATA_ADDRESS0,
        O2 => Z0
    );
    
    MUX7: MUX generic map(N => 5)
              port map(
                  I1 => D3,
                  I2 => D4,
                  C1 => RegDst,
                  O1 => WR_ADDRESS0
              );
    
    SL2: SL generic map(N => 32, M => 32)
            port map(
                I1 => CONSTANT_VALUE1,
                O1 => D6
            );
    
    ADD2: ADDER port map(
        I1 => SUM2,
        I2 => D6,
        O1 => D7
    );
    
    -- EX/MEM Pipeline Register
    EXMEM1: EXMEM port map(
        I1 => D7,
        I2 => DATA_ADDRESS0,
        I3 => D12,
        I5 => WR_ADDRESS0,
        I8 => Jump1,
        I9 => Branch1,
        I10 => MemtoReg1,
        I12 => MemRead1,
        I13 => MemWrite1,
        I14 => RegWrite1,
        I15 => Z0,
        O1 => BRANCH_ADDRESS,
        O2 => DATA_ADDRESS,
        O3 => DATA_WRITE,
        O5 => WR_ADDRESS1,
        O8 => Jump,
        O9 => Branch,
        O10 => MemtoReg2,
        O12 => MemRead,
        O13 => MemWrite,
        O14 => RegWrite2,
        O15 => Z1,
        C1 => '1',
        clk => clk
    );
    
    -- Memory Stage
    DM1: DATAMEM port map(
        I1 => DATA_ADDRESS,
        I2 => DATA_WRITE,
        C1 => MemWrite,
        C2 => MemRead,
        clk => clk,
        O1 => D8
    );
    
    ANDCTRL <= Branch and Z1;
    
    -- MEM/WB Pipeline Register
    MEMWB1: MEMWB port map(
        I1 => D8,
        I2 => DATA_ADDRESS,
        I3 => WR_ADDRESS1,
        I10 => MemtoReg2,
        I14 => RegWrite2,
        O1 => D9,
        O2 => D10,
        O3 => WR_ADDRESS,
        O10 => MemtoReg,
        O14 => RegWrite,
        C1 => '1',
        clk => clk
    );

    -- Write Back Stage
    MUX4: MUX generic map(N => 32)
              port map(
                  I1 => D10,
                  I2 => D9,
                  C1 => MemtoReg,
                  O1 => WRITEDATA
              );

    PCEnable <= PCEnable0;
    IFIDEnable <= IFIDEnable0;

    -- Monitoring and Reporting Process
    REPORT_PROC: process(clk)
    begin
        if rising_edge(clk) then
            cycle_count <= cycle_count + 1;

            -- Divider
            report "========================================" severity note;
            report "Cycle: " & integer'image(cycle_count) severity note;
            report "========================================" severity note;

            -- PC and Instruction Fetch
            report "PC: " & integer'image(to_integer(unsigned(INSTR_ADDRESS))) severity note;
            report "Instruction Fetch: 0x" & to_hex_string(INSTR0) severity note;

            -- Instruction Decode Stage
            if INSTR1 /= X"00000000" then
                report "ID Stage - Instruction: 0x" & to_hex_string(INSTR1) severity note;
            end if;

            -- Hazard Detection
            if MUXCtrl = '1' then
                report "*** LOAD-USE HAZARD DETECTED - PIPELINE STALLED ***" severity note;
            end if;

            -- Forwarding Status
            if EN1 /= "00" then
                case EN1 is
                    when "01" => report "FORWARDING - Source 1: from WB stage" severity note;
                    when "10" => report "FORWARDING - Source 1: from MEM stage" severity note;
                    when others => null;
                end case;
            end if;

            if EN2 /= "00" then
                case EN2 is
                    when "01" => report "FORWARDING - Source 2: from WB stage" severity note;
                    when "10" => report "FORWARDING - Source 2: from MEM stage" severity note;
                    when others => null;
                end case;
            end if;

            -- ALU Operation
            if RegWrite1 = '1' then
                report "EX Stage - ALU Result: " & integer'image(to_integer(signed(DATA_ADDRESS0))) severity note;
            end if;

            -- Memory Operations
            if MemRead = '1' then
                report "MEM Stage - Reading from address: " & integer'image(to_integer(unsigned(DATA_ADDRESS))) &
                       " Data: " & integer'image(to_integer(signed(D8))) severity note;
            end if;

            if MemWrite = '1' then
                report "MEM Stage - Writing to address: " & integer'image(to_integer(unsigned(DATA_ADDRESS))) &
                       " Data: " & integer'image(to_integer(signed(DATA_WRITE))) severity note;
            end if;

            -- Write Back Stage
            if RegWrite = '1' and WR_ADDRESS /= "00000" then
                report "WB Stage - Writing to Register R" & integer'image(to_integer(unsigned(WR_ADDRESS))) &
                       " Value: " & integer'image(to_integer(signed(WRITEDATA))) severity note;
                
                -- Print result when writing to R4
                if WR_ADDRESS = "00100" then
                    report "========================================" severity note;
                    report "*** RESULT: 4 + 5 = " & integer'image(to_integer(signed(WRITEDATA))) & " ***" severity note;
                    report "========================================" severity note;
                end if;
            end if;

            -- Stop simulation after enough cycles
            if cycle_count >= 15 then
                sim_done <= true;
                report "Simulation Complete" severity note;
            end if;

        end if;
    end process;

end TB_ARCH;