pragma circom 2.1.0;

include "./common.circom";

// Array access `out <== in[index]`.
// If `index >= n`, then this returns 0
//
// Parameters:
// - `n`: length of `in`
//
// Inputs:
// - `in`: an array of `n` values
// - `index`: index to access
//
// Outputs:
// - `out`: value at `in[index]`
template ArrayRead(n) {
  signal input in[n];
  signal input index;
  signal output out;

  signal intermediate[n];
  for (var i = 0; i < n; i++) {
    var isIndex = IsEqual()([index, i]);
    intermediate[i] <== isIndex * in[i];
  }

  out <== Sum(n)(intermediate);
}

// Array write `in[index] <== value`.
//
// Parameters:
// - `n`: length of `in`
//
// Inputs:
// - `in`: an array of `n` values
// - `index`: index to write to
// - `value`: value to be written
//
// Outputs:
// - `out`: array
template ArrayWrite(n) {
  signal input in[n];
  signal input index;
  signal input value;
  signal output out[n];

  for (var i = 0; i < n; i++) {
    var isIndex = IsEqual()([index, i]);
    out[i] <== IfElse()(isIndex, value, in[i]);
  }
}

// Finds the sum of an array of signals.
//
// Parameters:
// - `n`: length of `in`
//
// Inputs:
// - `in`: an array of `n` values
//
// Outputs:
// - `out`: sum of all values in `in`
template Sum(n) {
  signal input in[n];
  signal output out;

  var lc = 0;
  for (var i = 0; i < n; i++) {
    lc += in[i];
  }
  out <== lc;
}