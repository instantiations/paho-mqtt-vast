Description:
MSVC requires the .lib files. These can be easily generated

MINGW-W64 Instructions:
Use the following Mingw-w64 tools to generate .lib files
needed for Visual Studios
```console
>gendef esae40.dll
>dlltool.exe -d esae40.def -D esae40.dll -l esae40.lib

>gendef esae40.dll
>dlltool.exe -d esvm40.def -D esvm40.dll -l esvm40.lib
```
