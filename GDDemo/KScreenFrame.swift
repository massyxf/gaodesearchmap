//
//  ScreenFrame.swift
//  GDDemo
//
//  Created by yxf on 2019/7/4.
//  Copyright © 2019 k_yan. All rights reserved.
//

import UIKit

class KScreenFrame: NSObject {
    class func screenWidth() -> CGFloat {
        return UIScreen.main.bounds.width;
    }
    
    class func screenHeight() -> CGFloat {
        return UIScreen.main.bounds.height;
    }
    
    class func screenScale() -> CGFloat {
        return UIScreen.main.scale;
    }
    
    class func isNormalScreen() -> Bool {
        return screenHeight() < 800 ;
    }
    
    class func topSafeHeight() -> CGFloat{
        return isNormalScreen() ? 0 : 24;
    }
    
    class func naviTopSafeHeight() -> CGFloat{
        return isNormalScreen() ? 64 : 88;
    }
    
    class func bottomSafeHeight() -> CGFloat{
        return isNormalScreen() ? 0 : 34;
    }
    
    class func tabBottomSafeHeight() -> CGFloat{
        return isNormalScreen() ? 49 : 83;
    }
}
