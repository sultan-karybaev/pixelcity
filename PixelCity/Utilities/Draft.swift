////
////  ViewController.swift
////  PixelCity
////
////  Created by Sultan Karybaev on 9/26/18.
////  Copyright © 2018 Sultan Karybaev. All rights reserved.
////
//
//import UIKit
//import MapKit
//import CoreLocation
//import Alamofire
//import AlamofireImage
//
//class MapVC: UIViewController {
//
//    @IBOutlet weak var mapView: MKMapView!
//    @IBOutlet weak var pullUpViewHeightConstraint: NSLayoutConstraint!
//    @IBOutlet weak var pullUpView: UIView!
//
//    var locationManager = CLLocationManager()
//    let authorizationStatus = CLLocationManager.authorizationStatus()
//    let regionRadius: Double = 1000
//
//    var screenSize = UIScreen.main.bounds
//
//    var spinner: UIActivityIndicatorView?
//    var progressLabel: UILabel?
//
//    var flowLayout = UICollectionViewLayout()
//    var collectionView: UICollectionView?
//
//    var imageUrlArray = [String]()
//    var imageArray = [UIImage]()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        mapView.delegate = self
//        locationManager.delegate = self
//        configureLocationServices()
//        addDoubleTap()
//
//        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
//        collectionView?.register(PhotoCell.self, forCellWithReuseIdentifier: "photoCell")
//        collectionView?.delegate = self
//        collectionView?.dataSource = self
//        collectionView?.backgroundColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
//        //collectionView?.contentSize = CGSize(width: 40, height: 40)
//
//        pullUpView.addSubview(collectionView!)
//    }
//
//    func addSwipe() {
//        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(animateViewDown))
//        swipe.direction = .down
//        pullUpView.addGestureRecognizer(swipe)
//    }
//
//    func addDoubleTap() {
//        let double = UITapGestureRecognizer(target: self, action: #selector(dropPin(_:)))
//        double.numberOfTapsRequired = 2
//        double.delegate = self
//        mapView.addGestureRecognizer(double)
//    }
//
//    func animateViewUp() {
//        pullUpViewHeightConstraint.constant = 300
//        UIView.animate(withDuration: 0.3, animations: {
//            self.view.layoutIfNeeded()
//        })
//    }
//
//    @objc func animateViewDown() {
//        cancelAllSessions()
//        pullUpViewHeightConstraint.constant = 0
//        UIView.animate(withDuration: 0.3, animations: {
//            self.view.layoutIfNeeded()
//        })
//    }
//
//    func addSpinner() {
//        spinner = UIActivityIndicatorView()
//        spinner?.center = CGPoint(x: screenSize.width / 2 - (spinner?.frame.width)! / 2, y: 150)
//        spinner?.activityIndicatorViewStyle = .whiteLarge
//        spinner?.color = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
//        spinner?.startAnimating()
//        collectionView?.addSubview(spinner!)
//    }
//
//    func removeSpinner() {
//        if spinner != nil {
//            spinner?.removeFromSuperview()
//        }
//    }
//
//    func addProgressLabel() {
//        progressLabel = UILabel()
//        progressLabel?.frame = CGRect(x: screenSize.width / 2 - 100, y: 175, width: 200, height: 40)
//        progressLabel?.font = UIFont(name: "Avenir Next", size: 14)
//        progressLabel?.textColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
//        progressLabel?.textAlignment = .center
//        //progressLabel?.text = "12/40 PHOTOS LOADED"
//        collectionView?.addSubview(progressLabel!)
//    }
//
//    func removeProgressLabel() {
//        if progressLabel != nil {
//            progressLabel?.removeFromSuperview()
//        }
//    }
//
//    @IBAction func centerMapButtonPressed(_ sender: Any) {
//        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
//            centerMapOnUserLocation()
//        }
//    }
//
//}
//
//extension MapVC: MKMapViewDelegate {
//
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        if annotation is MKUserLocation {
//            return nil
//        }
//
//        let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
//        pinAnnotation.pinTintColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
//        pinAnnotation.animatesDrop = true
//        return pinAnnotation
//    }
//
//    func centerMapOnUserLocation() {
//        guard let coordinate = locationManager.location?.coordinate else { return }
//        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, regionRadius * 2, regionRadius * 2)
//        mapView.setRegion(coordinateRegion, animated: true)
//    }
//
//    @objc func dropPin(_ sender: UITapGestureRecognizer) {
//        removePin()
//        removeSpinner()
//        removeProgressLabel()
//        cancelAllSessions()
//
//        imageUrlArray = []
//        imageArray = []
//
//        collectionView?.reloadData()
//
//        animateViewUp()
//        addSwipe()
//        addSpinner()
//        addProgressLabel()
//
//        let touchPoint = sender.location(in: mapView)
//        let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
//
//        let annotation = DroppablePin(coordinate: touchCoordinate, identifier: "droppablePin")
//        mapView.addAnnotation(annotation)
//
//        //print(flickrURL(forApiKey: FLICKR_KEY, withAnnotation: annotation, andNumberOfPhotos: 40))
//
//        let coordinateRegion = MKCoordinateRegionMakeWithDistance(touchCoordinate, regionRadius * 2, regionRadius * 2)
//        mapView.setRegion(coordinateRegion, animated: true)
//
//        retrieveUrls(forAnnotation: annotation, handler: { bool in
//            if bool {
//                self.retrieveImages(handler: { success in
//                    if success {
//                        //self.removeSpinner()
//                        self.removeProgressLabel()
//                        self.collectionView?.reloadData()
//
//                        //self.collectionView?.reloadSections(IndexSet(integer: 0))
//                        //self.collectionView?.reloadItems(at: [IndexPath(item: 0, section: 0), IndexPath(item: 1, section: 0)])
//                        //self.collectionView!.reloadData()
//                        //self.collectionView!.collectionViewLayout.invalidateLayout()
//                        //self.collectionView!.layoutSubviews()
//                    }
//                })
//            }
//        })
//    }
//
//    func removePin() {
//        for annotation in mapView.annotations {
//            mapView.removeAnnotation(annotation)
//        }
//    }
//
//    func retrieveUrls(forAnnotation annotation: DroppablePin, handler: @escaping (_ status: Bool) -> ()) {
//        //imageUrlArray = []
//
//        let url = flickrURL(forApiKey: FLICKR_KEY, withAnnotation: annotation, andNumberOfPhotos: 40)
//        Alamofire.request(url).responseJSON(completionHandler: { response in
//            guard let json = response.result.value as? Dictionary<String, AnyObject> else { return }
//            let photosDict = json["photos"] as! Dictionary<String, AnyObject>
//            let photosDistArray = photosDict["photo"] as! [Dictionary<String, AnyObject>]
//            for photo in photosDistArray {
//                let farm = photo["farm"] as! Int
//                let id = photo["id"] as! String
//                //let isfamily = photo["isfamily"] as! Int
//                //let isfriend = photo["isfriend"] as! Int
//                //let ispublic = photo["ispublic"] as! Int
//                //let owner = photo["owner"] as! String
//                let secret = photo["secret"] as! String
//                let server = photo["server"] as! String
//                //let title = photo["title"] as! String
//                let postURL = "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_h_d.jpg"
//                self.imageUrlArray.append(postURL)
//            }
//            handler(true)
//        })
//    }
//
//    func retrieveImages(handler: @escaping (_ status: Bool) -> ()) {
//        //imageArray = []
//
//        for url in imageUrlArray {
//            Alamofire.request(url).responseImage(completionHandler: { response in
//                guard let image = response.result.value else { return }
//                self.imageArray.append(image)
//                self.progressLabel?.text = "\(self.imageArray.count)/40 IMAGES DOWNLOADED"
//
//                if self.imageArray.count == self.imageUrlArray.count {
//                    handler(true)
//                }
//            })
//        }
//    }
//
//    func cancelAllSessions() {
//        Alamofire.SessionManager.default.session.getTasksWithCompletionHandler({ (sessionDataTask, uploadData, downloadData) in
//            sessionDataTask.forEach({ $0.cancel() })
//            downloadData.forEach({ $0.cancel() })
//        })
//    }
//
//}
//
//extension MapVC: CLLocationManagerDelegate {
//
//    func configureLocationServices() {
//        if authorizationStatus == .notDetermined {
//            locationManager.requestAlwaysAuthorization()
//        } else {
//            return
//        }
//    }
//
//    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//        centerMapOnUserLocation()
//    }
//
//}
//
//extension MapVC: UIGestureRecognizerDelegate {
//
//}
//
//extension MapVC: UICollectionViewDelegate, UICollectionViewDataSource {
//
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return 1
//    }
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        print(imageArray.count)
//        print(imageArray)
//        return imageArray.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        print("guard \(indexPath.row)")
//        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotoCell else { return UICollectionViewCell() }
//        let imageFromIndex = imageArray[indexPath.row]
//        let imageView = UIImageView(image: imageFromIndex)
//        cell.addSubview(imageView)
//        print(cell)
//        return cell
//    }
//
//
//
//}
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
