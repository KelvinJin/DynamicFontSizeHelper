## DynamicFontSizeHelper
A helper that simplifies handling dynamic content size category with only one line of code.

### How to use

Drag and drop the `DynamicFontSizeHelper.swift` file to your project.

#### Interface Builder
1. Select the `UILabel` that you want to support dynamic content size.
2. Under **Attribute Inspector**, set the _Register For Size Change With Default Font Size_ to any `CGFloat` number you want.
3. No more!


#### Programmatically
```swift
// Initialize my label somewhere
let myLabel: UILabel

// And then
myLabel.registerForSizeChangeWithDefaultFontSize = 14.0
```

### What do I get?
This is what you get:  

![GIF Demo](https://raw.githubusercontent.com/KelvinJin/DynamicFontSizeHelper/master/DynamicFontSizeDemo.gif)

### License
MIT
