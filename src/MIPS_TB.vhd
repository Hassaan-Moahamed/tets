-- ============================================================
-- MIPS Testbench
-- ============================================================
library ieee;
use ieee.std_logic_1164.all;

entity tb_MIPS is  
end entity tb_MIPS;

architecture sim of tb_MIPS is
    signal clk    : std_ulogic := '0';
    signal reset  : std_ulogic := '1';
    constant clk_period : time := 100 ns;
  
    component MIPS_TOP is  
        port (
            clk   : in std_ulogic;
            reset : in std_ulogic
        );
    end component;
  
begin
    UUT: MIPS_TOP  
        port map (
            clk   => clk,
            reset => reset
        );
  
    clock_process : process
    begin
        while true loop
            clk <= '0';
            wait for clk_period/2;
            clk <= '1';
            wait for clk_period/2;
        end loop;
    end process;    
  
    reset_process : process
    begin
        reset <= '1';
        wait for 50 ns;
        reset <= '0';
        wait;
    end process;
    
end sim;