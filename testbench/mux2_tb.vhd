library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mux2_tb is end entity mux2_tb;

architecture rtl of mux2_tb is
    constant WORD_WIDTH : natural := 4;
    subtype word is std_logic_vector(WORD_WIDTH - 1 downto 0);

    component mux2
        generic (
            WORD_WIDTH : natural := 32
        );
        port (
            sel : in std_logic;
            in1 : in std_logic_vector(WORD_WIDTH - 1 downto 0);
            in2 : in std_logic_vector(WORD_WIDTH - 1 downto 0);
            qo : out std_logic_vector(WORD_WIDTH - 1 downto 0)
        );
    end component mux2;

    signal sel : std_logic;
    signal in1 : word;
    signal in2 : word;
    signal qo : word;

    signal success : boolean := true;
begin

    mux2_inst : mux2 generic map(WORD_WIDTH => WORD_WIDTH) port map(sel => sel, in1 => in1, in2 => in2, qo => qo);

    process
        procedure check(value : boolean; message : string := "") is begin
            if not value then
                success <= false;
                assert false report message severity error;
            end if;
        end procedure;

        procedure check_result(A : word; B : word; s0 : std_logic; expected : word) is begin
            in1 <= A;
            in2 <= B;
            sel <= s0;
            wait for 1 ns;

            check(qo = expected, "mux with input 0 = " & to_hstring(in1) &
            ", input 1 = " & to_hstring(in2) & " and sel = " & std_logic'image(sel) & " is " &
            to_hstring(qo) & " but should be " & to_hstring(expected)
            );
        end procedure;

    begin

        wait for 1 ns;

        check_result(X"A", X"B", '0', X"A");
        check_result(X"A", X"B", '1', X"B");
        check_result(X"A", X"C", '1', X"C");
        check_result(X"D", X"C", '1', X"C");

        if success then
            report "testbench mux2 succesful!";
        else
            report "testbench mux2 failed!";
        end if;
        wait;
    end process;

end architecture rtl;