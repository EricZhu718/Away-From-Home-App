//
//  AppDelegate.swift
//  Rewrite June30
//
//  Created by Ricky Wang on 6/30/20.
//  Copyright © 2020 SALT Group. All rights reserved.
//

import UIKit
import CoreLocation

@available(iOS 13.0, *)
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
    var window: UIWindow?

    
    let homeLocation:String = "home placemarks"
    // placemarks for the home
    
    let isHomeKey:String = "is at home"
    // if the app previously detected the user is at home
    
    let determinedHomeKey:String = "determined home"
    // whether we know the user's home or not
    
    let beganDeterminingHome:String = "began determining home"
    // whether we are in the middle of finding a person's home
    
    let lastChangeInLocTime:String = "last change in loc time"
    // last time (in seconds since january 2001) that we changed location
    
    let lastLoc:String = "last loc"
    // last location recorded
    
    let dateLeftHome:String = "left home date"
    // time left home
    
    let highSchool:String = "high school"
    // high school
    
    let middleSchool:String = "middle school"
    // high school
    
    let childConsent:String = "child consented"
    
    let parentConsent:String = "Parent consented"
    
    let leftForSchool:String = "left for school"
    
    var manager:CLLocationManager = CLLocationManager()
    
    let center = UNUserNotificationCenter.current()
    
    let username:String = "username"
    let schoolType:String = "middle or high school"
    
    
    var managerLoaded:Bool = false
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        print("App loaded")
        

        manager.delegate = self
        
        if !(CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways) {
            // am not authorized to take info
            askForAuthorizationIfNeeded()
        } else if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways && UserDefaults.standard.bool(forKey: childConsent) && UserDefaults.standard.bool(forKey: parentConsent)){
            managerLoaded = true
            startTrackingLocaiton()
        }
        
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
        }
        return true
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    /* react to change in authorization methods ------------------------------------------------------------------------------------------------------------------ */
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // responds to change in authorization
        
        askForAuthorizationIfNeeded()
    }
    func askForAuthorizationIfNeeded(){
        if CLLocationManager.authorizationStatus() == .authorizedAlways && UserDefaults.standard.bool(forKey: childConsent) && UserDefaults.standard.bool(forKey: parentConsent) {
            manager.startMonitoringSignificantLocationChanges()
            manager.allowsBackgroundLocationUpdates = true
            manager.pausesLocationUpdatesAutomatically = false
        } else if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            manager.requestAlwaysAuthorization()
        } else {
            manager.requestWhenInUseAuthorization()
            manager.requestAlwaysAuthorization()
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    /* react to change in location before home is determined methods ------------------------------------------------------------------------------------------------------------------ */
    
    func determineHomeProcedure(){
        // print("began determine home")
        if UserDefaults.standard.bool(forKey: beganDeterminingHome){
            if Date().timeIntervalSinceReferenceDate - UserDefaults.standard.double(forKey: lastChangeInLocTime) > 43200{
                hasBeen12Hours()
            } else {
                hasNotBeen12Hours()
            }
        } else {
            // starts by setting location
            if let loc = manager.location {
                let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: loc)
                UserDefaults.standard.set(encodedData, forKey: self.lastLoc)
                UserDefaults.standard.set(true, forKey: self.beganDeterminingHome)
                UserDefaults.standard.set(Date().timeIntervalSinceReferenceDate, forKey: self.lastChangeInLocTime)
                sendNotif(info: "Started recording your location. If you don't move in 12 hours, this will become your home", title: "Detection Update")
            }
        }
    }
    
    
    func hasBeen12Hours(){
        if !isSamePlace(locationOne: currentLocation!, locationTwo: getLastLoc()) {
            if let url:URL = URL(string: "http://35.184.19.218:8000/find_school?latlng=\(getLastLoc().coordinate.latitude),\(getLastLoc().coordinate.longitude)"){
                do {
                    let contents:String = try String(contentsOf: url)
                    if contents == "{\"error\":\"No HCPSS schools found for the given coordinates.\"}" || contents == "{\"error\":\"An error occurred.\"}" {
                        // do nothing for now
                        
                    } else {
                        let array:[String] = contents.components(separatedBy: ":")
                        var mid:String = array[1]
                        mid = mid.components(separatedBy: ",")[0]
                        mid = String(mid.prefix(mid.count-1))
                        mid = String(mid.suffix(mid.count-1))
                        UserDefaults.standard.set(mid,forKey: self.middleSchool)
                        var high:String = array[2]
                        high = String(high.prefix(high.count-2))
                        high = String(high.suffix(high.count-1))
                        UserDefaults.standard.set(high,forKey: self.highSchool)
                        UserDefaults.standard.set(true, forKey: self.determinedHomeKey)
                        UserDefaults.standard.set(Date().timeIntervalSinceReferenceDate, forKey: self.lastChangeInLocTime)
                        UserDefaults.standard.set(Date().timeIntervalSinceReferenceDate, forKey: self.dateLeftHome)
                        var encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: getLastLoc())
                        UserDefaults.standard.set(encodedData, forKey: self.homeLocation)
                        encodedData = NSKeyedArchiver.archivedData(withRootObject: currentLocation!)
                        UserDefaults.standard.set(encodedData, forKey: self.lastLoc)
                        sendNotif(info: "found home at " + getLastLoc().description, title: "Detection Update")
                    }
                } catch {
                    // do nothing for now
                }
            } else {
                // do nothing
            }
        }
    }
    
    
    func hasNotBeen12Hours(){
        if !isSamePlace(locationOne: currentLocation!, locationTwo: getLastLoc()) {
            let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: currentLocation!)
            UserDefaults.standard.set(encodedData, forKey: self.lastLoc)
            UserDefaults.standard.set(Date().timeIntervalSinceReferenceDate, forKey: self.lastChangeInLocTime)
            sendNotif(info: "changed current location, resetting timer for home detection", title: "Detection Update")
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    /* react to change in location after home is determined methods ------------------------------------------------------------------------------------------------------------------ */
    
    func recordChanges() {
        
        if UserDefaults.standard.bool(forKey: self.isHomeKey){
            if self.isHome(){
                // was at home last time, still at home now
                print("still at home")
            } else {
                // was at home last time, now not at home
                self.wasAtHomeNowNot()
            }
        } else {
            if self.isHome(){
                // was not at home last time, now at home
                self.wasNotAtHomeNowAm()
            } else {
                // was not at home last time, now at home
            }
            setLastLoc()
        }
    }
    
    
    
    // records whether the person is at home and sends info
    func wasAtHomeNowNot(){
        print("was at home now not")
        // indicates that person has left home, records time left home
        // if within the right time, will also set bool leftForSchool
        UserDefaults.standard.set(false, forKey: self.isHomeKey)
        UserDefaults.standard.set(Date().timeIntervalSinceReferenceDate, forKey: self.dateLeftHome)
        
        // school reopen part
        let date = Date()
        let calendar = Calendar.current
        
        if calendar.component(.weekday, from: date) > 1 && calendar.component(.weekday, from: date) < 7 {
            // if between the weekdays of monday and friday inclusive
            let hour = calendar.component(.hour, from: date)
            let minutes = calendar.component(.minute, from: date)
            if UserDefaults.standard.string(forKey: self.schoolType) == "middle school" {
                // 7:30 to 8:10
                if ((hour == 7 && minutes > 30) || (hour == 8 && minutes < 10)){
                    UserDefaults.standard.set(true, forKey: self.leftForSchool)
                }
            } else {
                
                // between 6:30 and 7:30
                if ((hour == 7 && minutes < 30) || (hour == 6 && minutes > 30)){
                    UserDefaults.standard.set(true, forKey: self.leftForSchool)
                }
            }
        }
        
        setLastLoc()
        
        
        // notification
        sendNotif(info: "left home "+currentLocation!.description, title: "Detection Update")
    }
    
    func wasNotAtHomeNowAm(){
        // posts necessary info to database/Data
        // posts information to database/reopen if necessary
        // records that you are now at home, sets bool leftForSchool to false, changes last location update time to now
        
        var postString:String = ""
        if UserDefaults.standard.string(forKey: self.schoolType) == "high school" {
            postString = "school=\(UserDefaults.standard.string(forKey: self.highSchool)!)&email=\(UserDefaults.standard.string(forKey: self.username)!)@inst.hcpss.org"
        } else {
            postString = "school=\(UserDefaults.standard.string(forKey: self.middleSchool)!)&email=\(UserDefaults.standard.string(forKey: self.username)!)@inst.hcpss.org"
        }
        postString += "&minutes_away="
        
        if UserDefaults.standard.bool(forKey: self.leftForSchool) {
            let date = Date()
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: date)
            let minutes = calendar.component(.minute, from: date)
            
            if UserDefaults.standard.string(forKey: self.schoolType) == "middle school"{
                if (hour > 15 || (hour == 15 && minutes > 20)){
                    postString+="\(60*(hour-15)+minutes-20)"
                    postStringToUrl(content: postString, webAddress: "http://stayhomeorder.org:8000/reopen")
                } else {
                    // do nothing
                }
            } else {
                if (hour >= 15 || (hour >= 14 && minutes >= 45)){
                    postString+="\(60*(hour-14)+minutes-45)"
                    postStringToUrl(content: postString, webAddress: "http://stayhomeorder.org:8000/reopen")
                } else {
                    // do nothing
                }
            }
        } else {
            postString+=String("\((Date().timeIntervalSinceReferenceDate-UserDefaults.standard.double(forKey: self.dateLeftHome))/60)".prefix(4))
            postStringToUrl(content: postString, webAddress: "http://stayhomeorder.org:8000/data")
        }
        
        // rewrites info
        UserDefaults.standard.set(Date().timeIntervalSinceReferenceDate, forKey: self.dateLeftHome)
        UserDefaults.standard.set(true, forKey: self.isHomeKey)
        UserDefaults.standard.set(false, forKey: self.leftForSchool)
        
        
        // notification
        sendNotif(info: "returned home", title: "Detection Update")
    }
    
    var currentLocation:CLLocation? = nil
    
    // if the location has changed
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        if locations[0].horizontalAccuracy < 100 {
            if !managerLoaded {
                currentLocation = locations[0]
                if UserDefaults.standard.bool(forKey: determinedHomeKey){
                    recordChanges()
                } else {
                    determineHomeProcedure()
                }
            } else {
                managerLoaded = false
            }
        }
    }
    
    
    
    
    
    
    
    
    
    
    /* compare location methods ------------------------------------------------------------------------------------------------------------------ */
    
    
    let maximumDistance:Double = 500
    func isHome() -> Bool {
        print("\(getLastLoc().coordinate), \(getHome().coordinate)")
        print("is home: \(currentLocation!.distance(from: getHome()) < maximumDistance)")
        return currentLocation!.distance(from: getHome()) < maximumDistance
    }
    
    func isSamePlace(locationOne: CLLocation, locationTwo: CLLocation) -> Bool {
        // print(locationOne.description + ", " + locationTwo.description)
        // print("same place: \(locationOne.distance(from: locationTwo) < maximumDistance)")
        return locationOne.distance(from: locationTwo) < maximumDistance
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    /* other methods ------------------------------------------------------------------------------------------------------------------ */
    
    func getLastLoc() -> CLLocation {
        return  NSKeyedUnarchiver.unarchiveObject(with: UserDefaults.standard.object(forKey: self.lastLoc) as! Data) as! CLLocation
    }
    
    func setLastLoc(){
        let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: currentLocation!)
        UserDefaults.standard.set(encodedData, forKey: self.lastLoc)
    }
    
    func getHome() -> CLLocation {
        return  NSKeyedUnarchiver.unarchiveObject(with: UserDefaults.standard.object(forKey: self.homeLocation) as! Data) as! CLLocation
    }
    
    func sendNotif(info:String, title:String){
        // send notification function
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = info
        content.sound = .default
        
        // 2
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: Date().description, content: content, trigger: trigger)
        
        // 3
        self.center.add(request, withCompletionHandler: nil)
        // print("notification sent")
    }
    
    func postStringToUrl(content:String, webAddress:String){
        // posts string content to the web address in the parameter
        let url = URL(string: webAddress)
        if let requestUrl = url {
            // Prepare URL Request Object
            var request = URLRequest(url: requestUrl)
            request.httpMethod = "POST"
            
            // Set HTTP Request Body
            request.httpBody = content.data(using: String.Encoding.utf8);
            // Perform HTTP Request
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                // Check for Error
                if let error = error {
                    self.sendNotif(info: "Error took place \(error)", title: "error sending url")
                    return
                }
                self.sendNotif(info: content, title: "Notification successfully sent")
            }
            task.resume()
        }
    }
    
    func startTrackingLocaiton() {
        // am authorized to take info
        manager.startMonitoringSignificantLocationChanges()
        // manager.startUpdatingLocation()
        manager.allowsBackgroundLocationUpdates = true
        manager.pausesLocationUpdatesAutomatically = false
        // determineHomeProcedure()
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.distanceFilter = kCLDistanceFilterNone
    }
    
    
    
    
    
    
    
    
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

