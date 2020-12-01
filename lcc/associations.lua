-- mapping of C types -> Lua types --

local associations = {
  int = "number",
  int32 = "number",
  int64 = "number",
  float = "number",
  bool = "boolean",
  struct = "table",
  char = {number = true, string = true},
  ["function"] = "function",
}

return associations
