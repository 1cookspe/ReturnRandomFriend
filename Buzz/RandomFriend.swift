//
//  RandomFriend.swift
//  Buzz
//
//  Created by Android Studio on 2017-06-17.
//  Copyright © 2017 Spencer Cook. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage

class RandomFriend: UIViewController {
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    let activityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameLabel.text = ""
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func getRandomFriend(_ sender: Any) {
        // show loading buffer to user
        showActivityBar(open: true)
        
        // create database reference and loop through entries of users
        let ref = Database.database().reference(fromURL: "https://buzz-782e5.firebaseio.com/")
        ref.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
            
            // objects in database
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                var counter = 0
                let number = snapshots.count
                
                // let's get the random number
                // this random number represents the random friend we will choose
                // so if the random number is 0, and Kramer is at the 0 index (ie. Kramer is the first friend in the database) then we will return Kramer
                let randomNumber = Int(arc4random_uniform(UInt32(number)))
                print(randomNumber)
                
                // loop through all the entries
                for snap in snapshots {
                    // when randomNumber hits the counter, we get the data from the user
                    if counter == randomNumber {

                        // set up variables to hold entries
                        var username: String = ""
                        var profilePhotoURL: String = ""
                        var profilePhoto:  UIImage?
                        
                        // get user, according to values in the database
                        if let dict = snap.value as? NSDictionary, let name = dict["name"] as? String, let url = dict["profilePicURL"] as? String {
                            username = name
                            profilePhotoURL = url
                            
                            // get image from firebase storage
                            let imgURL : NSURL = NSURL(string: profilePhotoURL)!
                            let request: NSURLRequest = NSURLRequest(url: imgURL as URL)
                            
                            // send url connection to download image from firebase storage, saved under "profilePicURL"
                            NSURLConnection.sendAsynchronousRequest(request as URLRequest, queue: OperationQueue.main, completionHandler: { (response, data, error) in
                                if error == nil {
                                    profilePhoto = UIImage(data: data!)
                                }
                                
                                // the username is stored in "username" and the profile photo stored in "profilePhoto"
                                // pass values to create friend to returnFriend method
                                self.returnFriend(username: username, image: profilePhoto!)
                            })
                            
                        }
                        
                        // stop loop because the random friend has been retrieved
                        break
                    }
                    
                    // increment counter as you move through the loop, which stops when the counter equals the random number and thus fetches the returned user
                    counter += 1
                    
                }
            }
        })

    }
    
    
    // called at end of closure to make object
    func returnFriend(username: String, image: UIImage) {
        // create friend instance with fetched username and photo
        let friend = Friend(username: username, profilePicture: image)
        // display friend username and photo to user
        self.usernameLabel.text = friend.getUsername()
        self.profilePicture.image = friend.getProfilePhoto()
        
        // stop loading
        showActivityBar(open: false)
    }
    
    func showActivityBar(open: Bool) {
        // loading bar
        if open {
            // show buffer to let user know it is loading
            self.activityIndicator.center = self.view.center
            self.activityIndicator.hidesWhenStopped = true
            self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
            self.activityIndicator.color = UIColor.red
            self.view.addSubview(self.activityIndicator)
            self.activityIndicator.startAnimating()
            UIApplication.shared.beginIgnoringInteractionEvents()
        } else { // stop showing
            self.activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
        }
    }
    
}
