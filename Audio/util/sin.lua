#!/usr/bin/lua

local n = 127
local scale = 2^16

for i = 0,n do
    local y = math.sin((i * 360 / n) * 3.141526 / 180);

    print(string.format("%02i => x\"%04x\",", i, (y * 0.5 + 0.5) * scale));
end
