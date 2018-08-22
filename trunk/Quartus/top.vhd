-- Copyright (c) 2013 Malte Graeper (mgraep@t-online.de) All rights reserved.

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.qfp32_unit_p.all;
use work.qfp_p.all;

entity Top is
  
  port (
    clock_50 : in  std_ulogic;
    key      : in  std_ulogic_vector(1 downto 0);
    sw       : in  std_ulogic_vector(3 downto 0);
    led      : out std_ulogic_vector(7 downto 0));

end Top;

architecture Rtl of Top is

  component qfp_unit
    generic (
      config : natural);
    port (
      clk_i      : in  std_ulogic;
      reset_n_i  : in  std_ulogic;
      cmd_i      : in  qfp_cmd_t;
      ready_o    : out std_ulogic;
      start_i    : in  std_ulogic;
      regA_i     : in  std_ulogic_vector(31 downto 0);
      regB_i     : in  std_ulogic_vector(31 downto 0);
      result_o   : out std_ulogic_vector(31 downto 0);
      cmp_gt_o   : out std_ulogic;
      cmp_z_o    : out std_ulogic;
      complete_o : out std_ulogic);
  end component;

  signal din : std_ulogic_vector(69 downto 0);
  signal dout : std_ulogic_vector(35 downto 0);
  signal count : unsigned(4 downto 0);

  signal clk      : std_ulogic;
  signal reset_n  : std_ulogic;
  signal cmd      : qfp_cmd_t;
  signal ready    : std_ulogic;
  signal start    : std_ulogic;
  signal regA     : std_ulogic_vector(31 downto 0);
  signal regB     : std_ulogic_vector(31 downto 0);
  signal result   : std_ulogic_vector(31 downto 0);
  signal cmp_gt   : std_ulogic;
  signal cmp_z    : std_ulogic;
  signal complete : std_ulogic;

begin  -- Rtl

  clk <= clock_50;
  reset_n <= key(0);

  process (clk, reset_n)
  begin  -- process
    if reset_n = '0' then               -- asynchronous reset (active low)
      din <= (others => '0');
      dout <= (others => '0');
      count <= to_unsigned(0,5);
    elsif clk'event and clk = '1' then  -- rising clock edge
      if count = to_unsigned(21,5) then
        count <= to_unsigned(0,5);			
        din <= (others => '0');
        dout <= result & cmp_gt & cmp_z & complete & ready;
      else
        din <= din(din'length-5 downto 0) & sw;-- shift in
        dout <= "0000" & dout(dout'length-1 downto 4); 
        count <= count+1; 
      end if;      
    end if;
  end process;

  cmd.unit <= unsigned(din(2 downto 0));
  cmd.sub_cmd <= din(4 downto 3);
  start <= din(5);
  regA <= din(37 downto 6);
  regB <= din(69 downto 38);

  led(3 downto 0) <= dout(3 downto 0);

  qfp_unit_1: qfp_unit
    generic map (
      config => qfp_config_add+qfp_config_mul+qfp_config_recp+qfp_config_misc)
    port map (
      clk_i      => clk,
      reset_n_i  => reset_n,
      cmd_i      => cmd,
      ready_o    => ready,
      start_i    => start,
      regA_i     => regA,
      regB_i     => regB,
      result_o   => result,
      cmp_gt_o   => cmp_gt,
      cmp_z_o    => cmp_z,
      complete_o => complete);
	
end Rtl;
