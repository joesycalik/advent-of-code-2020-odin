package day6

import "core:strings"
import "core:fmt"
import "core:slice"
import "core:unicode/utf8"

main :: proc() {
    lines := strings.split(string(#load("day6input.txt")), "\r\n");
    
    fmt.println("Part 1 Answer: ", part1(lines));
    fmt.println("Part 2 Answer: ", part2(lines));
}

part1 :: proc(lines : []string) -> int{
    questions : [dynamic]rune;
    for char in 'a'..'z' do append(&questions, char);

    answered_questions : [dynamic]rune;
    sum := 0;

    for line in lines {
        if len(line) == 0 {
            sum += len(answered_questions);
            clear(&answered_questions);
        }
        loop: for char in line {
            for answer in answered_questions {
                if char == answer do continue loop;
            }
            append(&answered_questions, char);
        }        
    }
    return sum;
}

part2 :: proc(lines : []string) -> (sum : int) {
    lines_in_group : [dynamic]string;
    for line in lines {
        if len(line) > 0 {
            append(&lines_in_group, line);
            continue;
        }

        loop : for char in lines_in_group[0] {
            for group_line in lines_in_group {
                if strings.contains_rune(group_line, char) == -1 do continue loop;
            }
            sum += 1;
        }
        clear(&lines_in_group);
    }

    return sum;
}