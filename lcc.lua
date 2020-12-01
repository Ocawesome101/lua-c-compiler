#!/usr/bin/env lua
-- LCC - the Lua C Compiler --

local args = {...}

local pre = require("lcc.preproc")
local patterns = require("lcc.patterns")

local cf = args[1]
local out = "a.lua"
local proc = pre.process(cf)

for i, dat in ipairs(patterns.assignment) do
  proc = dat(proc)
end

for i, dat in ipairs(patterns.gsub) do
  proc = proc:gsub(dat[1], dat[2])
end

io.output(out)
io.output():write(proc)
io.output():flush()
