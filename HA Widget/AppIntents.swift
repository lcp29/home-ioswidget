//
//  AppIntents.swift
//  Dorm Assistant
//
//  Created by 李昌埔 on 2024/11/7.
//

import AppIntents

struct AcSwitchIntent: AppIntent {
    static var title: LocalizedStringResource = "Ac On"
    static var description: IntentDescription = IntentDescription("Turn on the AC.")
    
    @Parameter(title: "newState")
    var newState: String
    
    func perform() async throws -> some IntentResult {
        let homeStore = HomeStore.shared
        guard let selectedInfo = homeStore.selected else { return .result() }
        let serverURL = selectedInfo.homeData.serverURL
        let serviceAPI = serverURL.appendingPathComponent("api/services/climate/turn_" + newState)
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
