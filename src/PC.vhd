library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PC is
port(
    I1  : in  std_ulogic_vector(31 downto 0);  -- Next PC
    O1  : out std_ulogic_vector(31 downto 0);  -- Current PC
    C1  : in  std_ulogic;                       -- PC enable (stall control)
    clk : in  std_ulogic
);
end PC;

architecture PC1 of PC is
signal D1: std_ulogic_vector(31 downto 0) := (others => '0');
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if C1 = '1' then
                D1 <= I1;  -- latch next PC
            end if;
        end if;
    end process;

    O1 <= D1;  -- current PC output
end PC1;
