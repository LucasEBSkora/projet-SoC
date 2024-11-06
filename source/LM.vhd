library IEEE;
library WORK;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use WORK.constants.all;

entity LM is
    port (
        data : in std_logic_vector(31 downto 0);
        position : in std_logic_vector(1 downto 0);
        funct : in load_sel;
        result : out std_logic_vector(31 downto 0)
    );
end entity LM;

architecture rtl of LM is
    signal selected_byte : std_logic_vector(7 downto 0);
    signal selected_half : std_logic_vector(15 downto 0);
begin

    with position select selected_byte <=
        data(7 downto 0) when "00",
        data(15 downto 8) when "01",
        data(23 downto 16) when "10",
        data(31 downto 24) when "11",
        (others => '0') when others;

    with position select selected_half <=
        data(15 downto 0) when "00",
        data(31 downto 16) when "10",
        (others => '0') when others;

    with funct select result <=
        (31 downto 8 => selected_byte(7)) & selected_byte when SEL_LB,
        (31 downto 16 => selected_half(15)) & selected_half when SEL_LH,
        data when SEL_LW,
        (31 downto 8 => '0') & selected_byte when SEL_LBU,
        (31 downto 16 => '0') & selected_half when SEL_LHU,
        data when others;

end architecture rtl;