library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity data_memory_tb is
end entity data_memory_tb;

architecture rtl of data_memory_tb is
    constant addr_width : natural := 3;
    constant data_width : natural := 32;
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
    signal clk_t : std_logic := '1';
    signal addr_t : natural range 0 to 7 := 0;
    signal data_in : std_logic_vector((data_width - 1) downto 0);
    signal write_enable : std_logic := '0';
    signal data_out : std_logic_vector((data_width - 1) downto 0);

    signal success : boolean := true;
begin
    ram : data_memory generic map(data_width => 32, ADDR_WIDTH => addr_width)
    port map(clk => clk_t, addr => addr_t, data => data_in, we => write_enable, q => data_out);

    clk_t <= not clk_t after 5 ns;

    process begin
        wait for 5 ns;
        for addr_pos in 0 to 7 loop
            addr_t <= natural(addr_pos);
            if addr_t /= to_integer(unsigned(data_out)) then
                success <= false;
            end if;
            assert addr_t = to_integer(unsigned(data_out)) report "unexpected value " & integer'image(to_integer(unsigned(data_out))) & " at " & natural'image(addr_t) severity error;
            wait for 10 ns;
        end loop;

        write_enable <= '1';
        for addr_pos in 0 to 2 ** addr_width - 1 loop
            addr_t <= natural(addr_pos);
            data_in <= std_logic_vector(to_unsigned(7 - natural(addr_pos), data_width));
            wait for 10 ns;
        end loop;

        write_enable <= '0';
        for addr_pos in 0 to 2 ** addr_width - 1 loop
            addr_t <= natural(addr_pos);
            if unsigned(data_out) /= 7 - addr_t then
                success <= false;
            end if;
            assert unsigned(data_out) = 7 - addr_t report "unexpected value " & integer'image(to_integer(unsigned(data_out))) & " at " & natural'image(addr_t) severity error;
            wait for 10 ns;
        end loop;
        if success then
            report "testbench data_memory_tb succesful!";
        else
            report "testbench data_memory_tb failed!";
        end if;
        wait;
    end process;
end architecture rtl;