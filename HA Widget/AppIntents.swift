//
//  AppIntents.swift
//  Dorm Assistant
//
//  Created by 李昌埔 on 2024/11/7.
//

import AppIntents

struct EmptyIntent: AppIntent {
    static var title: LocalizedStringResource = "Empty Intent"
    static var description: IntentDescription = IntentDescription("A intent that does nothing.")
    func perform() async throws -> some IntentResult {
        return .result()
    }
}

struct AcSwitchIntent: AppIntent {
    static var title: LocalizedStringResource = "Ac Switch"
    static var description: IntentDescription = IntentDescription("Switch the state of the AC.")
    
    @Parameter(title: "ifOn")
    var ifOn: Bool
    
    init() {}
    init(ifOn: Bool) {
        self.ifOn = ifOn
    }
    
    func perform() async throws -> some IntentResult {
        let homeStore = HomeStore.shared
        guard let selectedInfo = homeStore.selected else { return .result() }
        let serverURL = selectedInfo.homeData.serverURL
        let serviceAPI =
        if ifOn {
            serverURL.appendingPathComponent("api/services/climate/turn_on")
        } else {
            serverURL.appendingPathComponent("api/services/climate/turn_off")
        }
        var serviceRequest = URLRequest(url: serviceAPI)
        serviceRequest.httpMethod = "POST"
        let payload: [String: Any] = [
            "entity_id": selectedInfo.homeData.homeDetail.climate_entity
        ]
        serviceRequest.setValue("Bearer " + selectedInfo.homeData.bearerToken, forHTTPHeaderField: "authorization")
        serviceRequest.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        
        let serviceTask = URLSession.shared.dataTask(with: serviceRequest)
        serviceTask.resume()
        return .result()
    }
}
