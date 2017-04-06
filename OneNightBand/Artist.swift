//
//  Artist.swift
//  OneNightBand
//
//  Created by Thomas Threlkeld on 10/8/16.
//  Copyright © 2016 Thomas Threlkeld. All rights reserved.
//

import Foundation
import UIKit

class Artist: NSObject{
    var activeSessions: NSDictionary?
    var name: String?
    var email: String?
    var instruments = [String:Any]()
    var invites = [String:Any]()
    var password: String?
    var artistUID: String?
    var bio: String?
    var profileImageUrl = [String]()
    var location = [String:Any]()
    var media = [String]()
    var artistsBands: NSDictionary?
    var artistONBs: NSDictionary?
    var soloSessKeysOnFeed = [String]()
    
    
    
}
