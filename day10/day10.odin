package day10

import "core:fmt"
import "core:strings"
import "core:slice"
import "core:strconv"
import "core:sys/windows"

/* Profiling 
Regular build (odin run .\day9.odin)
----------------------------------------
Part 1 exec time: 5.000 microseconds
Part 2 exec time: 177.400 microseconds
----------------------------------------

Optimized build (odin build .\day9.odin -opt:3 -no-bounds-check -microarch=native)
----------------------------------------
Part 1 exec time: 0.300 microseconds
Part 2 exec time: 91.900 microseconds
----------------------------------------
*/
main :: proc() {
    lines := strings.split(string(#load("day10input.txt")), "\r\n");
    values : [dynamic]int;
    append(&values, 0);
    for line in lines {
        val, _ := strconv.parse_int(line);
        append(&values, val);
    }
    val_slice := values[:];
    slice.sort(val_slice);

    // Needed for the profiling below
    frq, cnt1, cnt2: windows.LARGE_INTEGER;
    // Part 1
    //-----------------------------------------------------------------------------------------------
    windows.QueryPerformanceCounter(&cnt1);
    windows.QueryPerformanceFrequency(&frq);

    part1_answer := part1(val_slice); // The actual part1() call

    windows.QueryPerformanceCounter(&cnt2);
    fmt.println("Part 1 exec time:", f64(cnt2 - cnt1) / f64(frq) * 1000.0 * 1000.0, "microseconds" );
    //-----------------------------------------------------------------------------------------------
    // Part 2
    //-----------------------------------------------------------------------------------------------
    windows.QueryPerformanceCounter(&cnt1);
    windows.QueryPerformanceFrequency(&frq);

    part2_answer := part2(val_slice); // The actual part2() call

    windows.QueryPerformanceCounter(&cnt2);
    fmt.println("Part 2 exec time:", f64(cnt2 - cnt1) / f64(frq) * 1000.0 * 1000.0, "microseconds" );
    //-----------------------------------------------------------------------------------------------

    fmt.println("Part 1 answer=", part1_answer);
    fmt.println("Part 2 answer=", part2_answer);
}

part1 :: proc(values : []int) -> int {
    diff_one, diff_three := 0, 1;
    for i in 0..<len(values) - 1 {
        diff := values[i + 1] - values[i];
        if diff == 1 do diff_one += 1;
        if diff == 3 do diff_three += 1;
    }
    return diff_one * diff_three;
}

Node_Type :: struct {
    val : int,
    in_vals : [dynamic]int,
    out_vals : [dynamic]int
}

part2 :: proc(values: []int) -> int {
    node_types : [dynamic]Node_Type;
    val_node_counts : map[int]int;
    loop : for val_idx in 0..<len(values) - 1 {
        new_node_type : Node_Type;
        new_node_type.val = values[val_idx];
        for range in 1..3 {
            if val_idx + range > len(values) - 1 do break;
            diff := values[val_idx + range] - values[val_idx];
            if diff <= 3 do append(&new_node_type.out_vals, values[val_idx + range]);
        }
        for range in 1..3 {
            if val_idx - range < 0 do break;
            diff := values[val_idx] - values[val_idx - range];
            if diff <= 3 do append(&new_node_type.in_vals, values[val_idx - range]);
        }
        append(&node_types, new_node_type);
    }

    val_node_counts[0] = 1;
    current_branches := 1;
    for val_idx in 0..<len(values) - 1 {
        node_count := val_node_counts[values[val_idx]];
        for out_val in node_types[val_idx].out_vals {
            val_node_counts[out_val] += node_count;
        }
        current_branches += (len(node_types[val_idx].out_vals) - 1) * node_count;

    }
    return current_branches;
}
