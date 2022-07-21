-------------------------------------------------------
--! @secded_dec_tb.vhd
--! @brief Descrição do Testbench codificador de Hamming genérico
--! @author Tiago M Lucio (tiagolucio@usp.br)
--! @date 2022-07-20
-------------------------------------------------------

library ieee;
use ieee.numeric_bit.all;
use ieee.math_real.all;

entity secded_dec_tb is
end entity;

architecture test of secded_dec_tb is
    component secded_enc8 is
        port (
            u_data: in bit_vector(7 downto 0);
            mem_data: out bit_vector(12 downto 0)
        );
    end component;

    component secded_enc16 is
        port (
            u_data: in bit_vector(15 downto 0);
            mem_data: out bit_vector(21 downto 0)
        );
    end component;

    component secded_dec is
        generic(
            data_size: positive := 16
        );
        port (
            mem_data: in bit_vector(data_size + positive(ceil(log2(real(data_size)))) + 1 downto 0);
            u_data: out bit_vector(data_size - 1 downto 0);
            uncorrectable_error: out bit
        );
    end component;
    
    signal data_i8, data_o8: bit_vector(7 downto 0);
    signal mem_data_i8, mem_data_o8: bit_vector(12 downto 0);
    signal uncorrectable_error8: bit;

    signal data_i16, data_o16: bit_vector(15 downto 0);
    signal mem_data_i16, mem_data_o16: bit_vector(21 downto 0);
    signal uncorrectable_error16: bit;

begin
    enc8: secded_enc8
        port map (data_i8, mem_data_o8);
    enc16: secded_enc16
        port map (data_i16, mem_data_o16);
    dec8: secded_dec
        generic map (8)
        port map (mem_data_i8, data_o8, uncorrectable_error8);
    dec16: secded_dec
        generic map (16)
        port map (mem_data_i16, data_o16, uncorrectable_error16);

    process 
    type pattern_array is array (integer range<>) of integer;
    constant patterns8 : pattern_array :=
        (
            0,
            1,
            2,
            3,
            4,
            5,
            7,
            8,
            10,
            20,
            25,
            31,
            32,
            50,
            64,
            90,
            97,
            99,
            100,
            101,
            120,
            127,
            128,
            129,
            150,
            200,
            250,
            254,
            255
        );

    constant patterns16 : pattern_array :=
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

        report real'image(ceil(log2(real(8))));

        wait for 1 ns;

        for i in patterns8'range loop
            wait for 1 ns;
            data_i8 <= bit_vector(to_unsigned(patterns8(i), 8));

            wait for 1 ns;

            mem_data_i8 <= mem_data_o8;
      
            wait for 1 ns;
            assert data_o8 = data_i8 and uncorrectable_error8 = '0'
                report "Deu ruim :(" & LF &
                    HT & "entrada: " & integer'image(patterns8(i)) & LF &
                    HT & "esperado: data_o =" & integer'image(patterns8(i)) & " uncorrectable_error = '0'" & LF &
                    HT & "obtido  : data_o =" & integer'image(to_integer(unsigned(data_o8))) & " uncorrectable_error = " & bit'image(uncorrectable_error8) & LF;

            wait for 1 ns;
            mem_data_i8(i mod 13) <= not mem_data_i8(i mod 13);

            wait for 1 ns;
            assert data_i8 = data_o8 and uncorrectable_error8 = '0'
                report "Deu ruim :(" & LF &
                    HT & "entrada: " & integer'image(patterns8(i)) & LF &
                    HT & "esperado: data_o =" & integer'image(patterns8(i)) & " uncorrectable_error = '0'" & LF &
                    HT & "obtido  : data_o =" & integer'image(to_integer(unsigned(data_o8))) & " uncorrectable_error = " & bit'image(uncorrectable_error8) & LF;

            wait for 1 ns;
            mem_data_i8((i + 5) mod 13) <= not mem_data_i8((i + 5) mod 13);

            wait for 1 ns;
            assert uncorrectable_error8 = '1'
                report "Deu ruim :(" & LF &
                    HT & "entrada: " & integer'image(patterns8(i)) & LF &
                    HT & "esperado: uncorrectable_error = '1'" & LF &
                    HT & "obtido  : uncorrectable_error = " & bit'image(uncorrectable_error8) & LF;
        end loop; 

        wait for 1 ns;
        
        for i in patterns16'range loop
            wait for 1 ns;
            data_i16 <= bit_vector(to_unsigned(patterns16(i), 16));

            wait for 1 ns;

            mem_data_i16 <= mem_data_o16;
      
            wait for 1 ns;
            assert data_o16 = data_i16 and uncorrectable_error16 = '0'
                report "Deu ruim :(" & LF &
                    HT & "entrada: " & integer'image(patterns16(i)) & LF &
                    HT & "esperado: data_o =" & integer'image(patterns16(i)) & " uncorrectable_error = '0'" & LF &
                    HT & "obtido  : data_o =" & integer'image(to_integer(unsigned(data_o16))) & " uncorrectable_error = " & bit'image(uncorrectable_error16) & LF;

            wait for 1 ns;
            mem_data_i16(i mod 22) <= not mem_data_i16(i mod 22);

            wait for 1 ns;
            assert data_i16 = data_o16 and uncorrectable_error16 = '0'
                report "Deu ruim :(" & LF &
                    HT & "entrada: " & integer'image(patterns16(i)) & LF &
                    HT & "esperado: data_o =" & integer'image(patterns16(i)) & " uncorrectable_error = '0'" & LF &
                    HT & "obtido  : data_o =" & integer'image(to_integer(unsigned(data_o16))) & " uncorrectable_error = " & bit'image(uncorrectable_error16) & LF;

            wait for 1 ns;
            mem_data_i16((i + 5) mod 22) <= not mem_data_i16((i + 5) mod 22);

            wait for 1 ns;
            assert uncorrectable_error16 = '1'
                report "Deu ruim :(" & LF &
                    HT & "entrada: " & integer'image(patterns16(i)) & LF &
                    HT & "esperado: uncorrectable_error = '1'" & LF &
                    HT & "obtido  : uncorrectable_error = " & bit'image(uncorrectable_error16) & LF;
        end loop; 
      
        report "EOF"; 
        wait;
    end process;

end architecture;