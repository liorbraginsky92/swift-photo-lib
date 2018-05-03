//
//  BoothViewController.swift
//  Photobooth
//
//  Created by Ryan Choi on 4/29/15.
//  Copyright (c) 2015 Matt Donnelly. All rights reserved.
//

import Foundation

import Foundation
import UIKit
import MobileCoreServices
import TwitterKit

class BoothViewController : UIViewController {
    
    @IBOutlet weak var navbar: UINavigationItem!
    
    // MARK: internal methods
    func setupNav(_ enableBackButton : Bool,
                           enableSettings : Bool = true, enableLogout : Bool = false){
        
        if let navigationController = self.navigationController {
            
            // Get the navigationBar.frame sizes
            let navHeight = navigationController.navigationBar.frame.height
            let navWidth = navigationController.navigationBar.frame.width
            
            // Create a border
            let navBorder = UIView(frame: CGRect(x: 0, y: navHeight - 2, width: navWidth, height: 2))
            navBorder.tag = 140
            
            // Change the border to blue
            navBorder.backgroundColor = UIColor(rgba: "#5EA9DD")
            navigationController.navigationBar.addSubview(navBorder)
        }
                            
        if (!enableBackButton){
            
            self.navigationItem.setHidesBackButton(true, animated: true)
        }
        
        if (enableSettings){
            
            // Append image to the navigation bar
            if let image = UIImage(named: "TwitterLogo") {
                
                let logoView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
                
                logoView.image = image.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                logoView.contentMode = UIViewContentMode.scaleAspectFit
                logoView.frame.origin.x = 10
                logoView.frame.origin.y = 8
                
                navbar.titleView = logoView
            }
            
            // Add a tap gesture to the navigation bar image to send the user to settings
            let recognizer = UITapGestureRecognizer(target: self, action: Selector(("showSettings")))
            self.navbar.titleView!.isUserInteractionEnabled = true
            self.navbar.titleView!.addGestureRecognizer(recognizer)
        }
        
        if enableLogout {
         
            // Append image to the navigation bar
            if let image = UIImage(named: "logout") {
                
                let logout: UIButton = UIButton(type: UIButtonType.custom)
                
                logout.setBackgroundImage(image, for: UIControlState())
                logout.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
                
                logout.addTarget(self, action: Selector(("logOut")), for: UIControlEvents.touchUpInside)

                navbar.rightBarButtonItem = UIBarButtonItem(customView: logout)
            }
        }
    }
    
    // MARK: accessors
    var navigationBarTitle:String {

        set (newVal) {

            navbar.title = newVal
        }
        
        get {
            
            return navbar.title ?? ""
        }
    
    }
    
    // MARK: ovverides
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        if let navigationController = self.navigationController,
                let border = navigationController.navigationBar.viewWithTag(140) {
        
                    let bounds = navigationController.navigationBar.bounds;
                    border.frame = CGRect(x: 0, y: bounds.height - 2, width: bounds.width, height: 2)
        }
    }
    
}
