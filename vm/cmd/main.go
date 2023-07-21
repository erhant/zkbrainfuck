package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"log"
	"os"
	"zkbrainfuck/pkg/compiler"
	"zkbrainfuck/pkg/vm"
)

func main() {
	code := flag.String("code", ",[.-]", "brainfuck code")
	export := flag.String("export", "", "path to export program information")
	path := flag.String("path", "", "path to file with brainfuck code")
	memorySize := flag.Uint("memory", 128, "memory size")
	opsize := flag.Uint("opsize", 0, "operations size")
	maxTicks := flag.Uint("ticks", 2048, "maximum number of ticks")
	isNumFmt := flag.Bool("num", false, "use numbers for input & output instead of runes")
	flag.Parse()

	// if export is given, we need to record program execution
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

	operations, err := compiler.Compile(*code, *opsize)
	if err != nil {
		fmt.Println()
		log.Fatalf("COMPILER ERROR: %s", err)
	}

	fmt.Print("{")
	for _, op := range operations {
		fmt.Printf("%d, ", op)
	}
	fmt.Print("}\n")

	if programExecution, err := vm.Execute(operations, *isNumFmt, *memorySize, *maxTicks, record); err != nil {
		fmt.Println()
		log.Fatalf("RUNTIME ERROR: %s", err)
	} else {
		if record {
			if err := export_program_execution(*export, programExecution); err != nil {
				log.Fatalf("EXPORT ERROR: %s", err)
			}
		}
	}
	fmt.Println()
}

func export_program_execution(path string, trace *vm.ProgramExecution) error {
	file, err := json.Marshal(trace)
	if err != nil {
		return err
	}
	if err := os.WriteFile(path, file, 0644); err != nil {
		return err
	}
	return nil
}
