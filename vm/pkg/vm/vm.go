package vm

import (
	"errors"
	"fmt"
	"zkbrainfuck/pkg/compiler"
)

type ProgramExecution struct {
	Ticks   uint   `json:"ticks"`
	Memsize uint   `json:"memsize"`
	Opsize  int    `json:"opsize"`
	Insize  int    `json:"insize"`
	Outsize int    `json:"outsize"`
	Ops     []uint `json:"ops"`
	Inputs  []uint `json:"inputs"`
	Outputs []uint `json:"outputs"`
}

// Executes a compiled brainfuck program.
//
// If record is `true`, will return a pointer to a ProgramExecution struct,
// which simply stores the operations along with inputs and outputs that have
// occured during the program execution. It will also keep record the number of
// ticks it took to run the program, and the amount of memory used.
func Execute(operations []uint, fmtNumbers bool, memorySize uint, ticks uint, record bool) (*ProgramExecution, error) {
	inputs := make([]uint, 0)
	outputs := make([]uint, 0)
	inFormat, outFormat := "%c", "%c"
	if fmtNumbers {
		inFormat, outFormat = "%d", "%d "
	}

	pgm_ctr, mem_ptr := uint(7), uint(0) // program counter, memory pointer
	max_mem_ptr := uint(0)               // maximum memory pointer encountered
	mem := make([]uint, memorySize)      // memory
	tick := uint(0)                      // tick
	opsize := uint(len(operations))      // number of operations
	for ; tick < ticks && pgm_ctr < opsize; tick++ {
		op := operations[pgm_ctr]
		switch op {

		case compiler.OP_NOOP:
			if pgm_ctr == opsize-1 {
				pgm_ctr++
			} else {
				return nil, errors.New("unexpected no-op")
			}

		case compiler.OP_INC_PTR:
			if mem_ptr == memorySize-1 {
				return nil, errors.New("memory pointer overflow")
			}
			mem_ptr++
			pgm_ctr++
			if mem_ptr > max_mem_ptr {
				max_mem_ptr = mem_ptr
			}

		case compiler.OP_DEC_PTR:
			if mem_ptr == 0 {
				return nil, errors.New("memory pointer underflow")
			}
			mem_ptr--
			pgm_ctr++

		case compiler.OP_INC_MEM:
			mem[mem_ptr]++
			pgm_ctr++

		case compiler.OP_DEC_MEM:
			if mem[mem_ptr] == 0 {
				return nil, errors.New("memory value underflow")
			}
			mem[mem_ptr]--
			pgm_ctr++

		case compiler.OP_OUTPUT:
			fmt.Printf(outFormat, mem[mem_ptr])
			pgm_ctr++
			if record {
				outputs = append(outputs, mem[mem_ptr])
			}

		case compiler.OP_INPUT:
			var in uint
			fmt.Print("> ")
			if _, err := fmt.Scanf(inFormat, &in); err != nil {
				return nil, errors.New("could not read user input")
			}
			mem[mem_ptr] = uint(in)
			pgm_ctr++
			if record {
				inputs = append(inputs, mem[mem_ptr])
			}

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
				return nil, errors.New("jump target equals current instruction")
			}
		}
	}

	if pgm_ctr < opsize {
		return nil, errors.New("maximum ticks reached before termination")
	}

	if record {
		return &ProgramExecution{
			tick,
			max_mem_ptr,
			len(operations),
			len(inputs),
			len(outputs),
			operations,
			inputs,
			outputs,
		}, nil
	} else {
		return nil, nil
	}

}
