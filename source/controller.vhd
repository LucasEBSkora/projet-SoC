library IEEE;
library WORK;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use WORK.constants.all;

entity controller is
    port (
        instr : in std_logic_vector(31 downto 0);
        store_position : in std_logic_vector(1 downto 0);
        reg_we : out std_logic;
        ram_we : out std_logic_vector(3 downto 0);
        pc_load : out std_logic;
        ri_sel : out std_logic;
        busw_sel : out std_logic;
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

    signal ram_we_half : std_logic_vector(3 downto 0) := (others => '0');
    signal ram_we_byte : std_logic_vector(3 downto 0) := (others => '0');

begin

    with opcode select reg_we <=
        '1' when OPCODE_R,
        '1' when OPCODE_I,
        '1' when OPCODE_LOAD,
        '0' when OPCODE_S,
        '0' when others;

    pc_load <= '0';

    with store_position select ram_we_half <=
        "0011" when "00",
        "1100" when "10",
        "1111" when others;

    with store_position select ram_we_byte <=
        "0001" when "00",
        "0010" when "01",
        "0100" when "10",
        "1000" when "11",
        "1111" when others;

    ram_we <= "1111" when opcode = OPCODE_S and funct3 = SEL_LSW else
        ram_we_half when opcode = OPCODE_S and funct3 = SEL_LSH else
        ram_we_byte when opcode = OPCODE_S and funct3 = SEL_LSB else
        (others => '0');

    busw_sel <= '1' when opcode = OPCODE_LOAD else
        '0';

    --  for I type instructions, we can't calculate the operation as simply because for operations other than
    --  srli and srai, funct7(5) is just a part of the immediate, not a way of choosing the operator.
    alu_op <= unsigned(funct7(5) & funct3) when opcode = OPCODE_R or (opcode = OPCODE_I and funct3 = "101") else
        unsigned('0' & funct3) when opcode = OPCODE_I else
        SEL_ADD when opcode = OPCODE_LOAD else
        (others => '0');

    reg_dest <= to_integer(unsigned(rd));
    reg_s1 <= to_integer(unsigned(rs1));
    reg_s2 <= to_integer(unsigned(rs2));

    with opcode select ri_sel <=
        '0' when OPCODE_R,
        '1' when OPCODE_I,
        '1' when OPCODE_LOAD,
        '1' when OPCODE_S,
        '0' when others;
end architecture rtl;