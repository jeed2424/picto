//
//  BaseService.swift
//  InstagramFirestoreTutorial
//
//  Created by Richard on 3/8/21.
//  Copyright © 2021 Stephan Dowless. All rights reserved.
//

import Foundation

class BaseService: NSObject {
    let APIService: ClientAPI
    
    init(api: ClientAPI) {
        APIService = api
    }
}
