//
//  PlayItem.swift
//  VoiceLikeMe
//
//  Created by Alguz on 4/18/20.
//  Copyright © 2020 Andre Rosa. All rights reserved.
//

import Foundation

class PlayItem : Comparable {
    
    var filename: String = "ODC"
    var duration: String = "00:00"
    var filedate : String = "4/10/2020, 8:12:25 AM"
    var fileCompareDate : String
    
    init(filename : String, duration : String, filedate : String, fileCompareDate : String){

        self.filename = filename
        self.duration = duration
        self.filedate = filedate
        self.fileCompareDate = fileCompareDate
    }
    
    static func ==(lhs: PlayItem, rhs: PlayItem) -> Bool {
        return lhs.fileCompareDate == rhs.fileCompareDate
    }

    static func <(lhs: PlayItem, rhs: PlayItem) -> Bool {
        return lhs.fileCompareDate > rhs.fileCompareDate
    }
    
    static func >(lhs: PlayItem, rhs: PlayItem) -> Bool {
        return lhs.fileCompareDate < rhs.fileCompareDate
    }
}
