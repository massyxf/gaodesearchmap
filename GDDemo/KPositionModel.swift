//
//  KPositionModel.swift
//  GDDemo
//
//  Created by yxf on 2019/7/8.
//  Copyright © 2019 k_yan. All rights reserved.
//

import UIKit
import AMapSearchKit

class KPositionModel: NSObject {

    var poi: AMapPOI?
    var isSelected = false
    
    init(with poi: AMapPOI) {
        super.init()
        self.poi = poi
    }
    
}
