

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity REG is
port(I1, I2, I3: in std_ulogic_vector(4 downto 0);
     I4: in std_ulogic_vector(31 downto 0);
     C1: in std_ulogic;
     CLK: in std_ulogic;  -- Clock input for synchronous write
     O1, O2: out std_ulogic_vector(31 downto 0));
end REG;

architecture REG1 of REG is
type REGISTERFILE is array (0 to 31) of std_ulogic_vector(31 downto 0);
signal M1: REGISTERFILE := (others => (others => '0'));
signal D1, D2, D3: std_ulogic_vector(4 downto 0) := (others => '0');
signal D4: std_ulogic_vector(31 downto 0) := (others => '0');
signal D5: std_ulogic := '0';
signal R1, R2: std_ulogic_vector(31 downto 0) := (others => '0');
begin

    D1 <= I1; --Read register 1  
    D2 <= I2; --Read register 2
    D3 <= I3; --Write register
    D4 <= I4; --Write data
    D5 <= C1; --RegWrite enable
    
    -- Combinational read (for faster forwarding)
    R1 <= M1(to_integer(unsigned(D1)));
    R2 <= M1(to_integer(unsigned(D2)));
    
    -- Synchronous write on rising edge
    write_proc: process(CLK)
    begin
        if rising_edge(CLK) then
            -- Write only if RegWrite enabled, not R0, and not error value
            if D5 = '1' and D3 /= "00000" and D4 /= std_ulogic_vector(to_signed(-1, 32)) then
                M1(to_integer(unsigned(D3))) <= D4;
            end if;
        end if;
    end process;

    O1 <= R1;
    O2 <= R2;
end REG1;