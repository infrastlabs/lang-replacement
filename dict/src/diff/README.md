# 

format a commandline-tool  
github.com/sergi/go-diff/diffmatchpatch: ref google-diff-match-patch, go implementiion

```bash
$ go run ./diff/main.go  > ss.txt
$ sed -e 's/\x1b//g' ss.txt > ss.txt2

# newDiffs
$ go run ./diff/main.go 
name名字
```

## Dev

```bash
# sam @ debian11 in .../_ee/lang-replacement |14:21:34  |master U:1 ?:4 ✗| 
$ go build ./diff/main.go 
# sam @ debian11 in .../_ee/lang-replacement |14:21:37  |master U:1 ?:4 ✗| 
$ ./main aa bb true
aa >>>>> bb
aabb

$ go build -o godiff ./diff/main.go
```