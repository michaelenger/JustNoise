//
//  NoiseMaker.swift
//  JustNoise
//
//  Created by Michael Enger on 15/05/2021.
//

import Foundation
import AVFoundation

class NoiseMaker {
    private let engine: AVAudioEngine

    private func generateSample() -> Float {
        return ((Float(arc4random_uniform(UINT32_MAX)) / Float(UINT32_MAX)) * 2 - 1)
    }

    public init() {
        engine = AVAudioEngine()
        
        let amplitude = Float(0.5)  // TODO Make this configurable?
        
        let mainMixer = engine.mainMixerNode
        let output = engine.outputNode
        let outputFormat = output.inputFormat(forBus: 0)

        let inputFormat = AVAudioFormat(commonFormat: outputFormat.commonFormat,
                                        sampleRate: outputFormat.sampleRate,
                                        channels: 1,
                                        interleaved: outputFormat.isInterleaved)

        let srcNode = AVAudioSourceNode { _, _, frameCount, audioBufferList -> OSStatus in
            let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)

            for frame in 0..<Int(frameCount) {
                let value = self.generateSample() * amplitude

                for buffer in ablPointer {
                    let buf: UnsafeMutableBufferPointer<Float> = UnsafeMutableBufferPointer(buffer)
                    buf[frame] = value
                }
            }

            return noErr
        }
        
        engine.attach(srcNode)

        engine.connect(srcNode, to: mainMixer, format: inputFormat)
        engine.connect(mainMixer, to: output, format: outputFormat)
        mainMixer.outputVolume = 0.5
        
        engine.prepare()
    }
    
    public func start() {
        do {
            try engine.start()
        } catch {
            print("Failed to start engine: \(error)")
        }
    }
    
    public func stop() {
        engine.stop()
    }
}
