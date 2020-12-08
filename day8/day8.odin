package day8

import "core:fmt"
import "core:strings"
import "core:strconv"

Instruction :: struct {
    operation : string,
    arg : int,
    called : bool
}

main :: proc() {
    lines := strings.split(string(#load("day8input.txt")), "\r\n");
    instructions := get_instructions(lines);
    
    part1_answer, _ := part1(instructions);
    fmt.println("Part 1 answer=", part1_answer);
    fmt.println("Part 2 answer=", part2(instructions));

}

part1 :: proc(instructions : [dynamic]Instruction) -> (acc : int, last_instruction_idx : int) {
    i := 0;

    loop : for {
        if i == len(instructions) || instructions[i].called == true do return acc, last_instruction_idx;
        instructions[i].called = true;
        last_instruction_idx = i;

        switch(instructions[i].operation) {
            case "jmp":
                i += instructions[i].arg;
                continue loop;
            case "acc": acc += instructions[i].arg;
            case "nop":
        }
        i += 1;
    }
}

part2 :: proc(instructions : [dynamic]Instruction) -> int {
    for i in 0..<len(instructions) {
        for _, i in instructions {
            instruction := &instructions[i];
            instruction.called = false;
        }

        if instructions[i].operation == "jmp" || instructions[i].operation == "nop" {
            switch_instruction_operation(&instructions[i]);
        }
        val, last_instruction_idx := part1(instructions);
        if last_instruction_idx == len(instructions) - 1 do return val;
        switch_instruction_operation(&instructions[i]);
    }
    return -1;
    
}

switch_instruction_operation :: proc(instruction : ^Instruction) {
    switch instruction.operation {
        case "jmp": instruction.operation = "nop";
        case "nop": instruction.operation = "jmp";
    }
}

get_instructions :: proc(lines : []string) -> (instructions : [dynamic]Instruction) {
    for line in lines {
        tokens := strings.split(line, " ");
        operation := tokens[0];
        arg,_ := strconv.parse_int(tokens[1]);
        instruction := Instruction{operation, arg, false};
        append(&instructions, instruction);
    }
    return instructions;
}

/*
Part 2 initial line of thinking - Backtracking based on a call stack, popping until hitting the last changed index
*/
