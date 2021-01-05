-- Copyright (c) 2013 Malte Graeper (mgraep@t-online.de) All rights reserved.

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package qfp32_test_p is

  type result_array_t is array (natural range <>) of std_ulogic_vector(31 downto 0);

  type qfp_test_t is record
    a : std_ulogic_vector(31 downto 0);
    b : std_ulogic_vector(31 downto 0);
    gt : std_ulogic;
    eq : std_ulogic;
    results : result_array_t(9 downto 0);
  end record qfp_test_t;

  type qfp_test_vector_t is array (natural range <>) of qfp_test_t;

end package qfp32_test_p;
