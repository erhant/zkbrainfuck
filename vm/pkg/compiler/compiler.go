package compiler

import (
	"errors"
	"zkbrainfuck/internal/ops"
)

// Compiles the brainfuck program to an array of numbers.
// Negative numbers represent opcodes, while positive numbers
// represent jump positions for loops.
//
// If opsize is non-zero, the resulting code will be appended NO_OPs to match that size.
func Compile(instructions string, opsize uint) ([]uint, error) {
	// find code length and prepare stack sizes for `[` and `]`
	// and check if they match correctly
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

	// if `[` and `]`s match, we should expect
	// the stack to be empty at this point
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
			operations[pgm_ctr] = ops.OP_INC_PTR
		case '<':
			operations[pgm_ctr] = ops.OP_DEC_PTR
		case '+':
			operations[pgm_ctr] = ops.OP_INC_MEM
		case '-':
			operations[pgm_ctr] = ops.OP_DEC_MEM
		case '.':
			operations[pgm_ctr] = ops.OP_OUTPUT
		case ',':
			operations[pgm_ctr] = ops.OP_INPUT
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
