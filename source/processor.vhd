library IEEE;
library WORK;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use WORK.constants.all;

entity processor is
    generic (
        ADDR_WIDTH : natural := 32;
        RAM_ADDR_WIDTH : natural := 8;
        DATA_WIDTH : natural := 32;
        REG_ADDR_WIDTH : natural := 5;
        PROGRAM_FILE : string
    );
    port (
        clk : in std_logic;
        reset : in std_logic
    );
end entity processor;

architecture rtl of processor is
    component PC
        generic (
            ADDR_WIDTH : natural := 16
        );
        port (
            load : in std_logic;
            clk : in std_logic;
            reset : in std_logic;
            addr_in : in natural range 0 to 2 ** ADDR_WIDTH - 1;
            addr_out : out natural range 0 to 2 ** ADDR_WIDTH - 1
        );
    end component PC;

    component instruction_memory
        generic (
            DATA_WIDTH : natural := 8;
            ADDR_WIDTH : natural := 8;
            MEMORY_DEPTH : natural := 2 ** ADDR_WIDTH - 1;
            INIT_FILE : string := "programs/imem_testbench.txt"
        );

        port (
            addr : in natural range 0 to 2 ** ADDR_WIDTH - 1;
            q : out std_logic_vector((DATA_WIDTH - 1) downto 0)
        );
    end component;

    component data_memory
        generic (
            DATA_WIDTH : natural := data_width;
            ADDR_WIDTH : natural := addr_width
        );
        port (
            clk : in std_logic;
            addr : in natural range 0 to 2 ** ADDR_WIDTH - 1;
            data : in std_logic_vector((DATA_WIDTH - 1) downto 0);
            we : in std_logic := '1';
            q : out std_logic_vector((DATA_WIDTH - 1) downto 0)
        );
    end component;

    component register_bank
        generic (
            WORD_WIDTH : natural := 32;
            ADDR_WIDTH : natural := 5
        );
        port (
            clk : in std_logic;
            write_enable : in std_logic;
            reset : in std_logic;
            RW : in natural range 0 to 2 ** ADDR_WIDTH - 1;
            RA : in natural range 0 to 2 ** ADDR_WIDTH - 1;
            RB : in natural range 0 to 2 ** ADDR_WIDTH - 1;
            busW : in std_logic_vector(WORD_WIDTH - 1 downto 0);
            busA : out std_logic_vector(WORD_WIDTH - 1 downto 0);
            busB : out std_logic_vector(WORD_WIDTH - 1 downto 0)
        );
    end component;

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

    component Imm_ext
        port (
            instr : in std_logic_vector(31 downto 0);
            instType : in opcode;
            immExt : out std_logic_vector(31 downto 0)
        );
    end component Imm_ext;

    component mux2
        generic (
            WORD_WIDTH : natural := 32
        );
        port (
            sel : in std_logic;
            in1 : in std_logic_vector(WORD_WIDTH - 1 downto 0);
            in2 : in std_logic_vector(WORD_WIDTH - 1 downto 0);
            qo : out std_logic_vector(WORD_WIDTH - 1 downto 0)
        );
    end component mux2;

    component LM
        port (
            data : in std_logic_vector(31 downto 0);
            position : in std_logic_vector(1 downto 0);
            funct : in load_sel;
            result : out std_logic_vector(31 downto 0)
        );
    end component LM;

    subtype data_word is std_logic_vector(DATA_WIDTH - 1 downto 0);

    signal load : std_logic;

    constant REG_MAX_ADDR : natural := 2 ** REG_ADDR_WIDTH - 1;
    signal RW : natural range 0 to REG_MAX_ADDR;
    signal RA : natural range 0 to REG_MAX_ADDR;
    signal RB : natural range 0 to REG_MAX_ADDR;
    signal BusA : data_word;
    signal BusB : data_word;
    signal BusW : data_word;

    signal result : data_word;
    signal ram_data : data_word;

    signal pc_out : natural range 0 to 2 ** ADDR_WIDTH - 1;
    signal addr_instr : natural range 0 to 2 ** ADDR_WIDTH - 1;
    signal instruction : data_word;

    signal register_write_enable : std_logic;
    signal data_mem_write_enable : std_logic;
    signal ri_sel : std_logic;
    signal busw_sel : std_logic;
    signal alu_op : alu_op_sel;

    signal immediate : data_word;

    signal operandB : data_word;

    alias funct3 : std_logic_vector(2 downto 0) is instruction(14 downto 12);
    alias opcode : std_logic_vector(6 downto 0) is instruction(6 downto 0);
    signal ram_out : data_word;

begin
    pc_inst : PC generic map(ADDR_WIDTH => ADDR_WIDTH) port map(load => load, clk => clk, addr_in => to_integer(unsigned(result(ADDR_WIDTH - 1 downto 0))), reset => reset, addr_out => addr_instr);

    rom : instruction_memory generic map(DATA_WIDTH => DATA_WIDTH, ADDR_WIDTH => ADDR_WIDTH, MEMORY_DEPTH => 2000, INIT_FILE => PROGRAM_FILE) port map(addr => addr_instr/4, q => instruction);

    ram : data_memory generic map(data_width => DATA_WIDTH, ADDR_WIDTH => RAM_ADDR_WIDTH)
    port map(
        clk => clk, addr => to_integer(unsigned(result(RAM_ADDR_WIDTH + 1 downto 2))),
        data => (others => '0'), we => data_mem_write_enable, q => ram_data);

    alu_inst : ALU generic map(WORD_WIDTH => DATA_WIDTH) port map(opA => BusA, opB => operandB, res => result, aluOp => alu_op);

    controller_inst : controller port map(
        instr => instruction, reg_we => register_write_enable, ram_we => data_mem_write_enable,
        pc_load => load, ri_sel => ri_sel, busw_sel => busw_sel, alu_op => alu_op, reg_dest => RW, reg_s1 => RA, reg_s2 => RB);

    bank : register_bank generic map(WORD_WIDTH => DATA_WIDTH, ADDR_WIDTH => REG_ADDR_WIDTH)
    port map(clk => clk, write_enable => register_write_enable, reset => reset, RW => RW, RA => RA, RB => RB, busW => BusW, busA => BusA, busB => BusB);

    immExt : Imm_ext port map(instr => instruction, instType => opcode, immExt => immediate);

    muxSelOpB : mux2 generic map(WORD_WIDTH => DATA_WIDTH) port map(sel => ri_sel, in1 => BusB, in2 => immediate, qo => operandB);

    muxSelBusW : mux2 generic map(WORD_WIDTH => DATA_WIDTH) port map(sel => busw_sel, in1 => result, in2 => ram_out, qo => BusW);

    lm_inst : LM port map(data => ram_data, position => result(1 downto 0), funct => funct3, result => ram_out);
end architecture rtl;