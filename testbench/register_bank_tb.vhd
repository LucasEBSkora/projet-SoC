library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity register_bank_tb is
end entity register_bank_tb;

architecture rtl of register_bank_tb is
    constant WORD_WIDTH : natural := 32;
    constant ADDR_WIDTH : natural := 5;

    component register_bank
        generic (
            WORD_WIDTH : natural := 32;
            ADDR_WIDTH : natural := 5
        );
        port (
            clk : in std_logic;
            write_enable : in std_logic;
            RW : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
            RA : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
            RB : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
            busW : in std_logic_vector(WORD_WIDTH - 1 downto 0);
            busA : out std_logic_vector(WORD_WIDTH - 1 downto 0);
            busB : out std_logic_vector(WORD_WIDTH - 1 downto 0)
        );
    end component;

    signal clk : std_logic := '0';
    signal we : std_logic := '0';
    signal sel_W : std_logic_vector(ADDR_WIDTH - 1 downto 0);
    signal sel_A : std_logic_vector(ADDR_WIDTH - 1 downto 0);
    signal sel_B : std_logic_vector(ADDR_WIDTH - 1 downto 0);
    signal data_in : std_logic_vector(WORD_WIDTH - 1 downto 0);
    signal data_A : std_logic_vector(WORD_WIDTH - 1 downto 0);
    signal data_B : std_logic_vector(WORD_WIDTH - 1 downto 0);

    signal success : boolean := true;
begin

    bank : register_bank generic map(WORD_WIDTH => WORD_WIDTH, ADDR_WIDTH => ADDR_WIDTH)
    port map(
        clk => clk, write_enable => we, RW => sel_W, RA => sel_A, RB => sel_B,
        busW => data_in, busA => data_A, busB => data_B);

    clk <= not clk after 5 ns;

    proc_name : process
    begin
        we <= '1';

        wait for 4 ns;

        data_in <= (others => '1');
        sel_W <= (others => '0');
        sel_A <= (others => '0');
        wait for 10 ns;

        if 0 /= to_integer(unsigned(data_A)) then
            success <= false;
            assert false report "register 0 has value  " & integer'image(to_integer(unsigned(data_A))) severity error;
        end if;

        for i in 1 to 2 ** ADDR_WIDTH - 1 loop
            data_in <= std_logic_vector(to_unsigned((2 ** ADDR_WIDTH - 1) - natural(i), WORD_WIDTH));
            sel_W <= std_logic_vector(to_unsigned(i, addr_width));
            sel_A <= std_logic_vector(to_unsigned(natural(i) - 1, addr_width));

            sel_B <= std_logic_vector(to_unsigned(i, addr_width));
            wait for 10 ns;
            if i > 1 and (2 ** ADDR_WIDTH) - i /= to_integer(unsigned(data_A)) then
                success <= false;
                assert false report "unexpected previous value " & integer'image(to_integer(unsigned(data_A))) & " at " & natural'image(i - 1) severity error;
            end if;
            if (2 ** ADDR_WIDTH - 1) - i /= to_integer(unsigned(data_B)) then
                success <= false;
                assert false report "unexpected value " & integer'image(to_integer(unsigned(data_B))) & " at " & natural'image(i) severity error;
            end if;
        end loop;

        we <= '0';
        data_in <= (others => '1');
        wait for 20 ns;

        for i in 0 to 2**(ADDR_WIDTH - 1) - 1 loop
        sel_A <= '0' & std_logic_vector(to_unsigned(i, addr_width-1));
        sel_B <= '1' & std_logic_vector(to_unsigned(i, addr_width-1));

        wait for 10 ns;

        if i /= 0 and (2 ** ADDR_WIDTH - 1) - i /= to_integer(unsigned(data_A)) then
            success <= false;
            assert false report "unexpected lower value " & integer'image(to_integer(unsigned(data_A))) & " at " & natural'image(i) severity error;
        end if;

        if (2 ** (ADDR_WIDTH - 1) - 1) - i /= to_integer(unsigned(data_B)) then
            success <= false;
            assert false report "unexpected upper value " & integer'image(to_integer(unsigned(data_B))) & " at " & natural'image(2**(ADDR_WIDTH - 1) + i) severity error;
        end if;
        
        end loop;
        wait;
    end process proc_name;

end architecture rtl;