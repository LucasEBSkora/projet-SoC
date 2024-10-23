library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Imm_ext_tb is end entity Imm_ext_tb;

architecture rtl of Imm_ext_tb is
    component Imm_ext
        port (
            instr : in std_logic_vector(31 downto 0);
            instType : in natural;
            immExt : out std_logic_vector(31 downto 0)
        );
    end component Imm_ext;

    signal instr : std_logic_vector(31 downto 0) := (others => '0');
    signal instType : natural := 0;
    signal immExt : std_logic_vector(31 downto 0);
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

        procedure check_result(new_instr : std_logic_vector(31 downto 0); instr_type : natural; expected : std_logic_vector(31 downto 0); instruction_name : string) is begin
            instr <= new_instr;
            instType <= instr_type;

            wait for 1 ns;

            check(immExt = expected, "immediate for instruction type " & integer'image(instr_type) &
            " with instruction " & instruction_name & "(" & to_hstring(new_instr) & ") is " &
            to_hstring(immExt) & " but should be " & to_hstring(expected)
            );
        end procedure;

        constant INSTRUCTION_I_ADD : std_logic_vector(31 downto 0) := B"000000000000_01000_000_00001_0010011";
        constant INSTRUCTION_I_SLT : std_logic_vector(31 downto 0) := B"111111111111_01100_010_10001_0010011";
        constant INSTRUCTION_I_SLTU : std_logic_vector(31 downto 0) := B"111111111100_01010_011_11001_0010011";
        constant INSTRUCTION_I_XOR : std_logic_vector(31 downto 0) := B"000000001010_01001_100_11101_0010011";
        constant INSTRUCTION_I_OR : std_logic_vector(31 downto 0) := B"000100100011_11000_110_11111_0010011";
        constant INSTRUCTION_I_OR2 : std_logic_vector(31 downto 0) := B"010101010101_00000_110_11110_0010011";
        constant INSTRUCTION_I_AND : std_logic_vector(31 downto 0) := B"000000000000_00010_111_01110_0010011";
        constant INSTRUCTION_I_SLL : std_logic_vector(31 downto 0) := B"011101100101_00001_001_00110_0010011";
        constant INSTRUCTION_I_SRL : std_logic_vector(31 downto 0) := B"000011111111_00100_101_00010_0010011";
        constant INSTRUCTION_I_SRA : std_logic_vector(31 downto 0) := B"011001100110_01000_101_00000_0010011";
    begin

        check_result(INSTRUCTION_I_ADD, 0, X"00000_000", "INSTRUCTION_I_ADD");
        check_result(INSTRUCTION_I_SLT, 0, X"FFFFF_FFF", "INSTRUCTION_I_SLT");
        check_result(INSTRUCTION_I_SLTU, 0, X"FFFFF_FFC", "INSTRUCTION_I_SLTU");
        check_result(INSTRUCTION_I_XOR, 0, X"00000_00A", "INSTRUCTION_I_XOR");
        check_result(INSTRUCTION_I_OR, 0, X"00000_123", "INSTRUCTION_I_OR");
        check_result(INSTRUCTION_I_OR2, 0, X"00000_555", "INSTRUCTION_I_OR2");
        check_result(INSTRUCTION_I_AND, 0, X"00000_000", "INSTRUCTION_I_AND");
        check_result(INSTRUCTION_I_SLL, 0, X"00000_765", "INSTRUCTION_I_SLL");
        check_result(INSTRUCTION_I_SRL, 0, X"00000_0FF", "INSTRUCTION_I_SRL");
        check_result(INSTRUCTION_I_SRA, 0, X"00000_666", "INSTRUCTION_I_SRA");

        wait for 1 ns;

        if success then
            report "testbench Imm_ext succesful!";
        else
            report "testbench Imm_ext failed!";
        end if;
        wait;
    end process;

end architecture rtl;