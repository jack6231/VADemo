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
    
    private(set) var avSpeechSynthesizer: AVSpeechSynthesizer
    
    private let locale = Locale(identifier: "en-US")
    
    override init() {
        avSpeechSynthesizer = AVSpeechSynthesizer()
        super.init()
        avSpeechSynthesizer.delegate = self
    }
    
    func ttsPlayWith(voiceText: String) {
        let voiceMessage = AVSpeechUtterance(string: voiceText)
        voiceMessage.volume = 1.0
        voiceMessage.voice = AVSpeechSynthesisVoice(language: locale.identifier)
        avSpeechSynthesizer.speak(voiceMessage)
    }
    
    deinit {
        print("345======== Audioplay deinit ==")
    }
}

extension AudioPlayer: AVSpeechSynthesizerDelegate {
    
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        print("345======== 语音播报开始")
    }
    
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        print("345======== 语音播报暂停")
//        synthesizer.continueSpeaking()
//        try? AVAudioSession.sharedInstance().setActive(true)
    }
    
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        let totalLength = utterance.speechString.count
        let isFinish = characterRange.location + characterRange.length >= totalLength
        print("345======== 语音播报 \(characterRange), isFinish: \(isFinish)")
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        print("345======== 语音播报取消")
    }
    
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        print("345======== 语音播报完成")
        AVAudioSession.printAudioSessionProperties()
        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            do {
                print("345======== set active false")
                try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            } catch {
                print("345======== set active false 失败: \(error)")
            }
        }
    }
}
