//
//  ConsentViewController.swift
//  Rewrite June30
//
//  Created by Ricky Wang on 7/11/20.
//  Copyright © 2020 SALT Group. All rights reserved.
//

import UIKit

class ConsentViewController: UIViewController {

    @IBOutlet weak var ChildConsent: UISegmentedControl!
    @IBOutlet weak var ParentConsent: UISegmentedControl!
    @available(iOS 13.0, *)
    @IBAction func ChildAction(_ sender: Any) {
        UserDefaults.standard.set(!UserDefaults.standard.bool(forKey: childConsent), forKey: childConsent)
        if UserDefaults.standard.bool(forKey: parentConsent) && UserDefaults.standard.bool(forKey: childConsent){
            let mainViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "Main View Controller") as! ViewController
            // mainViewController.popupInfoRequest()
            view.removeFromSuperview()
            
        }
        
        print("child consent: \(UserDefaults.standard.bool(forKey: childConsent))")
    }
    @IBAction func ParentAction(_ sender: Any) {
        UserDefaults.standard.set(!UserDefaults.standard.bool(forKey: parentConsent), forKey: parentConsent)
        if UserDefaults.standard.bool(forKey: parentConsent) && UserDefaults.standard.bool(forKey: childConsent){
            view.removeFromSuperview()

        }
        
        print("parent consent: \(UserDefaults.standard.bool(forKey: parentConsent))")
    }
    
    
    
    let childConsent:String = "child consented"
    let parentConsent:String = "Parent consented"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(UserDefaults.standard.bool(forKey: childConsent))")
        print("\(UserDefaults.standard.bool(forKey: parentConsent))")
        
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
