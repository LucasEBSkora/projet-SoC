library IEEE;
library WORK;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use WORK.constants.all;

entity LM_tb is end entity LM_tb;

architecture rtl of LM_tb is
    component LM
        port (
            data : in std_logic_vector(31 downto 0);
            position : in std_logic_vector(1 downto 0);
            funct : in load_sel;
            result : out std_logic_vector(31 downto 0)
        );
    end component LM;

    signal data : std_logic_vector(31 downto 0);
    signal position : std_logic_vector(1 downto 0);
    signal funct : load_sel;
    signal result : std_logic_vector(31 downto 0);
    signal success : boolean := true;
begin

    uut : LM port map(data => data, position => position, funct => funct, result => result);

    process
        procedure check(value : boolean; message : string := "") is begin
            if not value then
                success <= false;
                assert false report message severity error;
            end if;
        end procedure;

        procedure check_result(new_data : std_logic_vector(31 downto 0); new_position : std_logic_vector(1 downto 0); new_funct : load_sel; expected : std_logic_vector(31 downto 0)) is begin
            data <= new_data;
            position <= new_position;
            funct <= new_funct;

            wait for 1 ns;

            check(expected = result, "LM result for " & to_hstring(new_data) &
            " with selection " & integer'image(to_integer(unsigned(new_position))) & " and operation " & to_hstring(new_funct) & " is " &
            integer'image(to_integer(signed(result))) & " but should be " & to_hstring(expected)
            );
        end procedure;
    begin
        -- LB choose byte
        check_result(X"01020304", "00", SEL_LB, X"00000004");
        check_result(X"01020304", "01", SEL_LB, X"00000003");
        check_result(X"01020304", "10", SEL_LB, X"00000002");
        check_result(X"01020304", "11", SEL_LB, X"00000001");

        -- LB sign extention
        check_result(X"FE00007E", "00", SEL_LB, X"0000007E");
        check_result(X"FE00007E", "11", SEL_LB, X"FFFFFFFE");

        -- LH choose byte
        check_result(X"22221111", "00", SEL_LH, X"00001111");
        check_result(X"22221111", "10", SEL_LH, X"00002222");

        -- LH sign extention
        check_result(X"FFFE7FFE", "00", SEL_LH, X"00007FFE");
        check_result(X"FFFE7FFE", "10", SEL_LH, X"FFFFFFFE");

        -- LW
        check_result(X"12345678", "00", SEL_LW, X"12345678");
        check_result(X"FFDDEEBB", "00", SEL_LW, X"FFDDEEBB");

        -- LBU choose and no sign extention
        check_result(X"FE02037E", "00", SEL_LBU, X"0000007E");
        check_result(X"FE02037E", "01", SEL_LBU, X"00000003");
        check_result(X"FE02037E", "10", SEL_LBU, X"00000002");
        check_result(X"FE02037E", "11", SEL_LBU, X"000000FE");

        -- LH choose and no sign extention
        check_result(X"FFFE7FFE", "00", SEL_LHU, X"00007FFE");
        check_result(X"FFFE7FFE", "10", SEL_LHU, X"0000FFFE");

        wait for 1 ns;

        if success then
            report "testbench LM succesful!";
        else
            report "testbench LM failed!";
        end if;
        wait;
    end process;
end architecture rtl;