//
//  AudioPlayer.swift
//  VADemo
//
//  Created by Jack on 2024/11/6.
//

import UIKit
import AVFoundation
import CallKit

class AudioPlayer: NSObject {
    
    private(set) lazy var avSpeechSynthesizer: AVSpeechSynthesizer = {
        let speech = AVSpeechSynthesizer()
        speech.delegate = self
        return speech
    }()
    
    func ttsPlayWith(voiceText: String) {
        let locale = Locale(identifier: "en-US")
        let voiceMessage = AVSpeechUtterance(string: voiceText)
        voiceMessage.volume = 1.0
        voiceMessage.voice = AVSpeechSynthesisVoice(language: locale.identifier)
        self.avSpeechSynthesizer.speak(voiceMessage)
    }
}

extension AudioPlayer: AVSpeechSynthesizerDelegate {
    
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        print("345======== 语音播报开始")
    }
    
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        print("345======== 语音播报暂停")
    }
    
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        //print("345======== 语音播报 \(characterRange)")
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        print("345======== 语音播报取消")
    }
    
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        print("345======== 语音播报完成")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { // 延迟 1 秒
            do {
                print("345======== set active false")
                try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            } catch {
                print("345======== set active false error:\(error)")
            }
        }
    }
}
