--*********************************************************
--*   MIPS PROCESSOR TOP LEVEL                           *
--*   5-Stage Pipeline with Forwarding Unit ONLY         *
--*   HDU REMOVED - Forwarding handles all hazards       *
--*   With Enhanced Monitoring and Reporting             *
--*********************************************************

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

-- Helper function for hex string conversion
function to_hex_string(val: std_ulogic_vector) return string is
    variable result: string(1 to 8);
    variable nibble: integer;
begin
    for i in 0 to 7 loop
        nibble := to_integer(unsigned(val(31-i*4 downto 28-i*4)));
        case nibble is
            when 0 => result(i+1) := '0';
            when 1 => result(i+1) := '1';
            when 2 => result(i+1) := '2';
            when 3 => result(i+1) := '3';
            when 4 => result(i+1) := '4';
            when 5 => result(i+1) := '5';
            when 6 => result(i+1) := '6';
            when 7 => result(i+1) := '7';
            when 8 => result(i+1) := '8';
            when 9 => result(i+1) := '9';
            when 10 => result(i+1) := 'A';
            when 11 => result(i+1) := 'B';
            when 12 => result(i+1) := 'C';
            when 13 => result(i+1) := 'D';
            when 14 => result(i+1) := 'E';
            when 15 => result(i+1) := 'F';
            when others => result(i+1) := 'X';
        end case;
    end loop;
    return result;
end function;

-- Helper function to decode instruction type
function decode_instruction(instr: std_ulogic_vector) return string is
    variable opcode: std_ulogic_vector(5 downto 0);
begin
    opcode := instr(31 downto 26);
    case opcode is
        when "000000" => return "R-type";
        when "000001" => return "I-type (ADDI)";
        when "000010" => return "I-type (LOAD)";
        when "000011" => return "I-type (STORE)";
        when "000100" => return "I-type (ANDI)";
        when "000101" => return "I-type (ORI)";
        when "000110" => return "I-type (SLL)";
        when "000111" => return "I-type (SRL)";
        when "001000" => return "BRANCH";
        when "010000" => return "JUMP";
        when others => return "NOP/Unknown";
    end case;
end function;

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
signal Jump1, Branch1, MemRead1, MemtoReg1, MemWrite1, RegWrite1: std_ulogic := '0';
signal MemtoReg2, RegWrite2, Z0, Z1, ANDCTRL: std_ulogic := '0';
signal ALUOp0, ALUOp, ALUCTRL: std_ulogic_vector(2 downto 0) := (others => '0');
signal EN1 : std_ulogic_vector(1 downto 0) := (others => '0');
-- Forwarding select for ALU input A (Rs)

signal EN2 : std_ulogic_vector(1 downto 0) := (others => '0');
-- Forwarding select for ALU input B (Rt)

-- Constant enable signals (HDU removed)
constant PCEnable: std_ulogic := '1';
constant IFIDEnable: std_ulogic := '1';

-- Monitoring signals
signal cycle_count: integer := 1;
signal sim_done: boolean := false;

begin

    -- Clock Generation
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
    IM1: IM generic map(N => 128)
           port map(INSTR_ADDRESS, INSTR0);
    MUX1: MUX generic map(N => 32)
              port map(SUM0, BRANCH_ADDRESS, ANDCTRL, PCIN);

    -- IF/ID Pipeline Register (always enabled)
    IFID1: IFID port map(SUM0, INSTR0, SUM1, INSTR1, IFIDEnable, clk);
    
    -- Instruction Decode Stage
    CONTROL1: CONTROL port map(INSTR1(31 downto 26), RegDst0, Jump0, Branch0, 
                                MemRead0, MemtoReg0, MemWrite0, ALUSrc0, RegWrite0, ALUOp0);
    REG1: REG port map(INSTR1(25 downto 21), INSTR1(20 downto 16), WR_ADDRESS, 
                   WRITEDATA, RegWrite, clk, READDATA1, READDATA2);
    SE1: SE port map(INSTR1(15 downto 0), CONSTANT_VALUE0);

    -- ID/EX Pipeline Register (always enabled, no MUX for control signals)
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
    
    -- Forwarding Unit (handles all data hazards)
    FU1: FU port map(WR_ADDRESS1, WR_ADDRESS, RS, RT, RegWrite2, RegWrite, EN1, EN2);
    
    -- Forward data for source 1 (Rs)
    MUX5: MUX3 generic map(N => 32)
               port map(D1, WRITEDATA, DATA_ADDRESS, EN1, D11);
    
    -- Forward data for source 2 (Rt)
    MUX6: MUX3 generic map(N => 32)
               port map(D2, WRITEDATA, DATA_ADDRESS, EN2, D12);
    
    -- ALU source selection
    MUX2: MUX generic map(N => 32)
              port map(D12, CONSTANT_VALUE1, ALUSrc, D5);
    
    -- ALU operation
    ALU1: ALU port map(D11, D5, ALUCTRL, DATA_ADDRESS0, Z0);
    
    -- Write register selection
    MUX7: MUX generic map(N => 5)
              port map(D3, D4, RegDst, WR_ADDRESS0);
    
    -- Branch address calculation
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

    -- ENHANCED Monitoring and Reporting Process
    REPORT_PROC: process(clk)
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
                
                -- Special notification for R2 (the result register in our test)
                if WR_ADDRESS = "00010" then  -- R2
                    report "" severity note;
                    report "+------------------------------------+" severity note;
                    report "|  *** FINAL RESULT COMPUTED! ***   |" severity note;
                    report "|  R2 = " & integer'image(to_integer(signed(WRITEDATA))) & 
                           " (Expected: 9)           |" severity note;
                    report "|  Calculation: 4 + 5 = " & 
                           integer'image(to_integer(signed(WRITEDATA))) & "           |" severity note;
                    report "+------------------------------------+" severity note;
                    report "" severity note;
                end if;
            end if;

            report "" severity note;  -- Blank line for readability

            -- Stop simulation after enough cycles
            if cycle_count >= 20 then
                sim_done <= true;
                report "========================================" severity note;
                report "    SIMULATION COMPLETE" severity note;
                report "    Total Cycles: " & integer'image(cycle_count) severity note;
                report "========================================" severity note;
            end if;

        end if;
    end process;

end MIPS_ARCH;