library IEEE;
library WORK;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use WORK.constants.all;

entity controller_tb is
end entity controller_tb;

architecture rtl of controller_tb is
    subtype instruction is std_logic_vector(31 downto 0);
    subtype register_addr is natural range 0 to 31;

    component controller
        port (
            instr : in std_logic_vector(31 downto 0);
            reg_we : out std_logic;
            pc_load : out std_logic;
            ri_sel : out std_logic;
            alu_op : out unsigned(3 downto 0);
            reg_dest : out natural range 0 to 31;
            reg_s1 : out natural range 0 to 31;
            reg_s2 : out natural range 0 to 31
        );
    end component controller;

    signal instr : instruction := (others => '0');
    signal reg_we : std_logic;
    signal pc_load : std_logic;
    signal ri_sel : std_logic;
    signal alu_op : alu_op_sel;
    signal reg_dest : register_addr;
    signal reg_s1 : register_addr;
    signal reg_s2 : register_addr;

    signal success : boolean := true;
begin

    uut : controller port map(
        instr => instr, reg_we => reg_we, pc_load => pc_load, ri_sel => ri_sel, alu_op => alu_op,
        reg_dest => reg_dest, reg_s1 => reg_s1, reg_s2 => reg_s2
    );

    process

        procedure check(value : boolean; message : string := "") is begin
            if not value then
                success <= false;
                assert false report message severity error;
            end if;
        end procedure;

        procedure check_instruction(new_instruction : instruction; expected_op : alu_op_sel; rd : register_addr; rs1 : register_addr; rs2 : register_addr; expected_ri : std_logic; instruction_name : string) is begin
            instr <= new_instruction;

            wait for 1 ns;

            check(alu_op = expected_op, "ALU OP should be " & integer'image(to_integer(unsigned(expected_op))) & ", is " & integer'image(to_integer(unsigned(alu_op))) & " for instruction " & instruction_name);
            check(reg_dest = rd, "destination register should be " & integer'image(rd) & ", is " & integer'image(reg_dest) & " for instruction " & instruction_name);
            check(reg_s1 = rs1, "source register 1 should be " & integer'image(rs1) & ", is " & integer'image(reg_s1) & " for instruction " & instruction_name);
            check(reg_s2 = rs2, "source register 2 should be " & integer'image(rs2) & ", is " & integer'image(reg_s2) & " for instruction " & instruction_name);
            check(expected_ri = ri_sel, "RI select should be " & std_logic'image(expected_ri) & ", is " & std_logic'image(ri_sel) & " for instruction " & instruction_name);
        end procedure;

        constant INSTRUCTION_R_ADD : instruction := B"0000000_11111_00000_000_01010_0110011";
        constant INSTRUCTION_R_SUB : instruction := B"0100000_01010_11110_000_00001_0110011";
        constant INSTRUCTION_R_SLL : instruction := B"0000000_01011_11101_001_00010_0110011";
        constant INSTRUCTION_R_SLT : instruction := B"0000000_01100_11100_010_00011_0110011";
        constant INSTRUCTION_R_SLTU : instruction := B"0000000_01101_11011_011_00100_0110011";
        constant INSTRUCTION_R_XOR : instruction := B"0000000_01110_11010_100_00101_0110011";
        constant INSTRUCTION_R_SRL : instruction := B"0000000_01111_11001_101_00110_0110011";
        constant INSTRUCTION_R_SRA : instruction := B"0100000_10000_11000_101_00111_0110011";
        constant INSTRUCTION_R_OR : instruction := B"0000000_10001_10111_110_01000_0110011";
        constant INSTRUCTION_R_AND : instruction := B"0000000_10010_10110_111_01001_0110011";

        constant INSTRUCTION_I_ADD : instruction := B"000000011111_00000_000_01010_0010011";
        constant INSTRUCTION_I_SLL : instruction := B"0000000_01011_11101_001_00010_0010011";
        constant INSTRUCTION_I_SLT : instruction := B"000000001100_11100_010_00011_0010011";
        constant INSTRUCTION_I_SLTU : instruction := B"000000001101_11011_011_00100_0010011";
        constant INSTRUCTION_I_XOR : instruction := B"000000001110_11010_100_00101_0010011";
        constant INSTRUCTION_I_SRL : instruction := B"0000000_01111_11001_101_00110_0010011";
        constant INSTRUCTION_I_SRA : instruction := B"0100000_10000_11000_101_00111_0010011";
        constant INSTRUCTION_I_OR : instruction := B"000000010001_10111_110_01000_0010011";
        constant INSTRUCTION_I_AND : instruction := B"000000010010_10110_111_01001_0010011";
    begin

        wait for 1 ns;

        check(reg_we = '1', "register write enable not set!");
        check(pc_load = '0', "PC load set incorrectly!");

        check_instruction(INSTRUCTION_R_ADD, SEL_ADD, 10, 00, 31, '0', "INSTRUCTION_R_ADD");
        check_instruction(INSTRUCTION_R_SUB, SEL_SUB, 01, 30, 10, '0', "INSTRUCTION_R_SUB");
        check_instruction(INSTRUCTION_R_SLL, SEL_SLL, 02, 29, 11, '0', "INSTRUCTION_R_SLL");
        check_instruction(INSTRUCTION_R_SLT, SEL_SLT, 03, 28, 12, '0', "INSTRUCTION_R_SLT");
        check_instruction(INSTRUCTION_R_SLTU, SEL_SLTU, 04, 27, 13, '0', "INSTRUCTION_R_SLTU");
        check_instruction(INSTRUCTION_R_XOR, SEL_XOR, 05, 26, 14, '0', "INSTRUCTION_R_XOR");
        check_instruction(INSTRUCTION_R_SRL, SEL_SRL, 06, 25, 15, '0', "INSTRUCTION_R_SRL");
        check_instruction(INSTRUCTION_R_SRA, SEL_SRA, 07, 24, 16, '0', "INSTRUCTION_R_SRA");
        check_instruction(INSTRUCTION_R_OR, SEL_OR, 08, 23, 17, '0', "INSTRUCTION_R_OR");
        check_instruction(INSTRUCTION_R_AND, SEL_AND, 09, 22, 18, '0', "INSTRUCTION_R_AND");

        check_instruction(INSTRUCTION_I_ADD, SEL_ADD, 10, 00, 31, '1', "INSTRUCTION_I_ADD");
        check_instruction(INSTRUCTION_I_SLL, SEL_SLL, 02, 29, 11, '1', "INSTRUCTION_I_SLL");
        check_instruction(INSTRUCTION_I_SLT, SEL_SLT, 03, 28, 12, '1', "INSTRUCTION_I_SLT");
        check_instruction(INSTRUCTION_I_SLTU, SEL_SLTU, 04, 27, 13, '1', "INSTRUCTION_I_SLTU");
        check_instruction(INSTRUCTION_I_XOR, SEL_XOR, 05, 26, 14, '1', "INSTRUCTION_I_XOR");
        check_instruction(INSTRUCTION_I_SRL, SEL_SRL, 06, 25, 15, '1', "INSTRUCTION_I_SRL");
        check_instruction(INSTRUCTION_I_SRA, SEL_SRA, 07, 24, 16, '1', "INSTRUCTION_I_SRA");
        check_instruction(INSTRUCTION_I_OR, SEL_OR, 08, 23, 17, '1', "INSTRUCTION_I_OR");
        check_instruction(INSTRUCTION_I_AND, SEL_AND, 09, 22, 18, '1', "INSTRUCTION_I_AND");
        wait for 1 ns;

        if success then
            report "testbench PC succesful!";
        else
            report "testbench PC failed!";
        end if;
        wait;
    end process;
end architecture rtl;