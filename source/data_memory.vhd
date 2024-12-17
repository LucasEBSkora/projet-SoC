library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity data_memory is
    generic (
        BYTE_SIZE : natural := 8;
        N_BYTES : natural := 4;
        ADDR_WIDTH : natural := 5
    );
    port (
        clk : in std_logic;
        addr : in natural range 0 to 2 ** ADDR_WIDTH - 1;
        data : in std_logic_vector((BYTE_SIZE * N_BYTES - 1) downto 0);
        we : in std_logic_vector((N_BYTES - 1) downto 0) := (others => '0');
        q : out std_logic_vector((BYTE_SIZE * N_BYTES - 1) downto 0)
    );
end data_memory;

architecture rtl of data_memory is
    constant MAX_ADDR : natural := 2 ** ADDR_WIDTH - 1;

    subtype word_t is std_logic_vector((BYTE_SIZE - 1) downto 0);
    type memory_t is array(MAX_ADDR * N_BYTES downto 0) of word_t;

    function init_ram
        return memory_t is
        variable tmp : memory_t := (others => (others => '0'));
    begin
        for addr_pos in 0 to MAX_ADDR loop
            tmp(addr_pos) := std_logic_vector(to_unsigned(addr_pos, BYTE_SIZE));
        end loop;
        return tmp;
    end init_ram;

    signal ram : memory_t := init_ram;
    signal aligned_addr : natural range 0 to 2 ** ADDR_WIDTH - 1;
    signal word_to_write : std_logic_vector((BYTE_SIZE * N_BYTES - 1) downto 0) := (others => '0');
    signal bytes_written : natural range 0 to N_BYTES;
begin

    bytes_written <= to_integer(unsigned'("00" & we(0)) + unsigned'("00" & we(1)) + unsigned'("00" & we(2)) + unsigned'("00" & we(3)));

    word_to_write <= data when bytes_written = 4 else
        data(2 * BYTE_SIZE - 1 downto 0) & data(2 * BYTE_SIZE - 1 downto 0) when bytes_written = 2 else
        data(BYTE_SIZE - 1 downto 0) & data(BYTE_SIZE - 1 downto 0) & data(BYTE_SIZE - 1 downto 0) & data(BYTE_SIZE - 1 downto 0) when bytes_written = 1 else
        data;

    aligned_addr <= to_integer(to_unsigned(addr, ADDR_WIDTH)(ADDR_WIDTH - 1 downto 2) & "00");

    process (clk, we, addr, word_to_write)
    begin
        if (rising_edge(clk)) then
            for i in 0 to N_BYTES - 1 loop
                if (we(i) = '1') then
                    ram(aligned_addr + i) <= word_to_write((BYTE_SIZE * (i + 1) - 1) downto BYTE_SIZE * i);
                end if;
            end loop;
        end if;
    end process;

    output_assignement :
    for i in 0 to N_BYTES - 1 generate
        q((BYTE_SIZE * (i + 1) - 1) downto BYTE_SIZE * i) <= ram(aligned_addr + i);
    end generate;
end architecture rtl;