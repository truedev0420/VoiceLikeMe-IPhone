//
//  RecorderVC.swift
//  PitchPerfect
//
//  Created by Andre Rosa on 07/12/2017.
//  Copyright © 2017 Andre Rosa. All rights reserved.
//

import UIKit
import AVFoundation

enum RecordingStatus : String {
    case Stopped, Paused, Recording;
}

class RecorderVC: UIViewController {
    
    var audioRecorder: AVAudioRecorder!
    
    let rawFileName         = "recorded.raw"
    let convertedFileName   = "recorded.cvr"
    
    
    var waveFilePath        : String!
    var audioEngine         : AVAudioEngine!
    var sampleRate          : Int32!
    
    var currentRecordingStatus : RecordingStatus!
        
    let helpUrl = "https://appbestsmile.com/affirmation/"
    
    
    @IBOutlet weak var recordBtn        : UIButton!
    @IBOutlet weak var stopRecordingBtn : UIButton!
    @IBOutlet weak var pauseBtn         : UIButton!
    @IBOutlet weak var playListBtn      : UIButton!
    @IBOutlet weak var helpBtn          : UIButton!
    
    @IBOutlet weak var recordingLabel   : UILabel!
    @IBOutlet weak var timerLabel       : UILabel!
    
    @IBOutlet weak var pausedImageWrapper: UIView!
    @IBOutlet weak var pausedImage: UIImageView!

    
    var counter = 0
    var timer = Timer()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateRecordingStatus(recording: RecordingStatus.Stopped)
    }
    lazy var recordingImage: UIImageView = {
        let recordingGif = UIImage.gifImageWithName("recording")
        let imageView = UIImageView(image: recordingGif)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.pausedImageWrapper.addSubview(imageView)
        imageView.widthAnchor.constraint(equalTo: self.pausedImageWrapper.widthAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: self.pausedImageWrapper.heightAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: self.pausedImageWrapper.trailingAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: self.pausedImageWrapper.topAnchor).isActive = true
        return imageView
    }()
    
    func customAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func updateRecordingStatus(recording: RecordingStatus){
        
        currentRecordingStatus = recording
        
        switch(recording){
        case .Stopped :
            recordingLabel.isHidden = false
            recordBtn.isHidden = false
            stopRecordingBtn.isHidden = true
            pauseBtn.isEnabled = false
            pauseBtn.setImage(UIImage(named: "ic_media_pause"), for: UIControlState.normal)
            pausedImage.isHidden = true
            recordingImage.isHidden = true
            
            resetTimer()
            break;

        case .Paused :
            recordingLabel.isHidden = true
            recordBtn.isHidden = true
            stopRecordingBtn.isHidden = false
            pauseBtn.isEnabled = true
            pauseBtn.setImage(UIImage(named: "ic_media_record"), for: UIControlState.normal)
            pausedImage.isHidden = false
            recordingImage.isHidden = true
            
            pauseTimer() 
            break
            
        case .Recording :
            recordingLabel.isHidden = true
            recordBtn.isHidden = true
            stopRecordingBtn.isHidden = false
            pauseBtn.isEnabled = true
            pauseBtn.setImage(UIImage(named: "ic_media_pause"), for: UIControlState.normal)
            pausedImage.isHidden = true
            recordingImage.isHidden = false
            
            startTimer()
            break
        }
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(UpdateTimer), userInfo: nil, repeats: true)
    }
    
    func pauseTimer() {
        timer.invalidate()
    }

    func resetTimer() {
        timer.invalidate()
        counter = 0
        timerLabel.text = "00:00:00"
    }
    
    @objc func UpdateTimer() {
        counter = counter + 1
        
        var seconds = counter
        let hours = counter / (60 * 60);
        seconds = seconds % (60 * 60);
        let minutes = seconds / 60;
        seconds = seconds % 60;
        
        timerLabel.text = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

extension RecorderVC: AVAudioRecorderDelegate{
    @IBAction func recordAudio(_ sender: Any) {
        
        updateRecordingStatus(recording: RecordingStatus.Recording)
        
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0] as String
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord, with:AVAudioSessionCategoryOptions.defaultToSpeaker)

        try! session.setActive(true)

        waveFilePath = dirPath
        
        
        let rawFilePath = waveFilePath + "/" + rawFileName
        print("Raw file path : " + rawFilePath)
        
        audioEngine = AVAudioEngine()
        startRecording()
    }
    
        
    
    func convertRawData()
    {
                
        let rawFilePath = waveFilePath + "/" + rawFileName
                
        do{
            let destFilePath = waveFilePath + "/" + convertedFileName
            let fileManager = FileManager.default

                      
            if(!fileManager.fileExists(atPath:destFilePath)){
                fileManager.createFile(atPath: destFilePath, contents:nil, attributes: nil)
            }
            
            let fileDestination = FileHandle(forWritingAtPath: destFilePath)
            fileDestination?.seekToEndOfFile()
            
            let data = try Data(contentsOf: URL(fileURLWithPath: rawFilePath))
            var pointer = data.withUnsafeBytes {
                    Array($0.bindMemory(to: Int16.self)).map(Int16.init(littleEndian:))
            }
            
            let buffer: UnsafeMutablePointer<Int16> = UnsafeMutablePointer(&pointer)
            let frameSize = 2048
            
            Speex_init((Int32)(frameSize * 2), sampleRate)
            
            var offset = 0
            var dataCount = frameSize
            let frameData = UnsafeMutablePointer<Int16>.allocate(capacity: frameSize)

            while(true){
                
                let range = offset..<offset + dataCount
                var converted : UnsafeMutablePointer<Int16>
                for i in range {
                    frameData[i - offset] = buffer[i]
                }
                                
                converted = Speex_preprocess(frameData)
                
                let convertedData: Data = Data(bytes: converted, count: frameSize * 2)
                fileDestination?.seekToEndOfFile()
                fileDestination?.write(convertedData)
                offset += dataCount

                if(offset + frameSize < data.count / 2 )
                {
                    dataCount = frameSize
                }
                else if(offset + dataCount == data.count / 2)
                {
                    break;
                }
                else{
                    dataCount = data.count / 2 - offset
                }
            }
            
            fileDestination?.closeFile()
        }catch{
            print("Error: \(error)")
        }
    }
    
    
    func startRecording()
    {
        let inputNode = audioEngine.inputNode
        let bus = 0
        
        deleteFiles()

        let inputFormat = inputNode.inputFormat(forBus: 0)
        print("inputFormat : " + String(inputFormat.sampleRate))
        sampleRate = Int32(inputFormat.sampleRate)
        
        
        let format = AVAudioFormat(commonFormat: AVAudioCommonFormat.pcmFormatInt16, sampleRate: inputFormat.sampleRate, channels: 1, interleaved: false)
        
        
        inputNode.installTap(onBus: bus, bufferSize: 2048, format: format) { // inputNode.inputFormat(forBus: bus)
            (buffer: AVAudioPCMBuffer!, time: AVAudioTime!) -> Void in

                let values = UnsafeBufferPointer(start: buffer.int16ChannelData![0], count: Int(buffer.frameLength))
//                self.convertFile(data : Array(values))
                self.saveRawData(data : Array(values))
        }

        audioEngine.prepare()

        do {
            try audioEngine.start()
        } catch {
            print("Error info: \(error)")
        }
    }
    
    
    func deleteFiles(){
        
        let destFilePath = waveFilePath + "/" + rawFileName
        let fileManager = FileManager.default

        if(fileManager.fileExists(atPath:destFilePath)){
            
            try! fileManager.removeItem(atPath: destFilePath)
        }
        
        
        let sourceFilePath = waveFilePath + "/" + convertedFileName
        if(fileManager.fileExists(atPath:sourceFilePath)){
            
            try! fileManager.removeItem(atPath: sourceFilePath)
        }
    }
    
    
    @IBAction func stopRecording(_ sender: Any) {
        
        updateRecordingStatus(recording : RecordingStatus.Stopped)
        
        audioEngine.stop()
        
        convertRawData()
        createWavFile();
        
//        let destFilePath = waveFilePath + "/" + convertedFileName
//        performSegue(withIdentifier: "stopRecordingSG", sender : URL(string : destFilePath))
    }
    
    @IBAction func pauseRecording(_ sender: Any) {
        
        switch(currentRecordingStatus){
        case .Recording :
                 updateRecordingStatus(recording : RecordingStatus.Paused)
                 audioEngine.pause()
                 break
                
        case .Paused :
                 updateRecordingStatus(recording : RecordingStatus.Recording)
                 do {
                     try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: AVAudioSessionCategoryOptions.mixWithOthers)
                 } catch {
                 }
                break
            default : break
        }
    }
    
    
    @IBAction func showHelp(_ sender: Any) {
        let url = URL(string:helpUrl)!
        UIApplication.shared.open(url)
    }
    
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        
        if flag {
            
//            let destFilePath = waveFilePath + "/" + convertedFileName
                        
//            performSegue(withIdentifier: "stopRecordingSG", sender: audioRecorder.url)
//            performSegue(withIdentifier: "stopRecordingSG", sender : URL(string : destFilePath))
            
        } else {
            customAlert(title: "Ops...", message: "Some problem happened recording.")
            print("ANDRE: Problem Recording")
        }
    }
    
    func saveRawData(data : [Int16]){
        
        let destFilePath = waveFilePath + "/" + rawFileName
        let fileManager = FileManager.default
    
        if(!fileManager.fileExists(atPath:destFilePath)){
            fileManager.createFile(atPath: destFilePath, contents:nil, attributes: nil)
        }
           
        let fileDestination = FileHandle(forWritingAtPath: destFilePath)
        fileDestination?.seekToEndOfFile()
            
        var rawData : [Int16] = data
        let buffer : UnsafeMutablePointer<Int16> = UnsafeMutablePointer<Int16>(&rawData)
        let values = UnsafeBufferPointer(start: (buffer), count: Int(data.count))
        let myData = Data(buffer: values)
    
        fileDestination?.write(myData)
        fileDestination?.closeFile()
    }
    
    
