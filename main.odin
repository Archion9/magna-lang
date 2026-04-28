package Magna_Compiler

import "core:os"
import "core:fmt"
import "core:sys/windows"

Help := []string {
    "Magna Language Compiler\n\n",
    "\t-help -- Information about the compiler\n",
    "\t-version -- Version number of the magna",
    "\t-build [file] -- tokenizing the test.mag for now"
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
        case "-build": a : []Stmt = parse(lexing(readFile("test.mag")));
        for t in a{
            stmtPrint(t);
        }
        case: fmt.println("Unknown argument"); 
    }
}
stmtPrint :: proc(s: Stmt) {
    switch _ in s {
        case PrintStmt:
            fmt.print("PrintStmt(");
            print_expr(s.(PrintStmt).value);
            fmt.println(")");

        case ReturnStmt:
            fmt.print("ReturnStmt(");
            print_expr(s.(ReturnStmt).value);
            fmt.println(")");
    }
}
print_expr :: proc(e: ^Expr) {
    switch _ in e^ {
        case NumberLiteral:
            fmt.print(e.(NumberLiteral).value);

        case IdentifierExpr:
            fmt.print(e.(IdentifierExpr).name);

        case BinaryExpr:
            fmt.print("(");
            print_expr(e.(BinaryExpr).left);
            fmt.print(" ");
            fmt.print(token_to_string(e.(BinaryExpr).operator));
            fmt.print(" ");
            print_expr(e.(BinaryExpr).right);
            fmt.print(")");
    }
}

token_to_string :: proc(t: TokenType) -> string {
    #partial switch t {
    case .PLUS:  return "+";
    case .MINUS: return "-";
    case .STAR:  return "*";
    case .SLASH: return "/";
    case:
        return "?";
    }
}