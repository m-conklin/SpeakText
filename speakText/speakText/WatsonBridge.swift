//
//  WatsonBridge.swift
//  speakText
//
//  Created by Martin Conklin on 2016-10-07.
//  Copyright © 2016 Martin Conklin. All rights reserved.
//

import Foundation
import SpeechToTextV1
import AVFoundation

class SpeechToTextBridge: NSObject {
    let speechToText = SpeechToText(username: "77b3137d-673a-4625-9ed9-e9be0b404902", password: "e8Y2hqO4lZla")
//    let audio = NSBundle.mainBundle().URLForResource("Test", withExtension: "wav")!
//    let a = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, false)
    
//    func synthesize(audio: NSURL) {
    
    var text:String?
    func startStreaming() {
        var settings = RecognitionSettings(contentType: .Opus)
        settings.continuous = true
        settings.interimResults = true
        let failure = { (error: NSError) in print(error) }
        _ = speechToText.recognizeMicrophone(settings, failure: failure) { results in
//            print(results.bestTranscript)
            self.passText(results.bestTranscript)
        }
//    func synthesize(audio: NSURL) {

        //        var settings = RecognitionSettings(contentType: .WAV)
//        settings.interimResults = false
//        let failure = { (error: NSError) in print(error) }
//        speechToText.recognize(audio, settings: settings, failure: failure) { results in
//            print(results.bestTranscript)
//            self.passText(results.bestTranscript)
//        }
    }
    
    func stopStreaming() {
        speechToText.stopRecognizeMicrophone()
    }
    
    func passText(text: String) {
        let nc = NSNotificationCenter.defaultCenter()
        let dictionary = ["text": text]
        nc.postNotificationName("TextReturnedFromWatson", object: nil, userInfo: dictionary)
    }
    
}
