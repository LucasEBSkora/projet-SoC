library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Imm_ext is
    port (
        instr : in std_logic_vector(31 downto 0);
        instType : in natural;
        immExt : out std_logic_vector(31 downto 0)
    );
end entity Imm_ext;

architecture rtl of Imm_ext is
    alias imm12 : std_logic_vector(11 downto 0) is instr(31 downto 20);
begin

    immExt <= (31 downto 12 => imm12(11)) & imm12;

end architecture rtl;