//
//  MediaUtil.swift
//  VoiceLikeMe
//
//  Created by Alguz on 4/17/20.
//  Copyright © 2020 Andre Rosa. All rights reserved.
//

import Foundation

class MediaUtil {

    private static func dataToUTF8String(data: NSData, offset: Int, length: Int) -> String? {
        let range = NSMakeRange(offset, length)
        let subdata = data.subdata(with: range)
        return String(data: subdata, encoding: String.Encoding.utf8)
    }

    private static func dataToUInt32(data: NSData, offset: Int) -> Int {
        var num: UInt32 = 0
        let length = 4
        let range = NSMakeRange(offset, length)
        data.getBytes(&num, range: range)
        return Int(num)
    }

    static func repairWAVHeader(data: NSMutableData)->Data {

        // resources for WAV header format:
        // [1] http://unusedino.de/ec64/technical/formats/wav.html
        // [2] http://soundfile.sapp.org/doc/WaveFormat/

        var newData = Data()

        // update RIFF chunk size
        let fileLength = data.length
        var riffChunkSize = UInt32(fileLength - 8)
        let riffChunkSizeRange = NSMakeRange(4, 4)
        data.replaceBytes(in: riffChunkSizeRange, withBytes: &riffChunkSize)

        // find data subchunk
        var subchunkID: String?
        var subchunkSize = 0
        var fieldOffset = 12
        let fieldSize = 4
        while true {
            // prevent running off the end of the byte buffer
            if fieldOffset + 2*fieldSize >= data.length {
                return newData
            }

            // read subchunk ID
            subchunkID = dataToUTF8String(data: data, offset: fieldOffset, length: fieldSize)
            fieldOffset += fieldSize
            if subchunkID == "data" {
                break
            }

            // read subchunk size
            subchunkSize = dataToUInt32(data: data, offset: fieldOffset)
            fieldOffset += fieldSize + subchunkSize
        }

        let rllrRange = NSMakeRange(0, fieldOffset)

        data.replaceBytes(in: rllrRange, withBytes: nil, length: 0)
        newData = newWavHeader(pcmDataLength: data.length)
        newData.append(data as Data)
        return newData
    }

    private static func newWavHeader(pcmDataLength: Int) -> Data {
        var header = Data()
        let headerSize = 44
        let bitsPerSample = Int32(16)
        let numChannels: Int32 = 1
        let sampleRate: Int32 = 16000

        // RIFF chunk descriptor
        let chunkID = [UInt8]("RIFF".utf8)
        header.append(chunkID, count: 4)

        var chunkSize = Int32(pcmDataLength + headerSize - 4).littleEndian
        let chunkSizePointer = UnsafeBufferPointer(start: &chunkSize, count: 1)
        header.append(chunkSizePointer)

        let format = [UInt8]("WAVE".utf8)
        header.append(format, count: 4)

        // "fmt" sub-chunk
        let subchunk1ID = [UInt8]("fmt ".utf8)
        header.append(subchunk1ID, count: 4)

        var subchunk1Size = Int32(16).littleEndian
        let subchunk1SizePointer = UnsafeBufferPointer(start: &subchunk1Size, count: 1)
        header.append(subchunk1SizePointer)

        var audioFormat = Int16(1).littleEndian
        let audioFormatPointer = UnsafeBufferPointer(start: &audioFormat, count: 1)
        header.append(audioFormatPointer)

        var headerNumChannels = Int16(numChannels).littleEndian
        let headerNumChannelsPointer = UnsafeBufferPointer(start: &headerNumChannels, count: 1)
        header.append(headerNumChannelsPointer)

        var headerSampleRate = Int32(sampleRate).littleEndian
        let headerSampleRatePointer = UnsafeBufferPointer(start: &headerSampleRate, count: 1)
        header.append(headerSampleRatePointer)

        var byteRate = Int32(sampleRate * numChannels * bitsPerSample / 8).littleEndian
        let byteRatePointer = UnsafeBufferPointer(start: &byteRate, count: 1)
        header.append(byteRatePointer)

        var blockAlign = Int16(numChannels * bitsPerSample / 8).littleEndian
        let blockAlignPointer = UnsafeBufferPointer(start: &blockAlign, count: 1)
        header.append(blockAlignPointer)

        var headerBitsPerSample = Int16(bitsPerSample).littleEndian
        let headerBitsPerSamplePointer = UnsafeBufferPointer(start: &headerBitsPerSample, count: 1)
        header.append(headerBitsPerSamplePointer)

        // "data" sub-chunk
        let subchunk2ID = [UInt8]("data".utf8)
        header.append(subchunk2ID, count: 4)

        var subchunk2Size = Int32(pcmDataLength).littleEndian
        let subchunk2SizePointer = UnsafeBufferPointer(start: &subchunk2Size, count: 1)

        header.append(subchunk2SizePointer)

        return header
    }
}
