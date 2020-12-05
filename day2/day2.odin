package day2

import "core:os"
import "core:strings"
import "core:fmt"
import "core:strconv"
import "core:unicode/utf8"

Pass :: struct {
    letter_min, letter_max : int,
    letter : rune,
    password : string
};

// Input file has format of "policy: pass" where policy is details the min and max number of times a letter
// must be found in the password "{min}-{max} {letter}"
main :: proc() {
    bytes, err := os.read_entire_file("day2input.txt");
    lines := strings.split(cast(string)bytes, "\n");

    passes : [dynamic]Pass;
    defer delete(passes);

    fmt.println(len(lines));
    for line in lines {
        sections := strings.split(line, " ");
        pass : Pass;
        minmax := strings.split(sections[0], "-");
        pass.letter_min = strconv.atoi(minmax[0]);
        pass.letter_max = strconv.atoi(minmax[1]);
        pass.letter = cast(rune)sections[1][0];
        val : string = cast(string)sections[1][0];
        pass.password = sections[2];
        append(&passes, pass);
    }

    count_trees :: proc(dx, dy: int, grid: []string) -> (sum: int) {
	x, y: int;
	mod := len(grid[0]) - 1; // -1 since '\n' is part of string
	for y < len(grid) {
		if grid[y][x%mod] == '#' {
			sum += 1;
		}
		x += dx;
		y += dy;
	}
	return;
}

    fmt.println("Part 1 Answer: ", part1(&passes));
    fmt.println("Part 2 Answer: ", part2(&passes));
}

// How many passwords are valid according to their policies?
part1 :: proc(passes : ^[dynamic]Pass) -> int {
    valid_pass_count := 0;
    for pass in passes {
        letter_count := 0;
        for char in pass.password {
            if char == pass.letter {
                letter_count += 1;
            }
        }
        if letter_count >= pass.letter_min && letter_count <= pass.letter_max {
            valid_pass_count += 1;
        }
    }
    return valid_pass_count;
}

// Each policy actually describes two positions in the password, where 1 is first char.
// Exactly one of the positions must contain the given letter. Other instances are irrelevant
part2 :: proc(passes : ^[dynamic]Pass) -> int {
    valid_pass_count := 0;
    for pass in passes {
        pass_as_runes := utf8.string_to_runes(pass.password);
        if (pass_as_runes[pass.letter_min - 1] == pass.letter && pass_as_runes[pass.letter_max - 1] != pass.letter) ||
            (pass_as_runes[pass.letter_min - 1] != pass.letter && pass_as_runes[pass.letter_max - 1] == pass.letter) {
            valid_pass_count += 1;
        }
    }
    return valid_pass_count;
}