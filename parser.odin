package Magna_Compiler

import "core:fmt"
import "core:os"


Parser :: struct{
    tokens : []Token,
    pos : int
}

Stmt :: union{
    PrintStmt,
    ReturnStmt,
    IfStmt
}

PrintStmt :: struct {
    value: ^Expr, 
}

ReturnStmt :: struct {
    value: ^Expr,
}
IfStmt :: struct{
    condition : ^Expr,
    body : []Stmt
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

    for parse_peek(&p).type != .END_OF_FILE {
        stmt := parse_statement(&p);
        append(&stmts, stmt);
    }

    return stmts[:];
}

parse_statement :: proc(p: ^Parser) -> Stmt {
    if parse_match(p, .PRINT) {
        value := parse_expression(p);
        parse_expect(p, .SEMICOLON);
        return Stmt(PrintStmt{value = value});
    }

    if parse_match(p, .RETURN) {
        value := parse_expression(p);
        parse_expect(p, .SEMICOLON);
        return Stmt(ReturnStmt{value = value});
    }
    if parse_match(p, .IF){
        parse_expect(p, .LEFT_PARENTHESIS);
        cond := parse_expression(p);
        parse_expect(p, .RIGHT_PARENTHESIS);

        body : [dynamic]Stmt;
        
        parse_expect(p, .LEFT_BRACE);

        for parse_peek(p).type != .RIGHT_BRACE {
            stmt := parse_statement(p);
            append(&body, stmt);
        }
        parse_expect(p, .RIGHT_BRACE);

        return Stmt(IfStmt{
            condition = cond,
            body = body[:],
        });
    }

    fmt.println("Unparse_expected statement token:", parse_peek(p).value);
    os.exit(1);
}

parse_expression :: proc(p: ^Parser) -> ^Expr {
    return parse_equality(p);
}

parse_equality :: proc(p: ^Parser) -> ^Expr{
    left := parse_term(p);

    for {
        if parse_match(p, .EQUAL_EQUAL) {
            op := p.tokens[p.pos - 1].type;
            right := parse_factor(p);

            new_node := new(Expr);
            new_node^ = BinaryExpr{
                left = left,
                operator = op,
                right = right
            };
            left = new_node;
        }else {
            break;
        }
    }
    return left;
}

parse_term :: proc(p: ^Parser) -> ^Expr {
    left := parse_factor(p);

    for {
        if parse_match(p, .PLUS) || parse_match(p, .MINUS) {
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
        if parse_match(p, .STAR) || parse_match(p, .SLASH) {
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
    t := parse_advance(p);

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
            parse_expect(p, .RIGHT_PARENTHESIS);
            return expr;
        case .LEFT_BRACE:
            expr := parse_expression(p);
            parse_expect(p, .RIGHT_BRACE);
            return expr;
        case .EQUAL_EQUAL:
            expr := parse_expression(p);
            return expr;
        case:
            fmt.println("Uexpected primary token:", t.value);
            os.exit(1);
    }
}

parse_peek :: proc(p: ^Parser) -> Token {
    return p.tokens[p.pos];
}

parse_advance :: proc(p: ^Parser) -> Token {
    t := p.tokens[p.pos];
    p.pos += 1;
    return t;
}

parse_match :: proc(p: ^Parser, t: TokenType) -> bool {
    if parse_peek(p).type == t {
        parse_advance(p);
        return true;
    }
    return false;
}

parse_expect :: proc(p: ^Parser, t: TokenType) {
    if !parse_match(p, t) {
        fmt.println("parse_expected token:", t);
        fmt.println("Got this instead:", parse_peek(p).type);
        os.exit(1);
    }
}