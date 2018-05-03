//
// Copyright (C) 2015 Twitter, Inc. and other contributors.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//         http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import UIKit
import TwitterKit
import SafariServices

class AuthViewController: UIViewController {
    
    // MARK: initializers
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: overrides
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // TODO: check why the session is not recognized as nil
        let logInButton = TWTRLogInButton(logInCompletion: { session, error in
            if (session != nil) {

                self.showPhotoView()
            } else {
                
                self.alertWithTitle("Error", message: error!.localizedDescription)
                print("error: \(error!.localizedDescription)");
            }
        })
       
        self.view.addSubview(logInButton)
        logInButton.translatesAutoresizingMaskIntoConstraints = false
        
        var constraint =
        NSLayoutConstraint(item: logInButton,
            attribute: NSLayoutAttribute.centerY,
            relatedBy: NSLayoutRelation.equal,
            toItem: self.view,
            attribute: NSLayoutAttribute.centerY,
            multiplier: 1.0,
            constant: 0)
        
        self.view.addConstraint(constraint)

        constraint =
        NSLayoutConstraint(item: logInButton,
            attribute: NSLayoutAttribute.centerX,
            relatedBy: NSLayoutRelation.equal,
            toItem: self.view,
            attribute: NSLayoutAttribute.centerX,
            multiplier: 1.0,
            constant: 0)
        
        self.view.addConstraint(constraint)

    }
    
    // MARK: private methods
    func showPhotoView() {
        
        // ensure that presentViewController happens from the main thread/queue
        DispatchQueue.main.async(execute: {
            
            let controller = self.storyboard!.instantiateViewController(withIdentifier: "NavigationController") as! UINavigationController
            self.present(controller, animated: true, completion: nil)
        });
        
    }

    func alertWithTitle(_ title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }

}
