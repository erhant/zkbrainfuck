# Circomfuck

> A [Brainfuck](https://en.wikipedia.org/wiki/Brainfuck) ZKVM to prove correct execution of a Brainfuck program.

Brainfuck has 8 operations defined as follows:

| Code | Operation                                       |
| ---- | ----------------------------------------------- |
| `>`  | increment data pointer                          |
| `<`  | decrement data pointer                          |
| `+`  | increment pointed data                          |
| `-`  | decrement pointed data                          |
| `.`  | read from pointed data                          |
| `,`  | write to pointed data                           |
| `[`  | if pointed data is non-zero, go to matching `]` |
| `]`  | if pointed data is non-zero, go to matching `[` |

## Circuit

Consider a data pointer `p`, a current memory `m` and next memory `m'` where `m[p]` refers to the data pointed by the pointer `p` in that state. Likewise, data pointer in the next state is `p'`. Let `i'` denote the current instruction pointer and `i'` the next instruction pointer.

We have the following operations defined in Brainfuck in terms of state changes per instruction:

| Number | Token | Operation                         |
| ------ | ----- | --------------------------------- |
| 62     | `>`   | `p' <== p + 1`                    |
| 60     | `<`   | `p' <== p - 1`                    |
| 43     | `+`   | `m'[p] <== m[p] + 1`              |
| 45     | `-`   | `m'[p] <== m[p] - 1`              |
| 46     | `.`   | `out   <== m[p]`                  |
| 44     | `,`   | `m'[p] <== in`                    |
| 91     | `[`   | if `m[p] != 0` then `i' <== j[i]` |
| 93     | `]`   | if `m[p] != 0` then `i' <== j[i]` |

Number refers to the value returned by `charCodeAt` (in JS) for that character, yielding the ASCII value. We will treat the corresponding field elements for instruction codes.

If not specified otherwise, the following happens during the state transition:

- `p' <== p` data pointer stays the same
- `i' <== i` instruction pointer is incremented
- `m'[:] <== m[:]` memory blocks stay the same

## Honorable Mentions

- [Typefuck](https://github.com/susisu/typefuck) is a Brainfuck interpreter using the type-system of Typescript alone.
- [How Brainfuck Works](https://gist.github.com/roachhd/dce54bec8ba55fb17d3a) is a great Gist about Brainfuck.
