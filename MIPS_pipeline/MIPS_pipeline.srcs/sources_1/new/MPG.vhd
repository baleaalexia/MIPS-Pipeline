----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/02/2026 01:38:10 PM
-- Design Name: 
-- Module Name: MPG - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MPG is
  Port ( btn : in std_logic_vector(4 downto 0);
         clk : in std_logic;
         rst: out std_logic;
         enable: out std_logic
        );
end MPG;

architecture Behavioral of MPG is
       signal cnt : std_logic_vector(15 downto 0) := (others => '0');
       signal t : std_logic;
       signal q1, q2, q3 : std_logic;
       signal q11, q22, q33: std_logic;
begin

process(clk)
begin
    if rising_edge(clk) then
        cnt <= cnt + 1;
    end if;
end process;

t <= '1' when cnt = x"FFFF" else '0';

process(clk)
begin
    if rising_edge(clk) then
        if t = '1' then
            q1 <= btn(0);
            q11 <= btn(1);
        end if;
    end if;
end process;

process(clk)
begin
    if rising_edge(clk)then
        q2 <= q1;
        q22 <= q11;
        q3 <= q2;
        q33 <= q22;
    end if;
end process;

enable <= q2 and not q3;
rst <= q22 and not q33;
 
end Behavioral;
