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
            Button(action: toggleNoise) {
                Text(isNoisy ? "Stop" : "Start Noise")
                    .padding()
                    .frame(maxWidth:.infinity)
            }
            .background(Color(UIColor.systemIndigo))
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
            noiseMaker.start()
        }

        self.isNoisy.toggle()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
