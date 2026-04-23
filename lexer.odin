package Magna_Compiler

import "core:os"
import "core:strings"
import "core:fmt"

TokenType :: enum{
    LEFT_PARENTHESIS,
    RIGHT_PARENTHESIS,
    SEMICOLON,
    COLON,
    RETURN,
    EQUALS,
    IF_STATEMENT,
    NUMBER,
    IDENTIFIER,
}
Token :: struct{
    type : TokenType,
    value : string
}

readFile :: proc(filePath : string) -> []u8
{
    data, err := os.read_entire_file(filePath, context.allocator);

    if err != nil {
        return nil;
    }
    return data;
}


lexer :: proc(rawData : []u8) -> []Token
{
    tokens : [dynamic]Token;

    i := 0;
    for i < len(rawData){
        c := rawData[i];
        if(c == ' ' || c == '\n' || c == '\t'){
            i = i + 1;
            continue;
        }

        if c >= '0' && c <= '9' {
            start := i;

            for i < len(rawData) && rawData[i] >= '0' && rawData[i] <= '9' {
                i += 1;
            }

            value := string(rawData[start:i]);

            append(&tokens, Token{
                type = .NUMBER,
                value = value,
            });

            continue;
        }

        if (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') {
            start := i;

            for i < len(rawData) &&
                ((rawData[i] >= 'a' && rawData[i] <= 'z') ||
                 (rawData[i] >= 'A' && rawData[i] <= 'Z')) {

                i += 1;
            }

            value := string(rawData[start:i]);

            switch value {
            case "return":
                append(&tokens, Token{
                    type = .RETURN,
                    value = value,
                });
            case "if":
                append(&tokens, Token{
                    type = .IF_STATEMENT,
                    value = value,
                });
            case: 
                append(&tokens, Token{
                    type = .IDENTIFIER,
                    value = value,
                });
                
            }
            continue;
        }

        switch c {
        case '(':
            append(&tokens, Token{
                type = .LEFT_PARENTHESIS,
                value = "(",
            });
        case '=':
        append(&tokens, Token{
            type = .EQUALS,
            value = "=",
        });
            
        case ')':
            append(&tokens, Token{
                type = .RIGHT_PARENTHESIS,
                value = ")",
            });
            
        }

        i += 1;

    }
    return tokens[:];
}