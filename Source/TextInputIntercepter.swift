//
//  TextInputIntercepter.swift
//  TextFieldIntercepterDemo
//
//  Created by fashion on 2018/8/18.
//  Copyright © 2018年 shangZhu. All rights reserved.
//

import UIKit


typealias TextInputIntercepterBlock = (TextInputIntercepter,String)->()

enum TextInputIntercepterNumberType {
    /// 非数字
    case none
    /// 只允许 数字
    case numberOnly
    /// 小数的 (默认 两位 小数) 十进制的
    case decimal
}

class TextInputIntercepter: NSObject {
    /// maxCharacterNum 限制最大字符
    public var maxCharacterNum : UInt = UInt.max
    
    /// 小数点位数(当intercepterNumberType 为.decimal 有用)
    public var decimalPlaces : UInt = 0
    
    /// beyoudLimitBlock 超过限制最大字符数回调
    public var beyondLimitBlock : TextInputIntercepterBlock?
    
    /// 是否允许输入表情
    public var isEmojiAdmitted : Bool = false
    
    /// numberTypeDecimal 小数
    public var intercepterNumberType : TextInputIntercepterNumberType = .none {
        didSet{
            if intercepterNumberType == .decimal && decimalPlaces == 0 {
                decimalPlaces = 2
            }
            if intercepterNumberType != .none{
                isDoubleBytePerChineseCharacter = false
            }
        }
    }
    
    /* default false
     isDoubleBytePerChineseCharacter 为 false
     字母、数字、汉字都是1个字节 表情是两个字节
     isDoubleBytePerChineseCharacter 为 true
     不允许输入表情 一个汉字代表3个字节
     允许输入表情 一个汉字代表3个字节 表情代表4个字节
     */
    public var isDoubleBytePerChineseCharacter : Bool = false
    
    private var previousText : String?

    // MARK: Public  Methods
    
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

