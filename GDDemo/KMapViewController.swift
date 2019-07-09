//
//  KMapViewController.swift
//  GDDemo
//
//  Created by yxf on 2019/7/4.
//  Copyright © 2019 k_yan. All rights reserved.
//

import UIKit
import MAMapKit
import AMapSearchKit

class KMapViewController: UIViewController {
    lazy var mapView: MAMapView = {
        let mView = MAMapView.init(frame: CGRect.init());
        mView.delegate = self;
//        mView.zoomLevel = 13;//1km
        mView.zoomLevel = 15; //200m
        mView.runLoopMode = .default
        return mView;
    }()
    var pinView: MAAnnotationView?
    
    var positions: NSMutableArray = NSMutableArray.init();
    lazy var positionView: UITableView = {
        let listview = UITableView.init(frame: CGRect.init(), style: .plain);
        listview.delegate = self;
        listview.dataSource = self;
        listview.register(KPostionCell.self, forCellReuseIdentifier: KPostionCellId)
        listview.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: KScreenFrame.bottomSafeHeight(), right: 0);
        return listview;
    }()
    
    lazy var search: AMapSearchAPI? = {
        let search = AMapSearchAPI.init()
        search?.delegate = self;
        return search;
    }()
    ///地图每次请求的数量
    let dataNumberPerRequest = 20
    ///当前数据的page
    var currentDataPage = 1
    
    //map
    var currentLocation: CLLocation?
    var isFirstLoad = true
    var lastUserMovedCenterLocation: CLLocationCoordinate2D?
    
    //search
    var searchVc: UISearchController?
    var resultVc: KMapSearchResultVc?
    var currentRequest: AMapPOISearchBaseRequest?
    
    /// 搜索框的位置maxy
    var searchBarY: CGFloat = 0
    /// 在present SearchVc需要重新设置子视图的坐标，但是也会触发viewDidLayoutSubviews方法
    var isPresentSearchVc = false
    /// 在present SearchVc时会触发resultvc的scrollViewDidScroll
    var isChangingFrame = false
    
    // indicatorView
    lazy var indicatorView: UIActivityIndicatorView = {
        let indiView = UIActivityIndicatorView.init(style: .white)
        indiView.hidesWhenStopped = true
        indiView.color = UIColor.gray
        return indiView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.lightGray;
        self.navigationItem.title = "位置";
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: "取消", style: .plain, target: self, action: #selector(cancel));
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "确认", style: .plain, target: self, action: #selector(confirm));
        
        if #available(iOS 11.0, *) {
            positionView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false;
        }
        
        view.addSubview(positionView)
        view.addSubview(mapView);
        view.addSubview(indicatorView)
        
        positionView.kf_footerView = KFooterView.kf_footerView(loadingActionBlock: {[weak self] in
            self?.loadMore()
        });
        
        searchUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        mapView.showsUserLocation = true;
        mapView.userTrackingMode = .follow;
        if #available(iOS 11.0, *) {
            self.navigationItem.hidesSearchBarWhenScrolling = false;
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if isPresentSearchVc { return; }
        guard let searchBar = searchVc?.searchBar else { return }
        searchBarY = searchBar.frame.height + KScreenFrame.naviTopSafeHeight();
        resetFrame(mapY: searchBarY)
    }
    
    @objc class func mapVc() -> UIViewController {
        let vc = KMapViewController.init()
        let navi = UINavigationController.init(rootViewController: vc)
        return navi;
    }
    
}


///MARK: UI
extension KMapViewController{
    
    func resetFrame(mapY: CGFloat) {
        mapView.frame = CGRect.init(x: 0, y: mapY, width: KScreenFrame.screenWidth(), height: 200);
        positionView.frame = CGRect.init(x: 0, y: mapView.frame.maxY, width: KScreenFrame.screenWidth(), height: KScreenFrame.screenHeight() - mapView.frame.maxY);
        let size = indicatorView.frame.size;
        indicatorView.center = CGPoint.init(x: KScreenFrame.screenWidth() / 2, y: positionView.frame.minY + size.height / 2 + 10);
    }
    
    func pinViewAnimate() {
        guard let annoView = pinView else { return  }
        var frame = annoView.frame
        UIView.animate(withDuration: 0.2, animations: {
            frame.origin.y -= 10;
            annoView.frame = frame
        }) { (_) in
            UIView.animate(withDuration: 0.1, animations: {
                frame.origin.y += 10;
                annoView.frame = frame
            })
        }
    }
    
    func startIndiLoading() {
        if indicatorView.isAnimating{ return }
        indicatorView.startAnimating()
    }
    
    func stopIndiLoading() {
        if !indicatorView.isAnimating{ return }
        indicatorView.stopAnimating()
    }
    
    /// 改变地图的中心点
    func mapViewCenterChanged(location: CLLocationCoordinate2D) {
        mapView.centerCoordinate = location
        loadData(postion: location)
    }
}

///MARK: action
extension KMapViewController{
    @objc func cancel() {
        dismiss(animated: true, completion: nil);
    }
    
    @objc func confirm() {
        
    }
}

///MARK: data
extension KMapViewController{
    
    /// 加载数据
    func loadPositions(postion: CLLocationCoordinate2D,isLoadMore: Bool) {
        if let serchApi = search {
            currentDataPage = isLoadMore ? (currentDataPage + 1) : 1;
            let request = AMapPOIAroundSearchRequest.init()
            request.location = AMapGeoPoint.location(withLatitude: CGFloat(postion.latitude), longitude: CGFloat(postion.longitude));
            request.types = "风景名胜|商务住宅|政府机构及社会团体|交通设施服务|公司企业|道路附属设施|地名地址信息";
            request.sortrule = 0;
            request.requireExtension = true;
            request.page = currentDataPage
            currentRequest = request
            serchApi.aMapPOIAroundSearch(request)
        }
    }
    
