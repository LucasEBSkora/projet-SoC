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
        reset : in std_logic;
        write_enable : in std_logic;
        RW : in natural range 0 to 2 ** ADDR_WIDTH - 1;
        RA : in natural range 0 to 2 ** ADDR_WIDTH - 1;
        RB : in natural range 0 to 2 ** ADDR_WIDTH - 1;
        busW : in std_logic_vector(WORD_WIDTH - 1 downto 0);
        busA : out std_logic_vector(WORD_WIDTH - 1 downto 0);
        busB : out std_logic_vector(WORD_WIDTH - 1 downto 0)
    );
end entity;

architecture rtl of register_bank is
    component registerN
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
    end component;
    constant MAX_ADDR : natural := 2 ** ADDR_WIDTH - 1;

    type vector_array is array (natural range <>) of std_logic_vector(WORD_WIDTH - 1 downto 0);

    signal data_outs : vector_array(MAX_ADDR downto 0);
    signal write_enables : std_logic_vector(MAX_ADDR downto 1);
begin
    -- r0
    data_outs(0) <= (others => '0');
    -- r1 to rMAX
    registers :
    for i in 1 to MAX_ADDR generate
        regI : registerN generic map(WORD_WIDTH => WORD_WIDTH, INIT_VALUE => std_logic_vector(to_unsigned(i, WORD_WIDTH)))
        port map(data_in => busW, data_out => data_outs(i), write_enable => write_enables(i), reset => reset, clk => clk);

        write_enables(i) <= write_enable when RW = i else
        '0';
    end generate;

    busA <= data_outs(RA);
    busB <= data_outs(RB);
end architecture rtl;