library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mem is
    generic (
        DATA_WIDTH : natural := 8;
        ADDR_WIDTH : natural := 8
    );

    port (
        addr : in natural range 0 to 2 ** ADDR_WIDTH - 1;
        q : out std_logic_vector((DATA_WIDTH - 1) downto 0)
    );
end entity;

architecture rtl of mem is
    subtype word_t is std_logic_vector((DATA_WIDTH - 1) downto 0);
    type memory_t is array(2 ** ADDR_WIDTH - 1 downto 0) of word_t;

    function init_rom
        return memory_t is
        variable tmp : memory_t := (others => (others => '0'));
    begin
        for addr_pos in 0 to 2 ** ADDR_WIDTH - 1 loop
            tmp(addr_pos) := std_logic_vector(to_unsigned(addr_pos, DATA_WIDTH));
        end loop;
        -- tmp(0) := x"FF";
        return tmp;
    end init_rom;

    signal rom : memory_t := init_rom;

begin
    q <= rom(addr);
end rtl;