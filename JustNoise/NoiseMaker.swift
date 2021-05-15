//
//  NoiseMaker.swift
//  JustNoise
//
//  Created by Michael Enger on 15/05/2021.
//

import Foundation
import AVFoundation

/// A means to make noise.
class NoiseMaker {
    private let engine: AVAudioEngine
    private let equaliser: AVAudioUnitEQ

    /// Generate sample.
    /// - Returns A PCM sample.
    private func generateSample() -> Float {
        return ((Float(arc4random_uniform(UINT32_MAX)) / Float(UINT32_MAX)) * 2 - 1)
    }

    /// Create the noise maker.
    public init() {
        engine = AVAudioEngine()
        equaliser = AVAudioUnitEQ(numberOfBands: 1)
        
        let amplitude = Float(0.5) // TODO Make this configurable?
        
        let mainMixer = engine.mainMixerNode
        let output = engine.outputNode
        let outputFormat = output.inputFormat(forBus: 0)

        let inputFormat = AVAudioFormat(commonFormat: outputFormat.commonFormat,
                                        sampleRate: outputFormat.sampleRate,
                                        channels: 1,
                                        interleaved: outputFormat.isInterleaved)

        // White noise generator
        let sourceNode = AVAudioSourceNode { _, _, frameCount, audioBufferList -> OSStatus in
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
        
        engine.attach(sourceNode)
        
        // Setup equaliser
        let band = self.equaliser.bands[0]
        band.bypass = false
        band.frequency = 3000
        band.filterType = .parametric
        band.gain = 0
        band.bandwidth = 0.05
        
        engine.attach(self.equaliser)

        engine.connect(sourceNode, to: self.equaliser, format: inputFormat)
        engine.connect(self.equaliser, to: mainMixer, format: inputFormat)
        engine.connect(mainMixer, to: output, format: outputFormat)
        mainMixer.outputVolume = 0.5 // TODO Make this configurable?
        
        engine.prepare()
    }
    
    /// Start making noise.
    public func start() {
        do {
            try engine.start()
        } catch {
            print("Failed to start engine: \(error)")
        }
    }
    
    /// Stop making noise.
    public func stop() {
        engine.stop()
    }
    
    /// Toggle the EQ thing on or off
    public func toggleEQ() {
        let band = self.equaliser.bands[0]
        band.gain = band.gain == 0 ? -100 : 0
    }
}
