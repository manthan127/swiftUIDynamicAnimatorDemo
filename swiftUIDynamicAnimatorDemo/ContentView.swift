//
//  ContentView.swift
//  swiftUIDynamicAnimatorDemo
//
//  Created by mac on 20/09/22.
//

import SwiftUI

struct ContentView: View {
    @State var play = false
    @State var script = Script(title: "HOHO",text: "rtfgv dftcg fghgc cgbv" + .longText, textAlignment: .leading, size: 23,recordings: [Recording(scriptId: "0", path: "lasso"), Recording(scriptId: "1", path: "folder.fill"), Recording(scriptId: "2", path: "mic")])
    
    var body: some View {
        let customScroll = AnimatorViewRepresentable(playing: $play, script: script)
        return VStack(spacing: 0) {
            
            GeometryReader { geo in
                customScroll
                    .onAppear {
                        customScroll.coordinator.size = geo.size
                        customScroll.setUP()
                    }
            }.mask{Color.black}
            
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
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ContentView()
        }
    }
}