//    func convertFile(data : [Int16]) {
//
//        let destFilePath = waveFilePath + "/" + "converted.raw"
//        let fileManager = FileManager.default
//
//        if(!fileManager.fileExists(atPath:destFilePath)){
//            fileManager.createFile(atPath: destFilePath, contents:nil, attributes: nil)
//        }
//
//        let fileDestination = FileHandle(forWritingAtPath: destFilePath)
//
//        fileDestination?.seekToEndOfFile()
//
//        var rawData : [Int16] = data
//
//        Speex_init((Int32)(MemoryLayout.size(ofValue: rawData)), sampleRate)
//
//
//        let buffer : UnsafeMutablePointer<Int16> = Speex_preprocess(&rawData);
//        let values = UnsafeBufferPointer(start: (buffer), count: Int(data.count))
//        let myData = Data(buffer: values)
//
//        fileDestination?.write(myData)
//
////            fileDestination?.write(Data(bytes: &rawData, count: rawData.count))
//
//        fileDestination?.closeFile()
//
//        Speex_destroy()
//    }
    
    
    func createWavFile(){
        
        let sourceFilePath = waveFilePath + "/" + convertedFileName
        
        print("sourceFilePath : " + sourceFilePath)
        
        let fileSource = FileHandle(forReadingAtPath: sourceFilePath)

        do {
           let attribute = try FileManager.default.attributesOfItem(atPath: sourceFilePath)
           if let size = attribute[FileAttributeKey.size] as? UInt32 {
               
                print("filesize : " + String(size))
           }
        } catch {
           print("Error: \(error)")
        }
        
        
        let rawData = fileSource?.readDataToEndOfFile()
        
        let arFileManager = ARFileManager()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        let wavFileName = formatter.string(from: Date()) + ".wav"

        try! arFileManager.createWavFile(rawData : rawData!, filename : wavFileName, sampleRate : sampleRate)
                    
        fileSource?.closeFile()
    }
}
