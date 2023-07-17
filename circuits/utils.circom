pragma circom 2.1.0;

// Checks if two numbers are equal.
//
// Inputs:
// - `in`: two numbers
//
// Outputs:
// - `out`: 1 if `in[0] == in[1]`, 0 otherwise
template IsEqual() {
  signal input in[2];
  signal output {bool} out;

  out <== IsZero()(in[1] - in[0]);
}

// Checks if a number is zero.
//
// Inputs:
// - `in`: a number
//
// Outputs:
// - `out`: 1 if `in == 0`, 0 otherwise
template IsZero() {
  signal input in;
  signal output {bool} out;

  signal inv <-- in != 0 ? (1 / in) : 0;

  out <== (-in * inv) + 1;
  in * out === 0;
}

// If-else branching.
//
// Inputs:
// - `cond`: a boolean condition
// - `ifTrue`: signal to be returned if condition is true
// - `ifFalse`: signal to be returned if condition is false
//
// Outputs:
// - `out`: equals `cond ? ifTrue : ifFalse`
template IfElse() {
  signal input {bool} cond;
  signal input ifTrue;
  signal input ifFalse;
  signal output out;
  
  out <== cond * (ifTrue - ifFalse) + ifFalse;
}

// Swaps in[0] ~ in[1] if `cond` is true.
//
// Inputs:
// - `cond`: a boolean condition
// - `in`: two numbers
//
// Outputs:
// - `out`: two numbers either swapped or not
template Swap() {
  signal input {bool} cond;
  signal input in[2];
  signal output out[2];

  out[0] <== cond * (in[1] - in[0]) + in[0];
  out[1] <== cond * (in[0] - in[1]) + in[1];
}
