//
//  ContentView.swift
//  JustNoise
//
//  Created by Michael Enger on 15/05/2021.
//

import SwiftUI

struct ContentView: View {
    @State private var isNoisy: Bool = false
    
    private let noiseMaker = NoiseMaker()
    
    var body: some View {
        VStack {
            HStack {
                ForEach(noiseMaker.frequencies, id: \.self) { frequency in
                    GainSlider(value: 0, frequency: frequency, onGainChanged: onGainChanged)
                }
            }
            
            Button(action: toggleNoise) {
                Text(isNoisy ? "Be Quiet" : "Make Noise")
                    .padding()
                    .frame(maxWidth:.infinity)
            }
            .background(Color(UIColor.systemBlue))
            .foregroundColor(.white)
            .cornerRadius(8)
            
            Spacer()
        }
        .padding()
    }
    
    func toggleNoise() {
        if (isNoisy) {
            noiseMaker.stop()
        } else {
            do {
                try noiseMaker.start()
            } catch {
                print("Failed to start engine: \(error)")
            }
        }

        self.isNoisy.toggle()
    }
    
    func onGainChanged(_ frequency: Float, _ gain: Float) {
        do {
            try self.noiseMaker.changeGain(frequency: frequency, gain: gain)
        } catch {
            print("Cannot update gain: \(error)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
