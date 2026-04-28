package Magna_Compiler

import "core:os"
import "core:strings"
import "core:fmt"

TokenType :: enum{
    // Single letters
    LEFT_PARENTHESIS,
    RIGHT_PARENTHESIS,
    LEFT_BRACE, 
    RIGHT_BRACE,
    SEMICOLON,
    COLON,
    COMMA,

    // Operators
    PLUS,
    MINUS,
    STAR,
    SLASH, 
    EQUALS,
    EQUAL_EQUAL,
    NOT_EQUAL,
    LESS,
    LESS_EQUAL,
    GREATER,
    GREATER_EQUAL,

    /* Keywords */
    RETURN,
    IF,
    FLOAT_32,
    FLOAT_64,
    INTEGER,
    PRINT,

    
    // Literals
    STRING,
    IDENTIFIER,
    NUMBER,

    // Needs for parsing
    END_OF_FILE
}

Token :: struct{
    type : TokenType,
    value : string
}

Lexer :: struct {
    input : []u8,
    pos : int,
    tokens: [dynamic]Token
}

readFile :: proc(filePath : string) -> []u8
{
    data, err := os.read_entire_file(filePath, context.allocator);

    if err != nil {
        return nil;
    }
    return data;
}

lexing :: proc(rawData : []u8) -> []Token
{
    l := Lexer{
        input = rawData,
        pos = 0
    };

    for l.pos < len(l.input){
        c := advance(&l);

        if isWhiteSpace(c){
            continue;
        }

        if isDigit(c){
            scanNumber(&l, l.pos-1);
            continue;
        }

        if isLetter(c){
            scanIdentifier(&l, l.pos -1);
            continue;
        }
        scan_symbol(&l, c);
    }
    appendToken(&l, .END_OF_FILE, "");
    return l.tokens[:];
}

appendToken :: proc (l: ^Lexer, t : TokenType, value : string) {
    append(&l.tokens, Token{
        type = t,
        value = value,
    });
}

isWhiteSpace :: proc (c : u8) -> bool{
    return c == ' ' || c == '\n' || c == '\t' || c == '\r';
}

isLetter :: proc(c : u8) -> bool {
    return  (c >= 'a' && c <= 'z') ||
            (c >= 'A' && c <= 'Z') ||
             c == '_';
}

isDigit :: proc(c : u8) -> bool {
    return c >= '0' && c <= '9';
}

advance :: proc(l : ^Lexer) -> u8 {
    c := l.input[l.pos];
    l.pos = l.pos + 1;
    return c;
}

peek :: proc(l : ^Lexer) -> u8 { 
    if l.pos >= len(l.input) {
        return 0;
    }
    return l.input[l.pos];
}

scanNumber :: proc (l : ^Lexer, start : int){
    for l.pos < len(l.input) && isDigit(l.input[l.pos]) {
        l.pos += 1;
    }

    value := string(l.input[start:l.pos]);
    appendToken(l, .NUMBER, value);
}

scanIdentifier :: proc (l : ^Lexer, start : int){
    for l.pos < len(l.input) &&
        (isLetter(l.input[l.pos]) || isDigit(l.input[l.pos])) {
        l.pos += 1;
    }

    value := string(l.input[start:l.pos]);

    switch value {
        case "return":
            appendToken(l, .RETURN, value);
        case "if":
            appendToken(l, .IF, value);
        case "f32":
            appendToken(l, .FLOAT_32, "f32");
        case "f64":
            appendToken(l, .FLOAT_64, "f64");
        case "print":
            appendToken(l, .PRINT, "print"); 
        case:
            appendToken(l, .IDENTIFIER, value);
    }
}

scan_symbol :: proc(l: ^Lexer, c: u8) {
    switch c {
        case '(':
            appendToken(l, .LEFT_PARENTHESIS, "(");
        case ')':
            appendToken(l, .RIGHT_PARENTHESIS, ")");
        case '{':
            appendToken(l, .LEFT_BRACE, "{");
        case '}':
            appendToken(l, .RIGHT_BRACE, "}"); 
        case '=':
            if peek(l) == '=' {
                advance(l);
                appendToken(l, .EQUAL_EQUAL, "==");
            } else {
                appendToken(l, .EQUALS, "=");
            }
        case '+':
            appendToken(l, .PLUS, "+");
        case '*':
            appendToken(l, .STAR, "*");
        case ';':
            appendToken(l, .SEMICOLON, ";");
        case:
            fmt.printf("Error on lexer: unknown symbol at pos %d, character code: ", l.pos);
            fmt.println(c);
            os.exit(1);
    }
}