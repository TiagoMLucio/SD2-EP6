-------------------------------------------------------
--! @secded_dec.vhd
--! @brief Descrição do decodificador de Hamming genérico
--! @author Tiago M Lucio (tiagolucio@usp.br)
--! @date 2022-07-20
-------------------------------------------------------

library ieee;
use ieee.numeric_bit.all;
use ieee.math_real.all;

entity secded_dec is
    generic(
        data_size: positive := 16
    );
    port (
        mem_data: out bit_vector(data_size + positive(ceil(log2(real(data_size)))) + 1 downto 0);
        u_data: in bit_vector(data_size - 1 downto 0)
    );
end entity;

architecture arch of secded_dec is

    type array_bv is array (natural range <>) of bit_vector (mem_data'length - 1 downto 0);

    signal p: array_bv (positive(ceil(log2(real(data_size)))) + 1 downto 0);

begin
    
    iterate_cs : for i in c'length - 2 downto 0 generate
        p(i)(2 ** (i) - 1) <= mem_data(2 ** (i));
        get_c : for j in u_data'length - 1 downto 2 ** (i) + 1 generate
            p(i)(j) <= p(i)(j - 1) xor u_data(j) when (((j + 1) mod (2 ** (i + 1))) > (2 ** (i) - 1)) else p(i)(j - 1);
        end generate ; -- get_c   
    end generate ; -- iterate_cs

    p(c'length - 1)(0) <= mem_data(0);
    get_cfinal : for j in mem_data'length - 2 downto 1 generate
        p(c'length - 1)(j) <= p(c'length - 1)(j - 1) xor mem_data(j);
    end generate ; -- get_cfinal

    mem_data(0) <= p(0)(mem_data'length - 2);
    mem_data(1) <= p(1)(mem_data'length - 2);

    get_data : for i in mem_data'length - 2 downto 2 generate
        if_not_p: if floor(log2(real(i) + 0.00001)) = floor(log2(real(i + 1)) + 0.00001) generate
        mem_data(i) <= u_data(i -  positive(floor(log2(real(i))+ 0.00001)) - 1);
        end generate;
        if_p: if floor(log2(real(i) + 0.00001)) /= floor(log2(real(i + 1)) + 0.00001) generate
        mem_data(i) <= u_data(i -  positive(floor(log2(real(i))+ 0.00001)) - 1);
        end generate;
    end generate ; -- get_data

end arch; -- arch