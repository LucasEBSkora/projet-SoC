library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity register_bank_tb is
end entity register_bank_tb;

architecture rtl of register_bank_tb is
    constant WORD_WIDTH : natural := 32;
    constant ADDR_WIDTH : natural := 5;
    constant MAX_ADDR : natural := 2 ** ADDR_WIDTH - 1;

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

    signal clk : std_logic := '0';
    signal we : std_logic := '0';
    signal reset : std_logic := '0';
    signal sel_W : natural range 0 to MAX_ADDR;
    signal sel_A : natural range 0 to MAX_ADDR;
    signal sel_B : natural range 0 to MAX_ADDR;
    signal data_in : std_logic_vector(WORD_WIDTH - 1 downto 0);
    signal data_A : std_logic_vector(WORD_WIDTH - 1 downto 0);
    signal data_B : std_logic_vector(WORD_WIDTH - 1 downto 0);

    signal success : boolean := true;
begin

    bank : register_bank generic map(WORD_WIDTH => WORD_WIDTH, ADDR_WIDTH => ADDR_WIDTH)
    port map(
        clk => clk, write_enable => we, reset => reset, RW => sel_W, RA => sel_A, RB => sel_B,
        busW => data_in, busA => data_A, busB => data_B);

    clk <= not clk after 5 ns;

    process
        procedure check_value(register_n : natural range 0 to MAX_ADDR; expected : integer; actual : integer; prefix : string := "") is begin
            if expected /= actual then
                success <= false;
                assert false report prefix & " register " & natural'image(register_n) & " should have value " & integer'image(expected)
                & " but has " & integer'image(actual) severity error;
            end if;
        end;
        constant HALF_ADDR : natural := 2 ** (ADDR_WIDTH - 1);
    begin
        we <= '1';

        wait for 4 ns;

        data_in <= (others => '1');
        sel_W <= 0;
        sel_A <= 0;
        wait for 10 ns;
        check_value(0, 0, to_integer(signed(data_A)));
        for i in 1 to MAX_ADDR loop
            data_in <= std_logic_vector(to_unsigned((2 ** ADDR_WIDTH - 1) - natural(i), WORD_WIDTH));
            sel_W <= i;
            sel_A <= i - 1;

            sel_B <= i;
            wait for 10 ns;
            if i > 1 then
                check_value(i - 1, MAX_ADDR - (i - 1), to_integer(signed(data_A)), "previous");
            end if;
            check_value(i, MAX_ADDR - i, to_integer(signed(data_B)), "current");

        end loop;

        we <= '0';
        data_in <= (others => '1');
        wait for 20 ns;

        for i in 0 to HALF_ADDR - 1 loop
            sel_A <= i;
            sel_B <= HALF_ADDR + i;

            wait for 10 ns;
            if i /= 0 then
                check_value(i, MAX_ADDR - i, to_integer(signed(data_A)), "lower");
            end if;

            check_value(HALF_ADDR + i, (HALF_ADDR - 1) - i, to_integer(signed(data_B)), "upper");

        end loop;

        reset <= '1';

        wait for 10 ns;

        reset <= '0';

        wait for 10 ns;

        for i in 1 to MAX_ADDR loop
            sel_B <= i;
            wait for 10 ns;
            check_value(i, 0, to_integer(signed(data_B)), "reset");

        end loop;

        if success then
            report "testbench register_bank succesful!";
        else
            report "testbench register_bank failed!";
        end if;
        wait;
    end process;

end architecture rtl;