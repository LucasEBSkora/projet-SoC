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

    signal opA_signed, opB_signed : signed(WORD_WIDTH - 1 downto 0) := (others => '0');
    signal opA_unsigned, opB_unsigned : unsigned(WORD_WIDTH - 1 downto 0) := (others => '0');

    signal shift : natural range 0 to 31 := 0;
    signal res_sll, res_slt, res_sltu, res_srl, res_sra : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
begin

    opA_signed <= signed(opA);
    opB_signed <= signed(opB);

    opA_unsigned <= unsigned(opA);
    opB_unsigned <= unsigned(opB);

    shift <= to_integer(unsigned(opB(4 downto 0)));

    res_sll <= opA((WORD_WIDTH - 1 - shift) downto 0) & (shift - 1 downto 0 => '0');
    res_slt <= (WORD_WIDTH - 1 downto 1 => '0') & '1' when opA_signed < opB_signed else
        (WORD_WIDTH - 1 downto 1 => '0') & '0';
    res_sltu <= (WORD_WIDTH - 1 downto 1 => '0') & '1' when opA_unsigned < opB_unsigned else
        (WORD_WIDTH - 1 downto 1 => '0') & '0';
    res_srl <= (shift - 1 downto 0 => '0') & opA(WORD_WIDTH - 1 downto shift);
    res_sra <= (shift - 1 downto 0 => opA(WORD_WIDTH - 1)) & opA(WORD_WIDTH - 1 downto shift);

    with aluOp select res <=
        std_logic_vector(opA_signed + opB_signed) when SEL_ADD,
        std_logic_vector(opA_signed - opB_signed) when SEL_SUB,
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