library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity nbody is
	port (
		clk:		in std_logic;
		reset: 	in std_logic;
		
		debug:	out std_logic_vector(7 downto 0)
		
		);
end nbody;
		
architecture arch of nbody is
signal en_out1:	std_logic;
signal diff_x:	   signed(10 downto 0);
signal diff_y:	   signed(10 downto 0);

signal r:			unsigned(20 downto 0);
signal en_out2:	std_logic;

signal r_3:			unsigned(63 downto 0);
signal en_out3:	std_logic;

signal r_3_fp:		unsigned(63 downto 0);
signal en_out4:	std_logic;

signal mul_res:	unsigned(63 downto 0);
signal en_out5:	std_logic;

signal uns_out:	unsigned(63 downto 0);
signal en_out6:	std_logic;
-- debug
signal tmp_dbg:	unsigned(7 downto 0);
begin

	-- 1 stage pipeline - calculate 
	pipe_stage1: work.pipe_st1
		port map(clk => clk, reset => reset, en_in => '1', rx_a => "00000000011", rx_b => "00000000000", 
		ry_a => "00000000000", ry_b => "00000000000", diff_x => diff_x, diff_y => diff_y, en_out=> en_out1);
	
	-- 1 stage pipeline - calculate r
	pipe_stage2: work.pipe_st2
		port map(clk => clk, reset => reset, en_in => en_out1, diff_x => diff_x, diff_y => diff_y, r => r, en_out  => en_out2); 
	
	-- 1-stage pipeline - calculate r^3
	r_cube: work.r_cube
		port map(clk => clk, reset => reset, en_in => en_out2, r_in => r, r_3 => r_3, en_out => en_out3);
	
	r_cube_fp: work.unsigned_to_fp
		port map(clk => clk, reset => reset, en_in => en_out3, input => r_3, output => r_3_fp, en_out => en_out4);
	
	fpmu_test: work.fpmu
		port map(clk => clk, reset => reset, en_in => en_out4, a => r_3_fp, b => r_3_fp, result => mul_res, en_out => en_out5);
	
	fp_to_u64:	work.ftou
		port map(clk => clk, reset => reset, en_in => en_out5, input => mul_res, output => uns_out, debug => tmp_dbg, en_out => en_out6);
		
--	debug <= std_logic_vector(uns_out(63 downto 56));
--	debug <= std_logic_vector(uns_out(55 downto 48));
--	debug <= std_logic_vector(uns_out(47 downto 40));
--	debug <= std_logic_vector(uns_out(39 downto 32));
	debug <= std_logic_vector(uns_out(31 downto 24));
--	debug <= std_logic_vector(uns_out(23 downto 16));
--	debug <= std_logic_vector(uns_out(15 downto 8));
--	debug <= std_logic_vector(uns_out(7 downto 0));
--	debug <= std_logic_vector(tmp_dbg);
--	debug <= std_logic_vector(mul_res(51 downto 44));
		
end arch;