-- Copyright (c) 2018 Malte Graeper (mgraep@t-online.de) All rights reserved.

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.qfp_p.all;
use work.qfp32_misc_p.all;

entity qfp32_math is
  
  port (
    clk_i     : in  std_ulogic;
    reset_n_i : in  std_ulogic;

    en_i : in std_ulogic;

    cmd_i : in qfp_scmd_t;
    
    start_i : in  std_ulogic;
    ready_o : out std_ulogic;
    
    regA_i : in  qfp32_t;
    regB_i : in  qfp32_t;
    
    complete_o : out std_ulogic;
    result_o   : out qfp32_raw_t);

end qfp32_math;

architecture Rtl of qfp32_math is

  function expand (
    mant : std_ulogic_vector(28 downto 0);
    sign : std_ulogic;
    exp  : std_ulogic_vector(1 downto 0))
    return std_ulogic_vector is
    variable result : std_ulogic_vector(52 downto 0);
  begin
    result := (others => '0');
    result(28+to_integer(unsigned(exp))*8-1 downto to_integer(unsigned(exp))*8) := mant;
    return result;
  end function;

  function msbPos (
    data : unsigned)
    return unsigned is
    variable result : integer;
  begin  -- function msbPos
    result := data'length-1;
    while data(result+data'right) = '0' loop
      result := result-1;
    end loop;

    return to_unsigned(result,log2(data'length));
    
  end function msbPos;

  signal p1_shft_dir : std_ulogic;
  signal p1_int_sign : std_ulogic;

  signal p1_shift_bits : unsigned(4 downto 0);
  signal p1_int_part : unsigned(4 downto 0);
  signal p1_frac : unsigned(23 downto 0);

  signal p1_mant : unsigned(28 downto 0);

  signal first_bit_pos : unsigned(2 downto 0);
  signal p1_neg : unsigned(23 downto 0);

begin  -- Rtl

  -- 101.11 = 5.75
  -- 2 + 0.0111=0.25+0.125+0.0625

  -- 0.001100 = 0.125+0.0625

  process (first_bit_pos, p1_frac, p1_int_part, p1_shift_bits, regA_i.fmt.exp,
           regA_i.mant(23 downto 0), regA_i.mant(28 downto 21),
           regA_i.mant(28 downto 24), regA_i.mant(28 downto 5), p1_neg) is
    variable leading_zeros : unsigned(4 downto 0);
    variable first_bit_pos2 : unsigned(2 downto 0);
  begin  -- process
      if regA_i.fmt.exp = qfp_x0 and regA_i.mant(28 downto 24) = "00000" then
        p1_shft_dir <= '0'; -- left shift
        leading_zeros := fast_leading_zeros(To_StdULogicVector(std_logic_vector(regA_i.mant(23 downto 0))))(4 downto 0);
        p1_shift_bits <= leading_zeros+1;
        p1_int_part <= leading_zeros;
        p1_int_sign <= '1';
        p1_frac <= regA_i.mant(23 downto 0);
        p1_neg <= (others => '1');
      else
        p1_shft_dir <= '1';
        first_bit_pos2 := fast_leading_zeros(To_StdULogicVector(std_logic_vector(regA_i.mant(28 downto 21))))(2 downto 0);
        first_bit_pos <= first_bit_pos2;
        p1_shift_bits <= '0' & (to_unsigned(1,4)+('0' & first_bit_pos2));
        p1_int_part <= (regA_i.fmt.exp & (to_unsigned(7,3)-first_bit_pos2))-to_unsigned(3,5);
        p1_int_sign <= '0';
        p1_frac <= regA_i.mant(28 downto 5);
        p1_neg <= (others => '0');
      end if;

      p1_mant <= p1_int_part & (fast_shift(p1_frac,to_integer(p1_shift_bits),'0')(23 downto 0) xor p1_neg);
    
  end process;

  result_o <= (p1_mant & to_unsigned(0,24),"00000",'0' & qfp_x0,p1_int_sign);
  ready_o <= '1';
  complete_o <= start_i;
  
end rtl;

