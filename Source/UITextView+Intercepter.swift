//
//  UITextView+Intercepter.swift
//  TextFieldIntercepterDemo
//
//  Created by fashion on 2018/8/18.
//  Copyright © 2018年 shangZhu. All rights reserved.
//

import UIKit

extension UITextView {
    
    var dx_textInputIntercepter : TextInputIntercepter? {
        get {
            return objc_getAssociatedObject(self, RuntimeKey.dx_textViewIntercepterKey!) as? TextInputIntercepter
        }
        set(newValue) {
            objc_setAssociatedObject(self, RuntimeKey.dx_textViewIntercepterKey!, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
}
