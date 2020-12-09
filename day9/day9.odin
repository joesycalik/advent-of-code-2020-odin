package day9

import "core:strings"
import "core:strconv"
import "core:fmt"
import "core:container"
import "core:sys/windows"

/* Profiling 
Regular build (odin run .\day9.odin)
----------------------------------------
Part 1 exec time: 3400.300 microseconds
Part 2 exec time: 523.500 microseconds
----------------------------------------

Optimized build (odin build .\day9.odin -opt:3 -no-bounds-check -microarch=native)
----------------------------------------
Part 1 exec time: 166.700 microseconds
Part 2 exec time: 69.400 microseconds
----------------------------------------
*/
main :: proc() {
    lines := strings.split(string(#load("day9input.txt")), "\r\n");
    values : [dynamic]int;
    for line in lines {
        val, _ := strconv.parse_int(line);
        append(&values, val);
    }

    // Needed for the profiling below
    frq, cnt1, cnt2: windows.LARGE_INTEGER;
    // Part 1
    //-----------------------------------------------------------------------------------------------
    windows.QueryPerformanceCounter(&cnt1);
    windows.QueryPerformanceFrequency(&frq);

    part1_answer := part1(values[:]); // The actual part1() call

    windows.QueryPerformanceCounter(&cnt2);
    fmt.println("Part 1 exec time:", f64(cnt2 - cnt1) / f64(frq) * 1000.0 * 1000.0, "microseconds" );
    //-----------------------------------------------------------------------------------------------
    // Part 2
    //-----------------------------------------------------------------------------------------------
    windows.QueryPerformanceCounter(&cnt1);
    windows.QueryPerformanceFrequency(&frq);

    part2_answer := part2(values[:], part1_answer);; // The actual part2() call

    windows.QueryPerformanceCounter(&cnt2);
    fmt.println("Part 2 exec time:", f64(cnt2 - cnt1) / f64(frq) * 1000.0 * 1000.0, "microseconds" );
    //-----------------------------------------------------------------------------------------------

    fmt.println("Part 1 answer=", part1_answer);
    fmt.println("Part 2 answer=", part2_answer);
}

part1_ :: proc(values : []int) -> int {
    idx1, idx2 := 0, 24;
    for i in 25..<len(values) {
        next_int := values[i];
        num_valid := false;
        for a in idx1..idx2 {
            for b in a + 1..idx2 {
                if values[a] + values[b] == next_int do num_valid = true;
            }
        }
        if num_valid == false do return next_int;
        
        idx1 += 1;
        idx2 += 1;
    }
    
    return -1;
}

part2 :: proc(values : []int, target_val : int) -> int{
    sum, range_min , range_max : int;
    loop : for start_val, start_idx in values {
        sum, range_min, range_max = start_val, start_val, start_val;
        for end_val in values[start_idx + 1:] {
            sum += end_val;
            if end_val < range_min do range_min = end_val;
            if end_val > range_max do range_max = end_val;
            if sum == target_val do return range_min + range_max;
            if sum > target_val do continue loop;
        }
    }

    return -1;
}