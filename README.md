# weweChatAssitant
微信自动抢红包,微信修改经纬度


使用方式

1. 编译用来嵌入微信二进制的动态链接库TestTweak.dylib  运行脚本build_dylib.sh就可以生成

2. 拷贝其到微信的二进制包中


3. 修改微信二进制,使其能够加载我们的动态库,这一步需要使用[optool](https://github.com/alexzielenski/optool)来实现
```
optool install -c load -p "@executable_path/TestTweak.dylib" -t Payload/WeChat.app/WeChat
```



4. 接下来把我们生成的dylib(libautoGetRedEnv.dylib)、刚刚注入dylib的WeChat、以及embedded.mobileprovision文件(可以在之前打包过的App中找到)拷贝到WeChat.app中

一定要记得 需要这个embedded.mobileprovision文件,如果没有这个文件,重签名后是安装不了的


5. 重签名
这一步可以使用图形化工具[ios-app-signer](https://github.com/DanTheMan827/ios-app-signer)


> 重签名后使用iTools Pro来安装,出现错误提示  WatchKitAppBundleDNotPrefixed
 这个是由于这个app中不止一个可运行的程序,还有watch os的,由于我们这里不需要watch os,所以可以直接将文件夹 watch删掉 (其中有WeChatWatchNative.app)
> 再重新签名,就可以了

