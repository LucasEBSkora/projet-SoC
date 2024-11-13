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
            ram_we : out std_logic;
            pc_load : out std_logic;
            ri_sel : out std_logic;
            busw_sel : out std_logic;
            alu_op : out unsigned(3 downto 0);
            reg_dest : out natural range 0 to 31;
            reg_s1 : out natural range 0 to 31;
            reg_s2 : out natural range 0 to 31
        );
    end component controller;

    signal instr : instruction := (others => '0');
    signal reg_we : std_logic;
    signal ram_we : std_logic;
    signal pc_load : std_logic;
    signal ri_sel : std_logic;
    signal busw_sel : std_logic;
    signal alu_op : alu_op_sel;
    signal reg_dest : register_addr;
    signal reg_s1 : register_addr;
    signal reg_s2 : register_addr;

    signal success : boolean := true;
begin

    uut : controller port map(
        instr => instr, reg_we => reg_we, ram_we => ram_we, pc_load => pc_load, ri_sel => ri_sel, busw_sel => busw_sel, alu_op => alu_op,
        reg_dest => reg_dest, reg_s1 => reg_s1, reg_s2 => reg_s2
    );

    process

        procedure check(value : boolean; message : string := "") is begin
            if not value then
                success <= false;
                assert false report message severity error;
            end if;
        end procedure;

        procedure check_instruction_r(new_instruction : instruction; expected_op : alu_op_sel; rd : register_addr; rs1 : register_addr; rs2 : register_addr;instruction_name : string) is begin
            instr <= new_instruction;

            wait for 1 ns;

            check(alu_op = expected_op, "ALU OP should be " & integer'image(to_integer(unsigned(expected_op))) & ", is " & integer'image(to_integer(unsigned(alu_op))) & " for instruction " & instruction_name);
            check(reg_dest = rd, "destination register should be " & integer'image(rd) & ", is " & integer'image(reg_dest) & " for instruction " & instruction_name);
            check(reg_s1 = rs1, "source register 1 should be " & integer'image(rs1) & ", is " & integer'image(reg_s1) & " for instruction " & instruction_name);
            check(reg_s2 = rs2, "source register 2 should be " & integer'image(rs2) & ", is " & integer'image(reg_s2) & " for instruction " & instruction_name);
            check('1' = reg_we, "register write enable should be 1, is " & std_logic'image(reg_we) & " for instruction " & instruction_name);
            check('0' = pc_load, "PC load should be 0, is " & std_logic'image(reg_we) & " for instruction " & instruction_name);
            check('0' = ri_sel, "RI select should be 0, is " & std_logic'image(ri_sel) & " for instruction " & instruction_name);
            check('0' = busw_sel, "Bus W select should be 0, is " & std_logic'image(busw_sel) & " for instruction " & instruction_name);
            check('0' = ram_we, "RAM write enable should be 0, is " & std_logic'image(ram_we) & " for instruction " & instruction_name);
        end procedure;

        procedure check_instruction_i(new_instruction : instruction; expected_op : alu_op_sel; rd : register_addr; rs1 : register_addr; instruction_name : string) is begin
            instr <= new_instruction;

            wait for 1 ns;

            check(alu_op = expected_op, "ALU OP should be " & integer'image(to_integer(unsigned(expected_op))) & ", is " & integer'image(to_integer(unsigned(alu_op))) & " for instruction " & instruction_name);
            check(reg_dest = rd, "destination register should be " & integer'image(rd) & ", is " & integer'image(reg_dest) & " for instruction " & instruction_name);
            check(reg_s1 = rs1, "source register 1 should be " & integer'image(rs1) & ", is " & integer'image(reg_s1) & " for instruction " & instruction_name);
            check('1' = reg_we, "register write enable should be 1, is " & std_logic'image(reg_we) & " for instruction " & instruction_name);
            check('0' = pc_load, "PC load should be 0, is " & std_logic'image(reg_we) & " for instruction " & instruction_name);
            check('1' = ri_sel, "RI select should be 1, is " & std_logic'image(ri_sel) & " for instruction " & instruction_name);
            check('0' = busw_sel, "Bus W select should be 0, is " & std_logic'image(busw_sel) & " for instruction " & instruction_name);
            check('0' = ram_we, "RAM write enable should be 0, is " & std_logic'image(ram_we) & " for instruction " & instruction_name);
        end procedure;

        procedure check_instruction_load(new_instruction : instruction; rd : register_addr; rs1 : register_addr; instruction_name : string) is begin
            instr <= new_instruction;

            wait for 1 ns;
            check(alu_op = SEL_ADD, "ALU OP should be 0000, is " & integer'image(to_integer(unsigned(alu_op))) & " for instruction " & instruction_name);
            check(reg_dest = rd, "destination register should be " & integer'image(rd) & ", is " & integer'image(reg_dest) & " for instruction " & instruction_name);
            check(reg_s1 = rs1, "source register 1 should be " & integer'image(rs1) & ", is " & integer'image(reg_s1) & " for instruction " & instruction_name);
            check('1' = reg_we, "register write enable should be 1, is " & std_logic'image(reg_we) & " for instruction " & instruction_name);
            check('0' = pc_load, "PC load should be 0, is " & std_logic'image(reg_we) & " for instruction " & instruction_name);
            check('1' = ri_sel, "RI select should be 1, is " & std_logic'image(ri_sel) & " for instruction " & instruction_name);
            check('1' = busw_sel, "Bus W select should be 1, is " & std_logic'image(busw_sel) & " for instruction " & instruction_name);
            check('0' = ram_we, "RAM write enable should be 0, is " & std_logic'image(ram_we) & " for instruction " & instruction_name);
        end procedure;

        procedure check_instruction_S(new_instruction : instruction; rs1 : register_addr; rs2 : register_addr; instruction_name : string) is begin
            instr <= new_instruction;

            wait for 1 ns;
            check(alu_op = SEL_ADD, "ALU OP should be 0000, is " & integer'image(to_integer(unsigned(alu_op))) & " for instruction " & instruction_name);
            check(reg_s1 = rs1, "source register 1 should be " & integer'image(rs1) & ", is " & integer'image(reg_s1) & " for instruction " & instruction_name);
            check(reg_s2 = rs2, "source register 2 should be " & integer'image(rs2) & ", is " & integer'image(reg_s2) & " for instruction " & instruction_name);
            check('0' = reg_we, "register write enable should be 0, is " & std_logic'image(reg_we) & " for instruction " & instruction_name);
            check('0' = pc_load, "PC load should be 0, is " & std_logic'image(reg_we) & " for instruction " & instruction_name);
            check('1' = ri_sel, "RI select should be 1, is " & std_logic'image(ri_sel) & " for instruction " & instruction_name);
            check('1' = ram_we, "RAM write enable should be 1, is " & std_logic'image(ram_we) & " for instruction " & instruction_name);
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
        constant INSTRUCTION_I_SLL : instruction := B"0100000_01011_11101_001_00010_0010011";
        constant INSTRUCTION_I_SLT : instruction := B"010000001100_11100_010_00011_0010011";
        constant INSTRUCTION_I_SLTU : instruction := B"000000001101_11011_011_00100_0010011";
        constant INSTRUCTION_I_XOR : instruction := B"010000001110_11010_100_00101_0010011";
        constant INSTRUCTION_I_SRL : instruction := B"0000000_01111_11001_101_00110_0010011";
        constant INSTRUCTION_I_SRA : instruction := B"0100000_10000_11000_101_00111_0010011";
        constant INSTRUCTION_I_OR : instruction := B"010000010001_10111_110_01000_0010011";
        constant INSTRUCTION_I_AND : instruction := B"000000010010_10110_111_01001_0010011";

        constant INSTRUCTION_LOAD_1 : instruction := B"000000011111_00000_000_01010_0000011";
        constant INSTRUCTION_LOAD_2 : instruction := B"0100000_01011_11101_001_00010_0000011";
        constant INSTRUCTION_LOAD_3 : instruction := B"010000001100_11100_010_00011_0000011";
        constant INSTRUCTION_LOAD_4 : instruction := B"000000001101_11011_100_00100_0000011";
        constant INSTRUCTION_LOAD_5 : instruction := B"010000001110_11010_101_00101_0000011";
        constant INSTRUCTION_LOAD_6 : instruction := B"0000000_01111_11001_000_00110_0000011";
        constant INSTRUCTION_LOAD_7 : instruction := B"0100000_10000_11000_001_00111_0000011";
        constant INSTRUCTION_LOAD_8 : instruction := B"010000010001_10111_010_01000_0000011";
        constant INSTRUCTION_LOAD_9 : instruction := B"000000010010_10110_100_01001_0000011";
        constant INSTRUCTION_LOAD_10 : instruction := B"000000011111_00000_101_01010_0000011";

        constant INSTRUCTION_S_B_1 : instruction := B"0111000_11111_00000_000_01010_0100011";
        constant INSTRUCTION_S_B_2 : instruction := B"0100011_01010_11110_000_00001_0100011";
        constant INSTRUCTION_S_B_3 : instruction := B"0000010_01011_11101_000_00010_0100011";
        constant INSTRUCTION_S_B_4 : instruction := B"1110000_01100_11100_000_00011_0100011";
        constant INSTRUCTION_S_H_1 : instruction := B"0001000_01101_11011_001_00100_0100011";
        constant INSTRUCTION_S_H_2 : instruction := B"0010100_01110_11010_001_00101_0100011";
        constant INSTRUCTION_S_H_3 : instruction := B"0100100_01111_11001_001_00110_0100011";
        constant INSTRUCTION_S_H_4 : instruction := B"0111110_10000_11000_001_00111_0100011";
        constant INSTRUCTION_S_W_1 : instruction := B"0000110_10001_10111_010_01000_0100011";
        constant INSTRUCTION_S_W_2 : instruction := B"0000010_10010_10110_010_01001_0100011";
    begin

        wait for 1 ns;

        --                  instruction        op_sel   rd  rs1 rs2 name
        check_instruction_r(INSTRUCTION_R_ADD, SEL_ADD, 10, 00, 31, "INSTRUCTION_R_ADD");
        check_instruction_r(INSTRUCTION_R_SUB, SEL_SUB, 01, 30, 10, "INSTRUCTION_R_SUB");
        check_instruction_r(INSTRUCTION_R_SLL, SEL_SLL, 02, 29, 11, "INSTRUCTION_R_SLL");
        check_instruction_r(INSTRUCTION_R_SLT, SEL_SLT, 03, 28, 12, "INSTRUCTION_R_SLT");
        check_instruction_r(INSTRUCTION_R_SLTU, SEL_SLTU, 04, 27, 13, "INSTRUCTION_R_SLTU");
        check_instruction_r(INSTRUCTION_R_XOR, SEL_XOR, 05, 26, 14, "INSTRUCTION_R_XOR");
        check_instruction_r(INSTRUCTION_R_SRL, SEL_SRL, 06, 25, 15, "INSTRUCTION_R_SRL");
        check_instruction_r(INSTRUCTION_R_SRA, SEL_SRA, 07, 24, 16, "INSTRUCTION_R_SRA");
        check_instruction_r(INSTRUCTION_R_OR, SEL_OR, 08, 23, 17, "INSTRUCTION_R_OR");
        check_instruction_r(INSTRUCTION_R_AND, SEL_AND, 09, 22, 18, "INSTRUCTION_R_AND");

        --                  instruction        op_sel   rd  rs1 name
        check_instruction_i(INSTRUCTION_I_ADD, SEL_ADD, 10, 00, "INSTRUCTION_I_ADD");
        check_instruction_i(INSTRUCTION_I_SLL, SEL_SLL, 02, 29, "INSTRUCTION_I_SLL");
        check_instruction_i(INSTRUCTION_I_SLT, SEL_SLT, 03, 28, "INSTRUCTION_I_SLT");
        check_instruction_i(INSTRUCTION_I_SLTU, SEL_SLTU, 04, 27, "INSTRUCTION_I_SLTU");
        check_instruction_i(INSTRUCTION_I_XOR, SEL_XOR, 05, 26, "INSTRUCTION_I_XOR");
        check_instruction_i(INSTRUCTION_I_SRL, SEL_SRL, 06, 25, "INSTRUCTION_I_SRL");
        check_instruction_i(INSTRUCTION_I_SRA, SEL_SRA, 07, 24, "INSTRUCTION_I_SRA");
        check_instruction_i(INSTRUCTION_I_OR, SEL_OR, 08, 23, "INSTRUCTION_I_OR");
        check_instruction_i(INSTRUCTION_I_AND, SEL_AND, 09, 22, "INSTRUCTION_I_AND");

        --                  instruction            rd  rs1 name
        check_instruction_load(INSTRUCTION_LOAD_1, 10, 00, "INSTRUCTION_LOAD_1");
        check_instruction_load(INSTRUCTION_LOAD_2, 02, 29, "INSTRUCTION_LOAD_2");
        check_instruction_load(INSTRUCTION_LOAD_3, 03, 28, "INSTRUCTION_LOAD_3");
        check_instruction_load(INSTRUCTION_LOAD_4, 04, 27, "INSTRUCTION_LOAD_4");
        check_instruction_load(INSTRUCTION_LOAD_5, 05, 26, "INSTRUCTION_LOAD_5");
        check_instruction_load(INSTRUCTION_LOAD_6, 06, 25, "INSTRUCTION_LOAD_6");
        check_instruction_load(INSTRUCTION_LOAD_7, 07, 24, "INSTRUCTION_LOAD_7");
        check_instruction_load(INSTRUCTION_LOAD_8, 08, 23, "INSTRUCTION_LOAD_8");
        check_instruction_load(INSTRUCTION_LOAD_9, 09, 22, "INSTRUCTION_LOAD_9");
        check_instruction_load(INSTRUCTION_LOAD_10, 10, 00, "INSTRUCTION_LOAD_10");

        --                  instruction        rs1 rs2 name
        check_instruction_s(INSTRUCTION_S_B_1, 00, 31, "INSTRUCTION_S_B_1");
        check_instruction_s(INSTRUCTION_S_B_2, 30, 10, "INSTRUCTION_S_B_2");
        check_instruction_s(INSTRUCTION_S_B_3, 29, 11, "INSTRUCTION_S_B_3");
        check_instruction_s(INSTRUCTION_S_B_4, 28, 12, "INSTRUCTION_S_B_3");
        check_instruction_s(INSTRUCTION_S_H_1, 27, 13, "INSTRUCTION_S_H_1");
        check_instruction_s(INSTRUCTION_S_H_2, 26, 14, "INSTRUCTION_S_H_2");
        check_instruction_s(INSTRUCTION_S_H_3, 25, 15, "INSTRUCTION_S_H_3");
        check_instruction_s(INSTRUCTION_S_H_4, 24, 16, "INSTRUCTION_S_H_3");
        check_instruction_s(INSTRUCTION_S_W_1, 23, 17, "INSTRUCTION_S_W_1");
        check_instruction_s(INSTRUCTION_S_W_2, 22, 18, "INSTRUCTION_S_W_2");

        wait for 1 ns;

        if success then
            report "testbench PC succesful!";
        else
            report "testbench PC failed!";
        end if;
        wait;
    end process;
end architecture rtl;