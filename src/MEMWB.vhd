library ieee;                              
use ieee.std_logic_1164.all;               
use ieee.numeric_std.all;                  


entity MEMWB is
port(
     -- 32-bit data coming from MEM stage
     I1, I2 : in std_ulogic_vector(31 downto 0);  
     -- I1: Data read from memory
     -- I2: ALU result

     -- Destination register number
     I3 : in std_ulogic_vector(4 downto 0);       
     -- Register to be written in WB stage  (RD)

     -- Control signals needed in WB stage
     I10, I14 : in std_ulogic;                     
     -- I10: MemtoReg
     -- I14: RegWrite

     -- 32-bit outputs to WB stage
     O1, O2 : out std_ulogic_vector(31 downto 0);  
     -- O1: Memory data
     -- O2: ALU result

     -- Destination register output
     O3 : out std_ulogic_vector(4 downto 0);      
     -- Register number for write-back

     -- Control outputs to WB stage
     O10, O14 : out std_ulogic;                    
     -- O10: MemtoReg
     -- O14: RegWrite

     -- Control and clock
     C1, clk : in std_ulogic                       
     -- C1: Enable (stall control)
     -- clk: System clock
);
end MEMWB;

architecture MEMWB1 of MEMWB is

-- Internal storage registers (flip-flops)
signal D1, D2 : std_ulogic_vector(31 downto 0) := (others => '0'); 
-- D1: Stored memory data
-- D2: Stored ALU result

signal D3 : std_ulogic_vector(4 downto 0) := (others => '0');    
-- D3: Stored destination register number

signal D10, D14, D17 : std_ulogic := '0';                       
-- D10: Stored MemtoReg
-- D14: Stored RegWrite
-- D17: Enable signal

begin

    -- Enable signal assignment (used for stall)
    D17 <= C1;


    pc : process(clk)
    begin
        -- Rising edge detection + enable condition
        if (clk = '1' and clk'event and D17 = '1') then

            -- Latch data values
            D1 <= I1;        -- Store data read from memory
            D2 <= I2;        -- Store ALU result

            -- Latch destination register
            D3 <= I3;        -- Register index for write-back

            -- Latch control signals
            D10 <= I10;      -- MemtoReg control
            D14 <= I14;      -- RegWrite control
        end if;
    end process;

    --================================================
    -- Outputs: values forwarded to WB stage
    --================================================
    O1  <= D1;   -- Memory data to write-back MUX
    O2  <= D2;   -- ALU result to write-back MUX
    O3  <= D3;   -- Destination register number
    O10 <= D10;  -- MemtoReg control signal
    O14 <= D14;  -- RegWrite control signal

end MEMWB1;
