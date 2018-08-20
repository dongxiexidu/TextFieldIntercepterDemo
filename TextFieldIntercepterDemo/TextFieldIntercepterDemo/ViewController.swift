//
//  ViewController.swift
//  TextFieldIntercepterDemo
//
//  Created by fashion on 2018/8/18.
//  Copyright © 2018年 shangZhu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var cardTextField: UITextField!
    @IBOutlet weak var moneyTextField: UITextField!
    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            nameTextField.placeholder = "请输入姓名(汉字5个字，英文10个字母)"
            let intercepter = TextInputIntercepter.init()
            intercepter.maxCharacterNum = 10
            intercepter.isEmojiAdmitted = false
            intercepter.isDoubleBytePerChineseCharacter = false
            intercepter.beyondLimitBlock = { textIntercepter, string in
                print("最多只能输入汉字5个字，英文10个字母--\(string)")
            }
            intercepter.textInputView(inputView: nameTextField)
        }
        
        do {
            cardTextField.placeholder = "请输入卡号(只限数字)"
            let intercepter = TextInputIntercepter.init()
            intercepter.maxCharacterNum = 16
            intercepter.isEmojiAdmitted = false
            intercepter.intercepterNumberType = .numberOnly
            intercepter.beyondLimitBlock = { textIntercepter, string in
                print("最多只能输入16位卡号--\(string)")
            }
            intercepter.textInputView(inputView: cardTextField)
        }
        
        do {
            moneyTextField.placeholder = "请输入金额(最多9位数，保留2位小数)"
            
            let intercepter = TextInputIntercepter.init()
            intercepter.maxCharacterNum = 9
            // 保留两位小数
            intercepter.decimalPlaces = 2
            intercepter.intercepterNumberType = .decimal
            intercepter.beyondLimitBlock = { textIntercepter, string in
                print("最多只能输入9位数字--\(string)")
            }
            intercepter.textInputView(inputView: moneyTextField)
        }
        
        do {
            accountTextField.placeholder = "请输入您的账号"
            let intercepter = TextInputIntercepter.init()
            intercepter.maxCharacterNum = 16
            intercepter.beyondLimitBlock = { textIntercepter, string in
                print("最多只能输入16位数字--\(string)")
            }
            intercepter.textInputView(inputView: accountTextField)
        }
        
        do {
            passwordTextField.placeholder = "请输入您的密码"
            
            let intercepter = TextInputIntercepter.init()
            intercepter.maxCharacterNum = 16
            intercepter.beyondLimitBlock = { textIntercepter, string in
                print("最多只能输入16位数字--\(string)")
            }
            
            intercepter.textInputView(inputView: passwordTextField)
        }
        
    }


}

