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

library work;

entity ntsc_sync is
    generic (
	   clk_freq	  : integer := 150_000;
	   width	  : integer := 640
    );
    port (
	   clk		  : in std_logic;
	   rst		  : in std_logic;

	   out_sync	  : out std_logic;
	   out_ac	  : out std_logic;
	   out_field  : out std_logic;

	   out_frame  : out std_logic;
	   out_line	  : out std_logic;
	   out_pixel  : out std_logic
    );
end ntsc_sync;

architecture rtl of ntsc_sync is
    constant H_LINE_SIZE	    : integer := 31_77 * clk_freq / 100_000 - 1;
    constant LINE_SIZE		    : integer := 63_55 * clk_freq / 100_000 - 1;

    constant EQ_SIZE		    : integer := 2_30 * clk_freq / 100_000 - 1;
    constant SE_SIZE		    : integer := 27_30 * clk_freq / 100_000 - 1;
    constant BL_SIZE		    : integer := 4_70 * clk_freq / 100_000 - 1;

    constant PRE_SIZE		    : integer := 10_30 * clk_freq / 100_000 - 1;
    constant POST_SIZE		    : integer := 62_10 * clk_freq / 100_000 - 1;
    constant PIXEL_SIZE		    : integer := (POST_SIZE - PRE_SIZE) / width - 1;

    signal line_count		    : integer range 0 to 263 := 0;
    signal h_pixel_count	    : integer range 0 to H_LINE_SIZE := 0;
    signal pixel_count		    : integer range 0 to LINE_SIZE := 0;
    signal pixel_div		    : integer range 0 to PIXEL_SIZE := 0;
    signal field		        : std_logic := '0';

    signal line_count_n		    : integer range 0 to 263;
    signal h_pixel_count_n	    : integer range 0 to H_LINE_SIZE;
    signal pixel_count_n	    : integer range 0 to LINE_SIZE;
    signal pixel_div_n		    : integer range 0 to PIXEL_SIZE;
    signal field_n		        : std_logic;

    signal sync 		        : std_logic;
    signal eq, se, bl, ac	    : std_logic;
    signal frame, line, pixel   : std_logic;

begin

    process (line_count, pixel_count, h_pixel_count, field) begin
	   field_n <= field;
	   frame <= '0';

	   if h_pixel_count = H_LINE_SIZE then
	       h_pixel_count_n <= 0;
	   else
	       h_pixel_count_n <= h_pixel_count + 1;
	   end if;

	   if pixel_count = LINE_SIZE then
	       pixel_count_n <= 0;

	       if line_count = 263 then
		      line_count_n <= 0;
		      field_n <= not field;
		      frame <= '1';
	       else
		      line_count_n <= line_count + 1;
	       end if;
	   else
	       pixel_count_n <= pixel_count + 1;
	       line_count_n <= line_count;
	   end if;
    end process;

    process (line_count, pixel_count, h_pixel_count, eq, se, bl, ac) begin
	   ac <= '0';
	   pixel_div_n <= 0;
	   pixel <= '0';
	   line <= '0';
	   sync <= bl;

	   if line_count < 20 then
	       case line_count is
		      when 0 =>
		          sync <= eq;

		      when 1 =>
		          sync <= eq;

		      when 2 =>
		          if field = '0' or pixel_count < H_LINE_SIZE then
			         sync <= eq;
		          else
			         sync <= se;
		          end if;

		      when 3 =>
		          sync <= se;

		      when 4 =>
		          sync <= se;

		      when 5 =>
		          if field = '0' or pixel_count < H_LINE_SIZE then
			         sync <= se;
		          else
			         sync <= eq;
		          end if;

		      when 6 =>
		          sync <= eq;

		      when 7 =>
		          sync <= eq;

		      when 8 =>
		          if field = '0' or pixel_count < BL_SIZE then
			         sync <= eq;
		          end if;

		      when others =>
	       end case;
	   elsif line_count < 260 then
	       if pixel_count = POST_SIZE then
	           line <= '1';
	       end if;

	       if pixel_count > PRE_SIZE AND pixel_count < POST_SIZE then
	           ac <= '1';

	           if pixel_div = PIXEL_SIZE then
	               pixel_div_n <= 0;
		           pixel <= '1';
	           else
		          pixel_div_n <= pixel_div + 1;
	           end if;
	       end if;
	   end if;
    end process;

    eq <= '0' when h_pixel_count < EQ_SIZE else '1';    -- is the equalization pulse
    se <= '0' when h_pixel_count < SE_SIZE else '1';    -- is the serration pulse
    bl <= '0' when pixel_count < BL_SIZE else '1';      -- is the blanking pulse

    process (rst, clk) begin
	   if rising_edge(clk) then
	       if rst = '1' then
		      h_pixel_count <= 0;
		      pixel_count <= 0;
		      pixel_div <= 0;
		      line_count <= 0;
		      field <= '0';

		      out_sync <= '0';
		      out_ac <= '0';
		      out_field <= '0';
		      out_frame <= '0';
		      out_line <= '0';
		      out_pixel <= '0';
	       else
		      h_pixel_count <= h_pixel_count_n;
		      pixel_count <= pixel_count_n;
		      pixel_div <= pixel_div_n;
		      line_count <= line_count_n;
		      field <= field_n;

		      out_sync <= sync;
		      out_ac <= ac;
		      out_field <= field_n;
		      out_frame <= frame;
		      out_line <= line;
		      out_pixel <= pixel;
	       end if;
	   end if;
    end process;

end;
