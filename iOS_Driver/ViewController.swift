//
//  ViewController.swift
//  iOS_Driver
//
//  Created by Rey Cerio on 2017-05-27.
//  Copyright © 2017 Rey Cerio. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import CoreLocation

class DriverController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var trackerId = String()
    var locationManager = CLLocationManager()
    var userLocation: CLLocationCoordinate2D!
    var userLocationActive = false
    var values = [String: AnyObject]()
    let uid = Auth.auth().currentUser?.uid
    let location = CLLocationManager().location?.coordinate
    
    
    let mapView: MKMapView = {
        let map = MKMapView()
        return map
    }()
    
    lazy var pingLocButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Ping Location", for: .normal)
        button.addTarget(self, action: #selector(handlePingLocation), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLocationManager()
        mapView.delegate = self
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Ping", style: .plain, target: self, action: #selector(handlePingLocation))
        guard let lat = location?.latitude, let long = location?.longitude else {return}
        userLocation = CLLocationCoordinate2D(latitude: lat, longitude: long)
        setupView()
        checkIfUserExist()
        //hide ping location button, check database for a running ping, show button with appropriate title (ONLY FOR UBER BECAUSE YOU DONT WANT MULTIPLE ENTRY AND ALSO YOU CANT TO DELETE WHEN CANCEL CALL)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        checkIfUserExist()
    }
    
    func setupView() {
        view.addSubview(mapView)
        view.addConstraintsWithVisualFormat(format: "H:|[v0]|", views: mapView)
        view.addConstraintsWithVisualFormat(format: "V:|[v0]|", views: mapView)
    }
    
    func createAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            //self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func handlePingLocation() {
        guard let userId = Auth.auth().currentUser?.uid else {return}
        if self.userLocationActive == true {
            self.userLocationActive = false
            self.navigationItem.rightBarButtonItem?.tintColor = self.view.tintColor
            
            //self.pingLocButton.setTitle("Ping Location", for: .normal)
            self.handleRemoveLocEntry()
        } else  {
            Database.database().reference().child("CER_drivers").child(userId).observeSingleEvent(of: .value, with: { (snapshot) in
                let dictionary = snapshot.value as? [String: AnyObject]
                self.trackerId = dictionary?["trackerId"] as! String
                if self.trackerId == "Pending dispatcher acceptance" {
                    self.createAlert(title: "Not Authorized By Tracker", message: "Please ask dispatcher to add you.")
                } else {
                    self.navigationItem.rightBarButtonItem?.tintColor = .green
                    self.userLocationActive = true
                    self.handlePingAndSaveToDatabase(uid: userId)
                    self.handleSaveWithUniqueId()
                    self.handleDriverOnline()
                }
            }, withCancel: nil)
        }
    }
    
    func handleRemoveLocEntry() {
        guard let userId = uid else {return}
        let removeRef = Database.database().reference().child("CER_user_location").child(trackerId).child(userId)
        removeRef.removeValue(completionBlock: { (error, reference) in
            if error != nil {
                self.userLocationActive = false
                self.navigationItem.rightBarButtonItem?.tintColor = .green
                // self.pingLocButton.setTitle("Stop Ping", for: .normal)
                self.createAlert(title: "Cancel Ping Failed", message: "Please try again.")
            }
            let removeOnlineRef = Database.database().reference().child("CER_driver_online").child("\(self.trackerId)").child(userId)
            removeOnlineRef.removeValue()
            
        })
    }
    
    func handleDriverOnline() {  //checks if user is online
        
        guard let userId = Auth.auth().currentUser?.uid else {return}
        let date = String(describing: Date())
        
        values = ["uid": userId as AnyObject, "date": date as AnyObject, "user_online": "Yes" as AnyObject]
        
        let databaseRef = Database.database().reference().child("CER_driver_online").child(trackerId).child(userId)
        databaseRef.updateChildValues(values) { (error, reference) in
            
            if error != nil{
                print("Could not update Database!")
                return
            }
        }
    }
    
    func handlePingAndSaveToDatabase(uid: String) { //updates every time location changes
        
        guard let latitude = userLocation?.latitude else {return}
        let latString = String(describing: latitude)
        guard let longitude = userLocation?.longitude else {return}
        let longString = String(describing: longitude)
        let date = String(describing: Date())
        
        values = ["uid": uid as AnyObject, "date": date as AnyObject, "latitude": latString as AnyObject, "longitude": longString as AnyObject]
        
        let databaseRef = Database.database().reference().child("CER_user_location").child(trackerId).child(uid)
        databaseRef.updateChildValues(values) { (error, reference) in
            if error != nil{
                self.navigationItem.rightBarButtonItem?.tintColor = self.view.tintColor
                //self.pingLocButton.setTitle("Ping Location", for: .normal)
                self.createAlert(title: "Pinging Failed!", message: "Please try again.")
            }
        }
    }
    
    func handleSaveWithUniqueId(){ //save to database for admin records
        
        guard let userId = uid else {return}
        guard let latitude = userLocation?.latitude else {return}
        let latString = String(describing: latitude)
        guard let longitude = userLocation?.longitude else {return}
        let longString = String(describing: longitude)
        let date = String(describing: Date())
        let id = NSUUID().uuidString
        values = ["uid": userId as AnyObject, "date": date as AnyObject, "latitude": latString as AnyObject, "longitude": longString as AnyObject]
        let databaseRef = Database.database().reference().child("CER_saved_user_location").child(trackerId).child(userId).child(id)
        databaseRef.updateChildValues(values) { (error, reference) in
            if error != nil{
                self.navigationItem.rightBarButtonItem?.tintColor = self.view.tintColor
                //self.pingLocButton.setTitle("Ping Location", for: .normal)
                print(error ?? "unknown error")
            }
        }
    }
    
    func handleLogout() {
        do {
            try Auth.auth().signOut()
        } catch let err {
            print(err)
            return
        }
            locationManager.stopUpdatingLocation()
            let loginController = LoginController()
            present(loginController, animated: true, completion: nil)
    }
    
    func checkIfUserExist() {
        if Auth.auth().currentUser?.uid == nil {
            handleLogout()
        } else {
            
        }
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let userId = Auth.auth().currentUser?.uid else {return}
        if let location = manager.location?.coordinate {
            
            let userLocation2 = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            let region = MKCoordinateRegion(center: userLocation2, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            
            self.mapView.setRegion(region, animated: true)
            self.mapView.removeAnnotations(self.mapView.annotations)
            let annotation = MKPointAnnotation()
            annotation.coordinate = userLocation2
            annotation.title = "Driver Location"
            
            self.mapView.addAnnotation(annotation)
            
            let point1 = MKMapPointForCoordinate(userLocation)
            let point2 = MKMapPointForCoordinate(userLocation2)
            let distance = MKMetersBetweenMapPoints(point1, point2)
            
            if userLocationActive == true && distance > 50{
                handlePingAndSaveToDatabase(uid: userId)
                handleSaveWithUniqueId()
                userLocation = userLocation2
            }
        }
    }
}


