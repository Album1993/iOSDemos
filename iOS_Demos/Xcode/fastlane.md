配置项目

	project -> info -> configuration 设置 Staging，Production, release

	targets -> build setting -> other swift flags -> 
	 	staging : DSTG
	 	production: DPROD
	 	release: DPROD
	 	
	 	设置之后使用代码

```	 	
#if PROD
  print(“We brew beer in the Production”)
#elseif STG
  print(“We brew beer in the Staging”)
#endif
```
	 	
	 targets -> build setting -> product bundle identifier 
	 
	 	staging : com.svw.mos.staging
	 	production: com.svw.mos.production
	 	release: com.svw.mos.release

配置项目信息


配置证书

1 . bundle id :
com.svw.mos.staging
com.svw.mos.production
com.svw.mos.release

2 . 创建发布证书：
SVW_Sales_Distribution.p12

3 . 创建描述文件:
MOS_Production.mobileprovision(AdHoc)
MOS_Staging.mobileprovision(AdHoc)
MOS_Release.mobileprovision(App Store)

项目配置
	target -> general -> signing ,分别设置

构建fastlane
1.构建、发布测试环境的应用
2.构建、发布生产环境的应用

这两种方法之间的区别仅仅在于配置。共同的任务包括：
	•	用证书和配置文件签名
	•	构建并导出应用
	•	把应用上传到 Crashlytics（或其它分发平台）


