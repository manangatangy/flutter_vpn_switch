package main

import (
    "bytes"
    "os"
    "encoding/json"
    "fmt"
    "io/ioutil"
    "net/http"
)

var endPoint string

func main() {
    args := os.Args
    endPoint = "http://" + args[1] + ":8080/vpns/"

    command := args[2]
    switch (command) {
    case "list":
        doGetLocations()
        break
    case "current":
        doGetCurrent()
        break
    case "status":
        doGetStatus()
        break
    case "ping":
        doGetPing(args[3])
        break
    case "start":
        doPostStart()
        break
    case "stop":
        doPostStop()
        break
    case "switch":
        doPostSwitch(args[3])
        break
    }
}

func doGetCurrent() {
    fmt.Println("GetCurrent request...")
    response, err := http.Get(endPoint + "current")
    if err != nil {
        fmt.Printf("The HTTP request failed with error %s\n", err)
    } else {
        data, _ := ioutil.ReadAll(response.Body)
        fmt.Println(string(data))
    }
}

func doGetLocations() {
    fmt.Println("GetLocations request...")
    response, err := http.Get(endPoint + "locations")
    if err != nil {
        fmt.Printf("The HTTP request failed with error %s\n", err)
    } else {
        data, _ := ioutil.ReadAll(response.Body)
        fmt.Println(string(data))
    }
}

func doGetStatus() {
    fmt.Println("GetStatus request...")
    response, err := http.Get(endPoint + "status")
    if err != nil {
        fmt.Printf("The HTTP request failed with error %s\n", err)
    } else {
        data, _ := ioutil.ReadAll(response.Body)
        fmt.Println(string(data))
    }
}

func doGetPing(target string) {
    fmt.Println("GetPing request...")
    response, err := http.Get(endPoint + "ping/" + target)
    if err != nil {
        fmt.Printf("The HTTP request failed with error %s\n", err)
    } else {
        data, _ := ioutil.ReadAll(response.Body)
        fmt.Println(string(data))
    }
}

func doPostStart() {
    fmt.Println("PostStart request...")
    jsonData := map[string]string{}
    jsonValue, _ := json.Marshal(jsonData)
    response, err := http.Post(
        endPoint + "start",
        "application/json", 
        bytes.NewBuffer(jsonValue))
    if err != nil {
        fmt.Printf("The HTTP request failed with error %s\n", err)
    } else {
        data, _ := ioutil.ReadAll(response.Body)
        fmt.Println(string(data))
    }
}

func doPostStop() {
    fmt.Println("PostStop request...")
    jsonData := map[string]string{}
    jsonValue, _ := json.Marshal(jsonData)
    response, err := http.Post(
        endPoint + "stop",
        "application/json", 
        bytes.NewBuffer(jsonValue))
    if err != nil {
        fmt.Printf("The HTTP request failed with error %s\n", err)
    } else {
        data, _ := ioutil.ReadAll(response.Body)
        fmt.Println(string(data))
    }
}

func doPostSwitch(newLocation string) {
    fmt.Println("PostSwitch request...")
    jsonData := map[string]string{}
    jsonValue, _ := json.Marshal(jsonData)
    response, err := http.Post(
        endPoint + "switch/" + newLocation,
        "application/json", 
        bytes.NewBuffer(jsonValue))
    if err != nil {
        fmt.Printf("The HTTP request failed with error %s\n", err)
    } else {
        data, _ := ioutil.ReadAll(response.Body)
        fmt.Println(string(data))
    }
}



func doGet() {
    fmt.Println("Get request...")
    response, err := http.Get("https://httpbin.org/ip")
    if err != nil {
        fmt.Printf("The HTTP request failed with error %s\n", err)
    } else {
        data, _ := ioutil.ReadAll(response.Body)
        fmt.Println(string(data))
    }
}

func doPost() {
    fmt.Println("Post request...")
    jsonData := map[string]string{"firstname": "Nic", "lastname": "Raboy"}
    jsonValue, _ := json.Marshal(jsonData)
    response, err := http.Post("https://httpbin.org/post", "application/json", bytes.NewBuffer(jsonValue))
    if err != nil {
        fmt.Printf("The HTTP request failed with error %s\n", err)
    } else {
        data, _ := ioutil.ReadAll(response.Body)
        fmt.Println(string(data))
    }
}

