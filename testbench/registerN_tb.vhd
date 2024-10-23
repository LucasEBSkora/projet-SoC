library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity registerN_tb is
end entity registerN_tb;

architecture rtl of registerN_tb is
    constant WORD_WIDTH : natural := 32;
    component registerN
        generic (
            WORD_WIDTH : natural := 32;
            INIT_VALUE : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0')
        );
        port (
            data_in : in std_logic_vector(WORD_WIDTH - 1 downto 0);
            data_out : out std_logic_vector(WORD_WIDTH - 1 downto 0);
            write_enable : in std_logic;
            reset : in std_logic;
            clk : in std_logic
        );
    end component;

    signal clk_t : std_logic := '1';
    signal reset : std_logic := '0';
    signal data_in : std_logic_vector((WORD_WIDTH - 1) downto 0);
    signal write_enable : std_logic := '0';
    signal data_out : std_logic_vector((WORD_WIDTH - 1) downto 0);

    signal success : boolean := true;
begin
    reg : registerN generic map(WORD_WIDTH => WORD_WIDTH)
    port map(data_in => data_in, data_out => data_out, write_enable => write_enable, reset => reset, clk => clk_t);

    clk_t <= not clk_t after 5 ns;

    process
        subtype word is std_logic_vector((WORD_WIDTH - 1) downto 0);
        constant value1 : word := x"89ABCDEF";
        constant value2 : word := x"ABABABAB";
        constant zero : word := x"00000000";

        procedure check_value(expected : word; actual : word) is begin
            if expected /= actual then
                success <= false;
                assert false report "register output should be" & integer'image(to_integer(signed(expected))) & " is " & integer'image(to_integer(signed(actual))) severity error;
            end if;
        end;
    begin
        wait for 5 ns;
        write_enable <= '1';
        data_in <= value1;
        wait for 10 ns;
        check_value(data_out, value1);

        write_enable <= '0';
        data_in <= value2;
        wait for 10 ns;
        check_value(data_out, value1);

        write_enable <= '1';
        wait for 10 ns;
        check_value(data_out, value2);

        reset <= '1';
        wait for 10 ns;
        check_value(data_out, zero);

        if success then
            report "testbench registerN succesful!";
        else
            report "testbench registerN failed!";
        end if;
        wait;
    end process;
end architecture rtl;