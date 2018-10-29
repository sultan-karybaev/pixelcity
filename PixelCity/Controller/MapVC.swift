//
//  MapVC.swift
//  pixel-city
//
//  Created by Caleb Stultz on 7/17/17.
//  Copyright © 2017 Caleb Stultz. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Alamofire
import AlamofireImage

class MapVC: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var pullUpViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var pullUpView: UIView!
    
    var locationManager = CLLocationManager()
    let authorizationStatus = CLLocationManager.authorizationStatus()
    let regionRadius: Double = 1000
    
    var screenSize = UIScreen.main.bounds
    
    var spinner: UIActivityIndicatorView?
    var progressLabel: UILabel?
    
    var flowLayout = UICollectionViewFlowLayout()
    var collectionView: UICollectionView?
    
    var pinterestLayout = PinterestLayout()
    
    var imageUrlArray = [String]()
    //var imageArray = [UIImage]()
    var imageArray: [UIImage] = [] {
        didSet {
            self.collectionView?.reloadData()
        }
    }
    
    let transition = PopAnimator()
    var selectedImage: UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        configureLocationServices()
        addGesture()
        
        //layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 10, right: 0)
        flowLayout.itemSize = CGSize(width: screenSize.width / 3 - 1, height: (screenSize.width / 3 - 1) / 9 * 16)
        flowLayout.scrollDirection = .vertical
        //flowLayout.scroll
        flowLayout.minimumInteritemSpacing = 1
        flowLayout.minimumLineSpacing = 1
        
        //collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: pinterestLayout)
        collectionView?.translatesAutoresizingMaskIntoConstraints = false
        collectionView?.register(PhotoCell.self, forCellWithReuseIdentifier: "photoCell")
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        let top = NSLayoutConstraint(item: collectionView!, attribute: .top, relatedBy: .equal, toItem: pullUpView, attribute: .top, multiplier: 1, constant: 0)
        let leading = NSLayoutConstraint(item: collectionView!, attribute: .leading, relatedBy: .equal, toItem: pullUpView, attribute: .leading, multiplier: 1, constant: 0)
        let trailing = NSLayoutConstraint(item: collectionView!, attribute: .trailing, relatedBy: .equal, toItem: pullUpView, attribute: .trailing, multiplier: 1, constant: 0)
        let bottom = NSLayoutConstraint(item: collectionView!, attribute: .bottom, relatedBy: .equal, toItem: pullUpView, attribute: .bottom, multiplier: 1, constant: 0)
        
        pullUpView.addSubview(collectionView!)
        pullUpView.addConstraints([top, leading, trailing, bottom ])
        pullUpView.layoutIfNeeded()
        
        for mapviewview in mapView.subviews {
            if let gestures = mapviewview.gestureRecognizers {
                for gest in gestures {
                    if let g = gest as? UITapGestureRecognizer, g.numberOfTapsRequired == 2 {
                        g.delegate = self
                        print(g)
                    }
                }
            }
        }
        
