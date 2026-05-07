package Magna_Compiler

import "core:os"
import "core:fmt"

Codegen :: struct{
    temp_count : int,
    output : ^os.File
}


gen_expr :: proc(cg: ^Codegen, e: ^Expr) -> string {
    #partial switch _ in e {
    
    case NumberLiteral:
        return e.(NumberLiteral).value;

    case BinaryExpr:
        left := gen_expr(cg, e.(BinaryExpr).left);
        right := gen_expr(cg, e.(BinaryExpr).right);

        temp := fmt.tprintf("%%t%d", cg.temp_count);
        cg.temp_count += 1;

        op := "";

        #partial switch e.(BinaryExpr).operator {
            case .PLUS:  op = "add";
            case .MINUS: op = "sub";
            case .STAR:  op = "mul";
            case .SLASH: op = "sdiv";
        }
        
        fmt.fprintln(cg.output,
            temp, " = ", op, " i32 ", left, ", ", right);

        return temp;
    }

    return "0";
}

gen_stmt :: proc(cg: ^Codegen, s: Stmt) {
    #partial switch _ in s {

    case ReturnStmt:
        value := gen_expr(cg, s.(ReturnStmt).value);
        fmt.fprintln(cg.output, "ret i32 ", value);
    }
}