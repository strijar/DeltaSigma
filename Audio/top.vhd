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
	   reset_n	: in std_logic;
	   dout	    : out std_logic
    );
end top;

architecture rtl of top is
    signal rst      : std_logic;
    signal en		: std_logic := '1';

    signal clk_div	: unsigned(15 downto 0);
    signal din_div	: unsigned(15 downto 0);

    signal din		: std_logic_vector(15 downto 0);
    signal addr		: std_logic_vector(6 downto 0);

begin

    rst <= not reset_n;

    process(clk, rst) begin
	   if rising_edge(clk) then
	       if rst = '1' then
		      clk_div <= (others => '0');
	       else
		      if clk_div = (442 / 8) then
		          clk_div <= (others => '0');
		      else
		          clk_div <= clk_div + 1;
		      end if;
	       end if;
	   end if;
    end process;

    en <= '1' when clk_div = 0 else '0';

    -- Data

    process(clk) begin
	   if rising_edge(clk) then
	       if rst = '1' then
		      din_div <= (others => '0');
		      addr <= (others => '0');
	       else
		      if din_div = 442 then
		          din_div <= (others => '0');
		          addr <= std_logic_vector(unsigned(addr) + 1);
		      else
		          din_div <= din_div + 1;
		      end if;
	       end if;
	   end if;
    end process;

    sin_i: entity work.sin
	port map(
	    clk 	=> clk,
	    addr	=> addr,
	    dout	=> din
	);

    deltasigma_i: entity work.deltasigma
	generic map(
	    width	=> 16
	)
	port map(
	    clk 	=> clk,
	    rst 	=> rst,
	    en		=> en,

	    din		=> din,
	    dout	=> dout
	);

end rtl;
