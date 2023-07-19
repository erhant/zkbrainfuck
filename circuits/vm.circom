pragma circom 2.1.0;

include "./utils.circom";
include "./functions/bits.circom";

/*
OP_INC_PTR
OP_DEC_PTR
OP_INC_MEM
OP_DEC_MEM
OP_INPUT
OP_OUTPUT
*/

template VM(MEMSIZE, OPSIZE) {
  // op codes
  var OP_NOOP = 0;
  var OP_INC_PTR = 1;
  var OP_DEC_PTR = 2;
  var OP_INC_MEM = 3;
  var OP_DEC_MEM = 4;
  var OP_INPUT = 5;
  var OP_OUTPUT = 6;
  
  // current state
  signal input in; // input at this clock
  signal input pgm_ctr; // program counter
  signal input mem_ptr; // memory pointer
  signal input mem[MEMSIZE]; // current memory layout
  signal input op; // operation: operations[pgm_ctr]

  signal val <== ArrayRead(MEMSIZE)(mem, mem_ptr); // pointed value: mem[mem_ptr]
  signal val_is0 <== IsZero()(val); // is pointed value zero? (used by loops)

  // next state
  signal output out; // output
  signal output next_pgm_ctr;     // next program counter
  signal output next_mem_ptr;      // next memory pointer
  signal output next_mem[MEMSIZE]; // next memory layout

  // operation flags
  signal is_OP_NOOP <== IsEqual()([OP_NOOP, op]);
  signal is_OP_INC_PTR <== IsEqual()([OP_INC_PTR, op]);
  signal is_OP_DEC_PTR <== IsEqual()([OP_DEC_PTR, op]);
  signal is_OP_INC_MEM <== IsEqual()([OP_INC_MEM, op]);
  signal is_OP_DEC_MEM <== IsEqual()([OP_DEC_MEM, op]);
  signal is_OP_INPUT <== IsEqual()([OP_INPUT, op]);
  signal is_OP_OUTPUT <== IsEqual()([OP_OUTPUT, op]);

  // looping flag (when no operation is matched)
  var is_OP = Sum(7)([
    is_OP_NOOP,
    is_OP_INC_PTR,
    is_OP_DEC_PTR,
    is_OP_INC_MEM,
    is_OP_DEC_MEM,
    is_OP_INPUT,
    is_OP_OUTPUT
  ]);
  signal is_LOOP <== 1 - is_OP;

  signal is_pgm_ctr_lt_op <== LessThan(numBits(OPSIZE)+1)([pgm_ctr, op]);
  signal is_LOOP_BEGIN <== is_LOOP * is_pgm_ctr_lt_op;
  signal is_LOOP_END <== is_LOOP * (1 - is_pgm_ctr_lt_op);
  signal is_LOOP_JUMP <== Sum(2)([
    is_LOOP_BEGIN * val_is0, 
    is_LOOP_END * (1 - val_is0)
  ]);

  // update program counter
  signal jump_offset <== is_LOOP_JUMP * (op - 1);
  next_pgm_ctr <== pgm_ctr + 1 + jump_offset;

  // update memory pointer
  // +0 by default
  next_mem_ptr <== mem_ptr + is_OP_INC_PTR - is_OP_DEC_PTR;

  // set output if any
  // 0 by default
  out <== is_OP_OUTPUT * val;

  // updated pointer memory value
  // val by default
  var delta_val = Sum(3)([is_OP_INC_MEM, -is_OP_DEC_MEM, is_OP_INPUT * in]);
  next_mem <== ArrayWrite(MEMSIZE)(mem, mem_ptr, val + delta_val);
  
}