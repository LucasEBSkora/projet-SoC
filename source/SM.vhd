library IEEE;
library WORK;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use WORK.constants.all;

entity SM is
    port (
        current_data : in std_logic_vector(31 downto 0);
        new_data : in std_logic_vector(31 downto 0);
        position : in std_logic_vector(1 downto 0);
        funct : in load_sel;
        result : out std_logic_vector(31 downto 0)
    );
end entity SM;

architecture rtl of SM is

    alias selected_half : std_logic_vector(15 downto 0) is new_data(15 downto 0);
    alias selected_byte : std_logic_vector(7 downto 0) is new_data(7 downto 0);

    signal word_replace_half : std_logic_vector(31 downto 0);
    signal word_replace_byte : std_logic_vector(31 downto 0);
begin

    with position select word_replace_half <=
        current_data(31 downto 16) & selected_half when "00",
        selected_half & current_data(15 downto 0) when "10",
        current_data when others;

    with position select word_replace_byte <=
        current_data(31 downto 8) & selected_byte when "00",
        current_data(31 downto 16) & selected_byte & current_data(7 downto 0) when "01",
        current_data(31 downto 24) & selected_byte & current_data(15 downto 0) when "10",
        selected_byte & current_data(23 downto 0) when "11",
        current_data when others;

    with funct select result <=
        word_replace_byte when SEL_LSB,
        word_replace_half when SEL_LSH,
        new_data when SEL_LSW,
        current_data when others;

end architecture rtl;