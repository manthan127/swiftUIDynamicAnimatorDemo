//
//  ContentView.swift
//  swiftUIDynamicAnimatorDemo
//
//  Created by mac on 20/09/22.
//

import SwiftUI

struct ContentView: View {
    @State var play = false
    var body: some View {
        let customScroll = AnimatorViewRepresentable(playing: $play)
        return VStack {
            
            GeometryReader { geo in
                customScroll
                    .onAppear {
                        customScroll.coordinator.size = geo.size
                    }
            }
            
            HStack{
                Spacer()
                Button {
                    customScroll.prev()
                } label: {
                    Text("Prev")
                }
                
                Spacer()
                Button {
                    customScroll.playOrPause()
                } label: {
                    Text(play ? "Pause" : "Play")
                }
                
                Spacer()
                Button {
                    customScroll.next()
                } label: {
                    Text("Next")
                }
                Spacer()
            }
            .background(Color.white)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
