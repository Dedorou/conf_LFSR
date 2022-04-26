library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

entity conf_LFSR is 
generic(
	BITNES : natural := 10
);
port(
	clk, rst : in std_logic;
	rst_memory : in std_logic;
	memory_input : in std_logic;
	memory_enable : in std_logic;
	shift_input : in natural range 0 to bitnes;
	shift_input_enable : in std_logic;
	shift_enable : in std_logic;
	LFSR_enable : in std_logic;
	LFSR_input_enable : in std_logic;
	LFSR_input : in std_logic;
	seed : in std_logic_vector(BITNES-1 downto 0);
	outputLFSR : out std_logic_vector(BITNES downto 1)

);
end conf_LFSR;

architecture RTL of conf_LFSR is

signal LFSR : std_logic_vector(BITNES-1 downto 0);
signal temp_reg_alpha : std_logic_vector (BITNES downto 0);
signal temp_reg_beta : std_logic_vector (BITNES downto 1);
signal shift : natural range 0 to bitnes;
signal LFSR_shift_in : std_logic;
signal mem_rst : std_logic;

constant zeros : std_logic_vector(bitnes downto 1) := (others=>'0');

component conf_mem is
generic(
bitnes : natural := bitnes);
port(
clk : in std_logic;
rst : in std_logic;
mem_rst : in std_logic;
en : in std_logic;
cd_in : in std_logic;
reg_alpha : out std_logic_vector(bitnes downto 0);
reg_beta : out std_logic_vector(bitnes downto 1));
end component;

component shift_reg is
generic(
bitnes : natural := bitnes;
size : natural);
port(
clk : in std_logic;
rst : in std_logic;
en : in std_logic;
input_enable : in std_logic;
input : in natural range 0 to bitnes;
shift : out natural range 0 to bitnes);
end component;

begin


mem_reg : conf_mem generic map(
bitnes => bitnes)
port map(
clk =>clk,
rst =>rst,
mem_rst => mem_rst,
en =>memory_enable,
cd_in =>memory_input,
reg_alpha =>temp_reg_alpha,
reg_beta => temp_reg_beta );

shifts : shift_reg generic map(
bitnes=> bitnes,
size=>4)
port map (
clk =>clk,
rst =>rst,
en =>shift_enable,
input_enable => shift_input_enable,
input => shift_input,
shift => shift);

LFSR_module: process(clk)
variable LFSR_output : std_logic_vector(BITNES-1 downto 0);
begin
if(rising_edge(clk)) then
    if(rst = '1') then
        LFSR_output := (others => '0');
    else
		if LFSR_enable = '1' then
		      for k in 0 to bitnes loop
		          exit when k =(shift-1);
	   		      LFSR_output := LFSR_output(BITNES-2 downto 0) & LFSR_shift_in;
	   	       end loop;
	   	       if LFSR_output = zeros then
                  LFSR_output := seed;
               end if;
		elsif LFSR_input_enable ='1' then
			LFSR_output := LFSR_output(BITNES-2 downto 0) & LFSR_input;
		else
			LFSR_output :=LFSR_output;
		end if;
	end if;
end if;
	outputLFSR <= LFSR_output;
	LFSR <= LFSR_output;
end process;

feedback : process(LFSR)
variable tmp :std_logic;
begin
tmp := LFSR(bitnes-1);
for i in BITNES-1 downto 0 loop
    tmp := (tmp and temp_reg_beta(i+1)) xor (temp_reg_alpha(i+1) and LFSR(i));
end loop;
tmp:=tmp xor temp_reg_alpha(0);
LFSR_shift_in <= tmp;	
end process;

end RTL;