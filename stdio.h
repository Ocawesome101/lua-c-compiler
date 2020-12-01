int printf(char str, ...) {
  lcc_internal_lua_invoke("io.write", lcc_internal_lua_invoke("string.format", str, ...));
}
