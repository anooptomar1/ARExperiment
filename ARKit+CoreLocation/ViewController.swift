//
//  ViewController.swift
//  ARKit+CoreLocation
//
//  Created by Andrew Hart on 02/07/2017.
//  Copyright © 2017 Project Dent. All rights reserved.
//

import UIKit
import SceneKit 
import MapKit
import CocoaLumberjack

class ViewController: UIViewController, MKMapViewDelegate, SceneLocationViewDelegate {
    let sceneLocationView = SceneLocationView()
    
    let mapView = MKMapView()
    var userAnnotation: MKPointAnnotation?
    var locationEstimateAnnotation: MKPointAnnotation?
    
    var updateUserLocationTimer: Timer?
    
    ///Whether to show a map view
    ///The initial value is respected
    var showMapView: Bool = false
    
    var centerMapOnUserLocation: Bool = true
    
    ///Whether to display some debugging data
    ///This currently displays the coordinate of the best location estimate
    ///The initial value is respected
    var displayDebugging = false
    
    var infoLabel = UILabel()
        
    var updateInfoLabelTimer: Timer?
    
    var labelContainerView = StoryView()
    
    var adjustNorthByTappingSidesOfScreen = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        
//        infoLabel.font = UIFont.systemFont(ofSize: 10)
//        infoLabel.textAlignment = .left
//        infoLabel.textColor = UIColor.white
//        infoLabel.numberOfLines = 0
//        sceneLocationView.addSubview(infoLabel)
//        
//        // Update the label every 0.1
//        updateInfoLabelTimer = Timer.scheduledTimer(
//            timeInterval: 0.1,
//            target: self,
//            selector: #selector(ViewController.updateInfoLabel),
//            userInfo: nil,
//            repeats: true)
        
        //Set to true to display an arrow which points north.
        //Checkout the comments in the property description and on the readme on this.
//        sceneLocationView.orientToTrueNorth = false
        
//        sceneLocationView.locationEstimateMethod = .coreLocationDataOnly
        sceneLocationView.showAxesNode = false
        sceneLocationView.locationDelegate = self
        
        if displayDebugging {
            sceneLocationView.showFeaturePoints = true
        }
        
