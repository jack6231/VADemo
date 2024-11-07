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
    private let locale = Locale(identifier: "en-US")
    
    func ttsPlayWith(voiceText: String) {
        AVAudioSession.printAudioSessionProperties()
        let voiceMessage = AVSpeechUtterance(string: voiceText)
        voiceMessage.volume = 1.0
        voiceMessage.voice = AVSpeechSynthesisVoice(language: locale.identifier)
        self.avSpeechSynthesizer.speak(voiceMessage)
        AVAudioSession.printAudioSessionProperties()
    }
}

extension AudioPlayer: AVSpeechSynthesizerDelegate {
    
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        print("345======== 语音播报开始")
        AVAudioSession.printAudioSessionProperties()
    }
    
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        print("345======== 语音播报暂停")
    }
    
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        print("345======== 语音播报 \(characterRange)")
        //AVAudioSession.printAudioSessionProperties()
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        print("345======== 语音播报取消")
    }
    
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        print("345======== 语音播报完成")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // 延迟 1 秒
            AVAudioSession.printAudioSessionProperties()
            do {
                print("345======== set active false")
                try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
                AVAudioSession.printAudioSessionProperties()
            } catch {
                print("345======== set active false error:\(error)")
            }
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                let speech = AVSpeechSynthesizer()
                let voiceMessage = AVSpeechUtterance(string: "bey")
                voiceMessage.volume = 0
                speech.speak(voiceMessage)
                AVAudioSession.printAudioSessionProperties()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    AVAudioSession.printAudioSessionProperties()
                    try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
                    AVAudioSession.printAudioSessionProperties()
                }
            }
        }
    }
}
