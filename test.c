#include "stdio.h"

int main(int argc, char* argv) {
  printf("Hello, world! This (%d) is an integer!\n", 10);
  printf("Now testing file IO.\n");
  char data = "This is some data that a.lua should properly write to test.txt.";
  int fd = fopen("test.txt", "w");
  fwrite(fd, data);
  fclose(fd);
  printf("There should now be a file called test.txt with some text in it.\n")
}
