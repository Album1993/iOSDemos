
```
-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.jsContext =  [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];

    // 方法一
    __weak typeof(self) weakSelf = self;
    self.jsContext[@"getMessage"] = ^(){
        return [weakSelf blockCallMessage];
    };

    // 方法二
    self.jsContext[@"JavaScriptInterface"] = self;
}

- (NSString *)blockCallMessage
{
    return @"call via block";
}

#pragma mark - JSCallDelegate
  // 提供给JS调用的方法
- (NSString *)tipMessage
{
    return @"call via delegate";
}
```

HTML代码


```
<html>
<head>
</head>
<body>
    <script>
        function buttonClick1()
        {
            // 方法一
             var token = getMessage();

            alert(token)
        }
        function buttonClick2()
        {
            // 方法二
            var token = JavaScriptInterface.tipMessage();
        
            alert(token)
        }
        </script>
    <button id="abc" onclick="buttonClick1()">function 1</button>
    <button id="abcd" onclick="buttonClick2()">function 2</button>
</body>
</html>

```

方法一中的`jsContext[@"getMessage"]`需要和JS中调用的方法名一致，既**JS**中需要直接调用**getMessage()**，而`jsContext[@"getMessage"]`则赋值为一个**block**，这个**block**中调用的方法就是**JS**中调用**getMessage()**就是执行这个**block**；
方法二中的`jsContext[@"JavaScriptInterface"] = self`其中的**JavaScriptInterface**可以随便命名，保持**JS**中和该命名保持一致即可，**JS**中通过**JavaScriptInterface**来调用继承自**JSExport**的**delegate**中的方法，即`JavaScriptInterface.tipMessage()`


