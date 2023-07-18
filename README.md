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
    # use numbers for input & output
  -path string
    # path to file with brainfuck code
  -verbose
    # print compiled code
```

You may find a few example Brainfuck codes in [here](./vm/code). To run them, pass their paths via the `-p` option. By default, the VM will run `,+++++[-.]` which takes an input, increments it 5 times and then starts decrementing it, printing the value each time.

## Proving Execution

Our objective with zkBrainfuck is to prove correct execution of Brainfuck while hiding our inputs. To do that, instead of writing the Brainfuck VM as a circuit itself, we will write a constraining circuit that checks the execution steps and confirm that these steps are valid for a Brainfuck program.

To re-iterate what we mean here, consider a square-root circuit where given `n` it outputs `sqrt(n)`. Well, instead of doing that square-root stuff in a circuit, we could ask for an input `m` that will be output directly, and add a constraint such that `n === m * m` which makes things so much easier.

With that said, let us define the requirements for the circuit to prove a step of execution:

- Current memory layout `m`
- Next memory layout `m'`
- Current instruction pointer `i`
- Next instruction pointer `i'`
- Current memory pointer `p`
- Next memory pointer `p'`

zkBrainfuck operates over numbers instead of tokens, and we want this to be as circuit-friendly as possible. For that, the following methodology is used:

| `op`    | Code | Operation                                          |
| ------- | ---- | -------------------------------------------------- |
| 0       |      | ignore                                             |
| 1       | `>`  | `p' <== p + 1` and `i <== i + 1`                   |
| 2       | `<`  | `p' <== p - 1` and `i <== i + 1`                   |
| 3       | `+`  | `m'[p] <== m[p] + 1` and `i <== i + 1`             |
| 4       | `-`  | `m'[p] <== m[p] - 1` and `i <== i + 1`             |
| 5       | `.`  | `out   <== m[p]` and `i <== i + 1`                 |
| 6       | `,`  | `m'[p] <== in` and `i <== i + 1`                   |
| $i > 6$ | `[`  | if `m[p] == 0` then `i' <== op` else `i <== i + 1` |
| $j > 6$ | `]`  | if `m[p] != 0` then `i' <== op` else `i <== i + 1` |

To disambugate `op` values from jump targets, compiled code will be prepended with 7 zeros, one for each `op`. This way, `op` checks can be made with number comparisons and jump targets are safe. The circuit only has to assert that **(TODO: maybe make no-op 7 and rest be from 0..6?)**

## Honorable Mentions

- [Typefuck](https://github.com/susisu/typefuck) is a Brainfuck interpreter using the type-system of Typescript alone.
- [How Brainfuck Works](https://gist.github.com/roachhd/dce54bec8ba55fb17d3a) is a great Gist about Brainfuck.
- [Brainfuck in STARK](https://neptune.cash/learn/brainfuck-tutorial/) is a quite nice example of another zkBrainfuck based on STARK.
- [Brainfuck in Golang](https://github.com/kgabis/brainfuck-go/blob/master/bf.go) is another implementation of Brainfuck in go.
