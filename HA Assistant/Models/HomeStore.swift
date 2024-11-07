//
//  HomeStore.swift
//  Dorm Assistant
//
//  Created by 李昌埔 on 2024/11/4.
//

import Foundation

@MainActor
class HomeStore: ObservableObject {
    @Published var homeInfos: [UUID: HomeInfo] = [:]
    @Published var selected: HomeInfo? = nil
    
    private static func fileURL() throws -> URL {
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.helmholtz.haassistant") else { throw NSError(domain: "", code: 0) }
        return containerURL.appendingPathComponent("home_conf.json")
    }
    
    init(initHomes: [UUID: HomeInfo]) {
        self.homeInfos = initHomes
        updateSelected()
    }
    
    init() {
    }
    
    init(initHomes: [HomeInfo]) {
        for homeInfo in initHomes {
            self.homeInfos[homeInfo.id] = homeInfo
        }
        updateSelected()
    }
    
    func select(target: HomeInfo) {
        if selected?.id != target.id {
            homeInfos[selected!.id]?.homeData.current = false
            homeInfos[target.id]?.homeData.current = true
            selected = target
        }
    }
    
    private func updateSelected() {
        if self.homeInfos.isEmpty {
            selected = nil
        } else {
            selected = self.homeInfos.values.filter { $0.homeData.current }[0]
        }
    }
    
    func load() async throws {
        let task = Task<[UUID: HomeInfo], Error> {
            let fileURL = try Self.fileURL()
            guard let data = try? Data(contentsOf: fileURL) else {
                return [:]
            }
            let homeDatas = try JSONDecoder().decode([HomeData].self, from: data)
            var homeInfos: [UUID: HomeInfo] = [:]
            for homeData in homeDatas {
                let homeInfo = HomeInfo(data: homeData)
                homeInfos[homeInfo.id] = homeInfo
            }
            return homeInfos
        }
        let homeInfos = try await task.value
        self.homeInfos = homeInfos
        updateSelected()
    }
    
    func save(homeInfos: [UUID: HomeInfo]) async throws {
        let task = Task {
            let homeDatas = homeInfos.map { $0.value.homeData }
            let data = try JSONEncoder().encode(homeDatas)
            let fileURL = try Self.fileURL()
            try data.write(to: fileURL)
        }
        _ = try await task.value
    }
    
    func newHome(newInfo: HomeInfo) {
        if self.selected == nil {
            self.selected = newInfo
            newInfo.homeData.current = true
        }
        self.homeInfos[newInfo.id] = newInfo
    }
}

extension HomeStore {
    static let sampleData: HomeStore = HomeStore(initHomes: [
        HomeInfo(data: HomeData(name: "宿舍", serverURL: URL(string: "https://ha.fomal.host")!, current: true)),
        HomeInfo(data: HomeData(name: "宿舍局域网", serverURL: URL(string: "http://172.16.0.150:8123")!, current: false))
    ])
}