    @objc func textInputDidChange(noti : Notification) {

        if let obj = noti.object as? UIView {
            if obj.isFirstResponder == false {
                return
            }
        }
        
        let isTextField = noti.object is UITextField
        let isTextFieldTextDidChange : Bool = noti.name == NSNotification.Name.UITextFieldTextDidChange && isTextField
        
        let isTextView = noti.object is UITextView
        let isTextViewTextDidChange : Bool = noti.name == NSNotification.Name.UITextViewTextDidChange && isTextView
        
        if !isTextFieldTextDidChange && !isTextViewTextDidChange{
            return
        }
        
        if isTextField {
            textFieldTextDidChangeNotification(noti: noti)
        }
        if isTextView {
            textViewTextDidChangeNotification(noti: noti)
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension TextInputIntercepter {
    
    // MARK: Private  Methods
    func textFieldTextDidChangeNotification(noti: Notification) {
        let textField = noti.object as! UITextField
        var inputText = textField.text ?? ""
        
        let primaryLanguage = textField.textInputMode?.primaryLanguage
        // 获取高亮部分
        let selectedRange = textField.markedTextRange ?? UITextRange.init()
        let textPosition = textField.position(from: selectedRange.start, offset: 0)
        
        inputText = handleInputText(inputText: &inputText)
        let finalText = finalTextAfterProcessing(inputText: inputText as NSString, maxCharacterNum: maxCharacterNum, primaryLanguage: primaryLanguage, textPosion: textPosition, isDoubleBytePerChineseCharacter: isDoubleBytePerChineseCharacter)
        
        if let text = finalText,text.count > 0  {
            textField.text = finalText
        }else if intercepterNumberType == .numberOnly || intercepterNumberType == .decimal || isEmojiAdmitted == false{
            textField.text = inputText
        }
        previousText = textField.text
    }
    
    
    // MARK: Private  Methods
    func textViewTextDidChangeNotification(noti: Notification) {
        let textView = noti.object as! UITextView
        var inputText = textView.text ?? ""
        
        let primaryLanguage = textView.textInputMode?.primaryLanguage
        // 获取高亮部分
        let selectedRange = textView.markedTextRange ?? UITextRange.init()
        let textPosition = textView.position(from: selectedRange.start, offset: 0)
        
        inputText = handleInputText(inputText: &inputText)
        let finalText = finalTextAfterProcessing(inputText: inputText as NSString, maxCharacterNum: maxCharacterNum, primaryLanguage: primaryLanguage, textPosion: textPosition, isDoubleBytePerChineseCharacter: isDoubleBytePerChineseCharacter)
        
        if let text = finalText,text.count > 0  {
            textView.text = finalText
        }else if intercepterNumberType == .numberOnly || intercepterNumberType == .decimal || isEmojiAdmitted == false{
            textView.text = inputText
        }
        previousText = textView.text
    }
    
    // 对简体 中文 输入
    private func finalTextAfterProcessing(inputText : NSString, maxCharacterNum : UInt, primaryLanguage: String?, textPosion: UITextPosition?, isDoubleBytePerChineseCharacter : Bool) ->String?{
        
        var finalText : String?
        // "zh-Hant"简繁体中文输入 "zh-Hans" 简体中文
        if primaryLanguage == "zh-Hans" || primaryLanguage == "zh-Hant"{
            if textPosion != nil {
                finalText = processingText(isChinese: true, inputText: inputText, maxCharacterNum: maxCharacterNum, isDoubleBytePerChineseCharacter: isDoubleBytePerChineseCharacter)
            }
        }else{// 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
            finalText = processingText(isChinese: false, inputText: inputText, maxCharacterNum: maxCharacterNum, isDoubleBytePerChineseCharacter: isDoubleBytePerChineseCharacter)
        }
        return finalText

    }
    private func processingText(isChinese: Bool, inputText: NSString, maxCharacterNum : UInt, isDoubleBytePerChineseCharacter : Bool) -> String?{
        var processingText : String?
        if isDoubleBytePerChineseCharacter == true {
            processingText = doubleBytePerChineseCharacterSubString(isChinese: isChinese, subString: inputText, maxCharacterNum: maxCharacterNum)
        }else{
            if inputText.length > maxCharacterNum {
                let rangeIndex = inputText.rangeOfComposedCharacterSequence(at: Int(maxCharacterNum))
                if rangeIndex.length == 1 {
                    processingText = inputText.substring(to: Int(maxCharacterNum))
                }else{
                    
                    let tempRange = NSRange.init(location: 0, length: Int(maxCharacterNum))
                    let range : NSRange = inputText.rangeOfComposedCharacterSequences(for: tempRange)
                    processingText = inputText.substring(with: range)
                }
                if let process = processingText {
                    beyondLimitBlock?(self,process)
                }
                
            }
            
        }
        return processingText
        
    }
    
    private func doubleBytePerChineseCharacterSubString(isChinese: Bool, subString: NSString, maxCharacterNum : UInt) -> String?{
        
        if isEmojiAdmitted {
            // 调用 UTF8 编码处理 一个字符一个字节 一个汉字3个字节 一个表情4个字节
            let textBytesLength = subString.lengthOfBytes(using: String.Encoding.utf8.rawValue)
            
            if textBytesLength > maxCharacterNum {
                var range : NSRange = NSRange.init()
                var byteLength : UInt = 0
                var finalString = subString
                let text = subString
                var i = 0
                while i < subString.length && byteLength <= maxCharacterNum {
                    range = subString.rangeOfComposedCharacterSequence(at: i)
                    byteLength = byteLength + UInt(text.substring(with: range).count)
                    if byteLength > maxCharacterNum {
                        let newText = text.substring(with: NSRange(location: 0, length: range.location))
                        finalString = newText as NSString
                    }
                    i += range.length
                }
                
                return finalString as String
            }
            
        }
        // 不允许 输入 表情
        else {
            // TODO: BUG FIX
            // utf16一个字符1个字节 一个汉字3个字节 isDoubleBytePerChineseCharacter = true
            // utf8一个字符1个字节 一个汉字3个字节 isDoubleBytePerChineseCharacter = true
            // unicode  一个字符2个字节 一个汉字2个字节
            let encoding = String.Encoding.utf8.rawValue
            
            if let data = subString.data(using: encoding) as NSData?{
                let length = data.length
                var tempMaxNum = maxCharacterNum
                if isChinese {
                    tempMaxNum = maxCharacterNum*3/2
                }
                if length > tempMaxNum {
                    let tempLength = tempMaxNum
                    var subdata = data.subdata(with: NSRange.init(location: 0, length: Int(tempLength)))
                    var content = NSString.init(data: subdata, encoding: encoding)
                    //注意：当截取CharacterCount长度字符时把中文字符截断返回的content会是nil
                    if  content == nil || content?.length == 0 {
                        subdata = data.subdata(with: NSRange.init(location: 0, length: Int(tempLength-1)))
                        content = NSString.init(data: subdata, encoding: encoding)
                    }
                    if let myContent = content {
                        beyondLimitBlock?(self,myContent as String)
                    }
                    return content! as String
                }
            }
        }
        return nil
    }
    
    
    private func handleInputText(inputText: inout String) -> String {
        guard let previous = previousText else { return inputText }
        
        if previous.count >= inputText.count {
            return inputText
        }
        
        let tmpReplacementString = (inputText as NSString).substring(with: NSRange.init(location: previous.count, length: inputText.count-previous.count))
        
        // 只允许输入数字
        if intercepterNumberType == .numberOnly {
            if tmpReplacementString.dx_isCertainStringType(type: .number) == false {
                inputText = previous
            }
        }
            // 输入 小数
        else if intercepterNumberType == .decimal {
            let tmpRange = NSRange.init(location: previous.count, length: 0)
            let turple = inputTextShouldChangeCharacters(inputText: previous as NSString, InRange: tmpRange, replacementString: tmpReplacementString as NSString)
            
            if turple.0 == true {
                if inputText.count == maxCharacterNum && tmpReplacementString == "." {
                    inputText = turple.1 as String
                }
            }
            else {
                inputText = turple.1 as String
            }
            // 不允许输入表情
        }else if isEmojiAdmitted == false && tmpReplacementString.dx_isSpecialLetter() {
            inputText = previous
        }
        return inputText
    }
    
    private func inputTextShouldChangeCharacters(inputText: NSString, InRange range: NSRange, replacementString string: NSString) -> (Bool,NSString){
        /// 是否有小数点
        var isHaveDot : Bool = true
        if string == " " {
            return (false,inputText)
        }
        
        if inputText.contains(".") == false{
            isHaveDot = false
        }
        
        if string.length > 0 {
            if string == ":" || string == ";"{
                let text = inputText.replacingCharacters(in: range, with: "")
                return (false,text as NSString)
            }
            
            /// 当前输入的字符
            let single : unichar = string.character(at: 0)
            // 数字0到9对应的ASCLL值 48-59   : ASCLL==58 ; ASCLL==59
            if (single >= 48 && single <= 59) || UnicodeScalar(single) == "." {
                if inputText.length == 0 {
                    if UnicodeScalar(single) == "." {
                        let text = inputText.replacingCharacters(in: range, with: "")
                        return (false,text as NSString)
                    }
                }
                //输入的字符是否是小数点
                if UnicodeScalar(single) == "." {
                    if !isHaveDot {
                        isHaveDot = true
                        return (true,inputText)
                    }else{
                        let text = inputText.replacingCharacters(in: range, with: "")
                        return (false,text as NSString)
                    }
                }else{
                    if isHaveDot {
                        let ran = inputText.range(of: ".")
                        if range.location - ran.location <= decimalPlaces {
                            return (true,inputText)
                        }else{
                            return (false,inputText)
                        }
                        
                    }else{
                        return (true,inputText)
                    }
                }
            }else{//输入的数据格式不正确
                let text = inputText.replacingCharacters(in: range, with: "")
                return (false,text as NSString)
            }
        }
        return (true,inputText)
    }
 
}
