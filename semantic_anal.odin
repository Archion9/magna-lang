package Magna_Compiler

import "core:fmt"
import "core:os"

Type :: enum {
    INT,
    BOOL
}

analyze_expr :: proc (e : ^Expr) -> Type{
    switch _ in e{
        case NumberLiteral:
            return .INT;
        case IdentifierExpr:
            return .INT;
        case BinaryExpr:
            left_type := analyze_expr(e.(BinaryExpr).left);
            right_type := analyze_expr(e.(BinaryExpr).right);

            op := e.(BinaryExpr).operator;

            if op == .PLUS || op == .MINUS || op == .STAR || op == .SLASH {
                if left_type != .INT || right_type != .INT {
                    fmt.println("Type error: arithmetic needs INT");
                    os.exit(1);
                }
                return .INT;
            }

            if op == .EQUAL_EQUAL {
                if left_type != right_type {
                    fmt.println("Type error: cannot compare different types");
                    os.exit(1);
                }
                return .BOOL;
            }
    }
    return .INT;
}

analyze_stmt :: proc (s : ^Stmt){
    switch _ in s{
        case IfStmt:
            cond_type := analyze_expr(s.(IfStmt).condition);
            
            if cond_type != .BOOL && cond_type != .INT {
                fmt.println("Invalid IF condition");
                os.exit(1);
            }
            for i := 0; i < len(s.(IfStmt).body); i += 1 {
                analyze_stmt(&s.(IfStmt).body[i]);
            }
        case ReturnStmt:
            analyze_expr(s.(ReturnStmt).value);
        case PrintStmt:
            analyze_expr(s.(PrintStmt).value);
    }
}