package day4

import "core:strings"
import "core:fmt"
import "core:strconv"
import "core:reflect"

Passport :: struct {
    byr, iyr, eyr, hgt, hcl, ecl, pid, cid : string,
    fields_present : int
};

main :: proc() {
    passports := get_passports();
    defer delete(passports);
    fmt.println("Part 1 answer = ", get_valid_passport_count(&passports));
    fmt.println("Part 2 answer = ", get_valid_passport_count_strict(&passports));
}

get_valid_passport_count :: proc(passports : ^[dynamic]Passport) -> int {
    valid_passport_count := 0;
    for passport in passports {
        if passport.fields_present == 8 || (passport.fields_present == 7 && passport.cid == "") do valid_passport_count += 1;
    }
    return valid_passport_count;
}

get_valid_passport_count_strict :: proc(passports : ^[dynamic]Passport) -> int {
    valid_passport_count := 0;
    loop : for passport in passports {
        if !(passport.fields_present == 8 || (passport.fields_present == 7 && passport.cid == "")) do continue;
        
        byr := strconv.parse_int(passport.byr);
        if !(byr >= 1920 && byr <= 2002) do continue;

        iyr := strconv.parse_int(passport.iyr);
        if !(iyr >= 2010 && iyr <= 2020) do continue;

        eyr := strconv.parse_int(passport.eyr);
        if !(eyr >= 2020 && eyr <= 2030) do continue;

        hgt := passport.hgt;
        hgtNum := strconv.parse_int(hgt[:(len(hgt) - 2)]);
        hgtType := hgt[(len(hgt) - 2):];
        if (hgtType == "cm") {
            if !(hgtNum >= 150 && hgtNum <= 193) do continue;
        } else if (hgtType == "in") {
            if !(hgtNum >= 59 && hgtNum <= 76) do continue;
        } else do continue;

        if len(passport.hcl) == 7 && passport.hcl[0] == '#' {
            for char in passport.hcl[1:] {
                switch char {
                    case 'A'..'Z', 'a'..'z', '0'..'9': 
                    case: continue;
                }
            }
        } else do continue;

        switch passport.ecl {
            case "amb", "blu", "brn", "gry", "grn", "hzl", "oth":
            case: continue;
        }

        if !(len(passport.pid) == 9) do continue;

        valid_passport_count += 1;
    }
    return valid_passport_count;
}

get_passports :: proc() -> ([dynamic]Passport) {
    lines := strings.split(string(#load("day4input.txt")), "\n");

    passports : [dynamic]Passport;
    current_fields : Passport;

    for line in lines {
        if len(line) == 1 || line == lines[len(lines) - 1] {
            append(&passports, current_fields);
            current_fields = Passport{};
            continue;
        }

        kv_pairs := strings.split(line, " ");
        for pair in kv_pairs {
            split_pair := strings.split(pair, ":");
            passport_field_name := strings.trim_space(split_pair[0]);
            value := strings.trim_space(split_pair[1]);
            
            passport_field := reflect.struct_field_by_name(Passport, passport_field_name);
            (^string)(uintptr(&current_fields) + passport_field.offset)^ = value;
            current_fields.fields_present += 1;
        }
    }
    return passports;
}