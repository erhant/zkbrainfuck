pragma circom 2.1.0;

include "./utils.circom";
include "./functions/bits.circom";

template VM(MEMSIZE, OPSIZE) {
  var OP_NOOP    = 0;
  var OP_INC_PTR = 1;
  var OP_DEC_PTR = 2;
  var OP_INC_MEM = 3;
  var OP_DEC_MEM = 4;
  var OP_INPUT   = 5;
  var OP_OUTPUT  = 6;
  
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

  // looping flag (when no operation is matched)
  // we expect this sum to result in 1 or 0 due to distinct IsEquals
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

  // currently pointed value
  signal val <== ArrayRead(MEMSIZE)(mem, mem_ptr); // pointed value: mem[mem_ptr]
  signal val_is0 <== IsZero()(val);                // is pointed value zero? (used by loops)

  signal is_pgm_ctr_lt_op <== LessThan(numBits(OPSIZE)+1)([pgm_ctr, op]);

  signal is_LOOP_BEGIN    <== is_LOOP * is_pgm_ctr_lt_op;
  signal is_LOOP_END      <== is_LOOP * (1 - is_pgm_ctr_lt_op);
  signal is_LOOP_JUMP     <== Sum(2)([is_LOOP_BEGIN * val_is0, is_LOOP_END * (1 - val_is0)]);
  
  signal jmp_offset       <== is_LOOP_JUMP * (op - 1);

  // program counter is incremented by default
  // if there is a loop, we add `jump_target - 1` to cancel incremention
  // and set the counter to target
  // if no-op, we cancel the incremention to cause program to halt
  next_pgm_ctr <== pgm_ctr + 1 + jmp_offset - is_OP_NOOP;

  // memory pointer is incremented or decremented w.r.t op
  // otherwise, is equal to its current value
  next_mem_ptr <== mem_ptr + is_OP_INC_PTR - is_OP_DEC_PTR;

  // input & output pointers are incremented w.r.t their ops
  next_input_ptr <== input_ptr + is_OP_INPUT;
  next_output_ptr <== output_ptr + is_OP_OUTPUT;

  // memory layout will be updated by setting the currently pointed value
  // by default, the same value is written to the same place
  // if needed, that value is incremented, decremented
  // during an input, we add `in - val` to `val` to obtain `in`
  var delta_val = Sum(3)([is_OP_INC_MEM, -is_OP_DEC_MEM, is_OP_INPUT * (in - val)]);
  next_mem <== ArrayWrite(MEMSIZE)(mem, mem_ptr, val + delta_val);
  
  // output is only set during its respective op
  var expectedOut = IfElse()(is_OP_OUTPUT, val, out);
  out === expectedOut;
}