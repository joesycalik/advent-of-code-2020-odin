package day5

import "core:strings"
import "core:fmt"

main :: proc() {
    lines := strings.split(string(#load("day5input.txt")), "\n");

    part1_answer, occupied_seat_ids := part1(lines);
    fmt.println("Part 1 Answer = ", part1_answer);
    fmt.println("Part 2 Answer = ", part2(occupied_seat_ids));
}

part1 :: proc(lines : []string) -> (int, [dynamic]int) {
    rows : [128]int;
    for i in 0..<128 do rows[i] = i;
    columns : [8]int;
    for i in 0..<8 do columns[i] = i;

    maxID := 0;
    occupied_seat_ids : [dynamic]int;

    for line in lines {
        curr_row := rows[:];
        curr_col := columns[:];
        for char in line {
            switch char {
                case 'F': curr_row = curr_row[:len(curr_row)/2];
                case 'B': curr_row = curr_row[len(curr_row)/2:];
                case 'L': curr_col = curr_col[:len(curr_col)/2];
                case 'R': curr_col = curr_col[len(curr_col)/2:];
            }
        }
        res := (curr_row[0] * 8) + curr_col[0];
        append(&occupied_seat_ids, res);
        if res > maxID do maxID = res;
    }
    return maxID, occupied_seat_ids;
}

part2 :: proc(occupied_seat_ids : [dynamic]int) -> int {
    possible_ids : [dynamic]int;
    for i in 0..<128 {
        inner : for j in 0..<8 {
            possible_id := (i * 8) + j;
            for occupied_id in occupied_seat_ids {
                if occupied_id == possible_id do continue inner;
            }
            append(&possible_ids, possible_id);
        }
    }

    for possible_id in possible_ids {
        min1 := possible_id - 1;
        plus1 := possible_id + 1;
        hits := 0;
        for occupied_id in occupied_seat_ids {
            if occupied_id == min1 do hits += 1;
            if occupied_id == plus1 do hits += 1;
        }
        if hits == 2 do return possible_id;
    }
    return -1;

}