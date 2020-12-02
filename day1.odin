package day1

import "core:fmt"
import "core:mem"
import "core:os"
import "core:strconv"
import "core:runtime"
import "core:strings"

main :: proc() {
    fmt.println("Day 1 Answer: ", dayOne());
}

// Part 1: Find 2 entries in a file that sum to 2020, then mutiply them together to get the answer
// Part 2: Find 3 entries in the same file that sum to 2020 the return the product
dayOne :: proc() -> (part1, part2 : int){
    byteData, err := os.read_entire_file("day1input.txt");

    input : [dynamic]int;
    defer delete(input);

    curLine := strings.make_builder();
    defer strings.destroy_builder(&curLine);

    for char in string(byteData) {
        if char != '\n' { 
            strings.write_rune(&curLine, char);
        } else {
            append(&input, strconv.parse_int(strings.to_string(curLine)));
            strings.reset_builder(&curLine);
        }
    }

    subVals : map[int]int;
    defer delete(subVals);
    for val in input {
        subVal := 2020 - val;
        if subVal in subVals {
            part1 = val * subVal;
        }
        subVals[val] = subVal;
    }

    subVals2 : map[int]int;
    defer delete(subVals2);
    for subVal in subVals {
        for inVal in input {
            num := subVals[subVal] - inVal;
            if num in subVals2 {
                part2 = subVal * inVal * num;
            }
            subVals2[inVal] = num;
        }
    }

    return part1, part2;
}