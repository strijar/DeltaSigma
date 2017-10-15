#!/usr/bin/lua

local n = 255
local scale = 2^11
local min = 0.33
local max = 1.00

local gamma = 1.0/1.0;

for i = 0,n do
    local x = math.pow(i/n, gamma);
    local y = min + x * (max-min);

    print(string.format("%02i => x\"%04x\",", i, y / 3.3 * scale))
end

print("---")

print(string.format("0.3v = x\"%04x\"", 0.3 / 3.3 * scale))
print(string.format("0.33v = x\"%04x\"", 0.33 / 3.3 * scale))
print(string.format("step = %.5f", (1.0 - 0.33) / 3.3 * scale / 256))
