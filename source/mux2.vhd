library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mux2 is
    generic (
        WORD_WIDTH : natural := 32
    );
    port (
        sel : in std_logic;
        in1 : in std_logic_vector(WORD_WIDTH - 1 downto 0);
        in2 : in std_logic_vector(WORD_WIDTH - 1 downto 0);
        qo : out std_logic_vector(WORD_WIDTH - 1 downto 0)
    );
end entity mux2;

architecture rtl of mux2 is
begin

    with sel select qo <=
        in1 when '0',
        in2 when '1',
        in1 when others;

end architecture rtl;