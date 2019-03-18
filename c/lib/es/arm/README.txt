Description:
Location of VA Smalltalk for ARM Virtual Machine.
This is required because this project must link against the vm
to make use of the async queue and user prims.

Instructions:
- Copy esvm40.so to this directory.
- Run CMake, which will use this esvm40.so for linking
