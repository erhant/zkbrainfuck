pragma circom 2.1.0;

// Returns the minimum number of bits needed to represent `n`
function numBits(n) {
  var tmp = 1, ans = 1;
  while (tmp < n) {
    ans++;
    tmp <<= 1;
  }
  return ans + 1;
}