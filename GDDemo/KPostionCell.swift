//
//  KPostionCell.swift
//  GDDemo
//
//  Created by yxf on 2019/7/4.
//  Copyright © 2019 k_yan. All rights reserved.
//

import UIKit
import AMapSearchKit

let KPostionCellId = "KPostionCell"


class KPostionCell: UITableViewCell {

    lazy var postionTitleLabel: UILabel = {
        let label = UILabel.init()
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    lazy var postionDetailLabel: UILabel = {
        let label = UILabel.init()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.lightGray
        return label
    }()
    
    var position: KPositionModel?{
        didSet{
            self.postionTitleLabel.text = position?.poi?.name
            self.postionDetailLabel.text = position?.poi?.address
            let select = position?.isSelected ?? false
            self.accessoryType = select ? .checkmark : .none
        }
    }
    

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(postionTitleLabel)
        contentView.addSubview(postionDetailLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let width = self.contentView.frame.width - 60;
        postionTitleLabel.frame = CGRect.init(x: 10, y: 5, width: width, height: 20)
        postionDetailLabel.frame = CGRect.init(x: 10, y: 25, width: width, height: 15)
    }
    
}
