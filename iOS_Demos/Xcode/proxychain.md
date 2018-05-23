


安装 **proxychains**
 环境 **mac os 10.13.3**  需要[关闭 **mac** 上的 **sip**](https://zhuanlan.zhihu.com/p/21281236)

**step1：** `brew install proxychains-ng`
**step2：** `vim /usr/local/etc/proxychains.conf`
 
 修改 **ProxyList** 下 `socks5 127.0.0.1 1086`

**setp3:** **Shadowsocks** 全局模式下测试
 

``` 
 `curl myip.ipip.net`
 当前 IP：xx.xx.xx.xx  来自于：中国 上海 上海  电信
 proxychains4 curl myip.ipip.net
 当前 IP：xx.xx.xx.xx  来自于：美国 加利福尼亚州 洛杉矶  it7.net
```


注意: **socks,http**代理等使用的是**TCP**或**UDP**协议, 而**ping**命令则是**ICMP**协议, 所以**proxychains4**对**ping**命令无效.
  


