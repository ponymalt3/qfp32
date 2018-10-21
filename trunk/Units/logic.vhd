-- Copyright (c) 2018 Malte Graeper (mgraep@t-online.de) All rights reserved

library IEEE;
use IEEE.std_logic_1164.all;

library work;
use work.qfp_p.all;

package qfp32_logic_p is

  constant QFP_SCMD_SHF : qfp_scmd_t := "00";
  constant QFP_SCMD_AND : qfp_scmd_t := "01";
  constant QFP_SCMD_OR : qfp_scmd_t := "10";
  constant QFP_SCMD_XOR : qfp_scmd_t := "11";

end package qfp32_logic_p;

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.qfp_p.all;
use work.qfp32_logic_p.all;

entity qfp32_logic is
  
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

end qfp32_logic;

architecture Rtl of qfp32_logic is

  function expand (
    mant : unsigned(28 downto 0);
    sign : std_ulogic;
    exp  : unsigned(1 downto 0))
    return unsigned is
    variable result : unsigned(52 downto 0);
  begin
    result := (others => '0');
    result(28+to_integer(exp)*8 downto to_integer(exp)*8) := mant;
    return result;
  end function;

  signal p1_expand_a : unsigned(52 downto 0);
  signal p1_expand_b : unsigned(52 downto 0);

  signal op_shf : std_ulogic;

  signal p1_and : unsigned(52 downto 0);
  signal p1_or : unsigned(52 downto 0);
  signal p1_xor : unsigned(52 downto 0);

  signal shift_value : unsigned(5 downto 0);

  signal p1_result : unsigned(52 downto 0);

begin  -- Rtl

  process (cmd_i, op_shf, p1_and, p1_expand_a, p1_expand_b, p1_or, p1_xor,
           regA_i.fmt.exp, regA_i.fmt.sign, regA_i.mant, regB_i.fmt.exp,
           regB_i.fmt.sign, regB_i.mant, shift_value) is
  begin  -- process   

    p1_expand_a <= expand(regA_i.mant,regA_i.fmt.sign,regA_i.fmt.exp);
    p1_expand_b <= expand(regB_i.mant,regB_i.fmt.sign,regB_i.fmt.exp);

    p1_and <= (others => '1');
    p1_or <= (others => '0');
    p1_xor <= (others => '0');

    op_shf <= '0';

    case cmd_i is
      when QFP_SCMD_AND => p1_and <= p1_expand_b;
      when QFP_SCMD_OR => p1_or <= p1_expand_b;
      when QFP_SCMD_XOR => p1_xor <= p1_expand_b;
      when QFP_SCMD_SHF => op_shf <= '1';
      when others => null;
    end case;

    p1_result <= ((p1_expand_a and p1_and) or p1_or) xor p1_xor;

    if op_shf = '1' then
      shift_value <= p1_expand_b(29 downto 24);
      p1_result <= fast_shift(p1_expand_a,to_integer(shift_value),regB_i.fmt.sign);
    end if;

  end process;

  result_o <= (p1_result,"00000",'0' & qfp_x24,regA_i.fmt.sign);

  ready_o <= '1';
  complete_o <= start_i;
  
end Rtl;


