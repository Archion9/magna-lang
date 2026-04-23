package Magna_Compiler

import "core:os"
import "core:fmt"
import "core:sys/windows"

Help := []string {
    "Magna Language Compiler\n\n",
    "\t-help -- Information about the compiler\n",
    "\t-version -- Version number of the magna"
};


main :: proc(){
    args := os.args;

    // Change console output to utf8
    windows.SetConsoleOutputCP(.UTF8)

    if len(args) == 1 {
        fmt.println("Error: no arguments taken");
        return;
    }
    switch args[1]{
        case "-help": for x in Help {
             fmt.print(x);
        };
        case "-build": a : []Token = lexer(readFile("test.mag"));
        for t in a{
            fmt.printfln("%v %s", t.type, t.value);
        }
        case: fmt.println("Unknown argument"); 
    }
}