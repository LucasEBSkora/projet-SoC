library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity PC is
    generic (
        ADDR_WIDTH : natural := 16
    );
    port (
        load : in std_logic;
        clk : in std_logic;
        reset : in std_logic;
        addr_in : in natural range 0 to 2 ** ADDR_WIDTH - 1;
        addr_out : out natural range 0 to 2 ** ADDR_WIDTH - 1
    );
end entity PC;

architecture rtl of PC is
    component registerN
        generic (
            WORD_WIDTH : natural := 32
        );
        port (
            data_in : in std_logic_vector(WORD_WIDTH - 1 downto 0);
            data_out : out std_logic_vector(WORD_WIDTH - 1 downto 0);
            write_enable : in std_logic;
            reset : in std_logic;
            clk : in std_logic
        );
    end component;

    signal addr_next : std_logic_vector(ADDR_WIDTH - 1 downto 0) := (others => '0');
    signal addr_current : natural range 0 to 2 ** ADDR_WIDTH - 1 := 0;
    signal data_out : std_logic_vector(ADDR_WIDTH - 1 downto 0) := (others => '0');
begin

    reg : registerN generic map(WORD_WIDTH => ADDR_WIDTH)
    port map(
        data_in => addr_next,
        data_out => data_out, write_enable => '1', reset => reset, clk => clk);

    addr_current <= to_integer(unsigned(data_out));
    addr_out <= addr_current;

    addr_next <= std_logic_vector(to_unsigned(addr_in, ADDR_WIDTH)) when load = '1' else
        std_logic_vector(to_unsigned(addr_current + 4, ADDR_WIDTH));

end architecture rtl;