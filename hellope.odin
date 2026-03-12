package main

import "core:fmt"
import "core:sys/windows"

main :: proc(){
    // Change console output to utf8
    windows.SetConsoleOutputCP(.UTF8)

    text := "árvíztűrő tükörfúrógép"
    fmt.println("Hello World! ", text)
    a : int = 5
    b : int = 10
    fmt.println("The sum of", a, "and", b, "is", a + b)
}