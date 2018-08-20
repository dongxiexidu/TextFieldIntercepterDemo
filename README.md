# TextFieldIntercepterDemo

- [x] 支持`UITextField`和`UITextView`
- [x] 可限制字符长度`maxCharacterNum`
- [x] 超过限制最大字符长度,添加了block回调`beyondLimitBlock`
- [x] 可限制`金额`保留两位小数`decimalPlaces`
- [x] 可禁止输入表情`isEmojiAdmitted`


### Public  Methods
```
/// 设置 需要 拦截的输入框
///
/// - Parameter textInputView: 输入框
public func textInputView(inputView: UIView) {
    textInputView(textInputView: inputView, intercepter: self)
}


/// 设置 拦截器和拦截的输入框
///
/// - Parameters:
///   - textInputView: 输入框
///   - intercepter: 拦截器
public func textInputView(textInputView: UIView,intercepter: TextInputIntercepter) {
    if textInputView is UITextField {
        let textField = textInputView as! UITextField
        textField.dx_textInputIntercepter = intercepter
        NotificationCenter.default.addObserver(self, selector: #selector(textInputDidChange(noti:)), name: NSNotification.Name.UITextFieldTextDidChange, object: textInputView)
        
    }else if textInputView is UITextView {
        let textView = textInputView as! UITextView
        textView.dx_textInputIntercepter = intercepter
        NotificationCenter.default.addObserver(self, selector: #selector(textInputDidChange(noti:)), name: NSNotification.Name.UITextViewTextDidChange, object: textInputView)
    }
    
}


class func textInputView(textInputView: UIView,beyondLimitBlock: @escaping TextInputIntercepterBlock)-> TextInputIntercepter {
    let tempInputIntercepter = TextInputIntercepter.init()
    tempInputIntercepter.beyondLimitBlock = beyondLimitBlock
    tempInputIntercepter.textInputView(textInputView: textInputView, intercepter: tempInputIntercepter)
    return tempInputIntercepter
}
```

### Examples
```
cardTextField.placeholder = "请输入卡号(只限数字)"
let intercepter = TextInputIntercepter.init()
intercepter.maxCharacterNum = 16
intercepter.isEmojiAdmitted = false
intercepter.intercepterNumberType = .numberOnly
intercepter.beyondLimitBlock = { textIntercepter, string in
    print("最多只能输入16位卡号--\(string)")
}
intercepter.textInputView(inputView: cardTextField)
```



本文参考了
[Objective-C 版本](https://github.com/fangjinfeng/FJFTextInputIntercepter)
