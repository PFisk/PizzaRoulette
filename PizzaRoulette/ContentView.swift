//
//  ContentView.swift
//  PizzaRoulette
//
//  Created by Philip Fisker on 12/11/2022.
//

import SwiftUI
import Combine
import Haptica

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

struct ContentView: View {
    @State var showPizza = false
    @State var lowerNumber = "1"
    @State var upperNumber = "10"
    @State var pizzaNum = 0
    @State var pizzaList:[Int] = []
    
    @State var selectedIndex = 0
    
    @State var proxy: GeometryProxy?
    
    @State var isButtonDisabled: Bool = false
    
    let animationTime: Double = 2
    
    let textLimit = 3
    
    func limitText(_ textLimit: Int, input: String) -> String {
        if input.count > textLimit {
            return String(input.prefix(textLimit))
        } else {
            return input
        }
    }
    
    func hapticSequence(types: [String], pctIndices: [Int], amount: Int, delay: Double) -> Void {
        
        var pattern = ""
        var id = 0
        
        for type in types {
            
            let currentAmount = amount/100*pctIndices[id]
            
            switch (type) {
            case "heavy":
                for _ in 0...currentAmount {
                    pattern += "O" + dashAdder(id: id)
                }
            case "medium":
                for _ in 0...currentAmount {
                    pattern += "o" + dashAdder(id: id)
                }
            case "light":
                for _ in 0...currentAmount {
                    pattern += "." + dashAdder(id: id)
                }
            case "rigid":
                for _ in 0...currentAmount {
                    pattern += "X" + dashAdder(id: id)
                }
            case "soft":
                for _ in 0...currentAmount {
                    pattern += "x" + dashAdder(id: id)
                }
            default:
                return
            }
            id+=1
        }
        Haptic.play(pattern, delay: delay)
    }
    
    func dashAdder(id: Int) -> String {
        
        var dashes = ""
        
        if (id < 1) {
            dashes += "-"
        } else if (id == 1) {
            dashes += "---"
        } else if (id == 2) {
            dashes += "------"
        } else if (id >= 3) {
            dashes += "------------"
        }
        return dashes
    }
    
    var body: some View {
        
        VStack {
            VStack {
                Text("Pizza").font(.custom("Recoleta-Bold", size: 56))
                Text("Roulette").font(.custom("Recoleta-Bold", size: 56)).offset(y: -20)
            }
            .padding(.top, 40)
            Spacer()
            ZStack {
                Text("Input pizza ranges below...").font(.custom("Recoleta-Medium", size: 24)).opacity(!showPizza ? 1.0 : 0.0)
                RouletteView(selectedIndex: $selectedIndex).opacity(showPizza ? 1.0 : 0.0)
            }
//                        LinearGradient(gradient: Gradient(stops: [
//                            .init(color: .white, location: 0.0),
//                            .init(color: .clear, location: 0.1),
//                            .init(color: .clear, location: 0.9),
//                            .init(color: .white, location: 1.0),
//                        ]), startPoint: .leading, endPoint: .trailing)
//                    }
            }
            Spacer()
            VStack {
                HStack {
                    TextField("Min", text: $lowerNumber)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .font(.custom("Recoleta-SemiBold", size: 24))
                        .frame(height: 48)
                        .background( RoundedRectangle(cornerRadius: 20) .fill(Color.init(red: 0.9, green: 0.9, blue: 0.9)))
                        .onReceive(Just(lowerNumber)) { newValue in
                            lowerNumber = limitText(textLimit, input: lowerNumber)
                            let filtered = newValue.filter { "0123456789".contains($0) }
                            if filtered != newValue {
                                self.lowerNumber = filtered
                            }
                        }
                        .padding(.trailing, 50)
                    
                    TextField("Max", text: $upperNumber)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .font(.custom("Recoleta-SemiBold", size: 24))
                        .frame(height: 48)
                        .background( RoundedRectangle(cornerRadius: 20) .fill(Color.init(red: 0.9, green: 0.9, blue: 0.9)))
                        .onReceive(Just(upperNumber)) { newValue in
                            upperNumber = limitText(textLimit, input: upperNumber)
                            let filtered = newValue.filter { "0123456789".contains($0) }
                            if filtered != newValue {
                                self.upperNumber = filtered
                            }
                        }
                        .padding(.leading, 50)
                }
                .padding(.bottom, 20)
                Button {
                    selectedIndex = Int.random(in: 0...10)
                    showPizza = true
                    //Haptic sequence is hardcoded to fit 10 sec duration. Dynamic approach is TODO
                    //hapticSequence(types: ["heavy", "heavy", "medium", "light"], pctIndices: [35,15,5,4], amount: pizzaList.count, delay: 0.05)
                    self.hideKeyboard()
                } label: {
                    Text("Prøv lykken!")
                        .font(.custom("Recoleta-SemiBold", size: 24))
                        .padding(20)
                }
                .disabled(isButtonDisabled)
                .frame(maxWidth: .infinity)
                .background(isButtonDisabled ? Color(red: 255/255, green: 110/255, blue: 64/255).opacity(0.4) : Color(red: 255/255, green: 110/255, blue: 64/255))
                .cornerRadius(20)
                .foregroundColor(.black)
                .shadow(color: Color(red: 255/255, green: 110/255, blue: 64/255, opacity: 0.7).opacity(isButtonDisabled ? 0 : 1), radius: 10, y: 10)
                .animation(.default, value: isButtonDisabled)
            }
            .padding(.leading, 40)
            .padding(.trailing, 40)
            .onTapGesture {
                self.hideKeyboard()
            }
        }
    }

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
