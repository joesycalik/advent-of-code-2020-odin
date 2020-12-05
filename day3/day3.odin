package day3

import "core:os"
import "core:strings"
import "core:fmt"
import "core:unicode/utf8"

main :: proc() {
    bytes, err := os.read_entire_file("day3input.txt");
    lines := strings.split(cast(string)bytes, "\n");

    fmt.println("Part 1 Answer: ", part1(lines));
    fmt.println("Part 2 Answer: ", part2(lines));
}

// File has "." and "#" to represent open spaces and trees respectively. Same pattern repeats to the right indefinitely
// Get number of trees encountered if moving to char right 3 and down 1 until past the bottom of the map
part1 :: proc(lines : []string)  -> int {
    return checkSlope(lines, 3, 1);
}

// Calculate additional slopes and multiply the results of each
part2 :: proc(lines : []string)  -> int {
    return checkSlope(lines, 1, 1) *
        checkSlope(lines, 3, 1) *
        checkSlope(lines, 5, 1) *
        checkSlope(lines, 7, 1) *
        checkSlope(lines, 1, 2);
}

checkSlope :: proc(lines : []string, right, down : int) -> (numTreesEncountered : int) {
    downCounter := down;
    linePos := 0;

    for line in lines[1:] {
        downCounter -= 1;
        if downCounter != 0 do continue;
        downCounter = down;
        linePos = (linePos + right) % 31;
        if line[linePos] == '#' do numTreesEncountered += 1;
    }
    
    return numTreesEncountered;

}