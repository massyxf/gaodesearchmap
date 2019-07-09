//
//  KResultAttTool.swift
//  GDDemo
//
//  Created by yxf on 2019/7/5.
//  Copyright © 2019 k_yan. All rights reserved.
//

import UIKit

class KResultAttTool: NSObject {
    
    static let share = KResultAttTool.init()
    var key: String = ""
    
    func attText(from text:String?) -> NSAttributedString? {
        return attText(from: text, with: key)
    }
    
    func attText(from text:String?,with newKey: String) -> NSAttributedString? {
        guard let newtext = text else {
            return nil
        }
        let retAtt = NSMutableAttributedString.init(string: newtext)
        guard let regex = try? NSRegularExpression.init(pattern: newKey, options: []) else{
            return retAtt
        }
        let matches = regex.matches(in: newtext, options: [], range: NSRange.init(location: 0, length: newtext.count))
        let att = [NSAttributedString.Key.foregroundColor:UIColor.red]
        for matchedText in matches {
            retAtt.setAttributes(att, range: matchedText.range)
        }
        return retAtt
    }
}
