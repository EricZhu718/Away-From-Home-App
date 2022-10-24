//
//  ViewController.swift
//  Rewrite June30
//
//  Created by Ricky Wang on 6/30/20.
//  Copyright © 2020 SALT Group. All rights reserved.
//

import UIKit
import CoreLocation
@available(iOS 13.0, *)
class ViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var Home: UILabel!
    @IBOutlet weak var CurrentLoc: UILabel!
    @IBOutlet weak var CurrentTime: UILabel!
    @IBOutlet weak var TimeLeftOrArrive: UILabel!    
    @IBOutlet weak var ReopenStatus: UILabel!
    @IBOutlet weak var IsHome: UILabel!
    func displayAllData() {
        if UserDefaults.standard.bool(forKey: determinedHomeKey) {
            
            Home.text = (NSKeyedUnarchiver.unarchiveObject(with: UserDefaults.standard.object(forKey: self.homePlacemarksKey) as! Data) as! CLLocation).description
            TimeLeftOrArrive.text = "\((Date().timeIntervalSinceReferenceDate - UserDefaults.standard.double(forKey: dateLeftHome))/60)"
        } else {
            Home.text = "home not determined"
            TimeLeftOrArrive.text = "\((Date().timeIntervalSinceReferenceDate - UserDefaults.standard.double(forKey: lastChangeInLocTime))/60)"
        }
        
        if let currentLoc = UserDefaults.standard.object(forKey: self.lastLoc) as? Data {
            
            CurrentLoc.text = (NSKeyedUnarchiver.unarchiveObject(with: currentLoc) as! CLLocation).description
        } else {
            CurrentLoc.text = "current location unavailable"
        }
        
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        CurrentTime.text = "\(hour):\(minutes)"
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        ReopenStatus.text = "\(UserDefaults.standard.bool(forKey: appDelegate.leftForSchool))"
        
        IsHome.text = "\(UserDefaults.standard.bool(forKey: isHomeKey))"
    }
    @IBAction func SetHome(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if let url:URL = URL(string: "http://35.184.19.218:8000/find_school?latlng=\(appDelegate.getLastLoc().coordinate.latitude),\(appDelegate.getLastLoc().coordinate.longitude)"){
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
                    var encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: appDelegate.getLastLoc())
                    UserDefaults.standard.set(encodedData, forKey: appDelegate.homeLocation)
                    encodedData = NSKeyedArchiver.archivedData(withRootObject: manager.location!)
                    UserDefaults.standard.set(encodedData, forKey: self.lastLoc)
                    appDelegate.sendNotif(info: "found home at " + appDelegate.getLastLoc().description, title: "Detection Update")
                    
                    
                    
                    
                    UserDefaults.standard.set(true, forKey: self.isHomeKey)
                }
            } catch {
                // do nothing for now
            }
        } else {
            // do nothing
        }
    }
    
    
    let homePlacemarksKey:String = "home placemarks"
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
    
    let schoolType:String = "middle or high school"
    
    let username:String = "username"
    
    let childConsent:String = "child consented"
    
    let parentConsent:String = "Parent consented"
    
    var manager:CLLocationManager = CLLocationManager()
    
    var dateSinceLastOpen = 0.0// Date().timeIntervalSinceReferenceDate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // dateSinceLastOpen = Date().timeIntervalSinceReferenceDate
        
        if UserDefaults.standard.bool(forKey: childConsent) && UserDefaults.standard.bool(forKey: parentConsent){
            if let schoolType:String = UserDefaults.standard.string(forKey: schoolType){
                if let userID:String = UserDefaults.standard.string(forKey: username){
                    print(schoolType)
                    print(userID)
                } else {
                    print("no username")
                    popupInfoRequest()
                }
            } else {
                print("no school type")
                popupInfoRequest()
            }
        } else {
            popupInfoRequest()
            popupConsentRequest()
        }
        print("end view did load")
        print(UserDefaults.standard.string(forKey: username))
        let timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        displayAllData()
        // print(UserDefaults.standard.string(forKey: middleSchool))
        
    }
    
    @objc func timerAction() {
        displayAllData()
        
        // print(NSKeyedUnarchiver.unarchiveObject(with: UserDefaults.standard.object(forKey: self.lastLoc) as! Data) as! CLLocation)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // dateSinceLastOpen = Date().timeIntervalSinceReferenceDate
    }
    
    func popupConsentRequest(){
        let popUpConsent = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Consent Popup") as! ConsentViewController
        self.addChild(popUpConsent)
        popUpConsent.view.frame = self.view.frame
        
        self.view.addSubview(popUpConsent.view)
        popUpConsent.didMove(toParent: self)
    }
    
    
    func popupInfoRequest(){
        print("requested info")
        let main = UIStoryboard(name: "Main", bundle: nil)
        print("0")
        let popUpLogin = main.instantiateViewController(withIdentifier: "Login and School Type") as! InfoViewController
        print("1")
        self.addChild(popUpLogin)
        popUpLogin.view.frame = self.view.frame
        self.view.addSubview(popUpLogin.view)
        popUpLogin.didMove(toParent: self)
        print("end popup request")
    }
    
    // authorization must be granted first
    // continues (or starts) the procedure to determine the home of a person
    
}
