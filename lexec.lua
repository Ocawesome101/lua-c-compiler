#!/usr/bin/env lua
-- Execute LCC-compiled scripts --

local value = require("lcc.value")
local env = {}

local function get_values_from_args(...)
  local args = table.pack(...)
  local ret = {}
  for i=1, args.n, 1 do
    ret[i] = args[i].value or args[i]
    if ret[i].pack then
      ret[i] = ret[i].pack()
    end
  end
  return ret
end

env.lcc_internal_lua_invoke = function(dstr, ...)
  local base = _G
  for term in dstr.value.pack():gmatch("[^%.]+") do
    if base[term] then
      base = base[term]
    else
      error("no such lua_object: "..dstr.value.pack())
    end
  end
  local ret = base(table.unpack(get_values_from_args(...)))
  if type(ret) == "string" then
    return value("char", ret)
  else
    return value("void", nil)
  end
end

env.lcc_internal_make_fn = function(fn_name, fn_body, fn_type)
  if fn_name:match("lcc_internal") then
    error("cannot declare function: "..fn_name)
  end
  local new = function(...)
    local ret = fn_body(...) or value("int", 0)
    if ret and ret.type ~= fn_type then
      error("bad return from function '"..fn_name.."' - expected "..fn_type
        ..", got "..ret.type)
    end
    return ret
  end
  env[fn_name] = new
end

env.lcc_internal_assert = assert
env.lcc_internal_value = value

local call = assert(loadfile((select(1, ...)), "bt", env))

call()

local args = table.pack(select(2, ...))

local argc = value("int", args.n)
local argv = value("char*", args)
os.exit(env.main(argc, argv).value or 0)
