package main

import (
  // "gitee.com/g-devops/fk-exec-cmd"

  
	// "github.com/pkg/errors"
	"os/exec"
	"log"
	"fmt"
	"io"
	"strings"
)

func main() {
//   execmd.NewCmd().Run("ps aux | grep go")
  // execmd.NewCmd().Run("ps -ef |wc; pwd")

  cmd:= "ls /; pwd"
  // ret:= execute(cmd)
  execute(cmd)

  fmt.Println("ret")
}


type ExecRet struct{
	Code int
	Message string
}
func execute(cmdstr string)(*ExecRet){
	log.Printf("[DEBUG1] [host_exec] cmd: %s", cmdstr)
	// ref: dp's ./service/exec/exec.go
	ret:= &ExecRet{} //{0, ""}
	cmd := exec.Command("sh", "-c", cmdstr) 
 
	stdout, _ := cmd.StdoutPipe()
	stderr, _ := cmd.StderrPipe()
 
	if err := cmd.Start(); err != nil {
		// log.Printf()
		ret.Code= -1
		ret.Message= fmt.Sprintf("Error starting command: \n%s", err.Error())
		return ret
	}
	
	strout, _:= asyncLog(stdout)
	strerr, _:= asyncLog(stderr)
	if err := cmd.Wait(); err != nil {
		ret.Code= -2
		ret.Message= fmt.Sprintf("Finished with exec status: \n%s", err.Error())
		return ret
	}
	log.Printf("[DEB1UG1] [host_exec] out: %s", strout)
	log.Printf("[DEB1UG1] [host_exec] err: %s", strerr)
	ret.Code= 0
	ret.Message= fmt.Sprintf("result: \n%s\n%s", strerr, strout)
	return ret
}

func asyncLog(reader io.ReadCloser)(string, error) { //realtimeLog > none-real string
	ret := ""
	cache := "" //缓存不足一行的日志信息
	buf := make([]byte, 1024)
	for {
		num, err := reader.Read(buf)
		if err != nil && err!=io.EOF{
			return "err", err
		}
		if io.EOF == err { //err != nil || 
            break //end loop
        }
		if num > 0 {
			b := buf[:num]
			s := strings.Split(string(b), "\n")
			line := strings.Join(s[:len(s)-1], "\n") //取出整行的日志
			//fmt.Printf("%s%s\n", cache, line)
			cache = s[len(s)-1]

			//asyncLoger.Println() //to str: Sprintf
			ret= ret+"\n"+fmt.Sprintf("%s%s", cache, line)
		}
	}
	return ret, nil
}