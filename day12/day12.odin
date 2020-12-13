package day12

import "core:fmt"
import "core:strings"
import "core:strconv"

Command :: struct {
    instruction : string,
    val : int
}

turn_left :: proc(current_dir : int, val : int) -> int {
    ret_dir := current_dir;
    turn_val := val;
    for turn_val > 0 {
        if ret_dir - 1 == -1 do ret_dir = 3;
        else do ret_dir -= 1;
        turn_val -= 90;
    }
    return ret_dir;
}

turn_right :: proc(current_dir : int, val : int) -> int {
    ret_dir := current_dir;
    turn_val := val;
    for turn_val > 0 {
        if ret_dir + 1 == 4 do ret_dir = 0;
        else do ret_dir += 1;
        turn_val -= 90;
    }
    return ret_dir;
}

main :: proc() {
    lines := strings.split(string(#load("day12input.txt")), "\r\n");

    commands : [dynamic]Command;
    for line in lines {
        val, _ := strconv.parse_int(line[1:]);
        c := Command {line[:1], val};
        append(&commands, c);
    }

    fmt.println("Part 1 answer = ", part1(commands[:]));
    fmt.println("Part 2 answer = ", part2(commands[:]));
}

part1 :: proc(commands : []Command) -> int {
    current_dir := 1;
    ns, ew : int;
    for command in commands {
        switch command.instruction {
            case "L":
                current_dir = turn_left(current_dir, command.val);
            case "R":
                current_dir = turn_right(current_dir, command.val);
            case "N": ns += command.val;
            case "S": ns -= command.val;
            case "E": ew += command.val;
            case "W": ew -= command.val;
            case "F":
                switch current_dir {
                    case 0:
                        ns += command.val;
                    case 1:
                        ew += command.val;
                    case 2:
                        ns -= command.val;
                    case 3:
                        ew -= command.val;
                }
            
        }
    }
    return abs(ns) + abs(ew);
}

rotate_waypoint_left :: proc(wp_ns, wp_ew : int, val : int) -> (int, int) {
    ns := wp_ns;
    ew := wp_ew;
    turn_val := val;
    for turn_val > 0 {
        a := ew;
        b := -ns;
        ns = a;
        ew = b;
        turn_val -= 90;
    }
    return ns, ew;
}

rotate_waypoint_right :: proc(wp_ns, wp_ew : int, val : int) -> (int, int) {
    ns := wp_ns;
    ew := wp_ew;
    turn_val := val;
    for turn_val > 0 {
        a := -ew;
        b := ns;
        ns = a;
        ew = b;
        turn_val -= 90;
    }
    return ns, ew;
}

part2 :: proc(commands : []Command) -> int {
    wp_ns := 1;
    wp_ew := 10;
    loc_ns := 0;
    loc_ew := 0;
    for command in commands {
        switch command.instruction {
            case "L":
                wp_ns, wp_ew = rotate_waypoint_left(wp_ns, wp_ew, command.val);
            case "R":
                wp_ns, wp_ew = rotate_waypoint_right(wp_ns, wp_ew, command.val);
            case "N": wp_ns += command.val;
            case "S": wp_ns -= command.val;
            case "E": wp_ew += command.val;
            case "W": wp_ew -= command.val;
            case "F":
                loc_ns += (command.val * wp_ns);
                loc_ew += (command.val * wp_ew);
            
        }
    }
    return abs(loc_ns) + abs(loc_ew);
}