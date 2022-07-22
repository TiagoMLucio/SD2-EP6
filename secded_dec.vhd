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
        mem_data: in bit_vector(data_size + positive(ceil(log2(real(data_size)))) + 1 downto 0);
        u_data: out bit_vector(data_size - 1 downto 0);
        uncorrectable_error: out bit
    );
end entity;

architecture arch of secded_dec is

    type array_bv is array (natural range <>) of bit_vector (mem_data'length - 1 downto 0);

    -- c(i)(mem_data'length - 2) recebe 0 se a paridade p_i está correta e recebe 1 caso contrário (para c'length - 1 > i >= 0)
    -- c(c'length - 1)(mem_data'length - 1) recebe 0 se a paridade total está correta e recebe 1 caso contrário
    signal c: array_bv (positive(ceil(log2(real(data_size)))) + 1 downto 0);

    -- posição do erro na palavra
    signal syndrome: bit_vector(c'length - 2 downto 0);

begin
    
    iterate_cs : for i in c'length - 2 downto 0 generate
        c(i)(2 ** (i) - 1) <= mem_data(2 ** (i) - 1);
        get_c : for j in mem_data'length - 2 downto 2 ** (i) generate
            c(i)(j) <= c(i)(j - 1) xor mem_data(j) when (((j + 1) mod (2 ** (i + 1))) > (2 ** (i) - 1)) else c(i)(j - 1);
        end generate ; -- get_c   
        syndrome(i) <= c(i)(mem_data'length - 2); 
    end generate ; -- iterate_cs

    c(c'length - 1)(0) <= mem_data(0);
    get_cfinal : for j in mem_data'length - 1 downto 1 generate
        c(c'length - 1)(j) <= c(c'length - 1)(j - 1) xor mem_data(j);
    end generate ; -- get_cfinal

    -- syndrome não nula e paridade total correta
    uncorrectable_error <=  not c(c'length - 1)(mem_data'length - 1) when (unsigned(syndrome) /= 0) else '0';

    -- mem_data ignorando os bits de paridade
    -- corrige o bit caso i + 1 seja o valor da syndrome
    get_data : for i in mem_data'length - 2 downto 2 generate
        check_if_p: if floor(log2(real(i) + 0.00001)) = floor(log2(real(i + 1)) + 0.00001) generate
         u_data(i -  positive(floor(log2(real(i))+ 0.00001)) - 1) <= not mem_data(i) when (unsigned(syndrome) = i + 1) else mem_data(i);
        end generate;
    end generate ; -- get_data

end arch; -- arch

