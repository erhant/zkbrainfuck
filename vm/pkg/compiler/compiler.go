package compiler

import (
	"errors"
)

const (
	// A "no op" represented by 0. Halts the program.
	OP_NOOP uint = iota
	// Increment memory pointer.
	OP_INC_PTR
	// Decrement memory pointer.
	OP_DEC_PTR
	// Increment pointed value in memory.
	OP_INC_MEM
	// Decrement pointed value in memory.
	OP_DEC_MEM
	// Input value to the pointer memory slot.
	OP_INPUT
	// Output pointed value in memory.
	OP_OUTPUT
)

// Compiles the brainfuck program to an array of numbers.
//
// The result is an array of positive integers. First 7 elements will be 0 (NO_OP). The remaining elements can be any number
// where numbers 1..7 represent op codes for the 6 non-jumping brainfuck instructions.
//
// Numbers greater than 7 indicate a jump destination for a looping instruction. If destination is less than the op, it is a loop begin
// and otherwise it is a loop end.
//
// If opsize is non-zero, the resulting code will be appended NO_OPs to match the opsize.
func Compile(instructions string, opsize uint) ([]uint, error) {
	// find code length and prepare stack sizes for `[` and `]`
	stack_ptr, max_stack_ptr := 0, 0
	instruction_count := uint(0)
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
		default: // ignore comments and any other invalid character
		}
	}

	// if `[` & `]`s match, we should expect the stack to be empty at this point
	if stack_ptr != 0 {
		return nil, errors.New("missing ]")
	}

	// find operation size
	prepend_count := uint(7) // because of 6 non-loop operations + 1 no-op
	append_count := uint(1)  // because last step should be a 0
	min_operations_len := prepend_count + instruction_count + append_count
	operations_len := opsize
	if opsize == 0 {
		operations_len = min_operations_len
	} else {
		if opsize < min_operations_len {
			return nil, errors.New("insufficient opsize")
		}
	}

	// prepend 0s to disambugate instruction ~ jump target
	operations := make([]uint, operations_len)
	stack := make([]uint, max_stack_ptr)
	pgm_ctr := prepend_count // skip prepended zeros
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
