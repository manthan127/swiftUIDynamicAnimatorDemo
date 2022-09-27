//
//  Script.swift
//  swiftUIDynamicAnimatorDemo
//
//  Created by mac on 27/09/22.
//

import SwiftUI
import CoreData

class ScriptDefaultValue{
    static let size = 18
    static let textAlignment: TextAlignment = .leading
    static let font = "Roboto"
}


struct Script: Identifiable, Hashable, Equatable{
    var id: String
    var title: String
    var text: String
    var textAlignment: TextAlignment
    var font: String
    var speed: Float
    var size: Int
    var bgColor: String?
    var bgImage: String?
    var recordings: [Recording]
    var timestamp: Date
    
    init (
        id: Script.ID = UUID().uuidString,
        title: String,
        text: String = "",
        textAlignment: TextAlignment = ScriptDefaultValue.textAlignment,
        font: String = ScriptDefaultValue.font,
        size: Int = ScriptDefaultValue.size,
        recordings: [Recording] = []
    ){
        self.id = id
        self.title = title
        self.text = text
        self.textAlignment = textAlignment
        self.font = font
        self.speed = 0.25
        self.size = size
        self.recordings = recordings
        self.timestamp = Date()
    }
    
    var color: Color {
        self.bgColor != nil ? Color(self.bgColor!) : Color.clear
    }
    
    func getTitleFont() -> Font{
        Font.custom(font, size: CGFloat(size + 10))
    }
    
    func getFont() -> Font{
        Font.custom(font, size: CGFloat(size))
    }
    
    func getUIFont() -> UIFont?{
        UIFont(name: font, size: CGFloat(size))
    }
    
    mutating func setSize(_ size: CGFloat){
        self.size = Int(size)
    }
    
    func filterRecordings(for ids: Set<String>) -> Script{
        let filteredRecordings = recordings.filter({ !ids.contains($0.id) })
        let script = Script(
            id: id,
            title: title,
            text: text,
            textAlignment: textAlignment,
            font: font,
            size: size,
            recordings: filteredRecordings
        )
        return script
    }
}
