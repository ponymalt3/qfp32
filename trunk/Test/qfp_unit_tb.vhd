-- Copyright (c) 2013 Malte Graeper (mgraep@t-online.de) All rights reserved.

-------------------------------------------------------------------------------
-- Testbench for design "qfp_unit"
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all; -- read std_ulogic etc

library work;
use work.qfp_p.all;
use work.qfp32_add_p.all;
use work.qfp32_misc_p.all;
use work.qfp32_unit_p.all;
use work.qfp32_test_p.all;

library std;
use std.textio.all;

-------------------------------------------------------------------------------

entity qfp_unit_tb is

end entity qfp_unit_tb;

-------------------------------------------------------------------------------

architecture Behav of qfp_unit_tb is

  type cmd_vector_t is array (natural range <>) of qfp_cmd_t;

  constant cmds : cmd_vector_t(6 downto 0) :=
    (
      (QFP_UNIT_ADD,QFP_SCMD_ADD),      -- add
      (QFP_UNIT_ADD,QFP_SCMD_SUB),      -- sub
      (QFP_UNIT_MUL,"00"),              -- mul
      (QFP_UNIT_RECP,"00"),             -- recp
      (QFP_UNIT_MISC,QFP_SCMD_Q2I),     -- convert qfp to integer
      (QFP_UNIT_MISC,QFP_SCMD_I2Q),     -- convert integer to qfp
      (QFP_UNIT_DIV,"00")               -- division  
    );

  -- component ports
  signal clk      : std_ulogic := '1';
  signal reset_n  : std_ulogic;
  signal cmd      : qfp_cmd_t;
  signal idle     : std_ulogic;
  signal start    : std_ulogic;
  signal regA     : std_ulogic_vector(31 downto 0);
  signal regB     : std_ulogic_vector(31 downto 0);
  signal result   : std_ulogic_vector(31 downto 0);
  signal gt       : std_ulogic;
  signal z        : std_ulogic;
  signal complete : std_ulogic;

  signal i : integer;
  file test_file : text;
  signal test : qfp_test_t;

begin  -- architecture Behav

  -- component instantiation
  DUT: entity work.qfp_unit
    generic map (
      config => qfp_config_all)
    port map (
      clk_i      => clk,
      reset_n_i  => reset_n,
      cmd_i      => cmd,
      ready_o    => idle,
      start_i    => start,
      regA_i     => regA,
      regB_i     => regB,
      result_o   => result,
      cmp_gt_o   => gt,                 -- regB > regA
      cmp_z_o    => z,
      complete_o => complete);

  -- clock generation
  clk <= not clk after 10 ns;

  -- waveform generation
  process
    variable l : line;
    variable test_as_var : qfp_test_t;
    variable dummy : character;
  begin
    reset_n <= '0';
    regA <= (others => '0');
    regB <= (others => '0');
    start <= '0';
    cmd <= (QFP_UNIT_NONE,"00");

    file_open(test_file,"test.vector");
    
    i <= 0;
    test <= (X"00000000",X"00000000",'0','0',(X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000",X"00000000"));
    
    wait for 33 ns;

    reset_n <= '1';

    wait until rising_edge(clk);

    while not endfile(test_file) loop

      -- read entry from file
      readline(test_file,l);
      
      hread(l,test_as_var.a);
      read(l,dummy);    
      hread(l,test_as_var.b);         
      read(l,dummy);   
      read(l,test_as_var.gt);
      read(l,dummy); 
      read(l,test_as_var.eq);
      read(l,dummy);
      
      hread(l,test_as_var.results(6));
        read(l,dummy);

      for k in 1 to 6 loop
        hread(l,test_as_var.results(6-k));
        read(l,dummy);
      end loop;  -- k
      
      test <= test_as_var;

      wait for 1 ns;

      regA <= test.a;
      regB <= test.b;

      -- for each instruction
      for j in 0 to cmds'length-1 loop
        wait for 1 ns;
        
        cmd <= cmds(j);
        start <= '1';
        wait until rising_edge(clk);
        start <= '0';

        if complete = '0' then
          wait until rising_edge(clk) and complete = '1';
        end if;

        assert result = test.results(j) report "result error" severity failure;

        if j = cmds'length-2 then -- if op = sub   
          assert gt = test.gt and z = test.eq report "compare flag error" severity failure;
        end if;        
        
      end loop;  -- j

      i <= i+1;
      
    end loop;

    file_close(test_file);

    wait;
    
  end process;

end architecture Behav;
