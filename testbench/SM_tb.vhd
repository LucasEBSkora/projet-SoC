library IEEE;
library WORK;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use WORK.constants.all;

entity SM_tb is end entity SM_tb;

architecture rtl of SM_tb is
    component SM
        port (
            current_data : in std_logic_vector(31 downto 0);
            new_data : in std_logic_vector(31 downto 0);
            position : in std_logic_vector(1 downto 0);
            funct : in load_sel;
            result : out std_logic_vector(31 downto 0)
        );
    end component SM;

    signal data : std_logic_vector(31 downto 0);
    signal new_data : std_logic_vector(31 downto 0);
    signal position : std_logic_vector(1 downto 0);
    signal funct : load_sel;
    signal result : std_logic_vector(31 downto 0);

    signal success : boolean := true;
begin

    uut : SM port map(
        current_data => data, new_data => new_data,
        position => position, funct => funct, result => result
    );

    process
        procedure check(value : boolean; message : string := "") is begin
            if not value then
                success <= false;
                assert false report message severity error;
            end if;
        end procedure;

        procedure check_result(old : std_logic_vector(31 downto 0); replace_data : std_logic_vector(31 downto 0); new_position : std_logic_vector(1 downto 0); new_funct : load_sel; expected : std_logic_vector(31 downto 0)) is begin
            data <= old;
            new_data <= replace_data;
            position <= new_position;
            funct <= new_funct;

            wait for 1 ns;

            check(expected = result, "SM result for " & to_hstring(new_data) &
            " with selection " & integer'image(to_integer(unsigned(new_position))) & " and operation " & to_hstring(new_funct) & " is " &
            to_hstring(result) & " but should be " & to_hstring(expected)
            );
        end procedure;
    begin
        -- LB choose byte
        check_result(X"FFFFFFFF", X"01020304", "00", SEL_LSB, X"FFFFFF04");
        check_result(X"ABABABAB", X"04010203", "01", SEL_LSB, X"ABAB03AB");
        check_result(X"00000000", X"03040102", "10", SEL_LSB, X"00020000");
        check_result(X"11111111", X"04030201", "11", SEL_LSB, X"01111111");

        -- LH choose byte
        check_result(X"11112222", X"00000000", "00", SEL_LSH, X"11110000");
        check_result(X"11112222", X"00000000", "10", SEL_LSH, X"00002222");

        -- LW
        check_result(X"00010203", X"12345678", "00", SEL_LSW, X"12345678");
        check_result(X"12345678", X"FFDDEEBB", "00", SEL_LSW, X"FFDDEEBB");

        wait for 1 ns;

        if success then
            report "testbench SM succesful!";
        else
            report "testbench SM failed!";
        end if;
        wait;
    end process;
end architecture rtl;