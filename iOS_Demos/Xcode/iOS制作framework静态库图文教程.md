### iOS制作framework静态库图文教程



1.首先在xcode下新建cocoa touch framework工程：



2.新建好工程后，往里面添加要封装的代码，并且把包含公有api的头包含到自动生成的头文件里面

或者到Build Phases下Headers里面把公有头文件放到public下( swift 不需要添加headers)





3.在Build Setting――>Linking找到Mach－O Type 把值：Dynamic Library改为：Static Library,缺少这一步生成的framework就是动态库



4.找到Edit scheme在run――>info下把build configure的值由默认值Debug 改为Release



 5.选择要编译的硬件环境：分别在Generic IOS Device和 iPhone 6s Plus（选择最新的模拟器）下编译一次，编译完后就可以看到工程的products文件下的xxx.framework由红色变成黑色（注意：如果只编译了iphone 6s Plus模拟器，没有编译 Generic IOS Device ，那么xxx.framework还是不会变成黑色）



6.xxx.framework 变成黑色后，选中xxx.framework右键show in finder 就可以看到生成的framework静态库。分别有Release－iphoneos真机版和Release－iphonesimulator模拟器版，也就是说生成的版本只能分别在各自的硬件环境下使用。

7.合并真机和模拟器版framework静态库，这样就可以在模拟器和真机下使用了，不过要注意生成的静态库的大小等于真机版和模拟器版的大小的和，所以要对程序进行缩小时，可以只用其中一个版本



使用xcode自带的lipo可以合并两个版本：在终端下使用命令：lipo -create /User/...../release-iphoneos/xxx.framework/xxx /User/...../release-iphonesimular/xxx.framework/xxx -output ./xxx

其中xxx为你的库的名称，路径为生成的静态库的路径，然后把生成的xxx放到真机或者模拟器版的xxx.framework里面替换里面原有的xxx库