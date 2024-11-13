library IEEE;
library WORK;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use WORK.constants.all;

entity Imm_ext is
    port (
        instr : in std_logic_vector(31 downto 0);
        instType : in opcode;
        immExt : out std_logic_vector(31 downto 0)
    );
end entity Imm_ext;

architecture rtl of Imm_ext is
    alias imm12_i : std_logic_vector(11 downto 0) is instr(31 downto 20);
    signal imm12_s : std_logic_vector(11 downto 0);
    signal imm12 : std_logic_vector(11 downto 0);
begin
    imm12_s <= instr(31 downto 25) & instr(11 downto 7);

    with instType select imm12 <=
        imm12_i when OPCODE_I,
        imm12_i when OPCODE_LOAD,
        imm12_s when OPCODE_S,
        (others => '0') when others;

    immExt <= (31 downto 12 => imm12(11)) & imm12;

end architecture rtl;