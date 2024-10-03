library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity instruction_memory_tb is end entity instruction_memory_tb;

architecture testbench of instruction_memory_tb is
    component instruction_memory
        generic (
            DATA_WIDTH : natural := 8;
            ADDR_WIDTH : natural := 8
        );

        port (
            addr : in natural range 0 to 2 ** ADDR_WIDTH - 1;
            q : out std_logic_vector((DATA_WIDTH - 1) downto 0)
        );
    end component;
    signal addr_t : natural range 0 to 255 := 0;
    signal q_t : std_logic_vector(7 downto 0);
    signal success : boolean := true;
begin

    rom_1 : instruction_memory generic map(DATA_WIDTH => 8, ADDR_WIDTH => 8) port map(addr => addr_t, q => q_t);
    process
        variable data : integer;
    begin
        for addr_pos in 0 to 2 ** 8 - 1 loop
            addr_t <= natural(addr_pos);
            wait for 10 ns;
            data := to_integer(unsigned(q_t));
            if addr_t /= data then
                success <= false;
            end if;
            assert addr_t = data report "unexpected value " & integer'image(data) & " at " & natural'image(addr_t) severity error;
        end loop;
        if success then
            report "testbench instruction_memory_tb succesful!";
        else
            report "testbench instruction_memory_tb failed!";
        end if;
        wait;
    end process;

end architecture testbench;