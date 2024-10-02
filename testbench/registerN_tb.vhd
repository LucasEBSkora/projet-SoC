library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity registerN_tb is
end entity registerN_tb;

architecture rtl of registerN_tb is
    constant WORD_WIDTH : natural := 32;
    component registerN
        generic (
            WORD_WIDTH : natural := 32
        );
        port (
            data_in : in std_logic_vector(WORD_WIDTH - 1 downto 0);
            data_out : out std_logic_vector(WORD_WIDTH - 1 downto 0);
            write_enable : in std_logic;
            clk : in std_logic
        );
    end component;

    signal clk_t : std_logic := '1';
    signal data_in : std_logic_vector((WORD_WIDTH - 1) downto 0);
    signal write_enable : std_logic := '0';
    signal data_out : std_logic_vector((WORD_WIDTH - 1) downto 0);

    signal success : boolean := true;
begin
    reg : registerN generic map(WORD_WIDTH => WORD_WIDTH)
    port map(data_in => data_in, data_out => data_out, write_enable => write_enable, clk => clk_t);

    clk_t <= not clk_t after 5 ns;

    process begin
        wait for 5 ns;
        write_enable <= '1';
        data_in <= x"89ABCDEF";
        wait for 10 ns;
        if data_out /= x"89ABCDEF" then
            success <= false;
        end if;
        assert data_in = x"89ABCDEF" report "register output should be 0x89ABCDEF, is " & integer'image(to_integer(unsigned(data_out))) severity error;

        write_enable <= '0';
        data_in <= x"ABABABAB";
        wait for 10 ns;
        if data_out /= x"89ABCDEF" then
            success <= false;
        end if;
        assert data_out = x"89ABCDEF" report "register output should still be 0x89ABCDEF, is " & integer'image(to_integer(unsigned(data_out))) severity error;

        write_enable <= '1';
        wait for 10 ns;

        if data_out /= x"ABABABAB" then
            success <= false;
        end if;
        assert data_out = x"ABABABAB" report "register output should still be 0xABABABAB, is " & integer'image(to_integer(unsigned(data_out))) severity error;
        if success then
            report "testbench registerN_tb succesful!";
        else
            report "testbench registerN_tb failed!";
        end if;
        wait;
    end process;
end architecture rtl;