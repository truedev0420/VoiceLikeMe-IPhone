//
//  PlayerVC.swift
//  VoiceLikeMe
//
//  Created by Alguz on 4/16/20.
//  Copyright © 2020 Andre Rosa. All rights reserved.
//

import UIKit

class PlayerVC: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var playList: [PlayItem] = [] {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
        // Do any additional setup after loading the view.
    }
    
    
    func loadData() {
        
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            
            for url in fileURLs {
                
                let filename : String = String(url.absoluteString.split(separator: "/").last!)
                if filename.contains("recorded") {
                    continue
                }
                
                let filedate = getFileDate(filename : filename)
                let playItem = PlayItem(filename: filename, duration: getFileDuration(filename:filename), filedate : filedate)
                playList.append(playItem)
                
                print("file length : " + getFileDuration(filename: filename))
            }
            
        } catch {
            print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
        }
    }
    
    
    func getFileDate(filename : String) ->String {
        
        var start = filename.index(filename.startIndex, offsetBy: 0)
        var end = filename.index(filename.startIndex, offsetBy: 4)
        var range = start..<end
        let year = filename[range]
        
        start = filename.index(filename.startIndex, offsetBy: 4)
        end = filename.index(start, offsetBy: 2)
        range = start..<end
        let month = String(Int(String(filename[range]))!)
        
        start = filename.index(filename.startIndex, offsetBy: 6)
        end = filename.index(start, offsetBy: 2)
        range = start..<end
        let date = String(Int(String(filename[range]))!)
        
        start = filename.index(filename.startIndex, offsetBy: 9)
        end = filename.index(start, offsetBy: 2)
        range = start..<end
        let hour = String(Int(String(filename[range]))!)
        
        start = filename.index(filename.startIndex, offsetBy: 11)
        end = filename.index(start, offsetBy: 2)
        range = start..<end
        let minute = String(Int(String(filename[range]))!)
        
        let hour_val = Int(hour)!
        
        var filedate = date + "/" + month + "/" + year + ", "
        
        if(hour_val > 13){
            filedate += String(hour_val - 12) + ":" + minute + " PM"
        }else{
            filedate += hour + ":" + minute + " AM"
        }
        
        return filedate
    }

    func getFileDuration(filename : String) ->String{
            
        let filePath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0] as String
        
        do {
           let attribute = try FileManager.default.attributesOfItem(atPath: filePath + "/" + filename)
            
           if let fileSize = attribute[FileAttributeKey.size] as? UInt32 {
               
                print("filesize : " + String(fileSize))
                let totalSeconds = ceil(Double(fileSize - 44) / 44100)
            
                let minutes = floor(totalSeconds / 60)
                let seconds = totalSeconds - 60  * minutes
                
                return String(format:"%02d:%02d", minutes, seconds)
           }
        } catch {
           print("Error: \(error)")
        }
        
        return ""
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func action_goto_recorderVC(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
}

extension PlayerVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return playList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlayListCell", for: indexPath) as! PlayListCell
        cell.item = playList[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 86)
    }
    
}


class PlayListCell: UICollectionViewCell {
    var item: PlayItem? {
        didSet {
            lbl_name.text = self.item?.filename
            lbl_length.text = self.item?.duration
            lbl_date.text = self.item?.filedate
        }
    }
    
    @IBOutlet weak var btn_play: UIButton!
    @IBOutlet weak var lbl_name: UILabel!
    @IBOutlet weak var lbl_date: UILabel!
    @IBOutlet weak var lbl_length: UILabel!
    @IBOutlet weak var btn_setting: UIButton!
    @IBOutlet weak var lbl_currentDuration: UILabel!
    
    @IBOutlet weak var constraint_right: NSLayoutConstraint!
    @IBOutlet weak var progressBar: UIView!
    
    @IBAction func action_playToggle(_ sender: Any) {
        progressBar.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
        constraint_right.constant = -self.bounds.width / 2
    }
}


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
