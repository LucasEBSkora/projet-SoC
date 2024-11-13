library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity data_memory is
    generic (
        DATA_WIDTH : natural := 32;
        ADDR_WIDTH : natural := 3
    );
    port (
        clk : in std_logic;
        addr : in natural range 0 to 2 ** ADDR_WIDTH - 1;
        data : in std_logic_vector((DATA_WIDTH - 1) downto 0);
        we : in std_logic := '1';
        q : out std_logic_vector((DATA_WIDTH - 1) downto 0)
    );
end data_memory;

architecture rtl of data_memory is
    constant MAX_ADDR : natural := 2 ** ADDR_WIDTH - 1;

    subtype word_t is std_logic_vector((DATA_WIDTH - 1) downto 0);
    type memory_t is array(MAX_ADDR downto 0) of word_t;

    function init_ram
        return memory_t is
        variable tmp : memory_t := (others => (others => '0'));
    begin
        for addr_pos in 0 to MAX_ADDR loop
            tmp(addr_pos) := std_logic_vector(to_unsigned(addr_pos, DATA_WIDTH));
        end loop;
        -- to test lh, lb, lbu and lhu
        tmp(0) := X"01020304";
        tmp(2) := X"FF800010";
        return tmp;
    end init_ram;

    signal ram : memory_t := init_ram;
begin
    process (clk, we, addr, data)
    begin
        if (rising_edge(clk)) then
            if (we = '1') then
                ram(addr) <= data;
            end if;
        end if;
    end process;
    q <= ram(addr);
end architecture rtl;