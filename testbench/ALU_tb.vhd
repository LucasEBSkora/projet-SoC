library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ALU_tb is
end entity ALU_tb;

architecture rtl of ALU_tb is
    constant WORD_WIDTH : natural := 32;
    subtype word is std_logic_vector(WORD_WIDTH - 1 downto 0);

    subtype alu_op_sel is unsigned(3 downto 0);

    constant SEL_ADD : alu_op_sel := "0000";
    constant SEL_SUB : alu_op_sel := "1000";
    constant SEL_SLL : alu_op_sel := "0001";
    constant SEL_SLT : alu_op_sel := "0010";
    constant SEL_SLTU : alu_op_sel := "0011";
    constant SEL_XOR : alu_op_sel := "0100";
    constant SEL_SRL : alu_op_sel := "0101";
    constant SEL_SRA : alu_op_sel := "1101";
    constant SEL_OR : alu_op_sel := "0110";
    constant SEL_AND : alu_op_sel := "0111";

    component ALU
        generic (
            WORD_WIDTH : natural := 32
        );
        port (
            opA : in std_logic_vector(WORD_WIDTH - 1 downto 0);
            opB : in std_logic_vector(WORD_WIDTH - 1 downto 0);
            res : out std_logic_vector(WORD_WIDTH - 1 downto 0);
            aluOp : in unsigned(3 downto 0)
        );
    end component ALU;

    signal opA : word := (others => '0');
    signal opB : word := (others => '0');
    signal res : word;
    signal aluOp : alu_op_sel := "0000";

begin

    uut : ALU generic map(WORD_WIDTH => WORD_WIDTH) port map(opA => opA, opB => opB, res => res, aluOp => aluOp);

end architecture rtl;