//
//  User.swift
//  TestAppFirebase
//
//  Created by MacBook on 13.01.2022.
//

import Foundation
import Firebase

struct User {

   
    let uid: String
    let email: String

    init(user: Firebase.User) {
        self.uid = user.uid
        self.email = user.email ?? ""
    }
}
