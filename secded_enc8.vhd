-------------------------------------------------------
--! @secded_enc8.vhd
--! @brief Descrição do codificador de Hamming(13,8)
--! @author Tiago M Lucio (tiagolucio@usp.br)
--! @date 2022-07-20
-------------------------------------------------------

library ieee;
use ieee.numeric_bit.all;

entity secded_enc8 is
    port (
        u_data: in bit_vector(7 downto 0);
        mem_data: out bit_vector(12 downto 0)
    );
end entity;

architecture arch of secded_enc8 is

    signal p0, p1, p2, p3, p4 : bit;

begin

    p0 <= u_data(6) xor u_data(4) xor u_data(3) xor u_data(1) xor u_data(0);
    p1 <= u_data(6) xor u_data(5) xor u_data(3) xor u_data(2) xor u_data(0);
    p2 <= u_data(7) xor u_data(3) xor u_data(2) xor u_data(1);
    p3 <= u_data(7) xor u_data(6) xor u_data(5) xor u_data(4);
    p4 <= p0 xor p1 xor p2 xor p3 xor 
        u_data(7) xor u_data(6) xor u_data(5) xor u_data(4) xor u_data(3) xor u_data(2) xor u_data(1) xor u_data(0);

    mem_data <= p4 & u_data(7 downto 4) & p3 & u_data(3 downto 1) & p2 & u_data(0) & p1 & p0;

end arch ; -- arch