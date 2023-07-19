pragma circom 2.1.0;

include "./utils.circom";

/*
OP_INC_PTR
OP_DEC_PTR
OP_INC_MEM
OP_DEC_MEM
OP_INPUT
OP_OUTPUT
*/

template VM(MEMSIZE) {
  // op codes
  var OP_INC_PTR = 1;
  var OP_DEC_PTR = 2;
  var OP_INC_MEM = 3;
  var OP_DEC_MEM = 4;
  var OP_INPUT = 5;
  var OP_OUTPUT = 6;
  var NUM_OPS = 7; // correct ?

  // previous state
  signal input i;
  signal input p;
  signal input m[MEMSIZE];

  // next state
  signal input _i;
  signal input _p;
  signal input _m[MEMSIZE];

  // state changes
  var op = 0;
  signal i$[NUM_OPS]; // value to be added to i
  signal p$[NUM_OPS]; // value to be added to p
  signal m$[NUM_OPS]; // value to be written to m[p]

  // currently pointed memory value
  signal m_p <== ArrayRead(MEMSIZE)(m, p);
  signal m_p_is0 = IsZero()(m_p);

  // TODO: it could be possible to only care about i$ for jumps, and increment by default
  // increment pointer
  signal is_OP_INC_PTR <== IsEqual()([OP_INC_PTR, i]);
  i$[op] <== is_OP_INC_PTR * 1;
  p$[op] <== is_OP_INC_PTR * 1;
  m$[op] <== 0;
  op++;

  // decrement pointer
  signal is_OP_DEC_PTR <== IsEqual()([OP_DEC_PTR, i]);
  i$[op] <== is_OP_DEC_PTR * 1;
  p$[op] <== is_OP_DEC_PTR * (-1);
  m$[op] <== 0;
  op++;

  // increment memory
  signal is_OP_INC_MEM <== IsEqual()([OP_INC_PTR, i]);
  i$[op] <== is_OP_INC_MEM * 1;
  p$[op] <== 0;
  m$[op] <== is_OP_INC_MEM * 1;
  op++;

  // decrement memory
  signal is_OP_DEC_MEM <== IsEqual()([OP_INC_PTR, i]);
  i$[op] <== is_OP_DEC_MEM * 1;
  p$[op] <== 0;
  m$[op] <== is_OP_DEC_MEM * (-1);
  op++;

  // input
  // TODO

  // output
  // TODO

  // loop begin

  // loop end

  // update state
  var _i$ = Sum(NUM_OPS)(i$);
  _i <== i + _i$;
  var _p$ = Sum(NUM_OPS)(p$);
  _p <== p + _p$;

  // TODO: 
  var _m$ = Sum(NUM_OPS)(m$);
  ArrayWrite(MEMSIZE)(_m, p, _m$ + m_p);
  
}