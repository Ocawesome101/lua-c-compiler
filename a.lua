lcc_internal_make_fn('printf', function(str, ...)
lcc_internal_assert(str.type == 'char', "invalid argument to 'printf' - expected 'char'")
lcc_internal_assert(....type == 'void', "invalid argument to 'printf' - expected 'void'") 
lcc_internal_lua_invoke(lcc_internal_value('char', "io.write"), lcc_internal_lua_invoke(lcc_internal_value('char', "string.format"), str, ...));
end, 'int') 


lcc_internal_make_fn('main', function(argc, argv)
lcc_internal_assert(argc.type == 'int', "invalid argument to 'main' - expected 'int'")
lcc_internal_assert(argv.type == 'char*', "invalid argument to 'main' - expected 'char*'") 
printf(lcc_internal_value('char', "Hello, world!\n"));
end, 'int') 
