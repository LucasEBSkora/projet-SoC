library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity PC_tb is
end entity PC_tb;

architecture rtl of PC_tb is
    constant ADDR_WIDTH : natural := 16;
    constant MAX_ADDR : natural := 2 ** ADDR_WIDTH - 1;

    component PC
        generic (
            ADDR_WIDTH : natural := 32
        );
        port (
            load : in std_logic;
            clk : in std_logic;
            addr_in : in natural range 0 to 2 ** ADDR_WIDTH - 1;
            addr_out : out natural range 0 to 2 ** ADDR_WIDTH - 1
        );
    end component PC;

    signal clk : std_logic := '0';
    signal load : std_logic := '0';
    signal addr_in : natural range 0 to MAX_ADDR := 0;
    signal addr_out : natural range 0 to MAX_ADDR;

    signal success : boolean := true;
begin

    uut : PC generic map(ADDR_WIDTH => ADDR_WIDTH)
    port map(load => load, clk => clk, addr_in => addr_in, addr_out => addr_out);
    clk <= not clk after 5 ns;

    process
        procedure check(value : boolean; message : string := "") is begin
            if not value then
                success <= false;
                assert false report message severity error;
            end if;
        end procedure;
        constant value : natural := 16#FEDC#;
    begin
        wait for 1 ns;

        check(addr_out = 0, "initial value of PC is not 0! Is" & natural'image(addr_out));
        wait for 10 ns;

        check(addr_out = 4, "PC did not increment properly! should be 4, is" & natural'image(addr_out));
        wait for 100 ns;
        check(addr_out = 44, "PC did not increment properly! should be 44, is" & natural'image(addr_out));

        load <= '1';
        addr_in <= value;

        wait for 10 ns;

        check(addr_out = value, "PC did not jump properly! value is " & natural'image(addr_out));

        load <= '0';
        wait for 10 ns;

        check(addr_out = value + 4, "PC did not increment properly! value is " & natural'image(addr_out));

        if success then
            report "testbench PC succesful!";
        else
            report "testbench PC failed!";
        end if;
        wait;
    end process;

end architecture rtl;