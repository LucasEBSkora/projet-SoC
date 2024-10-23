library IEEE;
library WORK;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use WORK.constants.all;

entity controller is
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
end entity controller;

architecture rtl of controller is
    alias opcode : std_logic_vector(6 downto 0) is instr(6 downto 0);
    alias rd : std_logic_vector(4 downto 0) is instr(11 downto 7);
    alias funct3 : std_logic_vector(2 downto 0) is instr(14 downto 12);
    alias rs1 : std_logic_vector(4 downto 0) is instr(19 downto 15);
    alias rs2 : std_logic_vector(4 downto 0) is instr(24 downto 20);
    alias funct7 : std_logic_vector(6 downto 0) is instr(31 downto 25);
begin
    reg_we <= '1';
    pc_load <= '0';

    alu_op <= unsigned(funct7(5) & funct3);

    reg_dest <= to_integer(unsigned(rd));
    reg_s1 <= to_integer(unsigned(rs1));
    reg_s2 <= to_integer(unsigned(rs2));

    with opcode select ri_sel <=
        '0' when OPCODE_R,
        '1' when OPCODE_I,
        '0' when others;
end architecture rtl;