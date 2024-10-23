library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity registerN is
    generic (
        WORD_WIDTH : natural := 32;
        INIT_VALUE : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0')
    );
    port (
        data_in : in std_logic_vector(WORD_WIDTH - 1 downto 0);
        data_out : out std_logic_vector(WORD_WIDTH - 1 downto 0);
        write_enable : in std_logic;
        reset : in std_logic;
        clk : in std_logic
    );
end entity registerN;

architecture rtl of registerN is
    signal data : std_logic_vector(WORD_WIDTH - 1 downto 0) := INIT_VALUE;
begin
    data_out <= data;
    process (clk, write_enable, reset)
    begin
        if (reset = '1') then
            data <= (others => '0');
        elsif (rising_edge(clk) and write_enable = '1') then
            data <= data_in;
        end if;
    end process;

end architecture rtl;