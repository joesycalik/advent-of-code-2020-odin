package day9_ex

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
Part 1 exec time: 123.600 microseconds
Part 2 exec time: 69.000 microseconds
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

/*
Optimized build Performance (odin build .\day9.odin -opt:3 -no-bounds-check -microarch=native)
----------------------------------------
Part 1 exec time: 123.600 microseconds
----------------------------------------
*/
part1 :: proc(values : []int) -> int {
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

/*
Optimized build Performance (odin build .\day9.odin -opt:3 -no-bounds-check -microarch=native)
----------------------------------------
Part 1 exec time: 9082.100 microseconds <- Not unexpected, but ouch
----------------------------------------
*/
part1__ :: proc(values : []int) -> int {
    idx1 := 0;
    idx2 := 24;
    sums : map[int]container.Array(int);
    for i in 25..<len(values) {
        next_int := values[i];
        num_valid := false;
        for a in idx1..<idx2 {
            if a in sums && container.array_len(sums[a]) > 0 {
                if a == idx2 - 1 do container.array_pop_front(&sums[a]);
                container.array_push_back(&sums[a], values[a] + values[idx2]);
                for i in 0..<container.array_len(sums[a]) do if container.array_get(sums[a], i) == next_int do num_valid = true;
            } else {
                arr : container.Array(int);
                container.array_init(&arr);
                sums[a] = arr;
                for b in a + 1..idx2 {
                    if values[a] + values[b] == next_int do num_valid = true;
                    container.array_push_back(&sums[a], values[a] + values[b]);
                }
            }
        }
        if num_valid == false do return next_int;
        
        idx1 += 1;
        idx2 += 1;
    }
    
    return -1;
}

/*
Optimized build Performance (odin build .\day9.odin -opt:3 -no-bounds-check -microarch=native)
----------------------------------------
Part 1 exec time: 195.300 microseconds
----------------------------------------
*/
part1___ :: proc(values : []int) -> int {
    idx1 := 0;
    idx2 := 24;
    sums : [24 * 23][24]int;

    for i in 25..<len(values) {
        next_int := values[i];
        num_valid := false;
        for a in idx1..<idx2 {
            idx := idx2 - a - 1;
            if sums[a][idx] != 0 {
                if a == idx2 - 1 do sums[a][idx1] = 0;
                sums[a][idx2] = values[a] + values[idx];
                for i in sums[a] do if sums[a][i] == next_int do num_valid = true;
            } else {
                for b in a + 1..idx2 {
                    if values[a] + values[b] == next_int do num_valid = true;
                    sums[a][idx] = values[a] + values[b];
                }
            }
        }
        if num_valid == false do return next_int;
        
        idx1 += 1;
        idx2 += 1;
    }
    
    return -1;
}

/*
Optimized build Performance (odin build .\day9.odin -opt:3 -no-bounds-check -microarch=native)
----------------------------------------
Part 1 exec time: 242.100 microseconds
----------------------------------------
*/
part1____ :: proc(values : []int) -> int {
    idx1 := 0;
    idx2 := 24;
    sums : [24 * 24 * 24]int;
    for i in 25..<len(values) {
        next_int := values[i];
        num_valid := false;
        for a in idx1..<idx2 {
            if sums[25 * idx1 + a] != 0 {
                if a == idx2 - 1 do sums[25 * idx1] = 0;
                sums[25 * idx1 + 24] = values[a] + values[25 * idx1 + a];
                for i in 25 * idx1..<25 * idx1 + 24 do if sums[25 * idx1 + i] == next_int do num_valid = true;
            } else {
                for b in a + 1..idx2 {
                    if values[a] + values[b] == next_int do num_valid = true;
                    sums[25 * idx1 + a] = values[a] + values[b];
                }
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