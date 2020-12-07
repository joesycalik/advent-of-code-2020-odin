package day7

import "core:strings"
import "core:fmt"
import "core:strconv"

main :: proc() {
    lines := strings.split(string(#load("day7input.txt")), "\r\n");
    bags : map[string]map[string]string;

    for line in lines {
        key, value := Get_Bag_Map(line);
        bags[key] = value;
    }

    fmt.println("Part 1 Answer: ", part1(bags));
    fmt.println("Part 2 Answer: ", part2("shiny gold bag", bags));
}

part1 :: proc(bags : map[string]map[string]string) -> (sum : int) {
    for key, value in bags {
        if Check_Contents(value, bags) do sum += 1;
    }
    return sum;
}

Check_Contents :: proc(content : map[string]string, bags : map[string]map[string]string) -> bool {
    for key, value in content {
        if key == "shiny gold bag" do return true;
        if Check_Contents(bags[key], bags) do return true;
    }
    return false;
}

part2 :: proc(bag_to_check : string, bags : map[string]map[string]string) -> (sum : int) {
    content := bags[bag_to_check];
    for key, value in content {
        val_int,_ := strconv.parse_int(value);
        sum += (val_int + (val_int * part2(key, bags)));
    }
    return sum;
}

Get_Bag_Map :: proc(line : string) -> (key : string, value : map[string]string) {
    first_split := strings.split(line, "contain");
    key = strings.trim_suffix(strings.trim_space(first_split[0]), "s");

    second_split := strings.split(first_split[1], ",");

    content_strings : [dynamic]string;
    for sub in second_split {
        append(&content_strings, strings.trim_suffix(strings.trim_suffix(strings.trim_space(sub), "."), "s"));
    }

    for content in content_strings {
        if content == "no other bag" do continue;
        value[content[2:]] = content[0:1];
    }

    return key, value;
}