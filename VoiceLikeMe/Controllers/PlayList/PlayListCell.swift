//
//  PlayListCell.swift
//  VoiceLikeMe
//
//  Created by Alguz on 4/18/20.
//  Copyright © 2020 Andre Rosa. All rights reserved.
//

import UIKit
import AVFoundation

class PlayListCell: UICollectionViewCell, AVAudioPlayerDelegate {
    var item: PlayItem? {
        didSet {
            lbl_name.text = self.item?.filename
            lbl_length.text = self.item?.duration
            lbl_date.text = self.item?.filedate
            
            lbl_currentDuration.isHidden = true
        }
    }
    var viewController: PlayerVC!
    
    @IBOutlet weak var btn_play: UIButton!
    @IBOutlet weak var lbl_name: UILabel!
    @IBOutlet weak var lbl_date: UILabel!
    @IBOutlet weak var lbl_length: UILabel!
    @IBOutlet weak var lbl_currentDuration: UILabel!
    
    @IBOutlet weak var constraint_right: NSLayoutConstraint!
    @IBOutlet weak var progressBar: UIView!
    
    
    var playCount : Int = 1
    var player: AVAudioPlayer? = nil
    var timer: Timer? = nil
    var playing: Bool = false
    
    func stop() {
        
        player?.stop()
        self.progressBar.backgroundColor = UIColor(red: 1.0, green: 168 / 255, blue: 165 / 255, alpha: 0.0)
        playing = false
        self.constraint_right.constant = -self.bounds.width
        
        
        lbl_currentDuration.isHidden = true
        if let image = UIImage(named: "ic_play_arrow_grey") {
            self.btn_play.setBackgroundImage(image, for: .normal)
        }
    }
    
    func playOrPause(){
        
        if viewController.lastCell != self {
            viewController.lastCell?.stop()
        }
        
        if playing {
            player?.pause()
            
            if let image = UIImage(named: "ic_play_arrow_grey") {
                self.btn_play.setBackgroundImage(image, for: .normal)
            }
            
        } else {
            
            if viewController.lastCell != self {
                
                let filePath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0] as String

                try! player = AVAudioPlayer(contentsOf: URL(fileURLWithPath: filePath + "/" + (lbl_name.text)!))
                timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { timer in
                    
                    self.constraint_right.constant = -self.bounds.width * CGFloat(Float(self.player!.currentTime / self.player!.duration))
                    self.lbl_currentDuration.text = String(format: "%02d:%02d", Int(self.player!.currentTime) / 60, Int(self.player!.currentTime) % 60)
                }
                
                player?.delegate = self
            }
            
            player!.play()
            timer!.fire()
            viewController.lastCell = self
            
            lbl_currentDuration.isHidden = false
            
            if let image = UIImage(named: "ic_pause_grey") {
                self.btn_play.setBackgroundImage(image, for: .normal)
            }
            self.progressBar.backgroundColor = UIColor(red: 1.0, green: 168 / 255, blue: 165 / 255, alpha: 0.8)
        }
        
        playing = !playing
    }
    
    @IBAction func action_playToggle(_ sender: Any) {
        
        playCount = 1
        playOrPause()
    }
    
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
        stop()
        
        if playCount > 1 {
            playCount -= 1
            playOrPause()
        }
    }
    
    public func replay(playCount : Int){
        
        self.playCount = playCount
        self.playOrPause()
    }
}
