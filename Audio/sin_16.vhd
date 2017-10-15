library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;

entity sin is
    generic (
	addr_bits	: integer := 7;
	data_bits	: integer := 16
    );
    port (
	clk	: in std_logic;

	addr	: in std_logic_vector(addr_bits-1 downto 0);
	dout	: out std_logic_vector(data_bits-1 downto 0)
    );
end sin;

architecture rtl of sin is

type ram_type is array(natural range 0 to (2**(addr_bits))-1) of std_logic_vector(data_bits-1 downto 0);

signal ram : ram_type :=
(
00 => x"8000",
01 => x"8654",
02 => x"8ca4",
03 => x"92ed",
04 => x"992a",
05 => x"9f57",
06 => x"a570",
07 => x"ab72",
08 => x"b159",
09 => x"b720",
10 => x"bcc6",
11 => x"c245",
12 => x"c79a",
13 => x"ccc3",
14 => x"d1bc",
15 => x"d681",
16 => x"db10",
17 => x"df67",
18 => x"e381",
19 => x"e75d",
20 => x"eaf9",
21 => x"ee51",
22 => x"f164",
23 => x"f430",
24 => x"f6b4",
25 => x"f8ed",
26 => x"fada",
27 => x"fc7b",
28 => x"fdcd",
29 => x"fed1",
30 => x"ff85",
31 => x"ffe9",
32 => x"fffd",
33 => x"ffc1",
34 => x"ff35",
35 => x"fe59",
36 => x"fd2e",
37 => x"fbb5",
38 => x"f9ee",
39 => x"f7db",
40 => x"f57c",
41 => x"f2d4",
42 => x"efe4",
43 => x"ecae",
44 => x"e934",
45 => x"e578",
46 => x"e17d",
47 => x"dd44",
48 => x"d8d1",
49 => x"d427",
50 => x"cf47",
51 => x"ca36",
52 => x"c4f7",
53 => x"bf8c",
54 => x"b9f9",
55 => x"b443",
56 => x"ae6b",
57 => x"a876",
58 => x"a268",
59 => x"9c45",
60 => x"960f",
61 => x"8fcc",
62 => x"897f",
63 => x"832c",
64 => x"7cd7",
65 => x"7684",
66 => x"7037",
67 => x"69f4",
68 => x"63bf",
69 => x"5d9b",
70 => x"578d",
71 => x"5198",
72 => x"4bc0",
73 => x"460a",
74 => x"4077",
75 => x"3b0c",
76 => x"35cc",
77 => x"30bb",
78 => x"2bdc",
79 => x"2731",
80 => x"22be",
81 => x"1e85",
82 => x"1a89",
83 => x"16cd",
84 => x"1353",
85 => x"101d",
86 => x"0d2d",
87 => x"0a84",
88 => x"0826",
89 => x"0612",
90 => x"044b",
91 => x"02d2",
92 => x"01a7",
93 => x"00cb",
94 => x"003e",
95 => x"0002",
96 => x"0016",
97 => x"007a",
98 => x"012e",
99 => x"0231",
100 => x"0383",
101 => x"0523",
102 => x"0711",
103 => x"0949",
104 => x"0bcd",
105 => x"0e99",
106 => x"11ac",
107 => x"1504",
108 => x"189f",
109 => x"1c7b",
110 => x"2095",
111 => x"24eb",
112 => x"297b",
113 => x"2e40",
114 => x"3338",
115 => x"3861",
116 => x"3db7",
117 => x"4336",
118 => x"48db",
119 => x"4ea2",
120 => x"5489",
121 => x"5a8b",
122 => x"60a4",
123 => x"66d1",
124 => x"6d0e",
125 => x"7356",
126 => x"79a7",
127 => x"7ffb"
);

begin

    process (clk) begin
	if rising_edge(clk) then
	    dout <= ram(to_integer(unsigned(addr)));
	end if;
    end process;

end;
