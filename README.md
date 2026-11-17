# magna-lang
Work in progress compiled programming language

# Roadmap
Compiled programming language.

# Compiler structure

source -> lexer -> tokens -> parser -> Abstract tree -> semantic analysis -> code generation -> GCC assembler -> executable

# Requirements for the project
- Odin compiler
- GCC assembler
- Makefile

# How does codegen works?
- I use the GCC assembler (GAS) using the x86-64(AMD64) architecture with Intel syntax
- Platform is windows for now because i can't learn everything

# How to test?
- Run ```make build``` and then ```make run```