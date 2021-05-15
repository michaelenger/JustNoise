//
//  ContentView.swift
//  JustNoise
//
//  Created by Michael Enger on 15/05/2021.
//

import SwiftUI

struct ContentView: View {
    @State private var isNoisy: Bool = false
    
    var body: some View {
        VStack {
            Button(action: toggleNoise) {
                Text(isNoisy ? "Stop" : "Start Noise")
            }
            .padding()
            .background(Color(UIColor.systemIndigo))
            .foregroundColor(.white)
            .cornerRadius(8)
            Spacer()
        }
        .padding()
    }
    
    func toggleNoise() {
        self.isNoisy.toggle()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
