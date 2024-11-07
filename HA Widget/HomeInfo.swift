//
//  HomeInfo.swift
//  Dorm Assistant
//
//  Created by 李昌埔 on 2024/11/4.
//

import SwiftUI
import Foundation

struct HomeDetail: Codable {
    var temp_air_entity: String = ""
    var temp_air: Float?
    
    var humidity_air_entity: String = ""
    var humidity_air: Float?
    
    var climate_entity: String = ""
    var ac_status: String?
    var temp_ac: Float?
    
    var power_left_entity: String = ""
    var power_left: Float?
    
    var water_left_entity: String = ""
    var water_left: Float?
}

struct HomeData: Codable {
    var name: String = ""
    var serverURL: URL = URL(string: "URL")!
    var current: Bool = false
    var bearerToken: String = ""
    var lastError: Bool = false
    var homeDetail: HomeDetail = HomeDetail()
}

class HomeInfo: ObservableObject, Identifiable {
    @Published var homeData: HomeData
    var id: UUID
        
    init(data: HomeData) {
        id = UUID()
        homeData = data
    }
    
    init(id: UUID) {
        self.id = id
        homeData = HomeData()
    }
    
    init() {
        id = UUID()
        homeData = HomeData()
    }
    
    func from(data: HomeInfo) {
        DispatchQueue.main.async {
            self.id = data.id
            self.homeData = data.homeData
        }
    }
}
