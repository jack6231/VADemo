//
//  AudioSession.swift
//  VADemo
//
//  Created by Jack on 2024/11/7.
//

import UIKit
import AVFoundation
import CallKit

extension AVAudioSession {
    
    public static func printAudioSessionProperties() {
        let audioSession = AVAudioSession.sharedInstance()
        
        // Category
        let category = "Category: \(audioSession.category.rawValue)"
        
        // Mode
        let mode = "Mode: \(audioSession.mode.rawValue)"
        
        // Options - 构建包含每个选项的字符串
        var options = "Options: "
        let categoryOptions = audioSession.categoryOptions
        if categoryOptions.contains(.mixWithOthers) {
            options += "mixWithOthers, "
        }
        if categoryOptions.contains(.duckOthers) {
            options += "duckOthers, "
        }
        if categoryOptions.contains(.interruptSpokenAudioAndMixWithOthers) {
            options += "interruptSpokenAudioAndMixWithOthers, "
        }
        if categoryOptions.contains(.allowBluetooth) {
            options += "allowBluetooth, "
        }
        if categoryOptions.contains(.allowBluetoothA2DP) {
            options += "allowBluetoothA2DP, "
        }
        if categoryOptions.contains(.allowAirPlay) {
            options += "allowAirPlay, "
        }
        if categoryOptions.contains(.defaultToSpeaker) {
            options += "defaultToSpeaker, "
        }
        if #available(iOS 14.5, *) {
            if categoryOptions.contains(.overrideMutedMicrophoneInterruption) {
                options += "overrideMutedMicrophoneInterruption, "
            }
        }
        options = options.trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: [","])

        // Route Sharing Policy
        let routeSharingPolicy = "Route Sharing Policy: \(audioSession.routeSharingPolicy.rawValue)"
        
        // 组成一条打印信息
        let completeOutput = "==== \(category) | \(mode) | \(options) | \(routeSharingPolicy)"
        
        // 打印
        print(completeOutput)
    }
}