//        registerForPreviewing(with: self, sourceView: collectionView!)
//
//        pullUpView.addSubview(collectionView!)
    }
    
    func addGesture() {
        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(animateViewDown))
        singleTapGesture.numberOfTapsRequired = 1
        //singleTapGesture.delegate = self
        mapView.addGestureRecognizer(singleTapGesture)
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(dropPin(sender:)))
        doubleTapGesture.numberOfTapsRequired = 2
        //doubleTapGesture.delegate = self
        mapView.addGestureRecognizer(doubleTapGesture)
        
        singleTapGesture.require(toFail: doubleTapGesture)
    }
    
    func addSwipe() {
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(animateViewDown))
        swipe.direction = .down
        pullUpView.addGestureRecognizer(swipe)
    }
    
    func animateViewUp(coor: CLLocationCoordinate2D) {
        pullUpViewHeightConstraint.constant = 300
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        }, completion: { success in
            let annotation = DroppablePin(coordinate: coor, identifier: "droppablePin")
            self.mapView.addAnnotation(annotation)
            
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(coor, self.regionRadius * 2, self.regionRadius * 2)
            self.mapView.setRegion(coordinateRegion, animated: true)
        })
    }
    
    @objc func animateViewDown() {
        cancelAllSessions()
        pullUpViewHeightConstraint.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func addSpinner() {
        spinner = UIActivityIndicatorView()
        spinner?.center = CGPoint(x: (screenSize.width / 2) - ((spinner?.frame.width)! / 2), y: 150)
        spinner?.activityIndicatorViewStyle = .whiteLarge
        spinner?.color = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        spinner?.startAnimating()
        collectionView?.addSubview(spinner!)
    }
    
    func removeSpinner() {
        if spinner != nil {
            spinner?.removeFromSuperview()
        }
    }
    
    func addProgressLabel() {
        progressLabel = UILabel()
        progressLabel?.frame = CGRect(x: (screenSize.width / 2) - 120, y: 175, width: 240, height: 40)
        progressLabel?.font = UIFont(name: "Avenir Next", size: 14)
        progressLabel?.textColor = #colorLiteral(red: 0.2530381978, green: 0.2701380253, blue: 0.3178575337, alpha: 1)
        progressLabel?.textAlignment = .center
        collectionView?.addSubview(progressLabel!)
    }
    
    func removeProgressLabel() {
        if progressLabel != nil {
            progressLabel?.removeFromSuperview()
        }
    }
    
    @IBAction func centerMapBtnWasPressed(_ sender: Any) {
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
            centerMapOnUserLocation()
        }
    }
    
}

extension MapVC: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
        pinAnnotation.pinTintColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
        pinAnnotation.animatesDrop = true
        return pinAnnotation
    }

    func centerMapOnUserLocation() {
        guard let coordinate = locationManager.location?.coordinate else { return }
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, regionRadius * 2, regionRadius * 2)
        mapView.setRegion(coordinateRegion, animated: true)
    }

    @objc func dropPin(sender: UITapGestureRecognizer) {
        removePin()
        removeSpinner()
        removeProgressLabel()
        cancelAllSessions()

        imageUrlArray = []
        imageArray = []
        
        let touchPoint = sender.location(in: mapView)
        let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        let annotation = DroppablePin(coordinate: touchCoordinate, identifier: "droppablePin")
        if pullUpViewHeightConstraint.constant == 300 {
            mapView.addAnnotation(annotation)
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(touchCoordinate, regionRadius * 2, regionRadius * 2)
            mapView.setRegion(coordinateRegion, animated: true)
        } else {
            animateViewUp(coor: touchCoordinate)
        }
        
        addSwipe()
        addSpinner()
        addProgressLabel()
        
        print(mapView.region.span)
        let la = mapView.region.span.latitudeDelta
        let lo = mapView.region.span.longitudeDelta
        let deltaLatitude = Double(la)
        let deltaLongitude = Double(lo)
        let latitudeCircumference = 40075160 * cos(touchCoordinate.latitude * Double.pi / 180)
        let resultX = deltaLongitude * latitudeCircumference / 360
        let resultY = deltaLatitude * 40008000 / 360
        print(resultX, resultY)
        let zoom = log2(360 * Double(mapView.frame.size.width) / (mapView.region.span.longitudeDelta * 128))
        print("zoom \(zoom)")

        retrieveUrls(forAnnotation: annotation) { (finished) in
            if finished {
                self.removeSpinner()
                for url in self.imageUrlArray {
                    DispatchQueue.global().async {
                        Alamofire.request(url).responseImage(completionHandler: { (response) in
                            guard let image = response.result.value else { return }
                            self.imageArray.append(image)
//                            DispatchQueue.main.async {
//                                print("collectionView?.reloadData()")
//                                self.collectionView?.reloadData()
//                                self.collectionView?.collectionViewLayout.invalidateLayout()
//                            }
                        })
                    }
                }

            }
        }
    }

    func removePin() {
        for annotation in mapView.annotations {
            mapView.removeAnnotation(annotation)
        }
    }

    func retrieveUrls(forAnnotation annotation: DroppablePin, handler: @escaping (_ status: Bool) -> ()) {
        let url = flickrURL(forApiKey: FLICKR_KEY, withAnnotation: annotation, andNumberOfPhotos: 39)
        Alamofire.request(url).responseJSON(completionHandler: { response in
            guard let json = response.result.value as? Dictionary<String, AnyObject> else { return }
            //print(json)
            let photosDict = json["photos"] as! Dictionary<String, AnyObject>
            let photosDistArray = photosDict["photo"] as! [Dictionary<String, AnyObject>]
            for photo in photosDistArray {
                let farm = photo["farm"] as! Int
                let id = photo["id"] as! String
                //let isfamily = photo["isfamily"] as! Int
                //let isfriend = photo["isfriend"] as! Int
                //let ispublic = photo["ispublic"] as! Int
                //let owner = photo["owner"] as! String
                let secret = photo["secret"] as! String
                let server = photo["server"] as! String
                //let title = photo["title"] as! String
                let postURL = "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_h_d.jpg"
                self.imageUrlArray.append(postURL)
            }
            handler(true)
        })
    }

    func retrieveImages(handler: @escaping (_ status: Bool) -> ()) {
        for url in imageUrlArray {
            Alamofire.request(url).responseImage(completionHandler: { response in
                guard let image = response.result.value else { return }
                self.imageArray.append(image)
                self.progressLabel?.text = "\(self.imageArray.count)/40 IMAGES DOWNLOADED"

                if self.imageArray.count == self.imageUrlArray.count {
                    handler(true)
                }
            })
        }
    }

    func cancelAllSessions() {
        Alamofire.SessionManager.default.session.getAllTasks { (tasks) in
            tasks.forEach({$0.cancel()})
        }
        imageArray = []
        imageUrlArray = []
    }
}

