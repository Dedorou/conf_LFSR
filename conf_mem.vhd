library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;


entity conf_mem is
generic(
bitnes : natural := 9);
port(
clk : in std_logic;
rst : in std_logic;
mem_rst : in std_logic;
en : in std_logic;
cd_in : in std_logic;
reg_alpha : out std_logic_vector(bitnes downto 0);
reg_beta : out std_logic_vector(bitnes downto 1));
end conf_mem;

architecture RTL of conf_mem is

signal temp_alpha_reg : std_logic_vector(bitnes downto 0);
signal temp_beta_reg : std_logic_vector(bitnes downto 1);
signal beta_en : std_logic;
signal flag_feedback : std_logic;
signal flag_en : std_logic;
begin 
shift: process( CLK, RST,mem_rst, EN, cd_in, beta_en,flag_feedback )
begin
	if rst ='1' or mem_rst = '1' then 
		temp_alpha_reg<=(others => '0');
		temp_beta_reg<=(others=>'0');
		flag_feedback<='0';
		beta_en<='0';
	elsif rising_edge(clk) then
		if en ='1'  then
			temp_alpha_reg <= temp_alpha_reg(temp_alpha_reg'high-1 downto temp_alpha_reg'low) & cd_in;
		if beta_en ='1'  then
			temp_beta_reg <= temp_beta_reg(temp_beta_reg'high-1 downto temp_beta_reg'low) & '1';
		else
			temp_beta_reg <= temp_beta_reg;
			beta_en<='0';
		end if;
		beta_en<=flag_feedback and en;
		if flag_en ='1' then
			flag_feedback<='1';
		else 
	   		flag_feedback<=flag_feedback;
		end if;	
		else
			temp_alpha_reg <= temp_alpha_reg;
			beta_en<='0';
		end if;
		
		
	end if;		
flag_en <= (not flag_feedback and cd_in and en);

end process;
reg_alpha<=temp_alpha_reg;
reg_beta<=temp_beta_reg;
end RTL;