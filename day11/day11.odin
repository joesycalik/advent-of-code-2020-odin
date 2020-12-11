package day11

import "core:fmt"
import "core:strings"
import "core:unicode/utf8"
import "core:slice"
import "core:sys/windows"

Dir :: enum {
    N, S, E, W, NW, NE, SW, SE
}

/* Profiling 
Regular build (odin run .\day9.odin)
----------------------------------------
Part 1 exec time: 98758.600 microseconds
Part 2 exec time: 1120476.900 microseconds
----------------------------------------

Optimized build (odin build .\day9.odin -opt:3 -no-bounds-check -microarch=native)
----------------------------------------
Part 1 exec time: 14954.200 microseconds
Part 2 exec time: 414327.300 microseconds
----------------------------------------
*/
Seat :: struct {
    status : rune,
    row, col : int,
    adjacent_ids : [dynamic]int,
    seats_in_dir : map[Dir][]int
}

row_size : int;

main :: proc() {
    lines := strings.split(string(#load("day11input.txt")), "\r\n");
    row_size = len(lines[0]);
    seats : [dynamic]Seat;
    for line, rowIdx in lines {
        for char, colIdx in line {
            seat : Seat;
            seat.status = char;
            seat.row = rowIdx;
            seat.col = colIdx;
            set_adjacent_ids(&seat, rowIdx, colIdx, row_size, len(lines));
            append(&seats, seat);
        }
    }
    set_seats_in_dir(&seats, row_size, len(lines));

    // Needed for the profiling below
    frq, cnt1, cnt2: windows.LARGE_INTEGER;
    // Part 1
    //-----------------------------------------------------------------------------------------------
    windows.QueryPerformanceCounter(&cnt1);
    windows.QueryPerformanceFrequency(&frq);

    part1_answer := part1(seats[:]); // The actual part1() call

    windows.QueryPerformanceCounter(&cnt2);
    fmt.println("Part 1 exec time:", f64(cnt2 - cnt1) / f64(frq) * 1000.0 * 1000.0, "microseconds" );
    //-----------------------------------------------------------------------------------------------
    // Part 2
    //-----------------------------------------------------------------------------------------------
    windows.QueryPerformanceCounter(&cnt1);
    windows.QueryPerformanceFrequency(&frq);

    part2_answer := part2(seats[:]); // The actual part2() call

    windows.QueryPerformanceCounter(&cnt2);
    fmt.println("Part 2 exec time:", f64(cnt2 - cnt1) / f64(frq) * 1000.0 * 1000.0, "microseconds" );
    //-----------------------------------------------------------------------------------------------

    fmt.println("Part 1 answer=", part1_answer);
    fmt.println("Part 2 answer=", part2_answer);
}

part1 :: proc(seats : []Seat)  -> int {
    simulation_state : []rune;
    seatRunes : [dynamic]rune;

    round := 0;
    for seat, idx in seats do append(&seatRunes, seat.status);

    simulation_state = seatRunes[:];
    
    changes := 0;
    outer : for {
        prev_state : [dynamic]rune;
        for seat in simulation_state do append(&prev_state, seat);
        changes = 0;
        inner : for seat, idx in prev_state {
            if prev_state[idx] == '.' {
                simulation_state[idx] = '.';
                continue inner;
            }
            if round % 2 == 0 {
                if prev_state[idx]  == 'L' && 
                    get_occupied_adjacent_seat_count(prev_state[:], seats[idx].adjacent_ids[:]) == 0 {
                    simulation_state[idx] = '#';
                    changes += 1;
                }
            } else {
                if prev_state[idx]  == '#' && 
                    get_occupied_adjacent_seat_count(prev_state[:], seats[idx].adjacent_ids[:]) >= 4 {
                    simulation_state[idx] = 'L';
                    changes += 1;
                }
            }
        }
        round += 1;
        if changes == 0 do break;
    }

    count := 0;
    for char in simulation_state {
        if char == '#' do count += 1;
    }
    return count;
}

part2 :: proc(seats : []Seat)  -> int {
    simulation_state : []rune;
    seatRunes : [dynamic]rune;

    round := 0;
    for seat, idx in seats do append(&seatRunes, seat.status);

    simulation_state = seatRunes[:];
    
    changes := 0;
    outer : for {
        prev_state : [dynamic]rune;
        for seat in simulation_state do append(&prev_state, seat);
        changes = 0;
        inner : for seat, idx in prev_state {
            if prev_state[idx] == '.' {
                simulation_state[idx] = '.';
                continue inner;
            }
            if round % 2 == 0 {
                if prev_state[idx]  == 'L' && 
                    get_visible_occupied_seat_count(prev_state[:], seats[idx].seats_in_dir) == 0 {
                    simulation_state[idx] = '#';
                    changes += 1;
                }
            } else {
                if prev_state[idx]  == '#' && 
                    get_visible_occupied_seat_count(prev_state[:], seats[idx].seats_in_dir) >= 5 {
                    simulation_state[idx] = 'L';
                    changes += 1;
                }
            }
        }
        round += 1;
        if changes == 0 do break;
    }

    count := 0;
    for char in simulation_state {
        if char == '#' do count += 1;
    }
    return count;
}

get_occupied_adjacent_seat_count :: proc(seats : []rune, adjacent_ids : []int) -> int {
    count := 0;
    for id in adjacent_ids {
        if seats[id] == '#' do count += 1;
    }
    return count;
}

get_visible_occupied_seat_count :: proc(seats : []rune, seats_in_dir : map[Dir][]int) -> int {
    count := 0;
    for dir in Dir {
        inner : for id in seats_in_dir[dir] {
            if seats[id] == 'L' do break inner;
            if seats[id] == '#' {
                count += 1;
                break inner;
            }
        }
    }
    return count;
}

set_seats_in_dir :: proc(seats : ^[dynamic]Seat, row_size, row_count : int) {
    for seat in seats {
        if seat.status == '.' do continue;
        for dir in Dir {
            switch dir {
                case .N:
                    seats_north : [dynamic]int;
                    sub := 1;
                    for {
                        checked_seat := ((seat.row - sub) * row_size) + seat.col;
                        if (seat.row - sub) < 0 do break;
                        sub += 1;
                        if seats[checked_seat].status == '.' do continue;
                        append(&seats_north, checked_seat);
                    }
                    seat.seats_in_dir[.N] = seats_north[:];

                case .S:
                    seats_south : [dynamic]int;
                    sub := 1;
                    for {
                        checked_seat := ((seat.row + sub) * row_size) + seat.col;
                        if (seat.row + sub) > row_count - 1 do break;
                        sub += 1;
                        if seats[checked_seat].status == '.' do continue;
                        append(&seats_south, checked_seat);
                    }
                    seat.seats_in_dir[.S] = seats_south[:];

                case .W:
                    seats_west : [dynamic]int;
                    sub := 1;
                    for {
                        checked_seat := (seat.row * row_size) + (seat.col - sub);
                        if (seat.col - sub) < 0 do break;
                        sub += 1;
                        if seats[checked_seat].status == '.' do continue;
                        append(&seats_west, checked_seat);
                    }
                    seat.seats_in_dir[.W] = seats_west[:];

                case .E:
                    seats_east : [dynamic]int;
                    sub := 1;
                    for {
                        checked_seat := (seat.row * row_size) + (seat.col + sub);
                        if (seat.col + sub) > row_size - 1 do break;
                        sub += 1;
                        if seats[checked_seat].status == '.' do continue;
                        append(&seats_east, checked_seat);
                    }
                    seat.seats_in_dir[.E] = seats_east[:];

                case .NW:
                    seats_nw : [dynamic]int;
                    sub := 1;
                    for {
                        checked_seat := ((seat.row - sub) * row_size) + (seat.col - sub);
                        if (seat.col - sub) < 0 || (seat.row - sub) < 0 do break;
                        sub += 1;
                        if seats[checked_seat].status == '.' do continue;
                        append(&seats_nw, checked_seat);
                    }
                    seat.seats_in_dir[.NW] = seats_nw[:];

                case .NE:
                    seats_ne : [dynamic]int;
                    sub := 1;
                    for {
                        checked_seat := ((seat.row - sub) * row_size) + (seat.col + sub);
                        if checked_seat < 0 || (seat.col + sub) > row_size - 1 do break;
                        sub += 1;
                        if seats[checked_seat].status == '.' do continue;
                        append(&seats_ne, checked_seat);
                    }
                    seat.seats_in_dir[.NE] = seats_ne[:];

                case .SW:
                    seats_sw : [dynamic]int;
                    sub := 1;
                    for {
                        checked_seat := ((seat.row + sub) * row_size) + (seat.col - sub);
                        if (seat.row + sub) > row_count - 1 || (seat.col - sub) < 0 do break;
                        sub += 1;
                        if seats[checked_seat].status == '.' do continue;
                        append(&seats_sw, checked_seat);
                    }
                    seat.seats_in_dir[.SW] = seats_sw[:];

                case .SE:
                    seats_se : [dynamic]int;
                    sub := 1;
                    for {
                        checked_seat := ((seat.row + sub) * row_size) + (seat.col + sub);
                        if (seat.row + sub) > row_count - 1 || (seat.col + sub) > row_size - 1 do break;
                        sub += 1;
                        if seats[checked_seat].status == '.' do continue;
                        append(&seats_se, checked_seat);
                    }
                    seat.seats_in_dir[.SE] = seats_se[:];
            }
        }
    }
}

set_adjacent_ids :: proc(seat : ^Seat, rowIdx, colIdx : int, row_size, row_count : int) {
    if seat.status == '.' do return;
    for rowIdxOffset in -1..1 {
        if rowIdx + rowIdxOffset < 0 do continue;
        if rowIdx + rowIdxOffset > row_count - 1 do continue;

        for colIdxOffset in -1..1 {
            if rowIdxOffset == 0 && colIdxOffset == 0 do continue;
            if colIdx + colIdxOffset < 0 do continue;
            if colIdx + colIdxOffset > row_size - 1 do continue;

            adjacent_id := ((rowIdx + rowIdxOffset) * row_size) + (colIdx + colIdxOffset);
            append(&seat.adjacent_ids, adjacent_id);
        }
    }
}

print_problem :: proc(seats : []rune) {
    for seat, idx in seats {
        fmt.print(seats[idx]);
        if idx % row_size == row_size - 1 do fmt.println();
    }
    fmt.println();
}