//
//  HomeStateModel.swift
//  Dorm Assistant
//
//  Created by 李昌埔 on 2024/11/5.
//

import SwiftUI
import SwiftyJSON
import AppIntents

class HomeStateModel {
    static var shared: HomeStateModel = HomeStateModel()
    var homeStore: HomeStore?
    
    init() {}
    init(_ homeStore: HomeStore) {
        self.homeStore = homeStore
    }
    
    func refresh() {
        guard let selectedInfo = self.homeStore?.selected else { return }
        let serverURL = selectedInfo.homeData.serverURL
        let stateAPI = serverURL.appendingPathComponent("api/states")
        var stateRequest = URLRequest(url: stateAPI)
        stateRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        stateRequest.setValue("Bearer " + selectedInfo.homeData.bearerToken, forHTTPHeaderField: "authorization")
        
        let getStateTask = URLSession.shared.dataTask(with: stateRequest) { [self, selectedInfo] data, response, error in
            guard let data = data else { return }
            let jsonObj = try? JSON(data: data)
            let temp_air = Float(jsonObj?.array?.filter { $0["entity_id"].string == selectedInfo.homeData.homeDetail.temp_air_entity }.first?["state"].string ?? "")
            let humidity_air = Float(jsonObj?.array?.filter { $0["entity_id"].string == selectedInfo.homeData.homeDetail.humidity_air_entity }.first?["state"].string ?? "")
            let ac_status = jsonObj?.array?.filter { $0["entity_id"].string == selectedInfo.homeData.homeDetail.climate_entity }.first?["state"].string
            let temp_ac: Float? = if ac_status == "off" {
                nil
            } else {
                jsonObj?.array?.filter { $0["entity_id"].string == selectedInfo.homeData.homeDetail.climate_entity }.first?["attributes"]["temperature"].float
            }
            let power_left = Float(jsonObj?.array?.filter { $0["entity_id"].string == selectedInfo.homeData.homeDetail.power_left_entity }.first?["state"].string ?? "")
            let water_left = Float(jsonObj?.array?.filter { $0["entity_id"].string == selectedInfo.homeData.homeDetail.water_left_entity }.first?["state"].string ?? "")
            
            DispatchQueue.main.async { [self] in
                homeStore!.selected!.homeData.lastError = false
                homeStore!.selected!.homeData.homeDetail.temp_air = temp_air
                homeStore!.selected!.homeData.homeDetail.humidity_air = humidity_air
                homeStore!.selected!.homeData.homeDetail.ac_status = ac_status
                homeStore!.selected!.homeData.homeDetail.power_left = power_left
                homeStore!.selected!.homeData.homeDetail.water_left = water_left
                homeStore!.selected!.homeData.homeDetail.temp_ac = temp_ac
            }
        }
        
        getStateTask.resume()
    }
    
    func acOn() {
        guard let selectedInfo = self.homeStore?.selected else { return }
        let serverURL = selectedInfo.homeData.serverURL
        let serviceAPI = serverURL.appendingPathComponent("api/services/climate/turn_on")
        var serviceRequest = URLRequest(url: serviceAPI)
        serviceRequest.httpMethod = "POST"
        let payload: [String: Any] = [
            "entity_id": selectedInfo.homeData.homeDetail.climate_entity
        ]
        serviceRequest.setValue("Bearer " + selectedInfo.homeData.bearerToken, forHTTPHeaderField: "authorization")
        serviceRequest.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        
        let serviceTask = URLSession.shared.dataTask(with: serviceRequest)
        serviceTask.resume()
    }
    
    func acOff() {
        guard let selectedInfo = self.homeStore?.selected else { return }
        let serverURL = selectedInfo.homeData.serverURL
        let serviceAPI = serverURL.appendingPathComponent("api/services/climate/turn_off")
        var serviceRequest = URLRequest(url: serviceAPI)
        serviceRequest.httpMethod = "POST"
        let payload: [String: Any] = [
            "entity_id": selectedInfo.homeData.homeDetail.climate_entity
        ]
        serviceRequest.setValue("Bearer " + selectedInfo.homeData.bearerToken, forHTTPHeaderField: "authorization")
        serviceRequest.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        
        let serviceTask = URLSession.shared.dataTask(with: serviceRequest)
        serviceTask.resume()
    }
}
