//
//  File.swift
//  VoiceLikeMe
//
//  Created by Alguz on 4/23/20.
//  Copyright © 2020 Andre Rosa. All rights reserved.
//

import Foundation

class Global {

    public static func IsJapanese() -> Bool {
                
        let preferredLanguage = NSLocale.preferredLanguages[0]
        
        if preferredLanguage.starts(with: "ja"){
            return true
        } else{
            return false
        }
    }
}
