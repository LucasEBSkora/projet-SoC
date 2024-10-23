library IEEE;
library WORK;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package constants is
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
    
    subtype opcode is std_logic_vector(6 downto 0);
    constant OPCODE_R : opcode := B"0110011";
    constant OPCODE_I : opcode := B"0010011";
    
    
end package constants;
