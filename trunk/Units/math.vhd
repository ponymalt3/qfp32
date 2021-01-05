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

  signal p1_shft_dir : std_ulogic;
  signal p1_int_sign : std_ulogic;

  signal p1_shift_bits : unsigned(4 downto 0);
  signal p1_int_part : unsigned(4 downto 0);
  signal p1_frac : unsigned(28 downto 0);

  signal p1_mant : unsigned(28 downto 0);

  signal first_bit_pos : unsigned(2 downto 0);
  signal p1_neg : unsigned(23 downto 0);

  signal p1_shft_value : unsigned(5 downto 0);
  signal p1_shf_exp : unsigned(3 downto 0);
  signal p1_shf_exp2 : unsigned(3 downto 0);

  signal p1_cmd : qfp_scmd_t;
  signal p1_exp : unsigned(2 downto 0);
  signal p1_overflow : std_ulogic;

  signal p1_exp_adjust : unsigned(3 downto 0);
  signal shf_exp : unsigned(3 downto 0);
  signal shf_value : unsigned(5 downto 0);

  signal p2_en : std_ulogic;
  signal p2_cmd : qfp_scmd_t;
  signal p2_mant : unsigned(28 downto 0);
  signal p2_exp : unsigned(2 downto 0);
  signal p2_neg : unsigned(23 downto 0);
  signal p2_shf_result : unsigned(28 downto 0);
  signal p2_frac : unsigned(28 downto 0);
  signal p2_shft_dir : std_ulogic;
  signal p2_shift_bits : unsigned(4 downto 0);
  signal p2_int_part : unsigned(4 downto 0);
  signal p2_int_sign : std_ulogic;
  signal p2_overflow : std_ulogic;

