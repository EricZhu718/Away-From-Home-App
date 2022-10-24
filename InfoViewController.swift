//
//  InfoViewController.swift
//  Rewrite June30
//
//  Created by Ricky Wang on 7/11/20.
//  Copyright © 2020 SALT Group. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController, UITextFieldDelegate {
    
    let username:String = "username"
    let schoolType:String = "middle or high school"
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var midOrHigh: UISegmentedControl!
    
    @available(iOS 13.0, *)
    @IBAction func Save(_ sender: Any) {
        UserDefaults.standard.set(textField.text, forKey: username)
        if midOrHigh.selectedSegmentIndex == 0{
            UserDefaults.standard.set("high school", forKey: schoolType)
        } else {
            UserDefaults.standard.set("middle school", forKey: schoolType)
        }
        view.removeFromSuperview()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.startTrackingLocaiton()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self
        // Do any additional setup after loading the view.
    }
    
    func textFieldShouldReturn(_ scoreText: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
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
