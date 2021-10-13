
```bash
headless @ barge in .../lang-replacement/generate |17:31:51  |dev U:3 ?:3 ✗| 
$ cat t1.txt  |sed "s^<expect><\!\[CDATA\[^bb/^g"
bb/
# $ cat t1.txt 
<expect><![CDATA[
```