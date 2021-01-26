# C -> Lua transpiler

Why did I do this?  Because I'm insane.

Compiler is `lcc.lua` and outputs to `a.lua`.  Compile `test.c` with `./lcc.lua test.c`.  Run with `./lexec.lua a.lua`.

### Supported Features

 - [ ] Preprocessor
  - [X] `#include`
  - [ ] `#define`
  - [ ] comments
 - [ ] Core language
  - [ ] variable declaration
    - variables can be declared but must also be assigned a value immediately
  - [X] variable assignment
  - [ ] types
   - partially loosely implemented
  - [ ] `struct`
  - [?] inline constants
   - [X] `int`
   - [X] `float`
   - [X] `char`/`char*`
