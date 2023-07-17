package main

import (
	"errors"
	"fmt"
	"log"
)

const MEM_SIZE = 126
const MAX_CLOCKS = 1 << 16

type MEM_TYPE = uint32
type OP_TYPE = uint32

const (
	OP_INC_PTR = OP_TYPE(62)
	OP_DEC_PTR = OP_TYPE(60)
	OP_INC_MEM = OP_TYPE(43)
	OP_DEC_MEM = OP_TYPE(45)
	OP_INPUT   = OP_TYPE(44)
	OP_OUTPUT  = OP_TYPE(46)
)

// Compiles the brainfuck program.
func compile(instructions string) ([]OP_TYPE, error) {
	code := make([]OP_TYPE, len(instructions))
	for i, c := range instructions {
		switch c {
		case '>':
			code[i] = OP_INC_PTR
		case '<':
			code[i] = OP_DEC_PTR
		case '+':
			code[i] = OP_INC_MEM
		case '-':
			code[i] = OP_DEC_MEM
		case '.':
			code[i] = OP_INPUT
		case ',':
			code[i] = OP_OUTPUT
		case '[':
			j := i + 1 // j will point to the matching ]
			for ctr := 1; j < len(instructions); j++ {
				if instructions[j] == ']' {
					ctr--
					if ctr == 0 {
						break
					}
				} else if instructions[j] == '[' {
					ctr++
				}
			}

			if j < len(instructions) {
				code[i], code[j] = uint32(j)+1, uint32(i)
			} else {
				return nil, errors.New("missing ]")
			}
		case ']':
			if instructions[code[i]] != '[' {
				return nil, errors.New("missing [")
			}
		default:
			// ignore all else
		}
	}

	return code, nil
}

func run(code []OP_TYPE) error {
	clk := 0                          // clock
	i := 0                            // instruction pointer
	p := 0                            // memory pointer
	mem := make([]MEM_TYPE, MEM_SIZE) // memory

	for ; clk < MAX_CLOCKS && i < len(code); clk++ {
		// execute code
		c := code[i]
		switch c {
		case OP_INC_PTR:
			if p == MEM_SIZE-1 {
				return errors.New("memory pointer overflow")
			}
			p++
			i++
		case OP_DEC_PTR:
			if p == 0 {
				return errors.New("memory pointer underflow")
			}
			p--
			i++

		case OP_INC_MEM:
			mem[p]++
			i++
		case OP_DEC_MEM:
			mem[p]--
			i++
		default:
			// TODO
			if mem[p] == 0 {

			} else {

			}

		}

		if i >= len(code) {
			return errors.New("instruction pointer overflow")
		}

	}

	if clk == MAX_CLOCKS {
		return errors.New("maximum clock cycles reached")
	}
}

func main() {
	instructions := "++[-[]++]"

	// compile code
	feltcode, err := compile(instructions)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println(feltcode)

	// execute

}
