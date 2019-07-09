//
//  KResultTableView.swift
//  GDDemo
//
//  Created by yxf on 2019/7/8.
//  Copyright © 2019 k_yan. All rights reserved.
//

import UIKit

class KResultTableView: UITableView {
    
    var dismissBlock: (()->())?

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.visibleCells.count > 0{
            super.touchesBegan(touches, with: event)
            return
        }
        
        if let dismiss = dismissBlock {
            dismiss()
        }
        
    }

}
