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
  {"if(%b())do", "if %1 then"},
  {"function(.-)do", "function%1"},
  {"elseif(%b())do", "elseif %1 then"}
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
      "\nlcc_internal_assert(%s.type == '%s', \"invalid argument to '%s' - expected '%s'\")",
      word, typ, fn_name, typ)
  end
  ret = ret:sub(1, -3)
  return "("..ret..")" .. check_statements
end

local function escape_magic(str)
  return (str:gsub("([%[%]%(%)%*%-%+%^%$%%])", "%%%1"))
end

patterns.assignment = {
  -- inline strings
  function(dat)
    local pat = "([\"'].-[\"'])"
    for match in dat:gmatch(pat) do
      print("MATCH", match)
      dat = dat:gsub(escape_magic(match), string.format(
      "lcc_internal_value('char', %s)", match))
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
                      string.format("lcc_internal_make_fn('%s', function%s %s, '%s')",
                      fn_name, fn_args, fn_body, k))
      end
    end
    return dat
  end,
}

return patterns
