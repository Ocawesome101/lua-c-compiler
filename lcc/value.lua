-- makes all values into tables so they can be assigned to, as well as
-- "strongly" typed --

local associations = require("lcc.associations")

local function unpackString(str)
  local r = {}
  for c in str:gmatch(".") do
    r[#r+1] = c:byte()
  end
  function r.pack()
    local s = ""
    for i, byte in ipairs(r) do
      s = s .. string.char(byte)
    end
    return s
  end
  return r
end

local function value(vtype, val, lencap)
  -- due to oddities of generated code this check is necessary
  if type(val) == "table" and val.type then
    if val.type ~= vtype then
      for k,v in pairs(val) do print(k,v) end
      error("attempt to cast invalid value to " .. vtype)
    else
      return val
    end
  end
  -- we do some weird stuff here using shadow tables and metatables to validate
  -- value assignment
  local shadow = {
    value = ""
  }
  local new = setmetatable({
    type = vtype or "int",
    lencap = lencap or math.huge
  }, {__index = shadow, __newindex = function(t, k, v)
    if type(v) == "table" and t.type == "char*" then
      shadow.value = {}
      for i=1, #v, 1 do
        shadow.value[#shadow.value + 1] = unpackString(v[i])
      end
      return
    end
    if type(v) ~= associations[t.type] and
         (type(associations[t.type]) == "table" and not associations[t.type][type(v)]) then
      error("attempt to cast invalid value ("..type(v)..") as " .. t.type)
    end
    if type(v) == "string" and #v > t.lencap then
      error("attempt to assign too large a string to variable whose maximum length is "..t.lencap)
    end
    if type(v) == "string" then
      if t.lencap == 1 then
        shadow.value = v:byte()
      else
        shadow.value = unpackString(v)
      end
    else
      shadow.value = v
    end
  end, __tostring = function(t)
    if shadow.value.pack then
      return shadow.value.pack()
    end
    return tostring(shadow.value)
  end})
  if val then new.value = val end
  return new
end

return value
