library IEEE;
library WORK;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use WORK.constants.all;

entity Imm_ext_tb is end entity Imm_ext_tb;

architecture rtl of Imm_ext_tb is
    subtype word is std_logic_vector(31 downto 0);

    component Imm_ext
        port (
            instr : in std_logic_vector(31 downto 0);
            instType : in opcode;
            immExt : out std_logic_vector(31 downto 0)
        );
    end component Imm_ext;

    signal instr : word := (others => '0');
    signal instType : opcode := (others => '0');
    signal immExt : word;
    signal success : boolean := true;
begin

    immediate : Imm_ext port map(instr => instr, instType => instType, immExt => immExt);

    process

        procedure check(value : boolean; message : string := "") is begin
            if not value then
                success <= false;
                assert false report message severity error;
            end if;
        end procedure;

        procedure check_result(new_instr : word; instr_type : opcode; expected : word; instruction_name : string) is begin
            instr <= new_instr;
            instType <= instr_type;

            wait for 1 ns;

            check(immExt = expected, "immediate for instruction type " & to_hstring(instr_type) &
            " with instruction " & instruction_name & "(" & to_hstring(new_instr) & ") is " &
            to_hstring(immExt) & " but should be " & to_hstring(expected)
            );
        end procedure;

        constant INSTRUCTION_I_ADD : word := B"000000000000_01000_000_00001_0010011";
        constant INSTRUCTION_I_SLT : word := B"111111111111_01100_010_10001_0010011";
        constant INSTRUCTION_I_SLTU : word := B"111111111100_01010_011_11001_0010011";
        constant INSTRUCTION_I_XOR : word := B"000000001010_01001_100_11101_0010011";
        constant INSTRUCTION_I_OR : word := B"000100100011_11000_110_11111_0010011";
        constant INSTRUCTION_I_OR2 : word := B"010101010101_00000_110_11110_0010011";
        constant INSTRUCTION_I_AND : word := B"000000000000_00010_111_01110_0010011";
        constant INSTRUCTION_I_SLL : word := B"011101100101_00001_001_00110_0010011";
        constant INSTRUCTION_I_SRL : word := B"000011111111_00100_101_00010_0010011";
        constant INSTRUCTION_I_SRA : word := B"011001100110_01000_101_00000_0010011";

        constant INSTRUCTION_S_1 : word := B"0000000_00000_00000_000_00000_0100011";
        constant INSTRUCTION_S_2 : word := B"1111111_00000_00000_000_11111_0100011";
        constant INSTRUCTION_S_3 : word := B"1010101_00000_00000_000_01010_0100011";
    begin

        check_result(INSTRUCTION_I_ADD, OPCODE_I, X"00000_000", "INSTRUCTION_I_ADD");
        check_result(INSTRUCTION_I_SLT, OPCODE_I, X"FFFFF_FFF", "INSTRUCTION_I_SLT");
        check_result(INSTRUCTION_I_SLTU, OPCODE_I, X"FFFFF_FFC", "INSTRUCTION_I_SLTU");
        check_result(INSTRUCTION_I_XOR, OPCODE_I, X"00000_00A", "INSTRUCTION_I_XOR");
        check_result(INSTRUCTION_I_OR, OPCODE_I, X"00000_123", "INSTRUCTION_I_OR");
        check_result(INSTRUCTION_I_OR2, OPCODE_I, X"00000_555", "INSTRUCTION_I_OR2");
        check_result(INSTRUCTION_I_AND, OPCODE_I, X"00000_000", "INSTRUCTION_I_AND");
        check_result(INSTRUCTION_I_SLL, OPCODE_I, X"00000_765", "INSTRUCTION_I_SLL");
        check_result(INSTRUCTION_I_SRL, OPCODE_I, X"00000_0FF", "INSTRUCTION_I_SRL");
        check_result(INSTRUCTION_I_SRA, OPCODE_I, X"00000_666", "INSTRUCTION_I_SRA");

        check_result(B"011001100110_01000_101_00000_0010011", OPCODE_LOAD, X"00000_666", "INSTRUCTION LOAD");

        check_result(INSTRUCTION_S_1, OPCODE_S, X"00000_000", "INSTRUCTION_S_1");
        check_result(INSTRUCTION_S_2, OPCODE_S, X"FFFFF_FFF", "INSTRUCTION_S_2");
        check_result(INSTRUCTION_S_3, OPCODE_S, X"FFFFF_AAA", "INSTRUCTION_S_3");

        wait for 1 ns;

        if success then
            report "testbench Imm_ext succesful!";
        else
            report "testbench Imm_ext failed!";
        end if;
        wait;
    end process;

end architecture rtl;