package Magna_Compiler

import "core:strings"
import "core:os"
import "core:fmt"

Codegen :: struct{
    label_count : int,
    stack_depth : int,
    string_count : int,
    output : ^os.File
}

emit :: proc (cg : ^Codegen, instruction : string, value : string = ""){
    fmt.fprintln(cg.output, instruction, value);
}


gen_expr :: proc(cg: ^Codegen, e: ^Expr) {
    #partial switch _ in e {
    
    case NumberLiteral:
        emit(cg, "\tmov eax, ",  e.(NumberLiteral).value);

    case BinaryExpr:
        gen_expr(cg, e.(BinaryExpr).left);
        
        // Preserve its result.
        emit(cg, "\tpush rax");
        
        gen_expr(cg, e.(BinaryExpr).right);

        // Move right operand into ECX.
        emit(cg, "\tmov ecx, eax");

        // Restore left operand into EAX.
        emit(cg, "\tpop rax");

        #partial switch e.(BinaryExpr).operator {
            case .PLUS:  emit(cg, "\tadd eax, ecx");
            case .MINUS: emit(cg, "\tsub eax, ecx");
            case .STAR:  emit(cg, "\timul eax, ecx");
            case .SLASH: 
                emit(cg, "\tcdq");
                emit(cg, "\tidiv ecx")
        }
        case StringLiteral: 
            id := cg.string_count
            cg.string_count += 1

            emit(cg, ".section .rdata,\"dr\"");
            emit(cg, fmt.aprintf(".Lstr_%d:", id));

            emit(cg, fmt.aprintf("\t.asciz \"%s\"",e.(StringLiteral).value));
            emit(cg, ".text")
            emit(cg, fmt.aprintf("\tlea rax, [rip + .Lstr_%d]", id));
    }
}
gen_print_expr :: proc(cg: ^Codegen, e: ^Expr){

    #partial switch _ in e {

    case StringLiteral:
        gen_expr(cg, e)

        emit(cg, "\tlea rcx, [rip + .Lfmt_str]")
        emit(cg, "\tmov rdx, rax")

    case NumberLiteral, BinaryExpr:
        gen_expr(cg, e)

        emit(cg, "\tlea rcx, [rip + .Lfmt_int]")
        emit(cg, "\tmov edx, eax")
    }
    emit(cg, "\tcall printf");
}

gen_stmt :: proc(cg: ^Codegen, s: Stmt) {
    #partial switch _ in s {
    case IfStmt:
    
    case PrintStmt:
        gen_print_expr(cg, s.(PrintStmt).value);

    case ReturnStmt:
        gen_expr(cg, s.(ReturnStmt).value);
        emit(cg, "\tjmp .Lmain_epilogue")
    }
}

gen_code :: proc(cg: ^Codegen, statements: []Stmt){

    // File setup
    emit(cg, ".intel_syntax noprefix")
    emit(cg, "")
    emit(cg, ".extern printf")
    emit(cg, "")

    // Global data
    emit(cg, ".section .rdata,\"dr\"")
    emit(cg, ".Lfmt_int:")
    emit(cg, "\t.asciz \"%d\\n\"")
    emit(cg, "")
    emit(cg, ".Lfmt_str:")
    emit(cg, "\t.asciz \"%s\\n\"")
    emit(cg, "")

    // Main function
    emit(cg, ".text")
    emit(cg, ".globl main")
    emit(cg, ".seh_proc main")
    emit(cg, "main:")

    // Prologue
    emit(cg, "\tpush rbp")
    emit(cg, "\t.seh_pushreg rbp")
    emit(cg, "\tmov rbp, rsp")
    emit(cg, "\t.seh_setframe rbp, 0")
    emit(cg, "\tsub rsp, 32")
    emit(cg, "\t.seh_stackalloc 32")
    emit(cg, "\t.seh_endprologue")

    // Generate statements
    for s in statements {
        gen_stmt(cg, s)
    }

    // Default return value (when no explicit return executes)
    emit(cg, "\txor eax, eax")

    // Epilogue
    emit(cg, ".Lmain_epilogue:")
    emit(cg, "\tmov rsp, rbp")
    emit(cg, "\tpop rbp")
    emit(cg, "\tret")
    emit(cg, ".seh_endproc")
    // emit(cg, ".intel_syntax noprefix");

    // emit(cg, ".global main");
    // emit(cg, ".section .rdata");
    // emit(cg, "fmt:");
    // emit(cg, "\t.asciz \"%d\\n\"");
    // emit(cg, ".extern printf")

    // emit(cg, "main:");
    

    // for s in statements {
    //     gen_stmt(cg, s);
    // }

}