//
//  Recording.swift
//  swiftUIDynamicAnimatorDemo
//
//  Created by mac on 27/09/22.
//

import Foundation

struct Recording: Identifiable, Hashable, Equatable {

    var id: String = UUID().uuidString
    var path: String
    var date: Date
    var scriptId: String
    
    init(){
        self.id = UUID().uuidString
        self.scriptId = id
        self.path = ""
        self.date = Date()
    }
    
    init(id: String = UUID().uuidString, scriptId: String, path: String, date: Date = Date()){
        self.id = id
        self.scriptId = scriptId
        self.path = path
        self.date = date
    }
    
    func getUrl(isProduction: Bool) -> URL{
        let url: URL?
        if isProduction{
//            url = LocalFileManager.document.getUrl(from: path)
            url = nil
        }
        else{
            url = URL(string: path)
        }
        guard let newUrl = url else{
            return URL(string: "https://apple.com")!
        }
        return newUrl
    }
}
