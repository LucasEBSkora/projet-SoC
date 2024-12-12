library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity data_memory_tb is
end entity data_memory_tb;

architecture rtl of data_memory_tb is
    constant addr_width : natural := 5;
    constant byte_size : natural := 8;
    constant n_bytes : natural := 4;
    constant data_width : natural := byte_size * n_bytes;

    subtype word_t is std_logic_vector((data_width - 1) downto 0);

    component data_memory
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
    end component;
    signal clk_t : std_logic := '1';
    signal addr_t : natural range 0 to 31 := 0;
    signal data_in : word_t;
    signal write_enable : std_logic_vector((N_BYTES - 1) downto 0) := (others => '0');
    signal data_out : word_t;

    signal success : boolean := true;
begin
    ram : data_memory generic map(BYTE_SIZE => byte_size, N_BYTES => n_bytes, ADDR_WIDTH => addr_width)
    port map(clk => clk_t, addr => addr_t, data => data_in, we => write_enable, q => data_out);

    clk_t <= not clk_t after 5 ns;

    process
        procedure check(value : boolean; message : string := "") is begin
            if not value then
                success <= false;
                assert false report message severity error;
            end if;
        end procedure;

        procedure check_word(addr : natural range 0 to 31; expected_word : word_t) is
            variable data_int : integer;
            variable expected_byte : integer;
        begin
            addr_t <= addr;
            wait for 1 ns;
            for i in 0 to 3 loop
                data_int := to_integer(unsigned(data_out(BYTE_SIZE * (i + 1) - 1 downto BYTE_SIZE * i)));
                expected_byte := to_integer(unsigned(expected_word(BYTE_SIZE * (i + 1) - 1 downto BYTE_SIZE * i)));
                check(expected_byte = data_int, "unexpected value " & integer'image(data_int) & " at " & natural'image(addr_t + i) & ": expected value is " & integer'image(expected_byte));
            end loop;
            wait for 9 ns;
        end procedure;

    begin
        wait for 5 ns;
        for addr_pos in 0 to 7 loop
            check_word(addr_pos * 4,
            std_logic_vector(to_unsigned(addr_pos * 4 + 3, byte_size)) &
            std_logic_vector(to_unsigned(addr_pos * 4 + 2, byte_size)) &
            std_logic_vector(to_unsigned(addr_pos * 4 + 1, byte_size)) &
            std_logic_vector(to_unsigned(addr_pos * 4 + 0, byte_size))
            );

        end loop;

        write_enable <= "1111";
        for addr_pos in 0 to 7 loop
            addr_t <= natural(addr_pos * 4);
            data_in <= std_logic_vector(to_unsigned(31 - addr_pos * 4 - 3, byte_size)) &
                std_logic_vector(to_unsigned(31 - addr_pos * 4 - 2, byte_size)) &
                std_logic_vector(to_unsigned(31 - addr_pos * 4 - 1, byte_size)) &
                std_logic_vector(to_unsigned(31 - addr_pos * 4 - 0, byte_size));
            wait for 10 ns;
        end loop;

        write_enable <= "0000";
        for addr_pos in 0 to 7 loop
            check_word(addr_pos * 4,
            std_logic_vector(to_unsigned(31 - addr_pos * 4 - 3, byte_size)) &
            std_logic_vector(to_unsigned(31 - addr_pos * 4 - 2, byte_size)) &
            std_logic_vector(to_unsigned(31 - addr_pos * 4 - 1, byte_size)) &
            std_logic_vector(to_unsigned(31 - addr_pos * 4 - 0, byte_size))
            );
        end loop;
        if success then
            report "testbench data_memory_tb succesful!";
        else
            report "testbench data_memory_tb failed!";
        end if;
        wait;
    end process;
end architecture rtl;