import Foundation
import UIKit
import MobileCoreServices
import TwitterKit

class PreviewViewController: BoothViewController, UITextViewDelegate {
    
    // MARK: members
    fileprivate var orientation:UIImageOrientation!
    
    // MARK: UI elements outlets
    @IBOutlet weak var previewImage: UIImageView!
    @IBOutlet weak var tweetTxt: UITextView!
    
    // MARK: overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        super.setupNav(true, enableSettings : false)
        
        // get image from photo
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] 
        let destinationPath = (documentsPath as NSString).appendingPathComponent("photobooth.jpg")
        
        let image = UIImage(contentsOfFile: destinationPath)
        previewImage.image = UIImage(cgImage: image!.cgImage!, scale: 1.0, orientation: orientation)

        let tap = UITapGestureRecognizer(target:self, action:#selector(PreviewViewController.share))
        self.view.addGestureRecognizer(tap)
        
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(PreviewViewController.reset))
        self.view.addGestureRecognizer(swipe)
        
        tweetTxt.text = SettingsViewController.Settings.tweetText
        tweetTxt.becomeFirstResponder();
        tweetTxt.alpha = 0.6
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       
    }
    
    // MARK: user gestures handlers
    @IBAction func didTouchTweetButton(_ sender: AnyObject) {
        self.share()
    }
    
    // MARK: selectors
    func share(){
        
        let status = tweetTxt.text
        let uiImage = self.previewImage.image
        
        let composer = TWTRComposer()
        
        composer.setText(status)
        composer.setImage(uiImage)
        composer.show(from: self) { (result) -> Void in
            
            if (result == TWTRComposerResult.cancelled) {
                
                self.showCamera()
            } else {
                
                print("Sending tweet!")
                sleep(3)
                self.showTweets()
            }
        }
        
        print("share")
    }
    
    func reset(){
        
        self.showCamera()
        print("reset")
    }
    
    // MARK: accessors
    var imageOrientation: UIImageOrientation {
        
        set(newImageOrientation) {
            
            orientation = newImageOrientation
        }
        
        get{
            
            return orientation
        }
    }
  
    // MARK: internal methods
    func showCamera() {
        
        self.navigationController?.popViewController(animated: true)
        self.performSegue(withIdentifier: "camera", sender: self);
    }
    
    func showTweets(){
        
        DispatchQueue.main.async(execute: {
            
            let controller = TweetViewController()
            self.show(controller, sender: self)
            
        });
        
    }
    
    func showSettings() {
        
        DispatchQueue.main.async(execute: {
            let controller = self.storyboard!.instantiateViewController(withIdentifier: "SettingsViewController") 
            self.show(controller, sender: self)
        });
        
    }
    
}
