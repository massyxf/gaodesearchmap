//
//  KMapSearchResultVc.swift
//  GDDemo
//
//  Created by yxf on 2019/7/4.
//  Copyright © 2019 k_yan. All rights reserved.
//

import UIKit
import AMapSearchKit

@objc protocol KMapSearchResultVcDelegate {
    func resultVcDidScroll(resultVc: KMapSearchResultVc?);
    func resultVcDidSelectPoi(resultVc: KMapSearchResultVc?,poi: AMapPOI);
    func resultVcDismiss(resultVc: KMapSearchResultVc?);
}

class KMapSearchResultVc: UIViewController {
    
    //search
    lazy var searchApi: AMapSearchAPI? = {
        let api = AMapSearchAPI.init()
        api?.delegate = self
        return api
    }()
    var currentRequest: AMapPOISearchBaseRequest?
    var currrentLocation: CLLocationCoordinate2D?
    var currentPage = 1
    var isLoadingNewData = false
    
    
    //tableview
    lazy var tableView: KResultTableView = {
        let listView = KResultTableView.init(frame: CGRect.init(), style: .plain)
        listView.dataSource = self;
        listView.delegate = self;
        listView.register(KSearchResultCell.self, forCellReuseIdentifier: KSearchResultCellId)
        listView.tableFooterView = UIView.init()
        listView.rowHeight = 45
        return listView
    }()
    lazy var datas = NSMutableArray.init()
    
    weak var delegate: KMapSearchResultVcDelegate?
    var currentKey: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        tableView.frame = self.view.bounds;
        view.addSubview(tableView)
        
        tableView.backgroundColor = UIColor.gray.withAlphaComponent(0.7)
        tableView.dismissBlock = { [weak self] in
            self?.delegate?.resultVcDismiss(resultVc: self)
        }
        tableView.kf_footerView = KFooterView.kf_footerView(loadingActionBlock: { [weak self] in
            self?.loadMore()
        })
        
    }
}

//MARK: data
extension KMapSearchResultVc{
    
    func loadData(isMore:Bool = false) {
        
        currentPage = isMore ? (currentPage + 1) : 1;
        let request = AMapPOIKeywordsSearchRequest.init()
        request.keywords = currentKey
        request.requireSubPOIs = true
        request.requireExtension = true
        request.offset = 50
        request.page = currentPage
        
        if let location = currrentLocation {
            request.location = AMapGeoPoint.location(withLatitude: CGFloat(location.latitude), longitude: CGFloat(location.longitude));
        }
        request.types = "风景名胜|商务住宅|政府机构及社会团体|交通设施服务|公司企业|道路附属设施|地名地址信息";
        request.sortrule = 1;
        
        searchApi?.aMapPOIKeywordsSearch(request)
    }
    
    func loadMore() {
        if currentKey.count == 0 || datas.count == 0 {
            tableView.kf_footerView.endLoading()
            return
        }
        loadData(isMore: true)
    }
    
    func loadData(text:String) {
        if currentKey == text{ return }
        tableView.kf_footerView.reset()
        isLoadingNewData = true
        currentKey = text
        datas.removeAllObjects()
        tableView.reloadData()
        tableView.kf_footerView.backgroundColor = datas.count > 0 ? UIColor.white : UIColor.clear
        if text.count == 0 {
            isLoadingNewData = false
            return
        }
        loadData(isMore: false)
    }
    
}

//MARK: delegate
extension KMapSearchResultVc:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: KSearchResultCellId, for: indexPath) as! KSearchResultCell
        cell.poi = datas[indexPath.row] as? AMapPOI
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.resultVcDidSelectPoi(resultVc: self, poi: datas[indexPath.row] as! AMapPOI)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.resultVcDidScroll(resultVc: self)
    }
    
}

//MARK: UISearchResultsUpdating
extension KMapSearchResultVc: UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        searchController.searchResultsController?.view.isHidden = false
        guard let text = searchController.searchBar.text else { return }
        loadData(text: text)
    }
}

//MARK: AMapSearchDelegate
extension KMapSearchResultVc: AMapSearchDelegate{
    
    func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
        tableView.kf_footerView.endLoading()
        guard let rr = request as? AMapPOIKeywordsSearchRequest else{
            return;
        }
        
        if rr.keywords == nil || rr.keywords != currentKey {
            return;
        }
        isLoadingNewData = false
        KResultAttTool.share.key = currentKey
        if response.pois.count > 0 {
            for poi in response.pois {
                datas.add(poi)
            }
            tableView.reloadData()
        }else{
            tableView.kf_footerView.endWithNoMoreData()
        }
        tableView.kf_footerView.backgroundColor = datas.count > 0 ? UIColor.white : UIColor.clear
    }
    
    func aMapSearchRequest(_ request: Any!, didFailWithError error: Error!) {
        print("didFailWithError\(String(describing: error))")
    }
}
