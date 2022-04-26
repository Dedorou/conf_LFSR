library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity shift_reg is
generic(
bitnes : natural := 8;
size : natural:=4);
 Port (
clk : in std_logic;
rst : in std_logic;
en : in std_logic;
input_enable : in std_logic;
input : in natural range 0 to bitnes;
shift : out natural range 0 to bitnes);
end shift_reg;

architecture rtl of shift_reg is
type nat_array is array (size-1 downto 0) of natural range 0 to bitnes;
signal nat_array_temp : nat_array; 
signal clk_shift : std_logic:='1';
begin

process(clk, rst,en,input_enable,input)

variable temp : natural range 0 to bitnes;
begin
if(rising_edge(clk)) then
    if rst = '1' then
        for k in size-1 downto 0 loop
            nat_array_temp(k)<=1;
        end loop;
    elsif input_enable ='1' then
        for k in size-1 downto 1 loop
            nat_array_temp(k)<=nat_array_temp(k-1);
        end loop;
        nat_array_temp(0)<=input;  
    elsif en = '1' then
        temp:=nat_array_temp(size-1);
        for k in size-1 downto 1 loop
            nat_array_temp(k)<=nat_array_temp(k-1);
        end loop;
        nat_array_temp(0)<=temp;
    else
        nat_array_temp <= nat_array_temp;
    end if;
    shift<=nat_array_temp(size-1);
end if;
end process;
end rtl;
