int printf(char str, ...) {
  lcc_internal_lua_invoke("io.write", lcc_internal_lua_invoke("string.format", str, ...));
}

int fopen(char fname, char fmode) {
  int fd = lcc_internal_fopen(fname, fmode);
  return(fd);
}

int fread(int fd, int len) {
  return(lcc_internal_fread(fd, len))
}

int fwrite(int fd, char data) {
  return(lcc_internal_fwrite(fd, data))
}

int fclose(int fd) {
  return(lcc_internal_fclose(fd))
}
