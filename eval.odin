package Magna_Compiler

import "core:fmt"
import "core:strconv"

execute_stmt :: proc (s : Stmt){
    switch _ in s {
        case PrintStmt:
            value := evaluate_expr(s.(PrintStmt).value);
            fmt.println(value);

        case ReturnStmt:
            value := evaluate_expr(s.(ReturnStmt).value);
            fmt.println("return:", value);

        case IfStmt:
            cond := evaluate_expr(s.(IfStmt).condition);

            if cond != 0 {
                for stmt in s.(IfStmt).body  {
                    execute_stmt(stmt);
                }
            }
    }
}
evaluate_expr :: proc (e : ^Expr) -> f64{

    switch _ in e^ {
    case NumberLiteral:
        value, ok := strconv.parse_f64(e.(NumberLiteral).value);
        return value;

    case BinaryExpr:
        left := evaluate_expr(e.(BinaryExpr).left);
        right := evaluate_expr(e.(BinaryExpr).right);

        #partial switch e.(BinaryExpr).operator {
            case .PLUS:  return left + right;
            case .MINUS: return left - right;
            case .STAR:  return left * right;
            case .SLASH: return left / right;
            case .EQUAL_EQUAL:
                if left == right { return 1; }
                return 0;
        }

    case IdentifierExpr:
        return 0; // later: variables
    }

    return 0;
}