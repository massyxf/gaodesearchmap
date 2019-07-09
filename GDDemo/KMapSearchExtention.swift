//
//  KMapSearchExtention.swift
//  GDDemo
//
//  Created by yxf on 2019/7/4.
//  Copyright © 2019 k_yan. All rights reserved.
//

import Foundation
import UIKit
import AMapSearchKit

extension KMapViewController{
    func searchUI() {
        let retVc = KMapSearchResultVc.init()
        let serVc = UISearchController.init(searchResultsController: retVc)
        if #available(iOS 11.0,*) {
            self.navigationItem.searchController = serVc
            self.navigationItem.hidesSearchBarWhenScrolling = false
        }else{
            let headView = UITableView.init(frame: CGRect.init(x: 0, y: KScreenFrame.naviTopSafeHeight(), width: KScreenFrame.screenWidth(), height: 44), style: .plain)
            view.addSubview(headView)
            headView.tableHeaderView = serVc.searchBar
            headView.tableHeaderView?.frame = CGRect.init(x: 0, y: 0, width: 0, height: 44)
            headView.isScrollEnabled = false
            headView.backgroundColor = UIColor.clear
            serVc.searchBar.barTintColor = UIColor.init(red: 233/255.0, green: 233/255.0, blue: 233/255.0, alpha: 1)
        }
        
        serVc.searchBar.placeholder = "搜索";
        serVc.searchBar.setValue("取消", forKey: "_cancelButtonText")
        
        serVc.delegate = self;
        serVc.searchResultsUpdater = retVc;
        serVc.dimsBackgroundDuringPresentation = false
        serVc.searchBar.delegate = self

        self.definesPresentationContext = true
        
        self.searchVc = serVc
        self.resultVc = retVc
        retVc.delegate = self
    }
}

extension KMapViewController:UISearchControllerDelegate,UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func willPresentSearchController(_ searchController: UISearchController) {
        isPresentSearchVc = true
        if #available(iOS 11.0, *) {
            changeFrame(duration: 0.3, offset: 70)
        } else {
            changeFrame(duration: 0.3, offset: 64)
        }
    }
    
    func didPresentSearchController(_ searchController: UISearchController) {
        searchController.searchBar.becomeFirstResponder()
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        isPresentSearchVc = true
        changeFrame(duration: 0.45, offset: searchBarY)
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        isPresentSearchVc = false
    }
    
    func changeFrame(duration: CGFloat, offset: CGFloat) {
        self.isChangingFrame = true
        UIView.animate(withDuration: TimeInterval(duration), animations: {
            self.resetFrame(mapY: offset)
        }) { (_) in
            self.isChangingFrame = false
        }
    }
    
}

extension KMapViewController: KMapSearchResultVcDelegate{
    func resultVcDidScroll(resultVc: KMapSearchResultVc?) {
        
        //改变视图坐标时，不处理这里的逻辑
        if isChangingFrame { return }
        
        //这个方法可以结束搜索逻辑
        // searchVc?.isActive = false
        
        //修改searchBar的内容时，resultVc!.datas会清空,并请求新的数据，不能searchVc?.isActive = false
        if resultVc!.isLoadingNewData { return; }
        
        //reloaddata的时候scrollview会调用didscroll的方法，需要通过这个判断来处理逻辑
        if resultVc!.datas.count > 0 {
            searchVc?.searchBar.resignFirstResponder()
        }else{
            searchVc?.isActive = false
        }
    }
    
    func resultVcDidSelectPoi(resultVc: KMapSearchResultVc?, poi: AMapPOI) {
        searchVc?.isActive = false
        guard let location = poi.location else { return }
        let selectLocation = CLLocationCoordinate2D.init(latitude: CLLocationDegrees(location.latitude), longitude: CLLocationDegrees(location.longitude))
        mapViewCenterChanged(location: selectLocation);
    }
    
    func resultVcDismiss(resultVc: KMapSearchResultVc?) {
        searchVc?.isActive = false
    }
}