extension MapVC: CLLocationManagerDelegate {

    func configureLocationServices() {
        if authorizationStatus == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        } else {
            return
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        centerMapOnUserLocation()
    }

}

extension MapVC: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let g = gestureRecognizer as? UITapGestureRecognizer, g.numberOfTapsRequired == 2 {
            return false
        }
        return true
    }
}

extension MapVC: UICollectionViewDelegate, UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotoCell else { return UICollectionViewCell() }
        let imageView = Photo(image: self.imageArray[indexPath.item])
        imageView.tag = 100
        let top = NSLayoutConstraint(item: imageView, attribute: .top, relatedBy: .equal, toItem: cell, attribute: .top, multiplier: 1, constant: 0)
        let leading = NSLayoutConstraint(item: imageView, attribute: .leading, relatedBy: .equal, toItem: cell, attribute: .leading, multiplier: 1, constant: 0)
        let trailing = NSLayoutConstraint(item: imageView, attribute: .trailing, relatedBy: .equal, toItem: cell, attribute: .trailing, multiplier: 1, constant: 0)
        let bottom = NSLayoutConstraint(item: imageView, attribute: .bottom, relatedBy: .equal, toItem: cell, attribute: .bottom, multiplier: 1, constant: 0)
        cell.addSubview(imageView)
        cell.addConstraints([top, leading, trailing, bottom])
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? PhotoCell else {return}
        selectedImage = cell.viewWithTag(100) as? UIImageView
        
        guard let popVC = storyboard?.instantiateViewController(withIdentifier: "PopVC") as? PopVC else { return }
        popVC.initData(forImag: imageArray[indexPath.item])
        popVC.transitioningDelegate = self
        present(popVC, animated: true, completion: nil)
    }

}

extension MapVC: UIViewControllerPreviewingDelegate {
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = collectionView?.indexPathForItem(at: location), let cell = collectionView?.cellForItem(at: indexPath) else { return nil }
        guard let popVC = storyboard?.instantiateViewController(withIdentifier: "PopVC") as? PopVC else { return nil }
        popVC.initData(forImag: imageArray[indexPath.row])
        previewingContext.sourceRect = cell.contentView.frame
        return popVC
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
}

extension MapVC: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.originFrame = selectedImage!.superview!.convert(selectedImage!.frame, to: nil)
        transition.presenting = true
        selectedImage?.isHidden = true
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.presenting = false
        return transition
    }
}


