    func loadMore() {
        if(indicatorView.isAnimating){
            return;
        }
        loadPositions(postion: mapView.centerCoordinate, isLoadMore: true)
    }
    
    func loadData(postion: CLLocationCoordinate2D) {
        
        //停止加载更多的动画与请求
        positionView.kf_footerView.endLoading()
        
        //大头针动画
        pinViewAnimate()
        
        //清空当前数据
        positions.removeAllObjects()
        positionView.reloadData();
        startIndiLoading()
        
        loadPositions(postion: postion, isLoadMore: false)
    }
}

extension KMapViewController: MAMapViewDelegate{
    /*更新逻辑
     1.第一次获取到当前坐标值的时候，去请求附近数据信息
     2.移动地图的偏移量中精度或者纬度超过了当前像素单位的大小，即判定为有效移动
     3.有效移动会实现一个定位动画，并请求数据
     4.用户主动移动地图才会加载新数据，并且给lastUserMovedCenterLocation赋值
     */
    func mapView(_ mapView: MAMapView!, didUpdate userLocation: MAUserLocation!, updatingLocation: Bool) {
        currentLocation = userLocation.location
        if isFirstLoad {
            isFirstLoad = false
            
            let anno = MAPointAnnotation.init()
            anno.coordinate = currentLocation!.coordinate
            anno.lockedScreenPoint = CGPoint.init(x: KScreenFrame.screenWidth() / 2, y: 100)
            anno.isLockedToScreen = true
            mapView.addAnnotation(anno)
            
            loadData(postion: userLocation.location.coordinate)
        }
        resultVc?.currrentLocation = userLocation.location.coordinate
    }
    
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        if !annotation.isMember(of: MAPointAnnotation.self) {
            return nil
        }
        let pointReuseIdentifier = "pointReuseIdentifier"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: pointReuseIdentifier)
        if annotationView == nil{
            annotationView = MAPinAnnotationView.init(annotation: annotation, reuseIdentifier: pointReuseIdentifier)
            annotationView?.canShowCallout = false;
            annotationView?.isDraggable = false;
            annotationView?.image = UIImage.init(named: "pin.png")
            annotationView?.centerOffset = CGPoint.init(x: 0.2, y: -14.2)
        }
        pinView = annotationView
        return annotationView
    }
    
    func mapView(_ mapView: MAMapView!, mapDidMoveByUser wasUserAction: Bool) {
        if !wasUserAction {
            return
        }
        if let lastCo = lastUserMovedCenterLocation {
            let delLong = (mapView.centerCoordinate.longitude - lastCo.longitude) * 110 * 1000;
            let delLati = (mapView.centerCoordinate.latitude - lastCo.latitude) * 110 * 1000;
            let meterPerPoint = mapView.metersPerPointForCurrentZoom;
            if fabs(delLong) > meterPerPoint || fabs(delLati) > meterPerPoint{
                loadData(postion: mapView.centerCoordinate)
            }
        }
        lastUserMovedCenterLocation = mapView.centerCoordinate
    }
    
    func mapView(_ mapView: MAMapView!, mapDidZoomByUser wasUserAction: Bool) {
        
    }
}

extension KMapViewController: AMapSearchDelegate{
    func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
        if let cr = currentRequest,cr != request {
            return;
        }
        for obj in response.pois {
            let poiObj = KPositionModel.init(with: obj)
            poiObj.isSelected = positions.count == 0
            positions.add(poiObj)
        }
        stopIndiLoading()
        positionView.kf_footerView.endLoading()
        positionView.reloadData()
    }
    
    func aMapSearchRequest(_ request: Any!, didFailWithError error: Error!) {
        print("请求附近数据失败:\(String(describing: error))")
        guard let rr = request as? AMapPOIAroundSearchRequest else { return }
        if let cr = currentRequest,cr != rr{
            return;
        }
    }
}

extension KMapViewController: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return positions.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: KPostionCellId, for: indexPath) as! KPostionCell
        cell.position = positions[indexPath.row] as? KPositionModel
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let poi = positions[indexPath.row] as! KPositionModel
        if poi.isSelected {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        guard let location = poi.poi?.location else {
            return
        }
        
        var lastIdx = 0
        for postion in positions {
            let obj = postion as! KPositionModel
            if obj.isSelected {
                lastIdx = positions.index(of: obj)
            }
            obj.isSelected = false
        }
        poi.isSelected = true
        tableView.beginUpdates()
        tableView.reloadRows(at: [indexPath,IndexPath.init(row: lastIdx, section: 0)], with: .automatic)
        tableView.endUpdates()
        
        
        let selectLocation = CLLocationCoordinate2D.init(latitude: CLLocationDegrees(location.latitude), longitude: CLLocationDegrees(location.longitude))
        mapView.centerCoordinate = selectLocation
        pinViewAnimate()
    }
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        needUpdate = false;
//        var pointY = scrollView.contentOffset.y;
//        var frame = mapView.frame
//        if pointY > -264 {
//            if pointY > -200{
//                pointY = -200
//            }
//            frame.size.height = 200 - (pointY + 264);
//        }else{
//            frame.size.height = 200;
//        }
//        mapView.frame = frame
//    }
    
}
