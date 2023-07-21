package compiler

import (
	"fmt"
	"testing"
)

func arraysEq(a, b []uint) bool {
	if len(a) != len(b) {
		return false
	}
	for i, v := range a {
		if v != b[i] {
			return false
		}
	}
	return true
}

func TestCompile(t *testing.T) {
	cases := []struct {
		code string
		ops  []uint
	}{
		{code: ",[.-]", ops: []uint{0, 0, 0, 0, 0, 0, 0, 5, 11, 6, 4, 8, 0}},
		{code: "++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++.", ops: []uint{0, 0, 0, 0, 0, 0, 0, 3, 3, 3, 3, 3, 3, 3, 3, 55, 1, 3, 3, 3, 3, 40, 1, 3, 3, 1, 3, 3, 3, 1, 3, 3, 3, 1, 3, 2, 2, 2, 2, 4, 21, 1, 3, 1, 3, 1, 4, 1, 1, 3, 52, 2, 50, 2, 4, 15, 1, 1, 6, 1, 4, 4, 4, 6, 3, 3, 3, 3, 3, 3, 3, 6, 6, 3, 3, 3, 6, 1, 1, 6, 2, 4, 6, 2, 6, 3, 3, 3, 6, 4, 4, 4, 4, 4, 4, 6, 4, 4, 4, 4, 4, 4, 4, 4, 6, 1, 1, 3, 6, 1, 3, 3, 6, 0}},
	}
	for _, test := range cases {
		ops, err := Compile(test.code, 0)
		if err != nil {
			t.Error("Compilation failed:", err.Error())
		}
		if !arraysEq(ops, test.ops) {
			fmt.Println(ops)
			t.Error("Results do not match.")
		}

	}
}
