library IEEE;
library WORK;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use WORK.constants.all;
use IEEE.std_logic_textio;
entity ALU_tb is
end entity ALU_tb;

architecture rtl of ALU_tb is
    constant WORD_WIDTH : natural := 32;
    subtype word is signed(WORD_WIDTH - 1 downto 0);

    component ALU
        generic (
            WORD_WIDTH : natural := 32
        );
        port (
            opA : in signed(WORD_WIDTH - 1 downto 0);
            opB : in signed(WORD_WIDTH - 1 downto 0);
            res : out signed(WORD_WIDTH - 1 downto 0);
            aluOp : in unsigned(3 downto 0)
        );
    end component ALU;

    signal opA : word := (others => '0');
    signal opB : word := (others => '0');
    signal res : word;
    signal aluOp : alu_op_sel := "0000";

    signal success : boolean := true;
begin

    uut : ALU generic map(WORD_WIDTH => WORD_WIDTH) port map(opA => opA, opB => opB, res => res, aluOp => aluOp);

    process

        procedure check(value : boolean; message : string := "") is begin
            if not value then
                success <= false;
                assert false report message severity error;
            end if;
        end procedure;

        procedure check_result(operandA : word; operandB : word; op_sel : alu_op_sel; result : word) is begin
            opA <= operandA;
            opB <= operandB;
            aluOp <= op_sel;

            wait for 1 ns;

            check(result = res, "result of operation " & to_hstring(op_sel) & " with operands " &
            to_hstring(operandA) & " and " & to_hstring(operandB) &
            " is " & to_hstring(res) & " but should be " & to_hstring(result)
            );
        end procedure;
    begin
        check_result(X"00000000", X"00000000", SEL_ADD, X"00000000");
        check_result(X"FFFFFFFF", X"FFFFFFFF", SEL_ADD, X"FFFFFFFE");
        check_result(X"AA00AA00", X"00BB00BB", SEL_ADD, X"AABBAABB");
        check_result(X"00000005", X"00000005", SEL_ADD, X"0000000A");
        check_result(X"FFFFFFFF", X"00000001", SEL_ADD, X"00000000");
        check_result(X"7FFFFFFF", X"00000003", SEL_ADD, X"80000002");
        check_result(X"0000FFFF", X"00000001", SEL_ADD, X"00010000");
        check_result(X"00000018", X"00000045", SEL_ADD, X"0000005D");
        check_result(X"00000002", X"00000001", SEL_ADD, X"00000003");
        check_result(X"12345678", X"11111111", SEL_ADD, X"23456789");

        check_result(X"00000000", X"00000000", SEL_SUB, X"00000000");
        check_result(X"00000000", X"00000001", SEL_SUB, X"FFFFFFFF");
        check_result(X"00000001", X"00000001", SEL_SUB, X"00000000");
        check_result(X"FFFFFFFF", X"FFFFFFFF", SEL_SUB, X"00000000");
        check_result(X"AABBAABB", X"00BB00BB", SEL_SUB, X"AA00AA00");
        check_result(X"00000001", X"FFFFFFFF", SEL_SUB, X"00000002");
        check_result(X"00000045", X"00000018", SEL_SUB, X"0000002D");
        check_result(X"00000018", X"00000045", SEL_SUB, X"FFFFFFD3");
        check_result(X"12345678", X"11111111", SEL_SUB, X"01234567");
        check_result(X"00010000", X"00000001", SEL_SUB, X"0000FFFF");
        

        if success then
            report "testbench PC succesful!";
        else
            report "testbench PC failed!";
        end if;
        wait;
    end process;
end architecture rtl;