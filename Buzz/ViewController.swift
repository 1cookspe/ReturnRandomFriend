//
//  ViewController.swift
//  Buzz
//
//  Created by Android Studio on 2017-06-17.
//  Copyright © 2017 Spencer Cook. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseAuth
import FirebaseDatabase

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var idField: UITextField!
    let activityIndicator = UIActivityIndicatorView()


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func createAccount(_ sender: Any) {
        
        
        // ERROR CHECKING: First check that valid entries have been entered for the username, email, password, and photo
        if usernameField.text != "" && passwordField.text != "" && idField.text != "" && self.imageView.image != nil {
            // create user
            presentActivityBar(open: true)
            Auth.auth().createUser(withEmail: usernameField.text!, password: passwordField.text!, completion: {
            user, error in
                if error != nil { // error when making the account
                    print("There's an error")
                    print(error.debugDescription)
                    self.login()
                } else { // no error
                    print("Account created")
                    self.login()
                }
            })
        } else {
            
            showErrorAlert(title: "Invalid data", message: "Please input a valid username, email, photo, and password.")
        }
    }
    
    
    
    func login() {
        let email = usernameField.text!
        let password = passwordField.text!
        let username = idField.text!
        
        Auth.auth().signIn(withEmail: email, password: password, completion: {
            user, error in
            if error != nil { // there is an error in signing in, account already is incorrect, etc
                self.showErrorAlert(title: "Error", message: "Cannot be signed in. Check that you have the correct credientials, or you are not creating an already exisitng account")
                return
            }
            
            // signed in correctly
                
                // store image
                let imageName = NSUUID().uuidString
                let storageRef = Storage.storage().reference().child("ProfilePictures").child("\(imageName).png")
            
            // Check that image exists
                if let uploadData = UIImagePNGRepresentation(self.imageView.image!) {
                    storageRef.putData(uploadData, metadata: nil, completion: { (metadata, err) in
                        if err != nil {
                            return
                        }
                        
                        if let profilePhotoURL = metadata?.downloadURL()?.absoluteString {
                            let values = ["name": username, "email": email, "profilePicURL": profilePhotoURL]
                            self.saveUserIntoDatabase(uid: (user?.uid)!, values: values as [String : AnyObject])
                        }
                    })
                    
                }
    
        })
    }
    
    private func saveUserIntoDatabase(uid: String, values: [String: AnyObject]) {
        // SAVE USER INTO DATABASE
        let ref = Database.database().reference(fromURL: "https://buzz-782e5.firebaseio.com/")
        let usersReference = ref.child("users").child(uid)

        
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            if err != nil {
                return
            }
            
            print("User saved in database...")
            
            // move to the "Choose Random Friend" view controller
            self.performSegue(withIdentifier: "loggedIn", sender: nil)
            
        })
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "loggedIn" {
            let randomFriend = segue.destination as! RandomFriend
            randomFriend.title = "title"
        }
        
        presentActivityBar(open: false)
    }
    
    @IBAction func uploadPhoto(_ sender: Any) {
        
        // allow user to pick photo
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImage: UIImage?
        
        // give user option to edit photo
        if let chosenImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImage = chosenImage
        } else if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImage = editedImage
        }
        
        // set imageView as the image the user chooses from the library
        imageView.image = selectedImage
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Cancelled Picker...")
        dismiss(animated: true, completion: nil)
    }
    
    func presentActivityBar(open: Bool) {
        if open {
            // show buffer to let user know it is loading
            self.activityIndicator.center = self.view.center
            self.activityIndicator.hidesWhenStopped = true
            self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
            self.activityIndicator.color = UIColor.red
            self.view.addSubview(self.activityIndicator)
            self.activityIndicator.startAnimating()
            UIApplication.shared.beginIgnoringInteractionEvents()
        } else {
            self.activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
        }
    }
    
    func showErrorAlert(title: String, message: String) {
        // present an alert view if user creates error (eg. if they input invalid data)
        self.presentActivityBar(open: false)
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
        {
            (result : UIAlertAction) -> Void in
            print("You pressed OK")
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
}

