library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity instruction_memory is
    generic (
        DATA_WIDTH : natural := 8;
        ADDR_WIDTH : natural := 8;
        MEMORY_DEPTH : natural := 2 ** ADDR_WIDTH;
        INIT_FILE : string := "programs/imem_testbench.txt"
    );

    port (
        addr : in natural range 0 to 2 ** ADDR_WIDTH - 1;
        q : out std_logic_vector((DATA_WIDTH - 1) downto 0)
    );
end entity;

architecture rtl of instruction_memory is
    
    subtype word_t is std_logic_vector((DATA_WIDTH - 1) downto 0);
    type memory_t is array (0 to MEMORY_DEPTH - 1) of word_t;
    -- type memory_t is array(MAX_ADDR downto 0) of word_t;

    -- function converting hexadecimal string to std_logic_vector
    function str_to_slv(str : string) return std_logic_vector is
        alias str_norm : string(1 to str'length) is str;
        variable char_v : character;
        variable val_of_char_v : natural;
        variable res_v : std_logic_vector(4 * str'length - 1 downto 0);
    begin
        for str_norm_idx in str_norm'range loop
            char_v := str_norm(str_norm_idx);
            case char_v is
                when '0' to '9' => val_of_char_v := character'pos(char_v) - character'pos('0');
                when 'A' to 'F' => val_of_char_v := character'pos(char_v) - character'pos('A') + 10;
                when 'a' to 'f' => val_of_char_v := character'pos(char_v) - character'pos('a') + 10;
                when others => report "str_to_slv: Invalid characters for convert" severity ERROR;
            end case;
            res_v(res_v'left - 4 * str_norm_idx + 4 downto res_v'left - 4 * str_norm_idx + 1) :=
            std_logic_vector(to_unsigned(val_of_char_v, 4));
        end loop;
        return res_v;
    end function;

    -- function reading the hex (txt) file for instruction memory initialization
    impure function memInit(fileName : string) return memory_t is
        variable mem_tmp : memory_t;
        file filePtr : text;
        variable line_instr : line;
        variable instr_str : string(1 to DATA_WIDTH / 4);
        variable inst_num : integer := 0;
        variable instr_init : std_logic_vector(DATA_WIDTH - 1 downto 0);
    begin
        file_open(filePtr, fileName, READ_MODE);
        while (inst_num < MEMORY_DEPTH and not endfile(filePtr)) loop
            readline (filePtr, line_instr);
            read (line_instr, instr_str);
            instr_init := str_to_slv(instr_str);
            mem_tmp(inst_num) := instr_init;
            inst_num := inst_num + 1;
        end loop;
        file_close(filePtr);
        return mem_tmp;
    end function;
    signal rom : memory_t := memInit(INIT_FILE);

begin
    q <= rom(addr);
end rtl;