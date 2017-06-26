//
//  Friend.swift
//  Buzz
//
//  Created by Android Studio on 2017-06-17.
//  Copyright © 2017 Spencer Cook. All rights reserved.
//

import Foundation
import UIKit

class Friend {
    private var username: String?
    private var profilePicture: UIImage?
    
    init(username: String, profilePicture: UIImage) {
        self.username = username
        self.profilePicture = profilePicture
    }
    
    func setUsername(username: String) {
        self.username = username
    }
    
    func setProfilePhoto(photo: UIImage) {
        self.profilePicture = photo
    }
    
    func getUsername() -> String {
        return self.username!
    }
    
    func getProfilePhoto() -> UIImage {
        return self.profilePicture!
    }
    
}

