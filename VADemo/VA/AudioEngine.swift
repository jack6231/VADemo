//
//  VoiceAssistantAudioEngine.swift
//  VADemo
//
//  Created by Jack on 2024/11/6.
//

import UIKit
import AVFAudio
import CallKit

enum VoiceAssistantInterruptSomeReason {
    case wrongRecordRate // 采样率不一致
    case suspended // app 挂起，一般是闹钟，电话等操作打断
    case blueTooth // 蓝牙耳机或者插拔导致的问题
}

protocol AudioEngineDelegate : AnyObject {
    func audioEngine(_ audioEngine: AudioEngine, didReceiveBuffer buffer: AVAudioPCMBuffer, time: AVAudioTime)
    func audioEngine(_ audioEngine: AudioEngine, interrupted reason: VoiceAssistantInterruptSomeReason)
    func audioEngineEndInterrupted(_ audioEngine: AudioEngine)
}


class AudioEngine: NSObject {
    
    public weak var delegate: AudioEngineDelegate?
    private var audioEngine: AVAudioEngine?
    private var currentInputNode: AVAudioInputNode?
    private(set) var currentOutputFormat: AVAudioFormat?

    public func start() throws {
        if audioEngine == nil {
            audioEngine = AVAudioEngine()
        }
        addNotifications()
        installTap()
        audioEngine?.prepare()
        try audioEngine?.start()
    }
    
    public func restart() throws {
        destroy()
        try start()
    }
    
    public func stop() {
        audioEngine?.stop()
        currentOutputFormat = nil
        removeNotifications()
    }
    
    public func destroy() {
        stop()
        audioEngine = nil
        currentInputNode = nil
        currentOutputFormat = nil
    }
    
    public func isRunning() -> Bool{
        return audioEngine?.isRunning ?? false
    }
    
    private func installTap() {
        audioEngine?.inputNode.removeTap(onBus: 0)
        currentInputNode = audioEngine?.inputNode
        guard let inputFormat = currentInputNode?.inputFormat(forBus: 0),
              let outputFormat = currentInputNode?.outputFormat(forBus: 0) else {
            return
        }
        if inputFormat.sampleRate != outputFormat.sampleRate {
            let userInfo = [NSLocalizedDescriptionKey :  "Sample Rate Error", NSLocalizedFailureReasonErrorKey : "Voice Assistant Audio Engine inputFormat.sampleRate != outputFormat.sampleRate when install tap"]
            return
        }
        guard outputFormat.sampleRate > 0, outputFormat.channelCount > 0 else {
            let userInfo = [NSLocalizedDescriptionKey :  "Sample Rate Error", NSLocalizedFailureReasonErrorKey : "Assistant Audio outputFormat is not available"]
            return
        }
        currentOutputFormat = outputFormat
        currentInputNode?.installTap(onBus: 0, bufferSize: 1024, format: outputFormat, block: { [weak self] buffer, time in
            guard let `self` = self else { return }
            self.delegate?.audioEngine(self, didReceiveBuffer: buffer, time: time)
        })
    }
    
    private func addNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(audioEngineConfigChanged(noti:)), name: Notification.Name.AVAudioEngineConfigurationChange, object: audioEngine)
        NotificationCenter.default.addObserver(self, selector: #selector(audioSessionInterruption(noti:)), name: AVAudioSession.interruptionNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(audioSessionRouteChanged(noti:)), name: AVAudioSession.routeChangeNotification, object: nil)
    }
    
    private func removeNotifications() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.AVAudioEngineConfigurationChange, object: nil)
        NotificationCenter.default.removeObserver(self, name: AVAudioSession.routeChangeNotification, object: nil)
    }
    
    // 插拔耳机 断开/链接 蓝牙等
    @objc private func audioEngineConfigChanged(noti: NSNotification) {
        print("345======== audio engine 被打断1")
    }
    
    // 被打断 闹钟 电话等
    @objc private func audioSessionInterruption(noti: NSNotification) {
        print("345======== audio engine 被打断2")
        
    }
    //audio route 更换
    @objc private func audioSessionRouteChanged(noti: Notification) {
        print("345======== audio engine route change")
    }
}

