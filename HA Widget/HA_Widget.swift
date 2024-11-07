//
//  HA_Widget.swift
//  HA Widget
//
//  Created by 李昌埔 on 2024/11/7.
//

import WidgetKit
import SwiftUI
import SwiftyJSON
import AppIntents

let errorCode = [401: "Token错误", 403: "访问被禁止", 404: "未找到网址"]

struct Provider: TimelineProvider {
    var homeStore = HomeStore.shared
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(),
                    name: "家庭",
                    temp_air: 24,
                    humidity_air: 56,
                    ac_status: "cool",
                    temp_ac: 27,
                    power_left: 120,
                    water_left: 5.67)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(),
                                name: "家庭",
                                temp_air: 24,
                                humidity_air: 56,
                                ac_status: "cool",
                                temp_ac: 27,
                                power_left: 120,
                                water_left: 5.67)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        Task {
            do{
                try await homeStore.load()
            } catch {
                fatalError(error.localizedDescription)
            }
            guard let selectedInfo = self.homeStore.selected else { return }
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
                
                let currentEntry = SimpleEntry(
                    date: Calendar.current.date(byAdding: .minute, value: 30, to: Date())!,
                    name: homeStore.selected!.homeData.name,
                    temp_air: temp_air,
                    humidity_air: humidity_air,
                    ac_status: ac_status,
                    temp_ac: temp_ac,
                    power_left: power_left,
                    water_left: water_left)
                let currentTimeLine = Timeline(entries: [currentEntry], policy: .atEnd)
                completion(currentTimeLine)
            }
            
            getStateTask.resume()
        }
    }
    
    //    func relevances() async -> WidgetRelevances<Void> {
    //        // Generate a list containing the contexts this widget is relevant in.
    //    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let name: String
    let temp_air: Float?
    let humidity_air: Float?
    let ac_status: String?
    let temp_ac: Float?
    let power_left: Float?
    let water_left: Float?
}

struct HA_WidgetEntryView : View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    var entry: Provider.Entry
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(entry.name).font(.system(size: 20))
                Spacer()
                Text("AC").font(.system(size: 20))
                Spacer().frame(width: 5)
                if entry.ac_status == "off" {
                    Text("关").font(.system(size: 20)).bold()
                } else if entry.ac_status == nil || entry.temp_ac == nil {
                    Text("-").font(.system(size: 20)).bold()
                } else {
                    Text(Int(entry.temp_ac!).description + "°C").font(.system(size: 20)).bold()
                }
            }
            Spacer()
            HStack {
                VStack(alignment: .leading) {
                    Text("温度").font(.system(size: 15)).fontWeight(.light)
                    HStack(alignment: .bottom) {
                        if entry.temp_air == nil {
                            Text("-").bold().monospaced().font(.system(size: 30))
                        } else {
                            Text(String(format: "%.1f", entry.temp_air!)).bold().monospaced().font(.system(size: 30))
                            Text("°C").bold().monospaced().font(.system(size: 15))
                        }
                    }
                }
                if family == .systemMedium {
                    VStack(alignment: .leading) {
                        Text("剩余电量").font(.system(size: 15)).fontWeight(.light)
                        HStack(alignment: .bottom) {
                            if entry.power_left == nil {
                                Text("-").bold().monospaced().font(.system(size: 30))
                            } else {
                                Text(String(format: "%.1f", entry.power_left!)).bold().monospaced().font(.system(size: 30))
                                Text("kWh").bold().monospaced().font(.system(size: 15))
                                Spacer()
                            }
                        }
                    }
//                    Button(intent: AcSwitchIntent(newState: IntentParameter(title: "cool"))) {
//                        Text("开启空调")
//                    }
                }
            }
            HStack {
                VStack(alignment: .leading) {
                    Text("湿度").font(.system(size: 15)).fontWeight(.light)
                    HStack(alignment: .bottom) {
                        if entry.humidity_air == nil {
                            Text("-").bold().monospaced().font(.system(size: 30))
                        } else {
                            Text(String(format: "%.1f", entry.humidity_air!)).bold().monospaced().font(.system(size: 30))
                            Text("%").bold().monospaced().font(.system(size: 15))
                        }
                    }
                }
                if family == .systemMedium {
                    VStack(alignment: .leading) {
                        Text("剩余水量").font(.system(size: 15)).fontWeight(.light)
                        HStack(alignment: .bottom) {
                            if entry.water_left == nil {
                                Text("-").bold().monospaced().font(.system(size: 30))
                            } else {
                                Text(String(format: "%.1f", entry.water_left!)).bold().monospaced().font(.system(size: 30))
                                Text("m³").bold().monospaced().font(.system(size: 15))
                                Spacer()
                            }
                        }
                    }
                }
            }
        }
    }
}

struct HA_Widget: Widget {
    let kind: String = "HA_Widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                HA_WidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                HA_WidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

#Preview(as: .systemSmall) {
    HA_Widget()
} timeline: {
    SimpleEntry(date: Date(),
                name: "家庭",
                temp_air: 24,
                humidity_air: 56,
                ac_status: "cool",
                temp_ac: 27,
                power_left: 120,
                water_left: 5.67)
}
