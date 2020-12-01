int printf(char str, void ...) {
  lcc_internal_lua_invoke("io.write", lcc_internal_lua_invoke("string.format", str, ...));
}
