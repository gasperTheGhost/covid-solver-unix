package main

import (
	"fmt"
	"io/ioutil"
	"os"
	"strconv"
	"strings"
)

func main() {
	counter, err := strconv.Atoi(os.Args[1])
	threads, err := strconv.Atoi(os.Args[2])
	//pwd := os.Args[3]

	data, err := ioutil.ReadFile(fmt.Sprintf("3D_structures_%d.sdf", counter))
	if err != nil {
		fmt.Println("Error reading package data")
	}
	stringData := string(data)
	splitted := strings.Split(stringData, "$$$$")
	fileSize := len(splitted) / int(threads)
	lastFileSize := len(splitted) % int(threads)

	currentPosition := 0
	for i := 0; i < int(threads); i++ {
		fileData := ""
		if i == int(threads)-1 {
			fileData = strings.Join(splitted[currentPosition:], "$$$$")
		} else {
			fileData = strings.Join(splitted[currentPosition:currentPosition+fileSize], "$$$$")
		}
		currentPosition += fileSize
		ioutil.WriteFile(fmt.Sprintf("temp/temp_%d.sd", i), []byte(fileData), 0777)
	}
	fmt.Println(fileSize, lastFileSize)
	os.Remove(fmt.Sprintf("3D_structures_%d.sdf", counter))
}
