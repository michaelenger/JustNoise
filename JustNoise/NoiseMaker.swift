//
//  NoiseMaker.swift
//  JustNoise
//
//  Created by Michael Enger on 15/05/2021.
//

import Foundation
import AVFoundation

enum NoiseMakerError: Error {
    /// Thrown when a band with that frequency doesn't exist.
    case invalidFrequency(frequency: Float)
}

/// A means to make noise.
class NoiseMaker {
    private let engine: AVAudioEngine
    private let equaliser: AVAudioUnitEQ
    public let frequencies: [Float] = [
        80, 160, 250, 500, 900, 1500, 2500, 3200
    ]

    /// Generate sample.
    /// - Returns A PCM sample.
    private func generateSample() -> Float {
        return ((Float(arc4random_uniform(UINT32_MAX)) / Float(UINT32_MAX)) * 2 - 1)
    }

    /// Create the noise maker.
    public init() {
        engine = AVAudioEngine()
        equaliser = AVAudioUnitEQ(numberOfBands: frequencies.count)
        
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
        for (i, frequency) in frequencies.enumerated() {
            let band = self.equaliser.bands[i]
            band.bypass = false
            band.frequency = frequency
            band.filterType = .parametric
            band.gain = 0
            band.bandwidth = 0.05
        }
        
        engine.attach(self.equaliser)

        engine.connect(sourceNode, to: self.equaliser, format: inputFormat)
        engine.connect(self.equaliser, to: mainMixer, format: inputFormat)
        engine.connect(mainMixer, to: output, format: outputFormat)
        mainMixer.outputVolume = 0.5 // TODO Make this configurable?
        
        engine.prepare()
    }
    
    /// Start making noise.
    public func start() throws {
        try engine.start()
    }
    
    /// Stop making noise.
    public func stop() {
        engine.stop()
    }
    
    /// Change the gain of a specific frequency.
    /// - Parameter frequency: The frequency to change the gain value for.
    /// - Parameter gain: New gain value.
    public func changeGain(frequency: Float, gain: Float) throws {
        for (i, bandFrequency) in frequencies.enumerated() {
            if frequency == bandFrequency {
                let band = self.equaliser.bands[i]
                band.gain = gain
                return
            }
        }
        
        throw NoiseMakerError.invalidFrequency(frequency: frequency)

        
    }
}
