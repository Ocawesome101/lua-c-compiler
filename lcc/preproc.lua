-- LCC preprocessor module --

local pp = {}

-- directives
pp.directives = {}

function pp.directives.include(fspec)
  print("include", fspec)
  local file, tfile
  if fspec:match("<(%g-)>") then
    tfile = fspec:match("<(%g-)>")
  elseif fspec:match("\"(%g-)\"") then
    tfile = fspec:match("\"(%g-)\"")
    if io.open(tfile) then
      file = tfile
    end
  end
  for path in (cpath or package.cpath):gmatch("[^;]+") do
    if file then break end
    if io.open(path.."/"..tfile) then
      file = path.."/"..tfile
      break
    end
  end
  return pp.process(file)
end

function pp.process(file)
  print("preproc", file)
  local ret = ""
  for line in io.lines(file) do
    line = line:gsub("^(%s+)", "")
    local _, k, v = line:match("(#)([a-zA-Z]+) (.+)")
    if k and v then
      if pp.directives[k] then
        ret = ret .. pp.directives[k](v) .. "\n"
      else
        error("invalid preprocessor directive: "..k)
      end
    else
      ret = ret .. line .. "\n"
    end
  end
  print("done")
  return ret
end

return pp
