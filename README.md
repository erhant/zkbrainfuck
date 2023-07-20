# zkBrainfuck

> A [Brainfuck](https://en.wikipedia.org/wiki/Brainfuck) zkVM to prove correct execution of a Brainfuck program with secret inputs.

Brainfuck is a Turing-complete language that has only 8 operations defined as follows:

| Code | Operation                                        |
| ---- | ------------------------------------------------ |
| `>`  | increment data pointer                           |
| `<`  | decrement data pointer                           |
| `+`  | increment pointed data                           |
| `-`  | decrement pointed data                           |
| `.`  | read from pointed data                           |
| `,`  | write to pointed data                            |
| `[`  | if pointed data is zero, `goto` matching `]`     |
| `]`  | if pointed data is non-zero, `goto` matching `[` |

Any other symbol is ignored, and may effectively be used as comments. We have written a smol Brainfuck VM in Go, which you can find under the [vm](./vm/) folder. Assuming you have Go installed, you can build the binary simply via:

```sh
yarn vm:build
```

Afterwards, you can run the binary with:

```sh
yarn vm:run
  -code   string   # brainfuck code (default ",[.-]")
  -export string   # path to export program information
  -path   string   # path to import brainfuck code
  -memory uint     # memory size (default 128)
  -opsize uint     # operations size
  -ticks  uint     # maximum number of ticks (default 2048)
  -num             # use numbers for input & output instead of runes
```

You may find a few example Brainfuck codes in [here](./vm/sample). To run them, pass their paths via the `-path` option. Our VM does not allow for underflows, neither for the program counter or memory pointer. The default code `,[-]` simply takes an input and counts down, terminating when it reaches 0.

### From Code to Integers

...

## Proving Execution

TODO

| `op`     | Code | Operation                                            |
| -------- | ---- | ---------------------------------------------------- |
| 0        |      | ignore                                               |
| 1        | `>`  | `_p <== p + 1` and `_i <== i + 1`                    |
| 2        | `<`  | `_p <== p - 1` and `_i <== i + 1`                    |
| 3        | `+`  | `_m[p] <== m[p] + 1` and `_i <== i + 1`              |
| 4        | `-`  | `_m[p] <== m[p] - 1` and `_i <== i + 1`              |
| 5        | `.`  | `out   <== m[p]` and `_i <== i + 1`                  |
| 6        | `,`  | `_m[p] <== in` and `_i <== i + 1`                    |
| `i < op` | `[`  | if `m[p] == 0` then `_i' <== op` else `_i <== i + 1` |
| `i > op` | `]`  | if `m[p] != 0` then `_i' <== op` else `_i <== i + 1` |

To disambugate `op` values from jump targets, compiled code will be prepended with 7 zeros, one for each `op`. This way, `op` checks can be made with number comparisons and jump targets are safe. The circuit only has to assert that

## Constraints

Below are some example instantations with their constraint counts (using optimization level 1). With optimization level 2, one can get rid of linear constraints at the cost of a sligthly longer compilation time.

| Ticks | Memory Size | Operation Count | Non-linear Constraints | Linear Constraints |
| ----- | ----------- | --------------- | ---------------------- | ------------------ |
| 1024  | 256         | 20              | 1.65m                  | 565k               |
| 256   | 256         | 20              | 414k                   | 141k               |
| 1024  | 64          | 20              | 486k                   | 171k               |
| 256   | 64          | 20              | 120k                   | 43k                |
| 256   | 64          | 80              | 167k                   | 58k                |
| 2048  | 32          | 60              | 767k                   | 274k               |

Constraints grow in linear with the tick size and memory size. Operation count grows the circuit sub-linearly.

## Honorable Mentions

- [Typefuck](https://github.com/susisu/typefuck) is a Brainfuck interpreter using the type-system of Typescript alone.
- [How Brainfuck Works](https://gist.github.com/roachhd/dce54bec8ba55fb17d3a) is a great Gist about Brainfuck.
- [Brainfuck in STARK](https://neptune.cash/learn/brainfuck-tutorial/) is a quite nice example of another zkBrainfuck based on STARK.
- [Brainfuck in Golang](https://github.com/kgabis/brainfuck-go/blob/master/bf.go) is another implementation of Brainfuck in go.
