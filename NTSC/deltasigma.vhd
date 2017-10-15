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

-- Based on Xilinx XAPP154 --

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;

entity deltasigma is
    generic (
	width	: integer := 8
    );

    port (
	clk		: in std_logic;
	rst		: in std_logic;

	din		: in std_logic_vector(width-1 downto 0);
	dout		: out std_logic
    );
end deltasigma;

architecture rtl of deltasigma is

    signal delta_add	: unsigned(width+1 downto 0);
    signal sigma_add	: unsigned(width+1 downto 0);
    signal sigma_latch	: unsigned(width+1 downto 0);
    signal delta_b	: unsigned(width+1 downto 0);

    signal din_1	: std_logic_vector(width-1 downto 0);
    signal din_2	: std_logic_vector(width-1 downto 0);

begin

    delta_b(width+1) <= sigma_latch(width+1);
    delta_b(width) <= sigma_latch(width+1);
    delta_b(width-1 downto 0) <= (others => '0');

    delta_add <= unsigned(din_2) + delta_b;
    sigma_add <= delta_add + sigma_latch;

    process (clk) begin
	if rising_edge(clk) then
	    if rst = '1' then
		sigma_latch(width) <= '1';
		sigma_latch <= (others => '0');
		dout <= '0';

		din_1 <= (others => '0');
		din_2 <= (others => '0');
	    else
		sigma_latch <= sigma_add;
		dout <= sigma_latch(width+1);

		din_1 <= din;
		din_2 <= din_1;
	    end if;
	end if;
    end process;

end;
