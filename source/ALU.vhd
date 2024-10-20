library IEEE;
library WORK;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use WORK.constants.all;

entity ALU is
    generic (
        WORD_WIDTH : natural := 32
    );
    port (
        opA : in std_logic_vector(WORD_WIDTH - 1 downto 0);
        opB : in std_logic_vector(WORD_WIDTH - 1 downto 0);
        res : out std_logic_vector(WORD_WIDTH - 1 downto 0);
        aluOp : in unsigned(3 downto 0)
    );
end entity ALU;

architecture rtl of ALU is

    signal shift : natural range 0 to 15;
    signal res_sll : std_logic_vector(WORD_WIDTH - 1 downto 0);
    signal res_slt : std_logic_vector(WORD_WIDTH - 1 downto 0);
    signal res_sltu : std_logic_vector(WORD_WIDTH - 1 downto 0);
    signal res_srl : std_logic_vector(WORD_WIDTH - 1 downto 0);
    signal res_sra : std_logic_vector(WORD_WIDTH - 1 downto 0);
begin

    shift <= to_integer(unsigned(opB(4 downto 0)));

    res_sll <= opA(WORD_WIDTH - 1 - unsigned(shift) downto 0) & (others => '0');
    res_slt <= '1' when signed(opA) < signed(opB) else
        '0';
    res_sltu <= '1' when unsigned(opA) < unsigned(opB) else
        '0';
    res_srl <= (others => '0') & opA(WORD_WIDTH - 1 downto shift);
    res_sra <= (others => '0') & opA(WORD_WIDTH - 1 downto shift);

    with aluOp select res <=
        signed(opA) + signed(opB) when SEL_ADD,
        opA - opB when SEL_SUB,
        res_sll when SEL_SLL,
        res_slt when SEL_SLT,
        res_sltu when SEL_SLTU,
        opA xor opB when SEL_XOR,
        res_srl when SEL_SRL,
        res_sra when SEL_SRA,
        opA or opB when SEL_OR,
        opA and opB when SEL_AND,
        (others => '0') when others;

end architecture rtl;