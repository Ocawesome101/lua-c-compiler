-- structs --

local function struct(tbl, tbl2)
  if tbl2 then
    return setmetatable(tbl2, {__index=tbl1, __newindex=function(t,k,v)
      if not tbl1[k] then
        error("attempt to set nonexistent structure field")
      end
      rawset(t, k, v)
    end})
  end
  return setmetatable(tbl, {__newindex = function(k, v)
    error("attempt to set nonexistent struct field")
  end})
end

return struct
