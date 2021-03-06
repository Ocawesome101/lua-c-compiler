lcc_internal_make_fn('printf', function(str, ...)
lcc_internal_assert(str.type == 'char', "invalid argument to 'printf' - expected 'char' but got " .. str.type) 
lcc_internal_lua_invoke(lcc_internal_value('char', "io.write"), lcc_internal_lua_invoke(lcc_internal_value('char', "string.format"), str, ...));
end, 'int') 
lcc_internal_make_fn('fopen', function(fname, fmode)
lcc_internal_assert(fname.type == 'char', "invalid argument to 'fopen' - expected 'char' but got " .. fname.type)
lcc_internal_assert(fmode.type == 'char', "invalid argument to 'fopen' - expected 'char' but got " .. fmode.type) 
local fd = lcc_internal_value('int', lcc_internal_fopen(fname, fmode))
return(fd);
end, 'int') 
lcc_internal_make_fn('fread', function(fd, len)
lcc_internal_assert(fd.type == 'int', "invalid argument to 'fread' - expected 'int' but got " .. fd.type)
lcc_internal_assert(len.type == 'int', "invalid argument to 'fread' - expected 'int' but got " .. len.type) 
return(lcc_internal_fread(fd, len))
end, 'int') 
lcc_internal_make_fn('fwrite', function(fd, data)
lcc_internal_assert(fd.type == 'int', "invalid argument to 'fwrite' - expected 'int' but got " .. fd.type)
lcc_internal_assert(data.type == 'char', "invalid argument to 'fwrite' - expected 'char' but got " .. data.type) 
return(lcc_internal_fwrite(fd, data))
end, 'int') 
lcc_internal_make_fn('fclose', function(fd)
lcc_internal_assert(fd.type == 'int', "invalid argument to 'fclose' - expected 'int' but got " .. fd.type) 
return(lcc_internal_fclose(fd))
end, 'int') 
lcc_internal_make_fn('main', function(argc, argv)
lcc_internal_assert(argc.type == 'int', "invalid argument to 'main' - expected 'int' but got " .. argc.type)
lcc_internal_assert(argv.type == 'char*', "invalid argument to 'main' - expected 'char*' but got " .. argv.type) 
printf(lcc_internal_value('char', "Hello, world! This (%d) is an integer!\n"), lcc_internal_value('int', 10));
printf(lcc_internal_value('char', "Now testing file IO.\n"));
local data = lcc_internal_value('char', lcc_internal_value('char', "This is some data that a.lua should properly write to test.txt."))
local fd = lcc_internal_value('int', fopen(lcc_internal_value('char', "test.txt"), lcc_internal_value('char', "w")))
fwrite(fd, data);
fclose(fd);
printf(lcc_internal_value('char', "There should now be a file called test.txt with some text in it.\n"))
end, 'int') 