//
//  PlayItem.swift
//  VoiceLikeMe
//
//  Created by Alguz on 4/18/20.
//  Copyright © 2020 Andre Rosa. All rights reserved.
//

import Foundation

class PlayItem {
    var filename: String = "ODC"
    var duration: String = "00:00"
    var filedate : String = "4/10/2020, 8:12:25 AM"
    
    init(filename : String, duration : String, filedate : String){

        self.filename = filename
        self.duration = duration
        self.filedate = filedate
    }
}
