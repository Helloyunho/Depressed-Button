//
//  ContentView.swift
//  Depressed Button
//
//  Created by Helloyunho on 1/7/24.
//

import SwiftUI
import SwiftData
import Charts

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.self) private var environment
    @State private var dates: Set<DateComponents> = [Calendar.current.dateComponents([.calendar, .era, .year, .month, .day], from: Date())]
    @State private var updated = false
    @State private var todayCount = 0
    @State private var currentColor = Color.accentColor

//    var body: some View {
//        NavigationSplitView {
//            List {
//                ForEach(items) { item in
//                    NavigationLink {
//                        Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
//                    } label: {
//                        Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
//                    }
//                }
//                .onDelete(perform: deleteItems)
//            }
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    EditButton()
//                }
//                ToolbarItem {
//                    Button(action: addItem) {
//                        Label("Add Item", systemImage: "plus")
//                    }
//                }
//            }
//        } detail: {
//            Text("Select an item")
//        }
//    }
    
    var body: some View {
        TabView {
            VStack {
                Text("Depressed Button")
                    .font(.system(size: 40))
                    .fontWeight(.bold)
                Text("Press the big button below when you feel sad and want to cry")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                Text("Spam it when you feel really bad")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                Button(action: addItem) {
                    Circle()
                        .fill(.primary)
                }
                .padding(48)
            }
            VStack {
                MultiDatePicker(
                    "Start Date",
                    selection: $dates,
                    in: ..<Date.now
                )
                .datePickerStyle(.graphical)
                Chart {
                    ForEach(dates.map{$0.date!}.sorted(by: <), id: \.self) { date in
                        if updated {
                            BarMark(
                                x: .value("Date", date),
                                y: .value("Count", (try? getCount(of: date)) ?? 0)
                            )
                        } else {
                            BarMark(
                                x: .value("Date", date),
                                y: .value("Count", (try? getCount(of: date)) ?? 0)
                            )
                        }
                    }
                }
                .padding(32)
            }
            .padding()
        }
        .tabViewStyle(.page)
        .onAppear {
            todayCount = (try? getCount(of: .now)) ?? todayCount
        }
        .tint(currentColor)
    }
    
    private func getCount(of date: Date) throws -> Int {
        let calendar = Calendar.current
        let oneAfter = calendar.date(byAdding: .init(day: 1), to: date)!
        let midnight = calendar.startOfDay(for: date)
        let descriptor = FetchDescriptor<DepressedItem>(
            predicate: #Predicate {
                $0.timestamp > midnight && $0.timestamp < oneAfter
            }
        )
        
        return try modelContext.fetchCount(descriptor)
    }

    private func addItem() {
        updated.toggle()
        withAnimation {
            let newItem = DepressedItem(timestamp: Date())
            modelContext.insert(newItem)
        }
        todayCount = (try? getCount(of: .now)) ?? todayCount
        let colorToCG = Color.accentColor.resolve(in: environment).cgColor
        let CGtoUI = UIColor(cgColor: colorToCG)

        var hue: CGFloat = 0.0
        var saturation: CGFloat = 0.0
        var brightness: CGFloat = 0.0
        var opacity: CGFloat = 0.0
        CGtoUI.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &opacity)
        currentColor = Color(hue: (hue + CGFloat(todayCount) / 360).truncatingRemainder(dividingBy: 1), saturation: saturation, brightness: brightness, opacity: opacity)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: DepressedItem.self, inMemory: true)
}
