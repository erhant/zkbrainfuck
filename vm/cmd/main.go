package main

import (
	"flag"
	"fmt"
	"log"
	"os"
	"zkbrainfuck/pkg/compiler"
	"zkbrainfuck/pkg/vm"
)

func main() {
	// parse command line arguments
	code := flag.String("code", ",+++++[-.]", "brainfuck code")
	path := flag.String("path", "", "path to file with brainfuck code")
	export := flag.String("export", "", "path to export IO trace")
	isNumFmt := flag.Bool("num", false, "use numbers for input & output")
	verbose := flag.Bool("verbose", false, "print compiled code")
	maxClocks := flag.Uint("clocks", 1<<11, "maximum number of \"clock cycles\"")
	memorySize := flag.Uint("memory", 128, "memory size")
	opsize := flag.Uint("opsize", 0, "operations size")
	flag.Parse()

	// if export is given, we need to record IOTrace
	// and export it to a JSON file
	record := false
	if len(*export) != 0 {
		record = true
	}

	// if path is given, we read the code from that file
	// instead of using the `-code` argument
	if len(*path) != 0 {
		codeBytes, err := os.ReadFile(*path)
		if err != nil {
			log.Fatal(err)
		}

		*code = string(codeBytes)
	}

	// compile code
	operations, err := compiler.Compile(*code, *opsize)
	if err != nil {
		fmt.Println()
		log.Fatalf("COMPILER ERROR: %s", err)
	}

	// print compilation result if verbose
	if *verbose {
		fmt.Printf("%v\n\n", operations)
	}

	// run code
	if trace, err := vm.Run(operations, *isNumFmt, *memorySize, *maxClocks, record); err != nil {
		fmt.Println()
		log.Fatalf("RUNTIME ERROR: %s", err)
	} else {
		if record {
			fmt.Println("\nTRACE:")
			fmt.Println(*trace)
		}
	}
	fmt.Println()
}

func export_trace(path string, trace *vm.IOTrace) error {
	// export is '.' then print to console
	return nil // TODO
}