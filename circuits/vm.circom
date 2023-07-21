pragma circom 2.1.0;

include "./utils/arrays.circom";
include "./utils/common.circom";
include "./functions/bits.circom";

// The VM template handles a single "tick" of the Brainfuck code.
// Given the current state (such as program counter, memory pointer etc.)
// it will compute the next state.
//
// The output is not "assigned to" but instead "asserted equal". This is 
// because we run into "signal already assigned" error in the prior case.
// Outputting something is rather equivalent to getting it as a public 
// input and asserting equality.
//
// OPSIZE parameter is only required to compute number of bits required 
// for the LessThan comparison.
//
template VM(MEMSIZE, OPSIZE) {
  var OP_NOOP    = 0; //    no operation
  var OP_INC_PTR = 1; // >  move pointer right
  var OP_DEC_PTR = 2; // <  move pointer left
  var OP_INC_MEM = 3; // +  increment pointed memory
  var OP_DEC_MEM = 4; // -  decrement pointed memory
  var OP_INPUT   = 5; // ,  input value to pointed memory
  var OP_OUTPUT  = 6; // .  output value from pointed memory
  
  signal input op;           // current operation
  signal input in;           // input at this tick
  signal input out;          // output at this tick
  signal input pgm_ctr;      // program counter
  signal input mem_ptr;      // memory pointer
  signal input input_ptr;    // input pointer
  signal input output_ptr;   // output pointer
  signal input mem[MEMSIZE]; // current memory layout

  signal output next_pgm_ctr;      // next program counter
  signal output next_mem_ptr;      // next memory pointer
  signal output next_input_ptr;    // next input pointer
  signal output next_output_ptr;   // next output pointer
  signal output next_mem[MEMSIZE]; // next memory layout

  signal is_OP_NOOP    <== IsEqual()([OP_NOOP,    op]);
  signal is_OP_INC_PTR <== IsEqual()([OP_INC_PTR, op]);
  signal is_OP_DEC_PTR <== IsEqual()([OP_DEC_PTR, op]);
  signal is_OP_INC_MEM <== IsEqual()([OP_INC_MEM, op]);
  signal is_OP_DEC_MEM <== IsEqual()([OP_DEC_MEM, op]);
  signal is_OP_INPUT   <== IsEqual()([OP_INPUT,   op]);
  signal is_OP_OUTPUT  <== IsEqual()([OP_OUTPUT,  op]);
  var is_OP = Sum(7)([
    is_OP_NOOP,
    is_OP_INC_PTR,
    is_OP_DEC_PTR,
    is_OP_INC_MEM,
    is_OP_DEC_MEM,
    is_OP_INPUT,
    is_OP_OUTPUT
  ]);

  // if none of the OPs are matched, we must be looping.
  // we can be sure that is_OP is binary, because of disjoint
  // equality checks above.
  signal is_LOOP <== 1 - is_OP;

  // currently pointed value `mem[mem_ptr]` is referred to as `val`
  signal val <== ArrayRead(MEMSIZE)(mem, mem_ptr);
  signal val_is0 <== IsZero()(val);

  // determine jump destination; since program counter is incremented by default,
  // we can jump by adding (destination - 1 - pgm_ctr) to it
  // if not, the offset is kept to be 0
  signal is_pgm_ctr_lt_op <== LessThan(numBits(OPSIZE)+1)([pgm_ctr, op]);
  signal is_LOOP_BEGIN    <== is_LOOP * is_pgm_ctr_lt_op;
  signal is_LOOP_END      <== is_LOOP * (1 - is_pgm_ctr_lt_op);
  signal is_LOOP_JUMP     <== Sum(2)([is_LOOP_BEGIN * val_is0, is_LOOP_END * (1 - val_is0)]);
  signal jmp_offset       <== is_LOOP_JUMP * (op - 1 - pgm_ctr);

  // program counter is incremented by default.
  // if there is a loop, we add `destination - 1 - pgm_ctr` to cancel incremention
  // and set the counter to target.
  // if no-op, we cancel the incremention to cause program to halt.
  next_pgm_ctr <== pgm_ctr + 1 + jmp_offset - is_OP_NOOP;

  // memory pointer stays the same by default.
  // otherwise it is only incremented or decremented.
  next_mem_ptr <== mem_ptr + is_OP_INC_PTR - is_OP_DEC_PTR;

  // input and output pointers stay the same by default.
  // if there is an input or output, the respective pointer is incremented.
  next_input_ptr <== input_ptr + is_OP_INPUT;
  next_output_ptr <== output_ptr + is_OP_OUTPUT;

  // memory layout will be updated by setting the currently pointed value
  // by default, the same value is written to the same place.
  // if needed, that value is incremented, decremented.
  // during an input, we add `in - val` to `val` to obtain `in`.
  var delta_val = Sum(3)([
    is_OP_INC_MEM, 
    -is_OP_DEC_MEM, 
    is_OP_INPUT * (in - val)
  ]);
  next_mem <== ArrayWrite(MEMSIZE)(mem, mem_ptr, val + delta_val);
  
  // expected output is provided by the prover.
  // at the output operation, the actual output is compared
  // to the expect one, failing if they do not match.
  var tick_out = IfElse()(is_OP_OUTPUT, val, out);
  out === tick_out;

  // in case of emergency, break glass
  // log("op:", op, "\tval", val, "\tp:", mem_ptr, "\ti:", pgm_ctr);
}