        let pinCoordinate = CLLocationCoordinate2D(latitude: 43.64655, longitude: -79.4445287)
        let pinLocation = CLLocation(coordinate: pinCoordinate, altitude: 50)
//        let pinImage = UIImage(named: "pin")!
        let pinText = "#HipsterCop"
        let pinLocationNode = StoryAnnotationNode(location: pinLocation, text: pinText, deck: "Hipster Toronto police officer thinks dispensaries are overraided", image: "Hipster-Cop", date: "27 August 2017")
        sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: pinLocationNode)
        
        let pinCoordinate2 = CLLocationCoordinate2D(latitude: 43.6529562, longitude: -79.4155688)
        let pinLocation2 = CLLocation(coordinate: pinCoordinate2, altitude: 50)
        let pinText2 = "#Apartments"
        let pinLocationNode2 = StoryAnnotationNode(location: pinLocation2, text: pinText2, deck: "Couple has baby to get back at noisy neighbour", image: "Apartments", date: "15 May 2017")
        sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: pinLocationNode2)
        
        let pinCoordinate3 = CLLocationCoordinate2D(latitude: 43.713303, longitude: -79.394958)
        let pinLocation3 = CLLocation(coordinate: pinCoordinate3, altitude: 50)
        let pinText3 = "#Craiglist"
        let pinLocationNode3 = StoryAnnotationNode(location: pinLocation3, text: pinText3, deck: "Man gravely misunderstands Craigslist ad offering 'one nightstand'", image: "Craiglist", date: "15 April 2017")
        sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: pinLocationNode3)
        
        let pinCoordinate4 = CLLocationCoordinate2D(latitude: 43.6373712, longitude: 79.427477)
        let pinLocation4 = CLLocation(coordinate: pinCoordinate4, altitude: 50)
        let pinText4 = "#InstagramKid"
        let pinLocationNode4 = StoryAnnotationNode(location: pinLocation4, text: pinText4, deck: "Child sues parents for posting 'embarrassing' baby pictures on social media", image: "instagram-kid", date: "1 March 2017")
        sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: pinLocationNode4)
        
        let pinCoordinate5 = CLLocationCoordinate2D(latitude: 43.6454625, longitude: -79.386103)
        let pinLocation5 = CLLocation(coordinate: pinCoordinate5, altitude: 250)
        let pinText5 = "#SharingIsCaring"
        let pinLocationNode5 = StoryAnnotationNode(location: pinLocation5, text: pinText5, deck: "Man tries in vain to explain his nachos not for whole table",image: "nacho-sharing", date: "1 January 2017")
        sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: pinLocationNode5)
        
        view.addSubview(sceneLocationView)
        
        if showMapView {
            mapView.delegate = self
            mapView.showsUserLocation = true
            mapView.alpha = 0.8
            view.addSubview(mapView)
            
            updateUserLocationTimer = Timer.scheduledTimer(
                timeInterval: 0.5,
                target: self,
                selector: #selector(ViewController.updateUserLocation),
                userInfo: nil,
                repeats: true)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DDLogDebug("run")
        sceneLocationView.run()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        DDLogDebug("pause")
        // Pause the view's session
        sceneLocationView.pause()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        sceneLocationView.frame = CGRect(
            x: 0,
            y: 0,
            width: self.view.frame.size.width,
            height: self.view.frame.size.height)
        
        infoLabel.frame = CGRect(x: 6, y: 0, width: self.view.frame.size.width - 12, height: 14 * 4)
        
        
        if showMapView {
            infoLabel.frame.origin.y = (self.view.frame.size.height / 2) - infoLabel.frame.size.height
        } else {
            infoLabel.frame.origin.y = self.view.frame.size.height - infoLabel.frame.size.height
        }
        
        mapView.frame = CGRect(
            x: 0,
            y: self.view.frame.size.height / 2,
            width: self.view.frame.size.width,
            height: self.view.frame.size.height / 2)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.labelContainerView.removeFromSuperview()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    @objc func updateUserLocation() {
        if let currentLocation = sceneLocationView.currentLocation() {
            DispatchQueue.main.async {
                
                if let bestEstimate = self.sceneLocationView.bestLocationEstimate(),
                    let position = self.sceneLocationView.currentScenePosition() {
                    DDLogDebug("")
                    DDLogDebug("Fetch current location")
                    DDLogDebug("best location estimate, position: \(bestEstimate.position), location: \(bestEstimate.location.coordinate), accuracy: \(bestEstimate.location.horizontalAccuracy), date: \(bestEstimate.location.timestamp)")
                    DDLogDebug("current position: \(position)")
                    
                    let translation = bestEstimate.translatedLocation(to: position)
                    
                    DDLogDebug("translation: \(translation)")
                    DDLogDebug("translated location: \(currentLocation)")
                    DDLogDebug("")
                }
                
                if self.userAnnotation == nil {
                    self.userAnnotation = MKPointAnnotation()
                    self.mapView.addAnnotation(self.userAnnotation!)
                }
                
                UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.allowUserInteraction, animations: {
                    self.userAnnotation?.coordinate = currentLocation.coordinate
                }, completion: nil)
            
                if self.centerMapOnUserLocation {
                    UIView.animate(withDuration: 0.45, delay: 0, options: UIViewAnimationOptions.allowUserInteraction, animations: {
                        self.mapView.setCenter(self.userAnnotation!.coordinate, animated: false)
                    }, completion: {
                        _ in
                        self.mapView.region.span = MKCoordinateSpan(latitudeDelta: 0.0005, longitudeDelta: 0.0005)
                    })
                }
                
                if self.displayDebugging {
                    let bestLocationEstimate = self.sceneLocationView.bestLocationEstimate()
                    
                    if bestLocationEstimate != nil {
                        if self.locationEstimateAnnotation == nil {
                            self.locationEstimateAnnotation = MKPointAnnotation()
                            self.mapView.addAnnotation(self.locationEstimateAnnotation!)
                        }
                        
                        self.locationEstimateAnnotation!.coordinate = bestLocationEstimate!.location.coordinate
                    } else {
                        if self.locationEstimateAnnotation != nil {
                            self.mapView.removeAnnotation(self.locationEstimateAnnotation!)
                            self.locationEstimateAnnotation = nil
                        }
                    }
                }
            }
        }
    }
    
    @objc func updateInfoLabel() {
        if let position = sceneLocationView.currentScenePosition() {
            infoLabel.text = "x: \(String(format: "%.2f", position.x)), y: \(String(format: "%.2f", position.y)), z: \(String(format: "%.2f", position.z))\n"
        }
        
        if let eulerAngles = sceneLocationView.currentEulerAngles() {
            infoLabel.text!.append("Euler x: \(String(format: "%.2f", eulerAngles.x)), y: \(String(format: "%.2f", eulerAngles.y)), z: \(String(format: "%.2f", eulerAngles.z))\n")
        }
        
        if let heading = sceneLocationView.locationManager.heading,
            let accuracy = sceneLocationView.locationManager.headingAccuracy {
            infoLabel.text!.append("Heading: \(heading)º, accuracy: \(Int(round(accuracy)))º\n")
        }
        
        let date = Date()
        let comp = Calendar.current.dateComponents([.hour, .minute, .second, .nanosecond], from: date)
        
        if let hour = comp.hour, let minute = comp.minute, let second = comp.second, let nanosecond = comp.nanosecond {
            infoLabel.text!.append("\(String(format: "%02d", hour)):\(String(format: "%02d", minute)):\(String(format: "%02d", second)):\(String(format: "%03d", nanosecond / 1000000))")
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.labelContainerView.removeFromSuperview()
        
        let touch = touches.first
        var initialTouchLocation = CGPoint()
        initialTouchLocation = (touch?.location(in: sceneLocationView))!
        
        var hitTestOptions = [SCNHitTestOption: Any]()
        let results: [SCNHitTestResult] = sceneLocationView.hitTest(initialTouchLocation, options: hitTestOptions)
        for result in results {
            print(result)
//            if VirtualObject.isNodePartOfVirtualObject(result.node) {
            //                firstTouchWasOnObject = true
            //                break
            print("something touched")
            let parentNode = result.node.parent as! StoryAnnotationNode
            self.labelContainerView = (Bundle.main.loadNibNamed("StoryView", owner: self, options: nil)?.first as? StoryView)!
            self.labelContainerView.frame = CGRect(x: 10, y: self.view.frame.height - 110, width: self.view.frame.width - 20, height: 100)
            self.labelContainerView.alpha = 0
            self.labelContainerView.storyImage.image = UIImage(named: parentNode.image)
            self.labelContainerView.storyDate.text = parentNode.date
            self.labelContainerView.storyLabel.text = result.node.name
            UIView.animate(withDuration: 1.5, animations: {
                self.labelContainerView.alpha = 1.0
            })
            
            sceneLocationView.addSubview(self.labelContainerView)

        }
    }
    
    //MARK: MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        if let pointAnnotation = annotation as? MKPointAnnotation {
            let marker = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: nil)
            
            if pointAnnotation == self.userAnnotation {
                marker.displayPriority = .required
                marker.glyphImage = UIImage(named: "user")
            } else {
                marker.displayPriority = .required
                marker.markerTintColor = UIColor(hue: 0.267, saturation: 0.67, brightness: 0.77, alpha: 1.0)
                marker.glyphImage = UIImage(named: "compass")
            }
            
            return marker
        }
        
        return nil
    }
    
    //MARK: SceneLocationViewDelegate
    
    func sceneLocationViewDidAddSceneLocationEstimate(sceneLocationView: SceneLocationView, position: SCNVector3, location: CLLocation) {
        DDLogDebug("add scene location estimate, position: \(position), location: \(location.coordinate), accuracy: \(location.horizontalAccuracy), date: \(location.timestamp)")
    }
    
    func sceneLocationViewDidRemoveSceneLocationEstimate(sceneLocationView: SceneLocationView, position: SCNVector3, location: CLLocation) {
        DDLogDebug("remove scene location estimate, position: \(position), location: \(location.coordinate), accuracy: \(location.horizontalAccuracy), date: \(location.timestamp)")
    }
    
    func sceneLocationViewDidConfirmLocationOfNode(sceneLocationView: SceneLocationView, node: LocationNode) {
    }
    
    func sceneLocationViewDidSetupSceneNode(sceneLocationView: SceneLocationView, sceneNode: SCNNode) {
        
    }
    
    func sceneLocationViewDidUpdateLocationAndScaleOfLocationNode(sceneLocationView: SceneLocationView, locationNode: LocationNode) {
        
    }
}

extension DispatchQueue {
    func asyncAfter(timeInterval: TimeInterval, execute: @escaping () -> Void) {
        self.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(timeInterval * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: execute)
    }
}

extension UIView {
    func recursiveSubviews() -> [UIView] {
        var recursiveSubviews = self.subviews
        
        for subview in subviews {
            recursiveSubviews.append(contentsOf: subview.recursiveSubviews())
        }
        
        return recursiveSubviews
    }
}
