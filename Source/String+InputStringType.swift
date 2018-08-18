//
//  String+InputStringType.swift
//  TextFieldIntercepterDemo
//
//  Created by fashion on 2018/8/18.
//  Copyright © 2018年 shangZhu. All rights reserved.
//

import Foundation

enum InputStringType {
    /// 数字
    case number
    /// 字母
    case letter
    /// 汉字
    case Chinese
    /// 表情
    case emoji
}

extension String{
    ///  某个字符串是不是数字、字母、汉字
    func dx_isCertainStringType(type: InputStringType) -> Bool {

        return dx_matchRegular(type:type)
    }
    
    /// 字符串是不是特殊字符，此时的特殊字符就是：出数字、字母、汉字以外的
    func dx_isSpecialLetter()-> Bool {
        
        let isNumber : Bool = dx_isCertainStringType(type: .number)
        let isLeter : Bool = dx_isCertainStringType(type: .letter)
        let isChinese : Bool = dx_isCertainStringType(type: .Chinese)

        if isNumber || isLeter || isChinese {
            return false
        }
        return true
    }
    
    // MARK: 用正则判断条件
    func dx_matchRegular(type : InputStringType) -> Bool{
        var regularStr = ""
        switch type {
        case .number:
            regularStr = "^[0-9]*$"
        case .letter:
            regularStr = "^[A-Za-z]+$"
        case .Chinese:
            regularStr = "[\\u4e00-\\u9fa5]"
        case .emoji:
            regularStr = "[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]"
        }
        
        let regex = NSPredicate.init(format: "SELF MATCHES %@", regularStr)
        if regex.evaluate(with: self) == true {
            return true
        }else{
            return false
        }
            
    }

}

