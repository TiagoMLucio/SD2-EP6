-------------------------------------------------------
--! @secded_dec16.vhd
--! @brief Descrição do decodificador de Hamming(22,16)
--! @author Tiago M Lucio (tiagolucio@usp.br)
--! @date 2022-07-20
-------------------------------------------------------

library ieee;
use ieee.numeric_bit.all;

entity secded_dec16 is
    port (
        mem_data: in bit_vector(21 downto 0);
        u_data: out bit_vector(15 downto 0);
        syndrome: out natural;
        two_errors: out bit;
        one_error: out bit
    );
end entity;

architecture arch of secded_dec16 is

    signal c0, c1, c2, c3, c4, c5 : bit;
    signal aux: bit_vector(15 downto 0);
    signal data: bit_vector(21 downto 0);

begin

    aux <= mem_data(20 downto 16) & mem_data(14 downto 8) & mem_data(6 downto 4) & mem_data(2);

    c0 <= mem_data(0) xor aux(15) xor aux(13) xor aux(11) xor aux(10) xor aux(8) xor aux(6) xor aux(4) xor aux(3) xor aux(1) xor aux(0);
    c1 <= mem_data(1) xor aux(13) xor aux(12) xor aux(10) xor aux(9) xor aux(6) xor aux(5) xor aux(3) xor aux(2) xor aux(0);
    c2 <= mem_data(3) xor aux(15) xor aux(14) xor aux(10) xor aux(9) xor aux(8) xor aux(7) xor aux(3) xor aux(2) xor aux(1);
    c3 <= mem_data(7) xor aux(10) xor aux(9) xor aux(8) xor aux(7) xor aux(6) xor aux(5) xor aux(4);
    c4 <= mem_data(15) xor aux(15) xor aux(14) xor aux(13) xor aux(12) xor aux(11);
    c5 <= mem_data(21) xor mem_data(0) xor mem_data(1) xor mem_data(3) xor mem_data(7) xor mem_data(15) xor 
        aux(15) xor aux(14) xor aux(13) xor aux(12) xor aux(11) xor aux(10) xor aux(9) xor aux(8) xor 
        aux(7) xor aux(6) xor aux(5) xor aux(4) xor aux(3) xor aux(2) xor aux(1) xor aux(0);

    one_error <= c5;
    two_errors <= (c4 or c3 or c2 or c1 or c0) and (not c5);
    
    error_correction : for i in 0 to 21 generate
        data(i) <= not mem_data(i) when ((c4 & c3 & c2 & c1 & c0) = to_unsigned(i + 1, 5)) else mem_data(i);
    end generate ; -- error_correction
    
    u_data <= data(20 downto 16) & data(14 downto 8) & data(6 downto 4) & data(2);

end arch ; -- arch

0111111