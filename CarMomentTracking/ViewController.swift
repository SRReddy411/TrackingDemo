//
//  ViewController.swift
//  CarMomentTracking
//
//  Created by volive solutions on 03/01/19.
//  Copyright © 2019 volive solutions. All rights reserved.
//

import UIKit
import GoogleMaps


class ViewController: UIViewController,ARCarMovementDelegate,CLLocationManagerDelegate, GMSMapViewDelegate {
    
    

    var momentCar = ARCarMovement()
     var coordinateArr = NSMutableArray()
    var coordinateFirstArr = [CLLocation]()
    var coordinateLastArr = [CLLocation]()
    
    var mapView:GMSMapView!
    var oldCoordinate = CLLocationCoordinate2D()
    var timer:Timer!
    var counter:NSInteger!
      var driverMarker = GMSMarker()
  
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
     
        momentCar.delegate = self
        
        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.requestAlwaysAuthorization()
        
        //alloc array and load coordinate from json file
        //
        if let path = Bundle.main.path(forResource: "coordinates", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                
               // coordinateArr.addObjects(from: [jsonResult])

                   //print("coordinate arra data ",coordinateArr)
            } catch {
                // handle error
            }
        }
       
        

        self.mapView = GMSMapView.init(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))

        self.view.addSubview(self.mapView)

        self.counter = 0
        
        //start the timer, change the interval based on your requirement
        //
      self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerTriggered), userInfo: nil, repeats: true)
        

        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.locationManager.stopUpdatingLocation()
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
  

        coordinateFirstArr.append(locations.first!)
        coordinateLastArr.append(locations.last!)
        print("coordinate arra ",coordinateFirstArr)
        print("coordinate arra count",coordinateLastArr)
        
        oldCoordinate = CLLocationCoordinate2DMake((locations.first!.coordinate.latitude), (locations.first!.coordinate.longitude))
        print("current location ",oldCoordinate.latitude,oldCoordinate.longitude)
      let camera = GMSCameraPosition.camera(withLatitude: oldCoordinate.latitude, longitude:oldCoordinate.longitude, zoom:15)
       mapView.animate(to: camera)
        momentCar.delegate = self
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
//        driverMarker.position = CLLocationCoordinate2DMake(oldCoordinate.latitude,oldCoordinate.longitude)
//        // driverMarker.position = CLLocationCoordinate2DMake(40.7416627,-74.0049708)
//        driverMarker.icon = UIImage.init(named: "car")
//       
//        driverMarker.map = self.mapView;

    }
    

    // Creates a marker in the center of the map.
    func showMarker(position: CLLocationCoordinate2D){
       
        driverMarker.position = position
         driverMarker.icon = UIImage.init(named: "car")
        driverMarker.map = self.mapView
    }
    
    
    //MARK:- TtimerTriggered Method
    
    @objc func timerTriggered() {
        
        if self.counter < self.coordinateLastArr.count {
            
//            let newCoordinate = CLLocationCoordinate2D(latitude: (self.coordinateArr.object(at: 0) as AnyObject).objectAt(self.counter)["lat"] as! CLLocationDegrees, longitude: (self.coordinateArr.object(at: 0) as AnyObject).objectAt(self.counter)["long"] as! CLLocationDegrees)
            
            
            
            let newCoordinate = CLLocationCoordinate2D(latitude: coordinateLastArr[self.counter].coordinate.latitude, longitude: coordinateLastArr[self.counter].coordinate.longitude)


            self.momentCar.ARCarMovement(marker: driverMarker, oldCoordinate: self.oldCoordinate, newCoordinate: newCoordinate, mapView: self.mapView, bearing: 0)
            //self.oldCoordinate = newCoordinate
            self.counter = self.counter + 1

        }else{
            self.timer.invalidate()
            self.timer = nil
        }
    }
        
      
    
    //MARK:- ARCarMoment delegate Methods
    
    func ARCarMovementMoved(_ Marker: GMSMarker) {
        
//        driverMarker.position = CLLocationCoordinate2D(latitude: oldCoordinate.latitude, longitude:oldCoordinate.longitude)
        driverMarker.position = CLLocationCoordinate2DMake(oldCoordinate.latitude,oldCoordinate.longitude)
        // driverMarker.position = CLLocationCoordinate2DMake(40.7416627,-74.0049708)
        driverMarker.icon = UIImage.init(named: "car")
        driverMarker = Marker;
        driverMarker.map = self.mapView;
        
        //animation to make car icon in center of the mapview
        //
        
        let upDateCamera = GMSCameraUpdate.setTarget(driverMarker.position, zoom: 15.0)
        self.mapView.animate(with: upDateCamera)
       
    }


}

