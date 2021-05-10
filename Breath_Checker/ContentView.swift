//
//  ContentView.swift
//  Breath_Checker
//
//  Created by Jan Philipp Gehrke on 5/7/21.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var audioAnalyzer = AudioAnalyzer()
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Prediction:")
                Text(audioAnalyzer.prediction)
            }
            HStack {
                Text("Confidence:")
                Text("\(audioAnalyzer.confidence) %")
            }
            HStack {
                Button(action: {audioAnalyzer.stopAudioEngine()}, label: {
                    Image(systemName: "square.fill")
                        .font(.largeTitle)
                })
                Button(action: {audioAnalyzer.startAudioEngine()}, label: {
                    Image(systemName: "play.fill")
                        .font(.largeTitle)
                })
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
