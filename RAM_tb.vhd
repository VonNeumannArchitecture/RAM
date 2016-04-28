----------------------------------------------------------------------------------
-- Company: HS-Mannheim    
-- Engineer: MW and JA
-- 
-- Create Date: 26.04.2016 12:59:13
-- Design Name: 
-- Module Name: RAM_tb - Behavioral
-- Project Name: Von Neumann Rechner in VHDL
-- Target Devices:  Siumlate on 35µ Process
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
use IEEE.STD_LOGIC_TEXTIO.ALL;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

library STD;
use STD.TEXTIO.ALL;

entity RAM_tb is
    Generic (   addrwide  : natural := 8; -- 2^n -> 256 -> n = 8 
                datawide  : natural := 8);
--  Port ( );
end RAM_tb;

architecture Behavioral of RAM_tb is

    component RAM is
        Generic (   addrwide  : natural; 
                    datawide  : natural);
         Port ( clk : in STD_LOGIC;  -- RAM clock
                en : in STD_LOGIC;   -- enable / chip select
                rw : in STD_LOGIC;   -- write to memory =0 / read from memory=1
                addrbus : in STD_LOGIC_VECTOR;
                databus : inout STD_LOGIC_VECTOR);
    end component;

    signal clk, clk_en  : std_logic := '0';
    signal ram_clk , global_clk : std_logic; 

    signal en , rw : std_logic;
    signal addrbus : std_logic_vector (addrwide-1 downto 0); 
    signal databus : std_logic_vector (datawide-1 downto 0);   
   
    type init_state is (reset, fill_mem_1, fill_mem_2, fill_mem_3, fill_mem_4, fill_mem_5, ready, run); 
    signal init : init_state := reset;

begin
    ram_1 : RAM 
        generic map( 
            addrwide  => addrwide,
            datawide  => datawide
        )
        port map(
            clk => ram_clk, 
            en => en, 
            rw => rw,
            addrbus => addrbus,
            databus => databus 
        );
 
    clk   <= not clk  after 10 ns;  -- 100 MHz
    ram_clk <= clk;
    global_clk <= clk and clk_en; -- enable if initialization is done 
    -- Test Write/Read  
    --en <= '0', '1' after 250ns, '0' after 350ns, '1' after 650ns, '0' after 750ns;
    --rw <= '0', '1' after 650ns;
    --addrbus <= (others => 'Z');
    --databus <=  "ZZZZZZZZ", "00000011" after 250ns, "ZZZZZZZZ" after 350ns;
  
 
    test_proc: process (clk) is
        file read_file: text open read_mode is "i_file.txt";
            
        variable read_line : line;
        variable read_char : character; 
        variable read_vec : std_logic_vector(datawide-1 downto 0); 
        variable read_end : boolean;
            
    begin
        if falling_edge(clk) then 
            case init is
                when reset =>   -- set dfoult values 
                    addrbus <= (others => '0');
                    databus <= (others => '0'); 
                    en <= '0';
                    rw <= '0';
                    init <= fill_mem_1;
                    
                when fill_mem_1 =>  -- read new line
                    readline(read_file, read_line);
                    init <= fill_mem_2;
                    
                when fill_mem_2 =>  -- read first char    
                    read(read_line, read_char, read_end);
                    if read_char = '0' then -- possible hex number (first part)
                        init <= fill_mem_3;
                    elsif read_char = '/' then -- Comment
                        read_end := false;
                    end if; 
                    if not read_end then -- line end or comment
                        if endfile(read_file) then -- file end
                            init <= ready;
                        else 
                            init <= fill_mem_1; -- goto read new line
                        end if; 
                    end if;

                when fill_mem_3 =>  -- read secound char 
                    read(read_line, read_char);
                    if read_char = 'x' then -- possible hex number (secound part)
                        init <= fill_mem_4; -- goto read hex
                    else 
                        init <= fill_mem_2;
                    end if;    
                              
                when fill_mem_4 =>  -- read hex number
                    hread(read_line, read_vec);
                    databus <= read_vec;
                    en <= '1';  -- write to memory
                    init <= fill_mem_5; 
                                   
                when fill_mem_5 =>  -- update counter
                    en <= '0';
                    addrbus <= addrbus + 1;
                    init <= fill_mem_2; 
                    if addrbus = (addrbus'range => '1') then 
                        init <= ready;
                        Report "Memmory full!" severity warning;
                    end if; 
                    
                when ready =>   -- memory init done / reset control signals
                     en <= 'Z';
                     rw <= 'Z';
                     addrbus <= (others => 'Z');
                     databus <= (others => 'Z');
                     clk_en <= '1'; 
                     init <= run;
                     
                when run =>     -- run main simmulation
                    -- Init Done
                    -- simulation code for Running CPU
            end case; 
        end if; 
    end process test_proc;
    
end Behavioral;
