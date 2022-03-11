@echo off 
rem Usage: dart compile exe [arguments] <dart entry point>
rem -h, --help                          Print this usage information.
rem -o, --output                        Write the output to <file name>.
rem                                     This can be an absolute or relative path.
rem     --verbosity                     Sets the verbosity level of the compilation.
rem 
rem           [all] (default)           Show all messages
rem           [error]                   Show only error messages
rem           [info]                    Show error, warning, and info messages
rem           [warning]                 Show only error and warning messages
rem 
rem -D, --define=<key=value>            Define an environment declaration. To specify multiple declarations, use multiple
rem                                     options or use commas to separate key-value pairs.
rem                                     For example: dart compile exe -Da=1,b=2 main.dart
rem     --enable-asserts                Enable assert statements.
rem -p, --packages=<path>               Get package locations from the specified file instead of .packages.
rem                                     <path> can be relative or absolute.
rem                                     For example: dart compile exe --packages=/tmp/pkgs main.dart
rem     --[no-]sound-null-safety        Respect the nullability of types at runtime.
rem -S, --save-debugging-info=<path>    Remove debugging information from the output and save it separately to the specified
rem                                     file.
rem                                     <path> can be relative or absolute.
rem 
rem Run "dart help" to see global options.

set version=1.0.0
set name=switch_subfiles

@echo on 
dart compile exe bin\%name%.dart -o releases\%name%_%version%.exe
pause
