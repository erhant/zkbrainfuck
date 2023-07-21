# zkBrainfuck

> A [Brainfuck](https://en.wikipedia.org/wiki/Brainfuck) zkVM to prove correct execution of a Brainfuck program with secret inputs.

Brainfuck is a Turing-complete language that has only 8 operations, shown in the table below. Any other symbol is ignored, and may effectively be used as comments.

| Code | Operation                                        |
| ---- | ------------------------------------------------ |
| `>`  | increment data pointer                           |
| `<`  | decrement data pointer                           |
| `+`  | increment pointed data                           |
| `-`  | decrement pointed data                           |
| `,`  | write to pointed data                            |
| `.`  | read from pointed data                           |
| `[`  | if pointed data is zero, `goto` matching `]`     |
| `]`  | if pointed data is non-zero, `goto` matching `[` |

## Usage

We have written a small Brainfuck compiler & executer in Go, which you can find under the [vm](./vm/) folder. Assuming you have Go installed, you can build the binary simply via:

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

You may find a few example Brainfuck codes in [here](./vm/sample). To run your own Brainfuck code, provide its path to the `--path` option. If your inputs & outputs are numbers (not characters) make sure you also pass in the `--num` option.

The VM has a maximum number of ticks to prevent infinite loops. If the default tick amount is not enough, increase it with `--tick <amount>`.

To export the execution of the code, you will need to pass in `--export <path>` option. This will include all the operations, inputs and outputs that were encountered within the program. You can use the `ops`, `inputs` and `outputs` there as circuit signals. Note that you may have to append zeros to match signal sizes depending on the circuit template parameters. We do this [automatically](./tests/utils/index.ts) in our tests.

We have prepared tests with [Circomkit](https://github.com/erhant/circomkit) for 3 different brainfuck programs. You can run them with:

```sh
yarn test
```

Of course, you will need to have [Circom](https://docs.circom.io/) installed on your machine.

## Brainfuck Circuit

We will write the Brainfuck VM as an algebraic circuit, meaning that instead of tokens (like `+` or `-`) we shall operate on numbers. This is the reason we compile Brainfuck code in the first place, the result of compilation is simply an array of non-negative integers. The circuit asserts each "tick" to be valid, eventually running the program until no more ticks are left. Here is a rough demonstration of the instructions:

| `op`           | Code  | Relevant Constraint                                     |
| -------------- | ----- | ------------------------------------------------------- |
| 0              | no-op | `next_pgm_ctr <== pgm_ctr`                              |
| 1              | `>`   | `next_mem_ptr <== mem_ptr + 1`                          |
| 2              | `<`   | `next_mem_ptr <== mem_ptr - 1`                          |
| 3              | `+`   | `next_mem[mem_ptr] <== mem[mem_ptr] + 1`                |
| 4              | `-`   | `next_mem[mem_ptr] <== mem[mem_ptr] - 1`                |
| 5              | `,`   | `next_mem[mem_ptr] <== in`                              |
| 6              | `.`   | `out === mem[mem_ptr]`                                  |
| `pgm_ctr < op` | `[`   | `next_pgm_ctr <== mem[mem_ptr] == 0 ? op : pgm_ctr + 1` |
| `pgm_ctr > op` | `]`   | `next_pgm_ctr <== mem[mem_ptr] != 0 ? op : pgm_ctr + 1` |

To disambugate `op` values from jump targets, compiled code will be prepended with 7 zeros, one for each `op`. This way, `op` checks can be made with simple equality checks, and jump targets can be assumed safe. Brainfuck programs usually terminate when there is no more instructions left; however, we can't do that in our circuit.

In particular, the circuit operates until each "tick" is processed, whether there are any ops left or not is not of concern. For this reason, the compiled code will have a zero at the end, corresponding to "terminating the program". In a no-op, the program counter is NOT incremented, thereby consuming ticks at that position until the circuit is finished.

By default, all signals stay the same from a tick to next, except the program counter which is incremented.

### Parameters

The Brainfuck circuit is instantiated with the following parameters:

- `TICKS`: number of ticks to run
- `MEMSIZE`: maximum memory size
- `OPSIZE`: maximum number of operations
- `INSIZE`: maximum number of inputs
- `OUTSIZE`: maximum number of outputs

Note that we particularly use the word "maximum" because you do not necessarily have to provide exactly that many inputs, for any input with less elements for that parameter is assumed to be appended zeros. Our circuit has three inputs:

- `ops`: compiled code
- `inputs`: inputs in the order they appear
- `outputs`: outputs in the order they appear

For example, the object below belongs to the execution of `,[.-]`. Notice the prepended 7 zeros and 1 extra zero at the end for `op`. In this particular execution, the user has given the input `5` and got the output `5 4 3 2 1`. Extra information such as memory usage and ticks is also included here.

```json
{
  "ticks": 22,
  "memsize": 0,
  "opsize": 13,
  "insize": 1,
  "outsize": 5,
  "ops": [0, 0, 0, 0, 0, 0, 0, 5, 11, 6, 4, 8, 0],
  "inputs": [5],
  "outputs": [5, 4, 3, 2, 1]
}
```

To prepare this object as a circuit input, we append necessary zeros to inputs, outputs, and ops to match `INSIZE`, `OUTSIZE` and `OPSIZE` respectively. We also check the tick count and memory size to see if we can safely use the circuit.

### Constraints

We have some example constraint counts [here](./CONSTRAINTS.md). We can infer the following results:

- x2 `TICKS` results in ~x2 constraints
- x2 `OPSIZE` results in ~x1.5 constraints
- x2 `MEMSIZE` results in ~x1.3 constraints

We have an example circuit parameter ready in [circuits.json](./circuits.json): 1000 ticks, 8 memory size, 200 ops, 5 inputs, 15 outputs. This circuit results in close to **1 million** constraints. You can compile it via:

```sh
npx circomkit compile brainfuck
```

There could be further optimizations regarding `ArrayRead`. For example, we know that the maximum value an `input_ptr` or `output_ptr` can take a tick `t` is `t-1`. Therefore, instead of reading the entire array each tick, they can read from `0..(t-1)` thereby halving the number of constraints until `t == INSIZE` or `t == OUTSIZE` respectively.

Since this work is just for fun, constraint golfing is left for later at more times to kill.

### Drawbacks

First and foremost, the constraint count is HUGE. This is mostly because of the `ArrayRead` circuit which reads from an array with unknown index. Doing so requires an entire pass over the array with an equality check for each index. For small input arrays this should not be too much of a problem, but inputs may change from time to time.

The second problem is that due to the constraint count, a single huge circuit with many ticks, sufficient memory size, input size, and output size would be rather expensive (although possible). We believe folding may be used to fold each tick in a single recursive proof, perhaps using a tool such as Nova Scotia.

Third drawback is that, who even writes Brainfuck?

## See Also

- [Typefuck](https://github.com/susisu/typefuck) is a Brainfuck interpreter using the type-system of Typescript alone.
- [How Brainfuck Works](https://gist.github.com/roachhd/dce54bec8ba55fb17d3a) is a great Gist about Brainfuck.
- [Brainfuck in STARK](https://neptune.cash/learn/brainfuck-tutorial/) is a quite nice example of another zkBrainfuck based on STARK.
- [Brainfuck in Golang](https://github.com/kgabis/brainfuck-go/blob/master/bf.go) is another implementation of Brainfuck in go.
