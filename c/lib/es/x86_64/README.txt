Description:
Location of VA Smalltalk for x86_64 Virtual Machine.
This is required because this project must link against the vm
to make use of the async queue and user prims.

Windows Instructions:
- Copy esvm40.dll and esae40.dll to this directory
- Run CMake, which will use this esvm40.dll for linking
- esae40.dll is a dependency of esvm40.dll, so its required.

Linux Instructions:
- Copy esvm40.so to this directory.
- Run CMake, which will use this esvm40.so for linking
