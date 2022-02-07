//
//  ContentView.swift
//  BetterRest
//
//  Created by Moe Steinmüller on 2022/02/02.
//
import CoreML
import SwiftUI

struct ContentView: View {
    
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    @State private var coffeeRange = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("When do you want to wake up?")) {
                    
                    DatePicker("Please enter a time.", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                        .onChange(of: wakeUp) { newValue in
                            calculateBedtime()
                        }
                    
                }
                
                Section(header: Text("Desired amount of sleep")) {
                    
                    Stepper("\(sleepAmount.formatted())", value: $sleepAmount, in: 4...12, step: 0.25)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                        .padding([.trailing, .leading])
                        .onChange(of: sleepAmount) { newValue in
                            calculateBedtime()
                        }
                }
                
                Section(header: Text("Daily coffee intake")) {
                    
                    Picker("Coffee Amount", selection: $coffeeAmount) {
                        ForEach(coffeeRange, id: \.self) {
                            if $0 == 1 {
                                Text("1 cup")
                            } else {
                                Text("\($0) cups")
                            }
                        }
                    }
                    .onChange(of: coffeeAmount) { newValue in
                        calculateBedtime()
                    }
                    
                }
                
                VStack(alignment: .center, spacing: 20) {
                    Text("\(alertTitle)")
                        .font(.largeTitle)
                    Text("\(alertMessage)")
                        .font(.largeTitle)
                }
                .padding([.bottom, .top])
            }
            .navigationTitle("BetterRest")
        }
        .onAppear(perform: calculateBedtime)
    }
    
    func calculateBedtime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            alertTitle = "Your ideal bedtime is"
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
            
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime."
        }
    }
    
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
