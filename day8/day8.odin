package day8

import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:container"
import "core:sys/windows"

Instruction :: struct {
    operation : string,
    arg : int
}

possibly_corrupt : [dynamic]int;
hit : [1000]bool;

// Both original and optimized solution exec times tested with `odin build .\day8.odin -opt:3 -no-bounds-check -microarch=native`
/* Original solution exec time (Original code : https://pastebin.com/pkkyKYrs)
Part 1 : 114.900 microseconds
Part 2 : 307.600 microseconds
*/

/* Optimized solution exec time
Part 1 : 112.100 microseconds
Part 2 : 49.500 microseconds
*/
main :: proc() {
    lines := strings.split(string(#load("day8input.txt")), "\r\n");

    // This monstrosity does the profiling
    frq, cnt1, cnt2: windows.LARGE_INTEGER;
    windows.QueryPerformanceCounter(&cnt1);
    windows.QueryPerformanceFrequency(&frq);
    instructions := get_instructions(lines);
    part1_answer, _ := part1(instructions); // The actual part1() call
    windows.QueryPerformanceCounter(&cnt2);
    fmt.println( f64(cnt2 - cnt1) / f64(frq) * 1000.0 * 1000.0, "microseconds" );
    fmt.println("Part 1 answer=", part1_answer);

    
    windows.QueryPerformanceCounter(&cnt1);
    windows.QueryPerformanceFrequency(&frq);
    part2_answer := part2(instructions); // The actual part2() call
    windows.QueryPerformanceCounter(&cnt2);
    fmt.println( f64(cnt2 - cnt1) / f64(frq) * 1000.0 * 1000.0, "microseconds" );
    fmt.println("Part 1 answer=", part1_answer);
}

part1 :: proc(instructions : [dynamic]Instruction) -> (acc : int, last_instruction_idx : int) {
    i := 0;

    loop : for {
        if i == len(instructions) || hit[i] do return acc, last_instruction_idx;
        hit[i] = true;
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
    for idx := len(possibly_corrupt) - 1; idx >=0 ; idx -= 1 {
        patch_idx : = possibly_corrupt[idx];
        hit = {};

        switch_instruction_operation(&instructions[patch_idx]);
        val, last_instruction_idx := part1(instructions);
        if last_instruction_idx == len(instructions) - 1 do return val;
        switch_instruction_operation(&instructions[patch_idx]);
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
    for line, idx in lines {
        tokens := strings.split(line, " ");
        operation := tokens[0];
        arg,_ := strconv.parse_int(tokens[1]);
        instruction := Instruction{operation, arg};
        if operation == "jmp" || operation == "nop" do append(&possibly_corrupt, idx);
        append(&instructions, instruction);
    }
    return instructions;
}

/*
Part 2 initial line of thinking - Backtracking based on a call stack, popping until hitting the last changed index
*/