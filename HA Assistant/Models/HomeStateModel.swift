//
//  HomeStateModel.swift
//  Dorm Assistant
//
//  Created by 李昌埔 on 2024/11/5.
//

import SwiftUI
import SwiftyJSON

let errorCode = [401: "Token错误", 403: "访问被禁止", 404: "未找到网址"]

class HomeStateModel: ObservableObject {
    @Published var updating: Bool = false
    @Published var acTurningOn: Bool = false
    @Published var acTurningOff: Bool = false
    @Published var popupError: Bool = false
    @Published var popupMessage: String = ""
    @ObservedObject var homeStore: HomeStore
    
    init(_ homeStore: HomeStore) {
        self.homeStore = homeStore
    }
    
    func refresh() {
        updating = true
        let selectedInfo = self.homeStore.selected!
        let serverURL = selectedInfo.homeData.serverURL
        let stateAPI = serverURL.appendingPathComponent("api/states")
        var stateRequest = URLRequest(url: stateAPI)
        stateRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        stateRequest.setValue("Bearer " + selectedInfo.homeData.bearerToken, forHTTPHeaderField: "authorization")
        
        let getStateTask = URLSession.shared.dataTask(with: stateRequest) { [self, selectedInfo] data, response, error in
            guard error == nil else {
                DispatchQueue.main.async { [self] in
                    updating = false
                    homeStore.selected!.homeData.lastError = true
                    popMessage(error?.localizedDescription ?? "")
                }
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                DispatchQueue.main.async { [self] in
                    updating = false
                    homeStore.selected!.homeData.lastError = true
                    popMessage("错误：不是HTTP(S)请求")
                }
                return
            }
            
            guard response.statusCode == 200 else {
                DispatchQueue.main.async { [self] in
                    updating = false
                    homeStore.selected!.homeData.lastError = true
                    popMessage("网络请求错误(" + String(response.statusCode) + ")：" + (errorCode[response.statusCode] ?? ""))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async { [self] in
                    updating = false
                    homeStore.selected!.homeData.lastError = true
                    popMessage("没有返回信息")
                }
                return
            }
            
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
                updating = false
                homeStore.selected!.homeData.lastError = false
                homeStore.selected!.homeData.homeDetail.temp_air = temp_air
                homeStore.selected!.homeData.homeDetail.humidity_air = humidity_air
                homeStore.selected!.homeData.homeDetail.ac_status = ac_status
                homeStore.selected!.homeData.homeDetail.power_left = power_left
                homeStore.selected!.homeData.homeDetail.water_left = water_left
                homeStore.selected!.homeData.homeDetail.temp_ac = temp_ac
            }
        }
        
        getStateTask.resume()
    }
    
    private func popMessage(_ message: String){
        popupMessage = message
        popupError = true
    }
    
    func acOn() {
        acTurningOn = true
        let selectedInfo = self.homeStore.selected!
        let serverURL = selectedInfo.homeData.serverURL
        let serviceAPI = serverURL.appendingPathComponent("api/services/climate/turn_on")
        var serviceRequest = URLRequest(url: serviceAPI)
        serviceRequest.httpMethod = "POST"
        let payload: [String: Any] = [
            "entity_id": selectedInfo.homeData.homeDetail.climate_entity
        ]
        serviceRequest.setValue("Bearer " + selectedInfo.homeData.bearerToken, forHTTPHeaderField: "authorization")
        serviceRequest.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        
        let serviceTask = URLSession.shared.dataTask(with: serviceRequest) { [self] data, response, error in
            guard error == nil else {
                DispatchQueue.main.async { [self] in
                    acTurningOn = false
                    popMessage(error?.localizedDescription ?? "")
                }
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                DispatchQueue.main.async { [self] in
                    acTurningOn = false
                    popMessage("错误：不是HTTP(S)请求")
                }
                return
            }
            
            guard response.statusCode == 200 else {
                DispatchQueue.main.async { [self] in
                    acTurningOn = false
                    popMessage("网络请求错误(" + String(response.statusCode) + ")：" + (errorCode[response.statusCode] ?? ""))
                }
                return
            }
            
            DispatchQueue.main.async { [self] in
                acTurningOn = false
            }
            let waitSemaphore = DispatchSemaphore(value: 0)
            Task {
                try? await Task.sleep(for: .seconds(1))
                waitSemaphore.signal()
            }
            waitSemaphore.wait()
            DispatchQueue.main.async { [self] in
                refresh()
            }
        }
        
        serviceTask.resume()
    }
    
    func acOff() {
        acTurningOff = true
        let selectedInfo = self.homeStore.selected!
        let serverURL = selectedInfo.homeData.serverURL
        let serviceAPI = serverURL.appendingPathComponent("api/services/climate/turn_off")
        var serviceRequest = URLRequest(url: serviceAPI)
        serviceRequest.httpMethod = "POST"
        let payload: [String: Any] = [
            "entity_id": selectedInfo.homeData.homeDetail.climate_entity
        ]
        serviceRequest.setValue("Bearer " + selectedInfo.homeData.bearerToken, forHTTPHeaderField: "authorization")
        serviceRequest.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        
        let serviceTask = URLSession.shared.dataTask(with: serviceRequest) { [self] data, response, error in
            guard error == nil else {
                DispatchQueue.main.async { [self] in
                    acTurningOff = false
                    popMessage(error?.localizedDescription ?? "")
                }
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                DispatchQueue.main.async { [self] in
                    acTurningOff = false
                    popMessage("错误：不是HTTP(S)请求")
                }
                return
            }
            
            guard response.statusCode == 200 else {
                DispatchQueue.main.async { [self] in
                    acTurningOff = false
                    popMessage("网络请求错误(" + String(response.statusCode) + ")：" + (errorCode[response.statusCode] ?? ""))
                }
                return
            }
            
            DispatchQueue.main.async { [self] in
                acTurningOff = false
            }
            let waitSemaphore = DispatchSemaphore(value: 0)
            Task {
                try? await Task.sleep(for: .seconds(1))
                waitSemaphore.signal()
            }
            waitSemaphore.wait()
            DispatchQueue.main.async { [self] in
                refresh()
            }
        }
        
        serviceTask.resume()
    }
}