begin  -- Rtl

  process (clk_i, reset_n_i) is
  begin  -- process
    if reset_n_i = '0' then             -- asynchronous reset (active low)
      p2_en <= '0';
      p2_cmd <= "00";
      p2_exp <= to_unsigned(0,3);
      p2_frac <= (others => '0');
      p2_neg <= to_unsigned(0,24);
      p2_shft_dir <= '0';
      p2_shift_bits <= to_unsigned(0,5);
      p2_int_part <= to_unsigned(0,5);
      p2_int_sign <= '0';
    elsif clk_i'event and clk_i = '1' then  -- rising clock edge
      if en_i = '1' then
        p2_en <= start_i;
        p2_cmd <= p1_cmd;
        p2_exp <= p1_exp;
        p2_frac <= p1_frac;
        p2_neg <= p1_neg;
        p2_shft_dir <= p1_shft_dir;
        p2_shift_bits <= p1_shift_bits;
        p2_int_part <= p1_int_part;
        p2_int_sign <= p1_int_sign;
      end if;
    end if;
  end process;

  -- 101.11 = 5.75
  -- 2 + 0.0111=0.25+0.125+0.0625

  -- 0.001100 = 0.125+0.0625

  process (cmd_i, p1_cmd, p1_exp, p1_neg, p1_shf_exp, p1_shf_exp2, p1_shft_dir,
           p1_shft_value, p2_cmd, p2_frac, p2_int_part, p2_shf_result,
           p2_shft_dir, p2_shift_bits, regA_i,regB_i, shf_value) is
    variable leading_zeros : unsigned(4 downto 0);
    variable first_bit_pos2 : unsigned(2 downto 0);
    variable shf_bits : unsigned(3 downto 0);
    variable exp_add : unsigned(3 downto 0);    
    variable exp_sub : unsigned(3 downto 0);
  begin  -- process

    p1_cmd <= cmd_i;
    p1_frac <= regA_i.mant(28 downto 0);
    p1_neg <= (others => '0');
    p1_shift_bits <= to_unsigned(0,5);
    p1_exp <= '0' & qfp_x0;
    p1_shft_dir <= '0';
    p1_int_part <= to_unsigned(0,5);
    p1_int_sign <= '0';
    p1_overflow <= '0';

    p1_shft_value <= to_unsigned(0,6);
    p1_shf_exp <= to_unsigned(0,4);
    p1_shf_exp2 <= to_unsigned(0,4);
    shf_exp <= to_unsigned(0,4);

    leading_zeros := fast_leading_zeros(To_StdULogicVector(std_logic_vector(regA_i.mant(23 downto 0))))(4 downto 0);
    first_bit_pos2 := fast_leading_zeros(To_StdULogicVector(std_logic_vector(regA_i.mant(28 downto 21))))(2 downto 0);
    first_bit_pos <= first_bit_pos2;

    if p1_cmd = "00" then
      if regA_i.fmt.exp = qfp_x0 and regA_i.mant(28 downto 24) = "00000" then
        p1_shft_dir <= '0'; -- left shift
        p1_shift_bits <= leading_zeros+1;
        p1_int_part <= leading_zeros;
        p1_int_sign <= '1';
        p1_frac(23 downto 0) <= regA_i.mant(23 downto 0);
        p1_neg <= (others => '1');
      else
        p1_shft_dir <= '0';        
        first_bit_pos <= first_bit_pos2;
        p1_shift_bits <= '0' & (to_unsigned(1,4)+('0' & first_bit_pos2));
        p1_int_part <= (regA_i.fmt.exp & (to_unsigned(7,3)-first_bit_pos2))-to_unsigned(3,5);
        p1_int_sign <= '0';
        p1_frac(23 downto 0) <= regA_i.mant(28 downto 5);
        p1_neg <= (others => '0');
      end if;
    else

      p1_int_sign <= regA_i.fmt.sign;

      -- limit shift value
      p1_shft_value <= '0' & unsigned(regB_i.mant(28 downto 24));
      if regB_i.fmt.exp = "01" and regB_i.mant(28 downto 22) = to_unsigned(0,7) then
        p1_shft_value <= unsigned(regB_i.mant(21 downto 16));
      elsif regB_i.fmt.exp /= "00" then
        p1_shft_value <= to_unsigned(63,6); -- overflow
      end if;

      shf_value <= to_unsigned(0,6);
      if regB_i.fmt.sign = '0' then         -- shift left
        if regA_i.fmt.exp = "00" and regA_i.mant(28 downto 24) = "00000" then
          if p1_shft_value > (('0' & leading_zeros)+5) then
            shf_value <= p1_shft_value-(('0' & leading_zeros)+5);
          end if;
        elsif p1_shft_value > ("000" & first_bit_pos2) then
          shf_value <= p1_shft_value-("000" & first_bit_pos2);
        end if;
      elsif regA_i.fmt.exp /= "00" and p1_shft_value >= not(first_bit_pos2) then
        shf_value <= p1_shft_value-("000" & not(first_bit_pos2));
      end if;

      -- calculate exp shift
      if shf_value(2 downto 0) /= to_unsigned(0,3) then
        p1_shf_exp <= ('0' & shf_value(5 downto 3))+1;
      else
        p1_shf_exp <= '0' & shf_value(5 downto 3);
      end if;

      -- limit exp values
      p1_shf_exp2 <= p1_shf_exp;
      p1_exp <= to_unsigned(0,3);
      if regB_i.fmt.sign = '0' then
        exp_add := ("00" & regA_i.fmt.exp)+p1_shf_exp;
        if exp_add(3) = '1' then
          exp_add(2 downto 0) := to_unsigned(7,3);
        end if;
        p1_exp <= exp_add(2 downto 0);
      else
        if p1_shf_exp >= ("00" & regA_i.fmt.exp) then
          p1_exp <= to_unsigned(0,3);
          p1_shf_exp2 <= "00" & regA_i.fmt.exp; -- infinite loop
        else
          p1_exp <= '0' & (regA_i.fmt.exp-p1_shf_exp(1 downto 0));
        end if;
      end if;

      if p1_shft_dir = '0' and regA_i.mant = (28 downto 0 => '0') then
        p1_exp <= to_unsigned(0,3);
      end if;

      -- correct number of bits to shift
      shf_bits := p1_shft_value(5 downto 3)-p1_shf_exp2;

      if shf_bits(3) = '1' then
        p1_shift_bits <= (not shf_bits(1 downto 0) & not p1_shft_value(2 downto 0))+1;
        p1_shft_dir <= not regB_i.fmt.sign;
      else
        p1_shift_bits <= shf_bits(1 downto 0) & p1_shft_value(2 downto 0);
        p1_shft_dir <= regB_i.fmt.sign;
      end if;

      if shf_bits(2) /= shf_bits(3) then
        p1_shift_bits <= to_unsigned(31,5);
      end if;
    end if;

      
    -- stage 2

    p2_shf_result <= fast_shift(p2_frac,to_integer(p2_shift_bits),p2_shft_dir);

    if p2_cmd = "00" then
      p2_mant <= p2_int_part & (p2_shf_result(23 downto 0) xor p1_neg);
    else
      p2_mant <= p2_shf_result(28 downto 24) & (p2_shf_result(23 downto 0) xor p1_neg);
    end if;

  end process;

  p2_overflow <= '1' when p2_exp > 3 else '0';
  result_o <= (p2_mant & to_unsigned(0,24),"0000" & p2_overflow,p2_exp,p2_int_sign);
  ready_o <= '1';
  complete_o <= p2_en;
  
end rtl;

