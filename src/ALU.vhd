

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU is
port(I1, I2: in std_ulogic_vector(31 downto 0);
     C1: in std_ulogic_vector(2 downto 0);
     O1: out std_ulogic_vector(31 downto 0);
     O2: out std_ulogic);
end ALU;

architecture ALU1 of ALU is
    signal D1, D2: signed(31 downto 0) := (others => '0');
    signal D3: std_ulogic_vector(2 downto 0) := (others => '0');
    signal R1: signed(31 downto 0) := (others => '0');
    signal FlagZ: std_ulogic := '0';
    signal shift_amount: integer range 0 to 31;
    
    -- Temporary signals for shift operations
    signal temp_shift_left: unsigned(31 downto 0);
    signal temp_shift_right: unsigned(31 downto 0);
begin
    D1 <= signed(I1);
    D2 <= signed(I2);
    D3 <= C1;
    
    -- Safe shift amount (use only lower 5 bits, clamp to 0-31 range)
    shift_amount <= to_integer(unsigned(I2(4 downto 0))) when to_integer(unsigned(I2(4 downto 0))) < 32 
                    else 0;
    
    -- Pre-calculate logical shifts on unsigned values
    temp_shift_left <= shift_left(unsigned(D1), shift_amount);
    temp_shift_right <= shift_right(unsigned(D1), shift_amount);
    
    -- ALU operations
    with D3 select R1 <= 
        D1 + D2                              when "000",  -- Add
        D1 - D2                              when "001",  -- Subtract
        D1 and D2                            when "010",  -- AND
        D1 or D2                             when "011",  -- OR
        D1 nor D2                            when "100",  -- NOR
        signed(std_ulogic_vector(temp_shift_left))  when "101",  -- Logical left shift (FIXED)
        signed(std_ulogic_vector(temp_shift_right)) when "110",  -- Logical right shift (FIXED)
        D2 sll 16                            when "111",  -- Load upper immediate (*2^16)
        to_signed(-1, 32)                    when others; -- Error condition
    
    -- Zero flag (used for branch equal)
    -- For BEQ, the ALU performs subtraction and sets zero flag if result is zero
    FlagZ <= '1' when R1 = to_signed(0, 32) else '0';
    
    O1 <= std_ulogic_vector(R1);
    O2 <= FlagZ;
    
end ALU1;