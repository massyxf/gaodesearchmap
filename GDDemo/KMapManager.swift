//
//  KMapManager.swift
//  GDDemo
//
//  Created by yxf on 2019/7/4.
//  Copyright © 2019 k_yan. All rights reserved.
//

import UIKit
import AMapFoundationKit

let gd_key = "039896fb77efd9d17a52fd95ecfb0e24";

class KMapManager: NSObject {
    @objc class func loadConfig() -> Void {
        AMapServices.shared()?.apiKey = gd_key;
        AMapServices.shared()?.enableHTTPS = true;
    }
}
