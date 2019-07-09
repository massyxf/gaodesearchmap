//
//  KSearchResultCell.swift
//  GDDemo
//
//  Created by yxf on 2019/7/5.
//  Copyright © 2019 k_yan. All rights reserved.
//

import UIKit
import AMapSearchKit

let KSearchResultCellId = "KSearchResultCell"

class KSearchResultCell: UITableViewCell {

    var poi: AMapPOI?{
        didSet{
            titleLabel.attributedText = KResultAttTool.share.attText(from: poi?.name)
            addressLabel.attributedText = KResultAttTool.share.attText(from: poi?.address)
        }
    }
    
    lazy var titleLabel = UILabel.init()
    lazy var addressLabel = UILabel.init()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(titleLabel)
        contentView.addSubview(addressLabel)
        
        titleLabel.font = UIFont.systemFont(ofSize: 15)
        addressLabel.font = UIFont.systemFont(ofSize: 12)
        addressLabel.textColor = UIColor.lightGray
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let width = self.contentView.frame.width - 20
        titleLabel.frame = CGRect.init(x: 10, y: 5, width: width, height: 20)
        addressLabel.frame = CGRect.init(x: 10, y: 25, width: width, height: 15)
    }
}
