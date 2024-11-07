//
//  HomeEditModel.swift
//  Dorm Assistant
//
//  Created by 李昌埔 on 2024/11/5.
//

import SwiftUI

class HomeEditModel: ObservableObject {
    @Published var isShowingEditSheet: Bool
    @Published var editHomeInfo: HomeInfo
    @Published var editHomeId: UUID
    @Published var isNewHome: Bool
    @Published var userInputURL: String
    @Published var userInputURLValid: Bool
    
    init() {
        let newInfo = HomeInfo()
        self.isShowingEditSheet = false
        self.editHomeInfo = newInfo
        self.editHomeId = newInfo.id
        self.userInputURL = ""
        self.userInputURLValid = false
        self.isNewHome = true
    }
    
    func openNew() {
        self.isNewHome = true
        self.editHomeInfo = HomeInfo()
        self.editHomeId = self.editHomeInfo.id
        self.isShowingEditSheet = true
        self.userInputURLValid = false
        self.userInputURL = ""
    }
    
    func openEdit(editInfo: HomeInfo) {
        self.isNewHome = false
        self.editHomeInfo = editInfo
        self.editHomeId = editInfo.id
        self.isShowingEditSheet = true
        self.userInputURL = editInfo.homeData.serverURL.absoluteString
        self.userInputURLValid = true
    }
}
