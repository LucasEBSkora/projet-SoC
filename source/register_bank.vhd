library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity register_bank is
    generic (
        WORD_WIDTH : natural := 32;
        ADDR_WIDTH : natural := 5
    );
    port (
        clk : in std_logic;
        write_enable : in std_logic;
        RW : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
        RA : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
        RB : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
        busW : in std_logic_vector(WORD_WIDTH - 1 downto 0);
        busA : out std_logic_vector(WORD_WIDTH - 1 downto 0);
        busB : out std_logic_vector(WORD_WIDTH - 1 downto 0)
    );
end entity;

architecture rtl of register_bank is
    component registerN
        generic (
            WORD_WIDTH : natural := 32
        );
        port (
            data_in : in std_logic_vector(WORD_WIDTH - 1 downto 0);
            data_out : out std_logic_vector(WORD_WIDTH - 1 downto 0);
            write_enable : in std_logic;
            clk : in std_logic
        );
    end component;
    type vector_array is array (natural range <>) of std_logic_vector(WORD_WIDTH - 1 downto 0);

    signal data_outs : vector_array(2**ADDR_WIDTH - 1 downto 0);
    signal write_enables : std_logic_vector(2 ** ADDR_WIDTH - 1 downto 1);
begin
    data_outs(0) <= (others => '0');

    
        registers :
    for i in 1 to 2**ADDR_WIDTH - 1 generate
        regI : registerN generic map(WORD_WIDTH => WORD_WIDTH)
        port map(data_in => busW, data_out => data_outs(i), write_enable => write_enables(i), clk => clk);
        write_enables(i) <= write_enable when RW = std_logic_vector(to_unsigned(i, ADDR_WIDTH)) else '0';
    end generate;

    busA <= data_outs(to_integer(unsigned(RA)));
    busB <= data_outs(to_integer(unsigned(RB)));
end architecture rtl;