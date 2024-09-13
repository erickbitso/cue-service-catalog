package main

import (
	"tool/cli"
	"tool/file"
	"example.com/transform"
	"example.com/entities"
	"strings"
	"encoding/yaml"

)

// A command named "generate"
//
// Usage: cue cmd -t entity=<entityName> -t overrideFile=<filePath> generate 
//
// A command that generates Kubernetes YAML for a Service.
// Example: cue cmd -t entity=models -t overrideFile=overrides/deployment-config.yaml generate
command: generate: {

	var: {
		file:         *"out.txt" | string                            @tag(file)
		overrideFile: string | *"defaultFile/deployment-config.yaml" @tag(overrideFile)
		entity:       string                                         @tag(entity)
	}

	entityName: entities[var.entity].name

	readFile: file.Read & {
		filename: var.overrideFile
		contents: string
	}

	parsedFile: yaml.Unmarshal(readFile.contents)

	override: parsedFile.override

	result: transform.#Application & {
		"override": override
		name:       entityName
	}

	output: strings.Join([for r in result.$output {
		yaml.Marshal(r)
	}], "---\n")

	createFile: file.Create & {
		filename: var.file
		contents: output
	}

	print: cli.Print & {
		text: output
	}
}
