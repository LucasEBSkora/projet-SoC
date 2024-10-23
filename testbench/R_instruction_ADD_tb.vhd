library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity R_instruction_ADD_tb is end entity R_instruction_ADD_tb;

architecture rtl of R_instruction_ADD_tb is
    component processor
        generic (
            ADDR_WIDTH : natural := 8;
            DATA_WIDTH : natural := 32;
            REG_ADDR_WIDTH : natural := 5;
            PROGRAM_FILE : string
        );
        port (
            clk : in std_logic;
            reset : in std_logic
        );
    end component processor;

    signal clk : std_logic := '0';
begin

    clk <= not clk after 5 ns;
    proc : processor generic map(PROGRAM_FILE => "programs/add_02.hex") port map(clk => clk, reset => '0');

end architecture rtl;