----------------------------------------------------------------------------------
-- Company: HS-Mannheim
-- Engineer: MW and JA
-- 
-- Create Date: 19.04.2016 20:33:22
-- Design Name: 
-- Module Name: RAM - Behavioral
-- Project Name: Von Neumann Rechner in VHDL
-- Target Devices: Siumlate on 35µ Process
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 

-- source: http://www.lothar-miller.de/s9y/archives/20-RAM.html#extended
-- source: https://www.doulos.com/knowhow/vhdl_designers_guide/models/simple_ram_model/
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;



entity RAM is
    Generic (
          addrwide  : natural := 16; -- 2^n -> 256 -> n = 8 
          datawide  : natural := 8
          );
    Port ( clk : in STD_LOGIC;  -- RAM clock
           en : in STD_LOGIC;   -- enable / chip select
           rw : in STD_LOGIC;   -- write to memory = 0 / read from memory = 1
           addrbus : in STD_LOGIC_VECTOR (addrwide-1 downto 0);
           databus : inout STD_LOGIC_VECTOR (datawide-1 downto 0));
end RAM;

architecture Behavioral of RAM is
    type memory_type is array(0 to (2**addrwide)-1) of STD_LOGIC_VECTOR(datawide-1 downto 0);
    signal memory : memory_type; 

begin

    ram_pro: process (clk) is
    begin
        if rising_edge(clk) then 
            databus <= (others => 'Z');
            if en = '1' then
                if rw = '1' then -- read from memory
                    databus <= memory(to_integer(unsigned(addrbus)));                  
                else    -- write to memory
                    memory(to_integer(unsigned(addrbus))) <= databus; 
                end if; 
            end if; 
        end if; 
    end process ram_pro;
    
end Behavioral;
