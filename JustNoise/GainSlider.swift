//
//  GainSlider.swift
//  JustNoise
//
//  Created by Michael Enger on 15/05/2021.
//  Inspired by https://stackoverflow.com/a/61394106
//

import SwiftUI

/// Slider used to control the gain.
struct GainSlider: View {
    /// The gain value.
    @State var value: Float
    
    /// Frequency which is being gained.
    var frequency: Float
    
    /// Handle the gain changing.
    let onGainChanged: (Float, Float) -> Void

    var body: some View {
        VStack{
            Text(formatFrequency(frequency))
                .font(.system(size: 10))

            GeometryReader { geo in
                ZStack {
                    Rectangle()
                        .path(in: CGRect(x: 0,
                                         y: geo.size.height * 0.214, // roughly where 0.0 is
                                         width: geo.size.width,
                                         height: 2))
                        .fill(Color.gray)
                    GeometryReader { geo in
                        Slider(
                            value: Binding(get: {
                                self.value
                            }, set: { (newVal) in
                                self.value = newVal
                                self.onGainChanged(frequency, newVal)
                            }),
                            in: -96...24
                        )
                        .rotationEffect(.degrees(-90.0), anchor: .topLeading)
                        .frame(width: geo.size.height)
                        .offset(x: 2, y: geo.size.height)
                    }
                }
            }
        }
        .frame(maxWidth:36)
    }
    
    /// Format the frequency to a nice string (with a Hz suffix).
    /// - Parameter frequency: The frequency to format.
    /// - Returns: A string with the formatted frequency and a Hz (or kHz) suffix.
    private func formatFrequency(_ frequency: Float) -> String {
        if frequency >= 1000 {
            return String(format: "%.1fkHz", frequency / 1000)
        }
        return String(format: "%.0fHz", frequency)
    }
}

struct GainSlider_Previews: PreviewProvider {
    static var previews: some View {
        GainSlider(value: 0, frequency: 3200)  { (frequency, gain) in
            print("\(frequency) changed to \(gain)")
        }
    }
}
