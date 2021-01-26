-- patterns --

local types = require("lcc.types")

local patterns = {}
patterns.gsub = {
  {"{", "do"},
  {"}", "end"},
  {"&&", "and"},
  {"||", "or"},
  {"&(%w_)", "%1"},
  {"else if", "elseif"},
  {"if(%b()){", "if %1 then"},
  {"function(.-){", "function%1"},
  {"elseif(%b()){", "elseif %1 then"},
  {"}", "end"},
}

local function strip_types(str)
  for c_type in pairs(types) do
    str = str:gsub(c_type, "")
  end
  return str
end

-- input: function argstring
-- output: function argstring - types + assert statements checking types
local function convert_to_lua(fn_name, str)
  local temp = str:sub(2, -2)
  local ret = ""
  local check_statements = ""
  for typ, word in temp:gmatch("(%g+) (%g+),?%s?") do
    word = word:gsub(",", "")
    print(typ, word)
    ret = ret .. word .. ", "
    check_statements = check_statements .. string.format(
      "\nlcc_internal_assert(%s.type == '%s', \"invalid argument to '%s' - expected '%s' but got \" .. %s.type)",
      word, typ, fn_name, typ, word)
  end
  if temp:sub(-3) == "..." then -- last thing is varargs -- TODO: NASTY HACKS
    ret = ret .. "..., "
  end
  ret = ret:sub(1, -3)
  return "("..ret..")" .. check_statements
end

local function escape_magic(str)
  return (str:gsub("([%[%]%(%)%*%-%.%+%^%$%%])", "%%%1"))
end

patterns.assignment = {
  -- inline strings
  function(dat)
    local pat = "([\"'].-[\"'])"
    for match in dat:gmatch(pat) do
      print("MATCH", match)
      dat = dat:gsub(escape_magic(match), (string.format(
      "lcc_internal_value('char', %s)", match):gsub("%%", "%%%%")))
    end
    return dat
  end,
  -- inline constants
  function(dat)
    local pat = "(%d+)"
    for match in dat:gmatch(pat) do
      print("MATCH", match)
      local n = tonumber(match)
      if math.floor(n) == n then -- n is int
        dat = dat:gsub(match, string.format("lcc_internal_value('int', %d)",
        tonumber(match)))
      else -- n is not int
        dat = dat:gsub(escape_magic(match), string.format(
        "lcc_internal_value('float', %d)", tonumber(match)))
      end
    end
    return dat
  end,
  -- function creation
  function(dat)
    print(dat)
    local pat_base = "([%w_]-)(%b())([ \n]?)(%b{})"
    print(dat:match(pat_base))
    for k, v in pairs(types) do
      local pat = k .. " " .. pat_base
      print(pat)
      for fn_name, fn_args, spacer, fn_body in dat:gmatch(pat) do
        print(escape_magic(k.." "..fn_name..fn_args))
        dat = dat:gsub(escape_magic(fn_body), "")
        fn_body = fn_body:sub(2, -2) .. "end"
        local fn_orig_args = fn_args
        fn_args = convert_to_lua(fn_name, fn_args)
       -- print(string.format("function %s%s%s%s", fn_name, fn_args, spacer, fn_body))
        print(string.format("lcc_internal_make_fn('%s', function%s %s)",
                      fn_name, fn_args, fn_body))
        dat = dat:gsub(escape_magic(k.." "..fn_name..fn_orig_args),
                      (string.format(
                      "lcc_internal_make_fn('%s', function%s %s, '%s')",
                      fn_name, fn_args, fn_body, k):gsub("%%", "%%%%")))
      end
    end
    return dat
  end,
  -- variable creation / assignment
  function(dat)
    local pat_base = "([^%s]-) ?= ?(.+);"
    local lines = {}
    for line in dat:gmatch("[^\n]+") do
      for k, v in pairs(types) do
        local pat = k .. " " .. pat_base
        if line:match(pat) then
          local vname, val = line:match(pat)
          local vtype = k
          print(pat, "assign", vtype, vname, "=", val)
          lines[#lines + 1] = string.format(
                                    "local %s = lcc_internal_value('%s', %s)",
                                     vname, vtype, (val:gsub("%%", "%%%%")))
          goto continue
        end
      end
      if line:match(pat_base) then
        local vname, val = line:match(pat_base)
        lines[#lines + 1] = string.format("%s = %s", vname, val)
        goto continue
      end
      lines[#lines + 1] = line
      ::continue::
    end
    return table.concat(lines, "\n")
  end,
}

return patterns
