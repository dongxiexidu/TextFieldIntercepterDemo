//
//  UITextField+Intercepter.swift
//  TextFieldIntercepterDemo
//
//  Created by fashion on 2018/8/18.
//  Copyright © 2018年 shangZhu. All rights reserved.
//

import UIKit

struct RuntimeKey {
    static let dx_textFieldIntercepterKey = UnsafeRawPointer.init(bitPattern: "dx_textFieldIntercepter".hashValue)
    static let dx_textViewIntercepterKey = UnsafeRawPointer.init(bitPattern: "dx_textViewIntercepter".hashValue)
}

extension UITextField {
    
     var dx_textInputIntercepter : TextInputIntercepter? {
        get {
            return objc_getAssociatedObject(self, RuntimeKey.dx_textFieldIntercepterKey!) as? TextInputIntercepter
        }
        set(newValue) {
            objc_setAssociatedObject(self, RuntimeKey.dx_textFieldIntercepterKey!, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
}
