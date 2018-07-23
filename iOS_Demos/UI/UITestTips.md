#  检测是否是在UITest情况下


```
// Reset user defaults for UI tests
if ProcessInfo.processInfo.arguments.contains("UITEST")
{
prefs.reset()
words.clear()
}
```
