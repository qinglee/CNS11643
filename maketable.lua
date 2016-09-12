#!/usr/bin/env texlua

local SEQ = "CNS_strokes_sequence.txt"
local BMP = "CNS2UNICODE_Unicode BMP.txt"
local SIP = "CNS2UNICODE_Unicode 2.txt"

local cns2uni = { }
for _, txt in ipairs{ BMP , SIP } do
  for line in io.lines(txt) do
    local t = line:explode("\t")
    if not t[2] then break end
    local plane = tonumber(t[1], 16)
    local code  = tonumber(t[2], 16)
    if not cns2uni[plane] then cns2uni[plane] = { } end
    cns2uni[plane][code] = tonumber(t[3], 16)
  end
end

local unicode_seq = { }
unicode_seq[0x3007] = "5"

for line in io.lines(SEQ) do
  local t = line:explode("\t")
  local plane = tonumber(t[1], 16)
  local code  = tonumber(t[2], 16)
  local unicode = cns2uni[plane] and cns2uni[plane][code]
  if unicode then
    unicode_seq[unicode] = t[3]
  end
end

local function pairsByKeys (t, f)
  local a = { }
  for n in pairs(t) do a[#a+1] = n end
    table.sort(a, f)
    local i = 0
    return function ()
      i = i + 1
      return a[i], t[a[i]]
    end
end

local char = unicode.utf8.char
local format = unicode.utf8.format
local t = { }
for code, seq in pairsByKeys(unicode_seq) do
  t[#t+1] = format("%s\t%s", char(code), seq)
end

io.output("cns11643_strokeorder.txt")
io.write("# CNS11643 中的笔顺表\n")
io.write("# 原始数据为 http://www.cns11643.gov.tw/AIDB/Open_Data.zip\n")
io.write(table.concat(t, "\n"))
io.write("\n")
io.close()

local miss = { }
local byte = unicode.utf8.byte
for line in io.lines("sunwb_strokeorder.txt") do
  local t = line:explode("\t")
  if t[2] then
    local code = byte(t[1])
    if not unicode_seq[code] then
      miss[#miss+1] = format("%X\t%s\t%s", code, t[1], t[2])
    end
  end
end

io.output("miss.txt")
io.write(table.concat(miss, "\n"))
io.write("\n")
io.close()
