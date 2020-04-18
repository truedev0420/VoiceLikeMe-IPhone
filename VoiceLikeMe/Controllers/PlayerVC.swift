//
//  PlayerVC.swift
//  VoiceLikeMe
//
//  Created by Alguz on 4/16/20.
//  Copyright © 2020 Andre Rosa. All rights reserved.
//

import UIKit
import AVFoundation

class PlayerVC: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    let DIALOG_TITLE = "Options"
    let OPTION_SHARE = "Share File"
    let OPTION_RENAME = "Rename File"
    let OPTION_DELETE = "Delete File"
    let OPTION_REPLAY = "Replay File"
    
    let DOCUMENT_ROOT = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0] as String

    
    var playList: [PlayItem] = [] {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    var lastCell: PlayListCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
        // Do any additional setup after loading the view.
        
        let longPressGR = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(longPressGR:)))
        longPressGR.minimumPressDuration = 0.5
        longPressGR.delaysTouchesBegan = true
        self.collectionView.addGestureRecognizer(longPressGR)
    }
    
    
    @objc
    func handleLongPress(longPressGR: UILongPressGestureRecognizer) {
        if longPressGR.state != .ended {
            return
        }

        let point = longPressGR.location(in: self.collectionView)
        let indexPath = self.collectionView.indexPathForItem(at: point)

        if let indexPath = indexPath {
            
//            var cell = self.collectionView.cellForItem(at: indexPath)
            
            
            // =====        Show Options Dialog         ===== //
            
            let dialog = SelectionDialog(title: DIALOG_TITLE, closeButtonTitle: "Close")
            
//            dialog.addItem(item: "I have icon :)",
//                           icon: UIImage(named: "Icon1")!)
            
            
            
            // =====        Share File          ===== //
            
            dialog.addItem(item: OPTION_SHARE, didTapHandler:  { () in
                                   
                dialog.close()

                let fileURL = NSURL(fileURLWithPath: self.DOCUMENT_ROOT + "/"  + self.playList[indexPath.row].filename)
                var filesToShare = [Any]()
                filesToShare.append(fileURL)
                
                let activityViewController = UIActivityViewController(activityItems: filesToShare, applicationActivities: nil)
                self.present(activityViewController, animated: true, completion: nil)
            })
            
            
            // =====         Rename File         ===== //
            
            dialog.addItem(item: OPTION_RENAME, didTapHandler:  { () in
            
                dialog.close()

                let alert = UIAlertController(title: "Rename File", message: "", preferredStyle: .alert)
                alert.addTextField { (textField) in
                    textField.text = self.playList[indexPath.row].filename
                }

                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                    let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
                    let newFileName = textField?.text
                    
                    let sourceFile = self.DOCUMENT_ROOT  + "/" + self.playList[indexPath.row].filename
                    let destFile = self.DOCUMENT_ROOT  + "/" + newFileName!
                    
                    do {
                        try FileManager.default.moveItem(atPath: sourceFile, toPath: destFile)
                    }
                    catch let error as NSError {
                        print("Ooops! Something went wrong: \(error)")
                    }
                    
                    self.loadData()
                    
                }))

                self.present(alert, animated: true, completion: nil)
            })
            
            
            // =====            Delete File         ===== //
            
            dialog.addItem(item: OPTION_DELETE, didTapHandler:  { () in
                
                dialog.close()
                
                let refreshAlert = UIAlertController(title: "Confirm Delete", message: "Are you sure you would like to delete this file?", preferredStyle: UIAlertControllerStyle.alert)

                refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                    
                    let destFilePath = self.DOCUMENT_ROOT + "/"  + self.playList[indexPath.row].filename
                    let fileManager = FileManager.default

                    if(fileManager.fileExists(atPath:destFilePath)){
                        
                        try! fileManager.removeItem(atPath: destFilePath)
                    }
                    
                    self.loadData()
                }))

                refreshAlert.addAction(UIAlertAction(title: "NO", style: .cancel, handler: { (action: UIAlertAction!) in
                  print("Handle Cancel Logic here")
                  }))

                self.present(refreshAlert, animated: true, completion: nil)
            })
            
            
            // =====            Replay File         ===== //
            
            dialog.addItem(item: OPTION_REPLAY, didTapHandler:  { () in
            
                dialog.close()

                let alert = UIAlertController(title: "Replay File", message: "", preferredStyle: .alert)
                alert.addTextField { (textField) in
                }

                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                    let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
                    let textValue = textField?.text!
                       
                    let currentCell : PlayListCell = self.collectionView.cellForItem(at: indexPath) as! PlayListCell
                    currentCell.replay(playCount: Int(textValue ?? "1") ?? 1)
                }))

                self.present(alert, animated: true, completion: nil)
            })
            dialog.show()

        } else {
            print("Could not find index path")
        }
    }
    
    func loadData() {
        
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        playList.removeAll()
        
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
            }
        } catch {
            print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
        }
    }
    
    
    func getFileDate(filename : String) ->String {
        
//        var start = filename.index(filename.startIndex, offsetBy: 0)
//        var end = filename.index(filename.startIndex, offsetBy: 4)
//        var range = start..<end
//        let year = filename[range]
//
//        start = filename.index(filename.startIndex, offsetBy: 4)
//        end = filename.index(start, offsetBy: 2)
//        range = start..<end
//        let month = String(Int(String(filename[range]))!)
//
//        start = filename.index(filename.startIndex, offsetBy: 6)
//        end = filename.index(start, offsetBy: 2)
//        range = start..<end
//        let date = String(Int(String(filename[range]))!)
//
//        start = filename.index(filename.startIndex, offsetBy: 9)
//        end = filename.index(start, offsetBy: 2)
//        range = start..<end
//        let hour = String(Int(String(filename[range]))!)
//
//        start = filename.index(filename.startIndex, offsetBy: 11)
//        end = filename.index(start, offsetBy: 2)
//        range = start..<end
//        let minute = String(Int(String(filename[range]))!)
//
//        let hour_val = Int(hour)!
//
//        var filedate = date + "/" + month + "/" + year + ", "
//
//        if(hour_val > 13){
//            filedate += String(hour_val - 12) + ":" + minute + " PM"
//        }else{
//            filedate += hour + ":" + minute + " AM"
//        }
        
        let filePath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0] as String
        
        if let attributes = try? FileManager.default.attributesOfItem(atPath: filePath + "/" + filename) as [FileAttributeKey: Any],
            let creationDate = attributes[FileAttributeKey.creationDate] as? Date {
            
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            let filedate = formatter.string(from: creationDate)
            return filedate
        }
        
        return ""
    }

    func getFileDuration(filename : String) ->String{
            
        let filePath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0] as String
        
        do {
           let attribute = try FileManager.default.attributesOfItem(atPath: filePath + "/" + filename)
            
           if let fileSize = attribute[FileAttributeKey.size] as? UInt32 {
               
                print("filesize : " + String(fileSize))
                let totalSeconds = ceil(Double(fileSize - 44) / 44100) / 2
            
                let minutes = floor(totalSeconds / 60)
                let seconds = totalSeconds - 60  * minutes
                
                let duration = String(format:"%02d:%02d", Int(minutes), Int(seconds))
                return duration
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
        cell.viewController = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 86)
    }
    
}
