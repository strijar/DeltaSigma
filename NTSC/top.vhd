--
--  Copyright 2017 Oleg Belousov <belousov.oleg@gmail.com>,
--
--  All rights reserved.
--
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are met:
-- 
--    1. Redistributions of source code must retain the above copyright notice,
--       this list of conditions and the following disclaimer.
-- 
--    2. Redistributions in binary form must reproduce the above copyright
--       notice, this list of conditions and the following disclaimer in the
--       documentation and/or other materials provided with the distribution.
-- 
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDER ``AS IS'' AND ANY EXPRESS
-- OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
-- OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN
-- NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY
-- DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
-- LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
-- ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
-- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
-- THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
-- 
-- The views and conclusions contained in the software and documentation are
-- those of the authors and should not be interpreted as representing official
-- policies, either expressed or implied, of the copyright holder.
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top is
    port  (
	   clk	    : in std_logic;
	   reset_n  : in std_logic;
	   dout     : out std_logic
    );
end top;

architecture rtl of top is

    component clk_mul
    port(
        clk_out : out std_logic;
        clk_in  : in std_logic
    );
    end component;

    signal rst      : std_logic;

    signal sync, ac	: std_logic;
    signal field	: std_logic;
    signal frame	: std_logic;
    signal line		: std_logic;
    signal pixel	: std_logic;

    signal x		: unsigned(9 downto 0);
    signal y		: unsigned(8 downto 0);

    signal color	: std_logic_vector(7 downto 0);
 
    signal vdat		: std_logic_vector(10 downto 0);
    signal scaled	: std_logic_vector(10 downto 0);

    signal clk_dcm	: std_logic;

begin

    rst <= not reset_n;

    clk_mul_i: clk_mul
	port map (
	    clk_in     => clk,
	    clk_out    => clk_dcm
	);

    ntsc_sync_i: entity work.ntsc_sync
	generic map(
	    clk_freq    => 150_000,
	    width	    => 640
	)
	port map(
	    clk 	    => clk_dcm,
	    rst 	    => rst,

	    out_sync	=> sync,
	    out_ac	    => ac,
	    out_field	=> field,
	    out_frame	=> frame,
	    out_line	=> line,
	    out_pixel	=> pixel
	);

    process(rst, clk_dcm) begin
	   if rising_edge(clk_dcm) then
	       if rst = '1' then
		      x <= (others => '0');
		      y <= (others => '0');
	       else
		      if frame = '1' then
		          y <= (others => '0');
		      elsif line = '1' then
		          y <= y + 1;
		          x <= (others => '0');
		      elsif pixel = '1' then
		          x <= x + 1;
		      end if;
	       end if;
	   end if;
    end process;

    process(clk_dcm) begin
	   if rising_edge(clk_dcm) then
	       if pixel = '1' then
		      if x(5 downto 0) = 0 then
		          color <= x"FF";
		      elsif field = '0' and (y(4 downto 0) = 0) then
		          color <= x"FF";
		      else
		          color <= std_logic_vector(x(7 downto 0));
		      end if;
	       end if;
	   end if;
    end process;

    process(sync, ac, scaled) begin
	   if sync = '0' then
	       vdat <= "00000000000";	   -- 0.00v
	   else
	       if ac = '0' then
		      vdat <= "00010111010";   -- 0.30v
	       else
		      vdat <= scaled;		   -- 0.33v-1.0v
	       end if;
	   end if;
    end process;

    -- 204 + color * 1.6171875

    scaled <= std_logic_vector(
        x"cc" +
        unsigned("000" & color) + 
        unsigned("0000" & color(7 downto 1)) + 
        unsigned("0000000" & color(7 downto 4)) + 
        unsigned("00000000" & color(7 downto 5)) + 
        unsigned("000000000" & color(7 downto 6)) + 
        unsigned("0000000000" & color(7 downto 7)) 
    );

    deltasigma_i: entity work.deltasigma
	generic map(
	    width	=> 11
	)
	port map(
	    clk 	=> clk_dcm,
	    rst 	=> rst,

	    din		=> vdat,
	    dout	=> dout
	);

end rtl;
