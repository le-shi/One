package main

import (
	"time"
	fm "fmt"
)

// 返回当前东八区时间

//t, err := time.ParseInLocation(time.RFC3339, iso8601, time.UTC)
//if err != nil {
//	return iso8601
//}

//cz := time.FixedZone("CST", 8*3600)
//deal1.CreateTime = t.Now().In(cz).Format("2006-01-02 15:04:05")

var cstZone = time.FixedZone("CST", 8*3600) // 东八
var haha = time.Now().In(cstZone).Format("2006-01-02 15:04:05")

func main(){
	fm.Println(haha)
}
