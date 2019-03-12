Use the following Mingw-w64 tools to generate .lib files
needed for Visual Studios
>gendef esvm40.dll
>dlltool.exe -d esvm40.def -D esvm40.dll -l esvm40.lib