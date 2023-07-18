package main

import (
	"errors"
	"flag"
	"fmt"
	"log"
	"os"
)

const (
	OP_NOOP int = iota
	OP_INC_PTR
	OP_DEC_PTR
	OP_INC_MEM
	OP_DEC_MEM
	OP_INPUT
	OP_OUTPUT
)

// Compiles the brainfuck program to an array of numbers.
// Negative numbers represent opcodes, while positive numbers
// represent jump positions for loops.
func compile(instructions string) ([]int, error) {
	// find code length and prepare stack sizes for `[` and `]`
	// and check if they match correctly
	stack_ptr, max_stack_ptr := 0, 0

	instruction_count := 0
	prepend_count := 7 // because of 6 operations + 1 no-op
	for _, op := range instructions {
		switch op {
		case '>':
			instruction_count++
		case '<':
			instruction_count++
		case '+':
			instruction_count++
		case '-':
			instruction_count++
		case '.':
			instruction_count++
		case ',':
			instruction_count++
		case '[':
			instruction_count++
			stack_ptr++
			if stack_ptr > max_stack_ptr {
				max_stack_ptr = stack_ptr
			}
		case ']':
			instruction_count++
			if stack_ptr == 0 {
				return nil, errors.New("missing [")
			}
			stack_ptr--
		default: // ignore
		}
	}

	if stack_ptr != 0 {
		return nil, errors.New("missing ]")
	}

	// prepend 0s to disambugate instruction ~ jump target
	operations := make([]int, instruction_count+prepend_count)
	stack := make([]int, max_stack_ptr)
	pgm_ctr := prepend_count
	for _, op := range instructions {
		switch op {
		case '>':
			operations[pgm_ctr] = OP_INC_PTR
		case '<':
			operations[pgm_ctr] = OP_DEC_PTR
		case '+':
			operations[pgm_ctr] = OP_INC_MEM
		case '-':
			operations[pgm_ctr] = OP_DEC_MEM
		case '.':
			operations[pgm_ctr] = OP_OUTPUT
		case ',':
			operations[pgm_ctr] = OP_INPUT
		case '[':
			stack[stack_ptr] = pgm_ctr
			stack_ptr++
		case ']':
			stack_ptr--
			pgm_ctr_from := stack[stack_ptr]
			operations[pgm_ctr], operations[pgm_ctr_from] = pgm_ctr_from, pgm_ctr
		default:
			pgm_ctr-- // ignore this step
		}
		pgm_ctr++
	}

	return operations, nil
}

// Executes a compiled brainfuck program.
func run(operations []int, fmtNumbers bool, memorySize int, maxClocks int) error {
	pgm_ctr, mem_ptr := 0, 0       // program counter, memory pointer
	mem := make([]int, memorySize) // memory

	// decide formatting for input and output
	inFormat, outFormat := "%c", "%c"
	if fmtNumbers {
		inFormat, outFormat = "%d", "%d "
	}

	// program execution
	for clk := 0; clk < maxClocks && pgm_ctr < len(operations); clk++ {
		op := operations[pgm_ctr]
		switch op {

		case OP_NOOP:
			pgm_ctr++

		case OP_INC_PTR:
			if mem_ptr == memorySize-1 {
				return errors.New("memory pointer overflow")
			}
			mem_ptr++
			pgm_ctr++

		case OP_DEC_PTR:
			if mem_ptr == 0 {
				return errors.New("memory pointer underflow")
			}
			mem_ptr--
			pgm_ctr++

		case OP_INC_MEM:
			mem[mem_ptr]++
			pgm_ctr++

		case OP_DEC_MEM:
			mem[mem_ptr]--
			pgm_ctr++

		case OP_OUTPUT:
			fmt.Printf(outFormat, mem[mem_ptr])
			pgm_ctr++

		case OP_INPUT:
			var in rune
			fmt.Print("> ")
			if _, err := fmt.Scanf(inFormat, &in); err != nil {
				return errors.New("could not read user input")
			}
			mem[mem_ptr] = int(in)
			pgm_ctr++

		default:
			if pgm_ctr < op {
				// we are at [ because program counter is less than jump target
				if mem[mem_ptr] == 0 {
					pgm_ctr = op
				} else {
					pgm_ctr++
				}
			} else if pgm_ctr > op {
				// we are at ] because program counter is greater than jump target
				if mem[mem_ptr] != 0 {
					pgm_ctr = op
				} else {
					pgm_ctr++
				}
			} else {
				return errors.New("jump target equals current instruction")
			}
		}
	}

	if pgm_ctr < len(operations) {
		return errors.New("maximum clock cycles reached")
	}

	return nil
}

func main() {
	// parse command line arguments
	code := flag.String("code", ",+++++[-.]", "brainfuck code")
	path := flag.String("path", "", "path to file with brainfuck code")
	isNumFmt := flag.Bool("num", false, "use numbers for input & output")
	verbose := flag.Bool("verbose", false, "print compiled code")
	maxClocks := flag.Int("clocks", 1<<16, "maximum number of \"clock cycles\"")
	memorySize := flag.Int("memory", 128, "memory size")
	flag.Parse()

	// read code from path if needed
	if len(*path) != 0 {
		codeBytes, err := os.ReadFile(*path)
		if err != nil {
			log.Fatal(err)
		}

		*code = string(codeBytes)
	}

	// compile code
	operations, err := compile(*code)
	if err != nil {
		fmt.Println()
		log.Fatalf("COMPILER ERROR: %s", err)
	}

	// print compilation result if verbose
	if *verbose {
		fmt.Printf("%v\n\n", operations)
	}

	// run code
	if err := run(operations, *isNumFmt, *memorySize, *maxClocks); err != nil {
		fmt.Println()
		log.Fatalf("RUNTIME ERROR: %s", err)
	}
	fmt.Println()
}
