package main

import (
	"fmt"
	"log"
	"net/http"
)

// 启动个简单的httpserver端口8080

func HelloServer(w http.ResponseWriter, req *http.Request) {
	fmt.Println("Inside HelloServer handler")
	fmt.Fprintf(w, "Hello,"+req.URL.Path[1:])
}

func main() {
	http.HandleFunc("/", HelloServer)
	err := http.ListenAndServe("localhost:8080", nil)
	log.Info("Started 0.0.0.0:8080")
	if err != nil {
		log.Fatal("ListenAndServe: ", err.Error())
	}
}