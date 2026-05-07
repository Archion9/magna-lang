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
        case "-build": 
        tokens : []Token = lexing(readFile("test.mag"));
        for t in tokens{
            fmt.print(t.type);
            fmt.print(" ");
            
            fmt.println(t.value);
            
        }
        statements : []Stmt = parse(tokens);
        for s in statements{
            stmtPrint(s);
        }
        fmt.println();
        for &s in statements {
            analyze_stmt(&s);   
        }
        cg : Codegen;
        file, err := os.create("output.ll");
        if err != nil {
            fmt.println("Failed to create file");
            os.exit(1);
        }
        cg.output = file;
        fmt.fprintln(cg.output, "define i32 @main() {");
        fmt.fprintln(cg.output, "entry:");
        for s in statements{
            gen_stmt(&cg, s);
        }
        fmt.fprintln(cg.output, "}");
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
        case IfStmt:
            fmt.print("IfStmt(");
            print_expr(s.(IfStmt).condition);
            fmt.println(") {");
            for stmt in s.(IfStmt).body {
                stmtPrint(stmt);
            }

            fmt.println("}");

        case: fmt.println("Nem látom mit jelent");
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
    case .EQUAL_EQUAL: return "==";
    case:
        return "?";
    }
}