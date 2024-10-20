library IEEE;
library WORK;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use WORK.constants.all;
entity ALU_tb is
end entity ALU_tb;

architecture rtl of ALU_tb is
    constant WORD_WIDTH : natural := 32;
    subtype word is std_logic_vector(WORD_WIDTH - 1 downto 0);

    component ALU
        generic (
            WORD_WIDTH : natural := 32
        );
        port (
            opA : in std_logic_vector(WORD_WIDTH - 1 downto 0);
            opB : in std_logic_vector(WORD_WIDTH - 1 downto 0);
            res : out std_logic_vector(WORD_WIDTH - 1 downto 0);
            aluOp : in unsigned(3 downto 0)
        );
    end component ALU;

    signal opA : word := (others => '0');
    signal opB : word := (others => '0');
    signal res : word;
    signal aluOp : alu_op_sel := "0000";

begin

    uut : ALU generic map(WORD_WIDTH => WORD_WIDTH) port map(opA => opA, opB => opB, res => res, aluOp => aluOp);

end architecture rtl;