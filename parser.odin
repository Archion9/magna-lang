// Some function names was changed with a "P" at the end because of redeclaration issues with lexer
package Magna_Compiler

import "core:fmt"
import "core:os"


Parser :: struct{
    tokens : []Token,
    pos : int
}

Stmt :: union{
    PrintStmt,
    ReturnStmt
}

PrintStmt :: struct {
    value: ^Expr, // keep it simple for now
}

ReturnStmt :: struct {
    value: ^Expr,
}

Expr :: union {
    NumberLiteral,
    IdentifierExpr,
    BinaryExpr,
}
NumberLiteral :: struct {
    value: string,
}

IdentifierExpr :: struct {
    name: string,
}

BinaryExpr :: struct {
    left: ^Expr,
    operator: TokenType,
    right: ^Expr,
}


parse :: proc(tokens: []Token) -> []Stmt {
    p := Parser{tokens = tokens};

    stmts: [dynamic]Stmt;

    for peekP(&p).type != .END_OF_FILE {
        stmt := parse_statement(&p);
        append(&stmts, stmt);
    }

    return stmts[:];
}

parse_statement :: proc(p: ^Parser) -> Stmt {
    if match(p, .PRINT) {
        value := parse_expression(p);
        expect(p, .SEMICOLON);
        return Stmt(PrintStmt{value = value});
    }

    if match(p, .RETURN) {
        value := parse_expression(p);
        expect(p, .SEMICOLON);
        return Stmt(ReturnStmt{value = value});
    }

    fmt.println("Unexpected token:", peekP(p).value);
    os.exit(1);
}

parse_expression :: proc(p: ^Parser) -> ^Expr {
    return parse_term(p);
}

parse_term :: proc(p: ^Parser) -> ^Expr {
    left := parse_factor(p);

    for {
        if match(p, .PLUS) || match(p, .MINUS) {
            op := p.tokens[p.pos-1].type;
            right := parse_factor(p);

            new_node := new(Expr);
            new_node^ = BinaryExpr{
                left = left,
                operator = op,
                right = right,
            };
            left = new_node;
        } else {
            break;
        }
    }

    return left;
}

parse_factor :: proc(p: ^Parser) -> ^Expr {
    left := parse_primary(p);

    for {
        if match(p, .STAR) || match(p, .SLASH) {
            op := p.tokens[p.pos-1].type;
            right := parse_primary(p);
            
            new_node := new (Expr);
            new_node^ = BinaryExpr{
                left = left,
                operator = op,
                right = right,
            };
            left = new_node;
        } else {
            break;
        }
    }

    return left;
}

parse_primary :: proc(p: ^Parser) -> ^Expr {
    t := advanceP(p);

    // partial for now because i don't want to write all the cases yet
    #partial switch t.type {
        case .NUMBER:
            expr := new (Expr);
            expr^ = NumberLiteral{value = t.value};
            return expr;

        case .IDENTIFIER:
            expr := new (Expr);
            expr^ = IdentifierExpr{name = t.value};
            return expr;

        case .LEFT_PARENTHESIS:
            expr := parse_expression(p);
            expect(p, .RIGHT_PARENTHESIS);
            return expr;
        case .RIGHT_PARENTHESIS:
            expr := parse_expression(p);
            expect(p, .SEMICOLON);
            return expr;
        case:
            fmt.println("Unexpected token:", t.value);
            os.exit(1);
    }
}

peekP :: proc(p: ^Parser) -> Token {
    return p.tokens[p.pos];
}

advanceP :: proc(p: ^Parser) -> Token {
    t := p.tokens[p.pos];
    p.pos += 1;
    return t;
}

match :: proc(p: ^Parser, t: TokenType) -> bool {
    if peekP(p).type == t {
        advanceP(p);
        return true;
    }
    return false;
}

expect :: proc(p: ^Parser, t: TokenType) {
    if !match(p, t) {
        fmt.println("Expected token:", t);
        os.exit(1);
    }
}