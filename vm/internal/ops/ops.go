package ops

const (
	// A "no op", simply causes program counter to be incremented.
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
