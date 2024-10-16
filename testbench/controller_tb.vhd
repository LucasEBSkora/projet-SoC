library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
entity controller_tb is
end entity controller_tb;

architecture rtl of controller_tb is
    subtype instruction is std_logic_vector(31 downto 0);
    subtype alu_op_sel is unsigned(3 downto 0);
    subtype register_addr is std_logic_vector(4 downto 0);

    component controller
        port (
            instr : in std_logic_vector(31 downto 0);
            reg_we : out std_logic;
            pc_load : out std_logic;
            alu_op : out unsigned(3 downto 0);
            reg_dest : out std_logic_vector(4 downto 0);
            reg_s1 : out std_logic_vector(4 downto 0);
            reg_s2 : out std_logic_vector(4 downto 0)
        );
    end component controller;

    signal instr : instruction := (others => '0');
    signal reg_we : std_logic;
    signal pc_load : std_logic;
    signal alu_op : alu_op_sel;
    signal reg_dest : register_addr;
    signal reg_s1 : register_addr;
    signal reg_s2 : register_addr;

    signal success : boolean := true;
begin

    uut : controller port map(
        instr => instr, reg_we => reg_we, pc_load => pc_load, alu_op => alu_op,
        reg_dest => reg_dest, reg_s1 => reg_s1, reg_s2 => reg_s2
    );

    process

        procedure check(value : boolean; message : string := "") is begin
            if not value then
                success <= false;
                assert false report message severity error;
            end if;
        end procedure;

        procedure check_instruction(new_instruction : instruction; expected_op : alu_op_sel; rd : register_addr; rs1 : register_addr; rs2 : register_addr; instruction_name : string) is begin
            instr <= new_instruction;

            wait for 1 ns;

            check(alu_op = expected_op, "ALU OP should be " & integer'image(to_integer(unsigned(expected_op))) & ", is " & integer'image(to_integer(unsigned(alu_op))) & " for instruction " & instruction_name);
            check(reg_dest = rd, "destination register should be " & integer'image(to_integer(unsigned(rd))) & ", is " & integer'image(to_integer(unsigned(reg_dest))) & " for instruction " & instruction_name);
            check(reg_s1 = rs1, "source register 1 should be " & integer'image(to_integer(unsigned(rs1))) & ", is " & integer'image(to_integer(unsigned(reg_s1))) & " for instruction " & instruction_name);
            check(reg_s2 = rs2, "source register 2 should be " & integer'image(to_integer(unsigned(rs2))) & ", is " & integer'image(to_integer(unsigned(reg_s2))) & " for instruction " & instruction_name);
        end procedure;

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
    begin

        wait for 1 ns;

        check(reg_we = '1', "register write enable not set!");
        check(pc_load = '0', "PC load set incorrectly!");

        check_instruction(INSTRUCTION_R_ADD, SEL_ADD, "01010", "00000", "11111", "INSTRUCTION_R_ADD");
        check_instruction(INSTRUCTION_R_SUB, SEL_SUB, "00001", "11110", "01010", "INSTRUCTION_R_SUB");
        check_instruction(INSTRUCTION_R_SLL, SEL_SLL, "00010", "11101", "01011", "INSTRUCTION_R_SLL");
        check_instruction(INSTRUCTION_R_SLT, SEL_SLT, "00011", "11100", "01100", "INSTRUCTION_R_SLT");
        check_instruction(INSTRUCTION_R_SLTU, SEL_SLTU, "00100", "11011", "01101", "INSTRUCTION_R_SLTU");
        check_instruction(INSTRUCTION_R_XOR, SEL_XOR, "00101", "11010", "01110", "INSTRUCTION_R_XOR");
        check_instruction(INSTRUCTION_R_SRL, SEL_SRL, "00110", "11001", "01111", "INSTRUCTION_R_SRL");
        check_instruction(INSTRUCTION_R_SRA, SEL_SRA, "00111", "11000", "10000", "INSTRUCTION_R_SRA");
        check_instruction(INSTRUCTION_R_OR, SEL_OR, "01000", "10111", "10001", "INSTRUCTION_R_OR");
        check_instruction(INSTRUCTION_R_AND, SEL_AND, "01001", "10110", "10010", "INSTRUCTION_R_AND");
        if success then
            report "testbench PC succesful!";
        else
            report "testbench PC failed!";
        end if;
        wait;
    end process;
end architecture rtl;