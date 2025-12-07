--*********************************************************
--*   ENHANCED TESTBENCH FOR MIPS PROCESSOR             *
--*   Tests: Addition of 4 + 5 with detailed reporting  *
--*   Shows all pipeline stages and hazard detection    *
--*********************************************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity MIPS_TB is
end MIPS_TB;

architecture TB_ARCH of MIPS_TB is

-- Component Declarations (same as before)
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
     CLK: in std_ulogic;
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

-- Function to decode instruction mnemonic
function decode_instruction(instr: std_ulogic_vector) return string is
    variable opcode: std_ulogic_vector(5 downto 0);
begin
    opcode := instr(31 downto 26);
    case opcode is
        when "000000" => 
            if instr = X"00000000" then
                return "NOP";
            else
                return "R-type (ADD/SUB/AND/OR/NOR)";
            end if;
        when "000010" => return "LOAD (lw)";
        when "000011" => return "STORE (sw)";
        when "001000" => return "BRANCH (beq)";
        when "010000" => return "JUMP (j)";
        when others => return "UNKNOWN";
    end case;
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
    PC1: PC port map(PCIN, INSTR_ADDRESS, PCEnable, clk);
    ADD1: ADDER port map(INSTR_ADDRESS, FOUR, SUM0);
    IM1: IM generic map(N => 128) port map(INSTR_ADDRESS, INSTR0);
    MUX1: MUX generic map(N => 32) port map(SUM0, BRANCH_ADDRESS, ANDCTRL, PCIN);

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
    MUX8: MUX generic map(N => 11) port map(MUXHDUIN, "00000000000", MUXCtrl, MUXHDUOUT);

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
                         RegDst0, Jump0, Branch0, MemtoReg0, ALUSrc0, MemRead0, MemWrite0, 
                         RegWrite0, ALUOp0, SUM2, D1, D2, CONSTANT_VALUE1, D3, D4, RS,
                         RegDst, Jump1, Branch1, MemtoReg1, ALUSrc, MemRead1, MemWrite1, 
                         RegWrite1, ALUOp, '1', clk);
    RT <= D3;
    RD <= D4;

    -- Execution Stage
    ALUC1: ALUC port map(ALUOp, CONSTANT_VALUE1(5 downto 0), ALUCTRL);
    FU1: FU port map(WR_ADDRESS1, WR_ADDRESS, RS, RT, RegWrite2, RegWrite, EN1, EN2);
    MUX5: MUX3 generic map(N => 32) port map(D1, WRITEDATA, DATA_ADDRESS, EN1, D11);
    MUX6: MUX3 generic map(N => 32) port map(D2, WRITEDATA, DATA_ADDRESS, EN2, D12);
    MUX2: MUX generic map(N => 32) port map(D12, CONSTANT_VALUE1, ALUSrc, D5);
    ALU1: ALU port map(D11, D5, ALUCTRL, DATA_ADDRESS0, Z0);
    MUX7: MUX generic map(N => 5) port map(D3, D4, RegDst, WR_ADDRESS0);
    SL2: SL generic map(N => 32, M => 32) port map(CONSTANT_VALUE1, D6);
    ADD2: ADDER port map(SUM2, D6, D7);
    
    -- EX/MEM Pipeline Register
    EXMEM1: EXMEM port map(D7, DATA_ADDRESS0, D12, WR_ADDRESS0, 
                           Jump1, Branch1, MemtoReg1, MemRead1, MemWrite1, RegWrite1, Z0,
                           BRANCH_ADDRESS, DATA_ADDRESS, DATA_WRITE, WR_ADDRESS1,
                           Jump, Branch, MemtoReg2, MemRead, MemWrite, RegWrite2, Z1, 
                           '1', clk);
    
    -- Memory Stage
    DM1: DATAMEM port map(DATA_ADDRESS, DATA_WRITE, MemWrite, MemRead, clk, D8);
    ANDCTRL <= Branch and Z1;
    
    -- MEM/WB Pipeline Register
    MEMWB1: MEMWB port map(D8, DATA_ADDRESS, WR_ADDRESS1, MemtoReg2, RegWrite2,
                           D9, D10, WR_ADDRESS, MemtoReg, RegWrite, '1', clk);

    -- Write Back Stage
    MUX4: MUX generic map(N => 32) port map(D10, D9, MemtoReg, WRITEDATA);

    PCEnable <= PCEnable0;
    IFIDEnable <= IFIDEnable0;

    -- ENHANCED Monitoring and Reporting Process
    REPORT_PROC: process(clk)
        variable first_cycle: boolean := true;
    begin
        if rising_edge(clk) then
            cycle_count <= cycle_count + 1;

            -- Header banner
            report "========================================" severity note;
            report "========== CYCLE " & integer'image(cycle_count) & " ===========" severity note;
            report "========================================" severity note;

            -- IF Stage
            report ">>> IF STAGE:" severity note;
            report "    PC = " & integer'image(to_integer(unsigned(INSTR_ADDRESS))) & 
                   " | Fetching: 0x" & to_hex_string(INSTR0) severity note;
            if INSTR0 /= X"00000000" then
                report "    Instruction type: " & decode_instruction(INSTR0) severity note;
            end if;

            -- ID Stage
            if INSTR1 /= X"00000000" then
                report ">>> ID STAGE:" severity note;
                report "    Instruction: 0x" & to_hex_string(INSTR1) & 
                       " (" & decode_instruction(INSTR1) & ")" severity note;
                report "    Rs=R" & integer'image(to_integer(unsigned(INSTR1(25 downto 21)))) &
                       " Rt=R" & integer'image(to_integer(unsigned(INSTR1(20 downto 16)))) &
                       " Rd=R" & integer'image(to_integer(unsigned(INSTR1(15 downto 11)))) severity note;
                report "    ReadData1=" & integer'image(to_integer(signed(READDATA1))) &
                       " ReadData2=" & integer'image(to_integer(signed(READDATA2))) severity note;
            else
                report ">>> ID STAGE: NOP/Bubble" severity note;
            end if;

            -- Hazard Detection
            if MUXCtrl = '1' then
                report "*** HAZARD DETECTED! Pipeline stalled ***" severity warning;
                report "    PCEnable=" & std_ulogic'image(PCEnable) & 
                       " IFIDEnable=" & std_ulogic'image(IFIDEnable) severity warning;
            end if;

            -- EX Stage
            if RegWrite1 = '1' or ALUSrc = '1' then
                report ">>> EX STAGE:" severity note;
                report "    ALU Input A (D11) = " & integer'image(to_integer(signed(D11))) severity note;
                report "    ALU Input B (D5)  = " & integer'image(to_integer(signed(D5))) severity note;
                report "    ALU Control = " & integer'image(to_integer(unsigned(ALUCTRL))) severity note;
                report "    ALU Result = " & integer'image(to_integer(signed(DATA_ADDRESS0))) severity note;
                
                -- Forwarding status
                if EN1 /= "00" then
                    case EN1 is
                        when "01" => report "    FORWARD A: from WB stage" severity note;
                        when "10" => report "    FORWARD A: from MEM stage" severity note;
                        when others => null;
                    end case;
                end if;
                if EN2 /= "00" then
                    case EN2 is
                        when "01" => report "    FORWARD B: from WB stage" severity note;
                        when "10" => report "    FORWARD B: from MEM stage" severity note;
                        when others => null;
                    end case;
                end if;
            end if;

            -- MEM Stage
            if MemRead = '1' then
                report ">>> MEM STAGE: LOAD" severity note;
                report "    Address: " & integer'image(to_integer(unsigned(DATA_ADDRESS))) &
                       " | Data read: " & integer'image(to_integer(signed(D8))) severity note;
            elsif MemWrite = '1' then
                report ">>> MEM STAGE: STORE" severity note;
                report "    Address: " & integer'image(to_integer(unsigned(DATA_ADDRESS))) &
                       " | Data write: " & integer'image(to_integer(signed(DATA_WRITE))) severity note;
            elsif RegWrite2 = '1' then
                report ">>> MEM STAGE: ALU result passing through" severity note;
                report "    Data: " & integer'image(to_integer(signed(DATA_ADDRESS))) severity note;
            end if;

            -- WB Stage
            if RegWrite = '1' and WR_ADDRESS /= "00000" then
                report ">>> WB STAGE: Writing to Register File" severity note;
                report "    R" & integer'image(to_integer(unsigned(WR_ADDRESS))) & 
                       " <= " & integer'image(to_integer(signed(WRITEDATA))) severity note;
                
                -- Special notification for R4 (the result)
                if WR_ADDRESS = "00100" then
                    report "" severity note;
                    report "+------------------------------------+" severity note;
                    report "¦  *** FINAL RESULT COMPUTED! ***   ¦" severity note;
                    report "¦  R4 = " & integer'image(to_integer(signed(WRITEDATA))) & 
                           " (Expected: 9)           ¦" severity note;
                    report "¦  Calculation: 4 + 5 = " & 
                           integer'image(to_integer(signed(WRITEDATA))) & "           ¦" severity note;
                    report "+------------------------------------+" severity note;
                    report "" severity note;
                end if;
            end if;

            report "" severity note;  -- Blank line for readability

            -- Stop simulation after enough cycles
            if cycle_count >= 15 then
                sim_done <= true;
                report "========================================" severity note;
                report "    SIMULATION COMPLETE" severity note;
                report "    Total Cycles: " & integer'image(cycle_count) severity note;
                report "========================================" severity note;
            end if;

        end if;
    end process;

end TB_ARCH;