-------------------------------------------------------
--! @secded_dec16_tb.vhd
--! @brief Descrição do Testbench codificador de Hamming(22,16)
--! @author Tiago M Lucio (tiagolucio@usp.br)
--! @date 2022-07-20
-------------------------------------------------------

library ieee;
use ieee.numeric_bit.all;

entity secded_dec16_tb is
end entity;

architecture test of secded_dec16_tb is
    component secded_enc16 is
        port (
            u_data: in bit_vector(15 downto 0);
            mem_data: out bit_vector(21 downto 0)
        );
    end component;

    component secded_dec16 is
        port (
            mem_data: in bit_vector(21 downto 0);
            u_data: out bit_vector(15 downto 0);
            syndrome: out natural;
            two_errors: out bit;
            one_error: out bit
        );
    end component;

    signal data_i, data_o: bit_vector(15 downto 0);
    signal mem_data_i, mem_data_o: bit_vector(21 downto 0);
    signal two_errors: bit;
    signal one_error: bit;

begin
    enc: secded_enc16
        port map (data_i, mem_data_o);
    dec: secded_dec16
        port map (mem_data_i, data_o, open, two_errors, one_error);

    process 
    type pattern_array is array (integer range<>) of integer;
    constant patterns : pattern_array :=
      (
        0,
        1,
        2,
        4,
        5,
        8,
        16,
        32,
        50,
        64,
        83,
        101,
        128,
        200,
        500,
        732,
        1000,
        1024,
        2342,
        5231,
        8342,
        13245,
        23542,
        35535,
        40000,
        51234,
        65534,
        65535
      );
    begin
        report "BOT";

        for i in patterns'range loop
            wait for 1 ns;
            data_i <= bit_vector(to_unsigned(patterns(i), 16));

            wait for 1 ns;

            mem_data_i <= mem_data_o;
      
            wait for 1 ns;
            assert data_o = data_i and one_error = '0' and two_errors = '0'
                report "Deu ruim :(" & LF &
                    HT & "entrada: " & integer'image(patterns(i)) & LF &
                    HT & "esperado: data_o =" & integer'image(patterns(i)) & " one_error = '0' e two_erros = '0'" & LF &
                    HT & "obtido  : data_o =" & integer'image(to_integer(unsigned(data_o))) & " one_error = " & bit'image(one_error) & " e two_erros = " & bit'image(two_errors) & LF;

            wait for 1 ns;
            mem_data_i(i mod 22) <= not mem_data_i(i mod 22);

            wait for 1 ns;
            assert data_i = data_o and one_error = '1' and two_errors = '0'
                report "Deu ruim :(" & LF &
                    HT & "entrada: " & integer'image(patterns(i)) & LF &
                    HT & "esperado: data_o =" & integer'image(patterns(i)) & " one_error = '0' e two_erros = '0'" & LF &
                    HT & "obtido  : data_o =" & integer'image(to_integer(unsigned(data_o))) & " one_error = " & bit'image(one_error) & " e two_erros = " & bit'image(two_errors) & LF;

            wait for 1 ns;
            mem_data_i((i + 5) mod 22) <= not mem_data_i((i + 5) mod 22);

            wait for 1 ns;
            assert one_error = '0' and two_errors = '1'
                report "Deu ruim :(" & LF &
                    HT & "entrada: " & integer'image(patterns(i)) & LF &
                    HT & "esperado: one_error = '0' e two_erros = '0'" & LF &
                    HT & "obtido  : one_error = " & bit'image(one_error) & " e two_erros = " & bit'image(two_errors) & LF;
        end loop; 
      
        report "EOF"; 
        wait;
    end process;

end architecture;