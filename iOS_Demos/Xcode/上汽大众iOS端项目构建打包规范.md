# 上汽大众iOS端项目构建打包规范

### 1. 删除无用资源
1.1 使用 **LSUnusedResources** 分析无用图片
1.2 将项目中无用文件剔除
1.3 将项目中除**release**版本中需要的资源加载，其余文件打包前全部删除

### 2. 保证图片在相同显示效果的情况下占最小容量
2.1 超过**10k**的图片需要压缩至10k以下，使用工具**ImageOptim**
2.2 尽量使用**webp**格式图片
2.3 使用**Assets.xcassets**管理图片
2.4 项目中音频压缩，降低采样率
2.5 H5资源打包
2.6 H5远端化
2.7 动态下载资源

### 3. 可执行文件瘦身

3.1 **cocoapods**中所有库明确是否在**release**中需要接入

```
pod libWeChatSDK:configurations => ['Debug']
pod libWeChatSDK-device:configurations => ['Release']
```

3.2 使用**AppCode** 扫描代码，删除无用类，以及无用引用

3.3 编译选项

`Optimization Level` ： Fastest, Smallest[-Os]
`Strip Debug Symbols During Copy` ：yes
`Strip Link Product` : yes
`Make Strings Read-Only`: yes
`Linking-Dead Code Stripping` ：yes
`Deployment Postprocessing` ：yes
`Symbols hidden by default`：yes
`Enable bitcode`： yes

3.4 重复代码整理
利用第三方软件： **simian**扫描

3.5代码中长字符串抽离
提高压缩比率

3.6 尽量少使用属性 减少**getter** 和 **setter**

3.7 删除**framework**中无用的**Mach-O**文件




