
```bash
# https://www.bejson.com/xml2json/
# demo:
tpl.xml > tpl.json > tpl2.xml > tpl2.json
```

## jq

```bash
# 
https://blog.csdn.net/a12345678n/article/details/95479561 #${Str//"被替换的内容"/"替换的内容"}
https://www.cnblogs.com/tinywan/p/7684414.html #keys, has #Linux 命令详解（十一）Shell 解析 json命令jq详解
https://www.cnblogs.com/cheyunhua/p/13417989.html #del #jq基本用法：修改访问


# headless @ barge in .../_ct/lang-replacement |15:16:13  |master U:2 ?:3 ✗| 
# set attr
$ cat tpl/_replace.json |jq ".target=\"AAA\""
{
  "target": "AAA",
  "expect": "默认"
}

# insertArr
$ rep=$(cat tpl/_replace.json |jq ".target=\"AAA\"" -c)
$ cat tpl/_file.json |jq ".item.replace[.item.replace|length]=$rep"
{
  "name": "js/app/connections/partials/create-connection-form.html",
  "item": {
    "replace": [
      {
        "target": "AAA",
        "expect": "默认"
      }
    ]
  }
}
```

## gen

- format: https://www.sojson.com/

