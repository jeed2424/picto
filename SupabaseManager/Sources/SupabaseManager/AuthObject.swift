//
//  File.swift
//  
//
//  Created by Jay on 2023-09-30.
//

import Foundation

public struct AuthObject {
    let email: String?
    let password: String?

    public init(email: String?, password: String?) {
        self.email = email
        self.password = password
    }
}
