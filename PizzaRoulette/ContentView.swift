//
//  ContentView.swift
//  PizzaRoulette
//
//  Created by Philip Fisker on 12/11/2022.
//

import SwiftUI
import Combine

struct ContentView: View {
    @State var showPizza = false
    @State var lowerNumber = "0"
    @State var upperNumber = "0"
    @State var pizzaNum = 0
    
    func getPizza(low:String, high:String) -> Int {
        return Int.random(in: (Int(low) ?? 0)...(Int(high) ?? 0))
    }
    
    var body: some View {
        
        VStack {
            !showPizza ? Text("Input pizza ranges...") : Text("Your number is: " + "\(pizzaNum)")
            Button {
                showPizza = true
                pizzaNum = getPizza(low: lowerNumber, high: upperNumber)
            } label: {
                Text("Prøv lykken!")
                    .padding(20)
            }
            .buttonStyle(.bordered)
            TextField("Lower number", text: $lowerNumber)
                .keyboardType(.numberPad)
                .background(.gray)
                .onReceive(Just(lowerNumber)) { newValue in
                    let filtered = newValue.filter { "0123456789".contains($0) }
                    if filtered != newValue {
                        self.lowerNumber = filtered
                    }
                }
            TextField("Upper number", text: $upperNumber)
                .keyboardType(.numberPad)
                .background(.gray)
                .onReceive(Just(upperNumber)) { newValue in
                    let filtered = newValue.filter { "0123456789".contains($0) }
                    if filtered != newValue {
                        self.upperNumber = filtered
                    }
                }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
