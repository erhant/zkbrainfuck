pragma circom 2.1.0;

// Checks if two numbers are equal.
//
// Inputs:
// - `in`: two numbers
//
// Outputs:
// - `out`: 1 if `in[0] == in[1]`, 0 otherwise
//
template IsEqual() {
  signal input in[2];
  signal output {bit} out;

  out <== IsZero()(in[1] - in[0]);
}

// Checks if a number is zero.
//
// Inputs:
// - `in`: a number
//
// Outputs:
// - `out`: 1 if `in == 0`, 0 otherwise
//
template IsZero() {
  signal input in;
  signal output {bit} out;

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
//
template IfElse() {
  signal input {bit} cond;
  signal input ifTrue;
  signal input ifFalse;
  signal output out;
  
  out <== cond * (ifTrue - ifFalse) + ifFalse;
}

// Computes `in[0] < in[1]`.
//
// Parameters:
// - `n`: min number of bits to represent the inputs
//
// Inputs:
// - `in`: two numbers
//
// Outputs:
// - `out`: 1 if `in[0] < in[1]`, 0 otherwise.
//
template LessThan(n) {
  assert(n <= 252);
  signal input in[2];
  signal output out;

  component bits = Num2Bits(n+1);

  bits.in <== in[0]+ (1<<n) - in[1];

  out <== 1-bits.out[n];
}

// Decomposes a number to its bits.
//
// Parameters:
// - `n`: number of bits
//
// Inputs:
// - `in`: two numbers
//
// Outputs:
// - `out`: an array of bits
//
template Num2Bits(n) {
  assert(n < 254);
  signal input in;
  signal output {bit} out[n];

  var lc = 0;
  var bit_value = 1;

  for (var i = 0; i < n; i++) {
    out[i] <-- (in >> i) & 1;
    out[i] * (out[i] - 1) === 0;

    lc += out[i] * bit_value;
    bit_value <<= 1;
  }

  lc === in;
}