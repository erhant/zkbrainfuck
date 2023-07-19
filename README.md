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

Any other symbol is ignored, and may effectively be used as comments.

## Virtual Machine

We have written a Brainfuck compiler & runner in Go, which you can find under the [vm](./vm/) folder. Assuming you have Go installed, you can build the binary simply via:

```sh
yarn vm:build
```

Afterwards, you can run the binary with:

```sh
yarn vm:run
  -clocks int
    # maximum number of "clock cycles" (default 65536)
  -code string
    # brainfuck code (default ",+++++[-.]")
  -memory int
    # memory size (default 128)
  -num
    # use numbers for input & output instead of characters
  -path string
    # path to file with brainfuck code (overwrites -code)
  -verbose
    # print compiled code
```

You may find a few example Brainfuck codes in [here](./vm/sample). To run them, pass their paths via the `-path` option. By default, the VM will run `,+++++[-.]` which takes an input, increments it 5 times and then starts decrementing it, printing the value each time.

## Proving Execution

Our objective with zkBrainfuck is to prove correct execution of Brainfuck while hiding our inputs. To do that, instead of writing the Brainfuck VM as a circuit itself, we will write a constraining circuit that checks the execution steps and confirm that these steps are valid for a Brainfuck program.

To re-iterate what we mean here, consider a square-root circuit where given `n` it outputs `sqrt(n)`. Well, instead of doing that square-root stuff in a circuit, we could ask for an input `m` that will be output directly, and add a constraint such that `n === m * m` which makes things so much easier while still providing execution correctness.

With that said, let us define the requirements for the circuit to prove a step of execution:

- Current input `in`
- Current output `out`
- Current & next instruction `i` and `_i`
- Current & next memory layouts `m` and `_m`
- Current & next memory pointers `p` and `_p`

These inputs are given for **each** clock cycle. Only the the list of instructions and outputs are public, the rest are private inputs.

zkBrainfuck operates over numbers instead of tokens, and we want this to be as circuit-friendly as possible. For that, the following methodology is used (think for each clock cycle):

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

| Clocks | Memory Size | Operation Count | Non-linear Constraints | Linear Constraints |
| ------ | ----------- | --------------- | ---------------------- | ------------------ |
| 1024   | 256         | 20              | 1.65m                  | 565k               |
| 256    | 256         | 20              | 414k                   | 141k               |
| 1024   | 64          | 20              | 486k                   | 171k               |
| 256    | 64          | 20              | 120k                   | 43k                |
| 256    | 64          | 80              | 167k                   | 58k                |
| 2048   | 32          | 60              | 767k                   | 274k               |

Constraints grow in linear with the clock size and memory size. Operation count grows the circuit sub-linearly.

## Honorable Mentions

- [Typefuck](https://github.com/susisu/typefuck) is a Brainfuck interpreter using the type-system of Typescript alone.
- [How Brainfuck Works](https://gist.github.com/roachhd/dce54bec8ba55fb17d3a) is a great Gist about Brainfuck.
- [Brainfuck in STARK](https://neptune.cash/learn/brainfuck-tutorial/) is a quite nice example of another zkBrainfuck based on STARK.
- [Brainfuck in Golang](https://github.com/kgabis/brainfuck-go/blob/master/bf.go) is another implementation of Brainfuck in go.
