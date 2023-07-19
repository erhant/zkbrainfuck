package vm

import (
	"errors"
	"fmt"
	"zkbrainfuck/internal/ops"
)

// signal input ops[OPSIZE];
// signal input inputs[CLOCKS];
// signal output outputs[CLOCKS];

type IOTrace struct {
	opsize  uint
	clocks  uint
	ops     []uint
	inputs  []uint
	outputs []uint
}

// Executes a compiled brainfuck program.
//
// If record is `true`, will return a pointer to execution trace.
func Run(operations []uint, fmtNumbers bool, memorySize uint, clocks uint, record bool) (*IOTrace, error) {
	// prepare IOTrace inputs
	var inputs []uint
	var outputs []uint
	if record {
		inputs = make([]uint, clocks)
		outputs = make([]uint, clocks)
	} else {
		inputs = nil
		outputs = nil
	}

	// decide formatting for input and output
	inFormat, outFormat := "%c", "%c"
	if fmtNumbers {
		inFormat, outFormat = "%d", "%d "
	}

	// program execution
	pgm_ctr, mem_ptr := uint(0), uint(0) // program counter, memory pointer
	mem := make([]uint, memorySize)      // memory
	clk := uint(0)                       // clock
	opsize := uint(len(operations))      // number of operations
	for ; clk < clocks && pgm_ctr < opsize; clk++ {
		op := operations[pgm_ctr]
		switch op {

		case ops.OP_NOOP:
			pgm_ctr++

		case ops.OP_INC_PTR:
			if mem_ptr == memorySize-1 {
				return nil, errors.New("memory pointer overflow")
			}
			mem_ptr++
			pgm_ctr++

		case ops.OP_DEC_PTR:
			if mem_ptr == 0 {
				return nil, errors.New("memory pointer underflow")
			}
			mem_ptr--
			pgm_ctr++

		case ops.OP_INC_MEM:
			mem[mem_ptr]++
			pgm_ctr++

		case ops.OP_DEC_MEM:
			mem[mem_ptr]--
			pgm_ctr++

		case ops.OP_OUTPUT:
			fmt.Printf(outFormat, mem[mem_ptr])
			pgm_ctr++
			if record {
				outputs[clk] = mem[mem_ptr]
			}

		case ops.OP_INPUT:
			var in uint
			fmt.Print("> ")
			if _, err := fmt.Scanf(inFormat, &in); err != nil {
				return nil, errors.New("could not read user input")
			}
			mem[mem_ptr] = uint(in)
			pgm_ctr++
			if record {
				inputs[clk] = mem[mem_ptr]
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
		return nil, errors.New("maximum clock cycles reached before termination")
	}

	if record {
		return &IOTrace{
			opsize,
			clocks,
			operations,
			inputs,
			outputs,
		}, nil
	} else {
		return nil, nil
	}

}
