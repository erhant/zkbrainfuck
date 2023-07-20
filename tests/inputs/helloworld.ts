import type { TestCase } from "../types";

export const helloworld: TestCase = {
  program: {
    ticks: 972,
    memsize: 6,
    opsize: 138,
    insize: 0,
    outsize: 13,
    ops: [
      0, 0, 0, 0, 0, 0, 0, 30, 5, 6, 12, 6, 10, 5, 6, 6, 5, 5, 5, 3, 5, 4, 5, 2, 1, 5, 27, 26, 6, 6, 7, 3, 3, 3, 3, 3,
      3, 3, 3, 79, 1, 3, 3, 3, 3, 64, 1, 3, 3, 1, 3, 3, 3, 1, 3, 3, 3, 1, 3, 2, 2, 2, 2, 4, 45, 1, 3, 1, 3, 1, 4, 1, 1,
      3, 76, 2, 74, 2, 4, 39, 1, 1, 6, 1, 4, 4, 4, 6, 3, 3, 3, 3, 3, 3, 3, 6, 6, 3, 3, 3, 6, 1, 1, 6, 2, 4, 6, 2, 6, 3,
      3, 3, 6, 4, 4, 4, 4, 4, 4, 6, 4, 4, 4, 4, 4, 4, 4, 4, 6, 1, 1, 3, 6, 1, 3, 3, 6, 0,
    ],
    inputs: [],
    outputs: [72, 101, 108, 108, 111, 32, 87, 111, 114, 108, 100, 33, 10],
  },
  params: {
    insize: 0,
    outsize: 15,
    opsize: 140,
    memsize: 8,
    ticks: 1000,
  },
  name: "hello-world",
  num: false,
};
