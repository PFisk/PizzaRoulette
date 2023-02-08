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
        
    @State var proxy: GeometryProxy?
    @State var scrollView: GeometryProxy?
    @State var offset: CGFloat = 0
    
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
    
    func wheelSpin() -> Void {
        offset = 0
        //Duration time is hardcoded with haptics to match. A dynamic approach is TODO
        withAnimation(Animation.timingCurve(0, 0.8, 0.2, 1, duration: 10)) {
                offset = CGFloat(-(proxy?.size.width ?? 0) + (scrollView?.size.width ?? 0)) + 80
            }
    }
    
    func getPizza(min: Int, max: Int) -> Void {
        var tempPizzaList:[Int] = []
        let tempLowerNum:Int = (min)
        let tempUpperNum:Int = (max)
        if tempLowerNum >= tempUpperNum {
            return
        }
        let numRange = (tempLowerNum...tempUpperNum)
        tempPizzaList.append(contentsOf: numRange)
        tempPizzaList.shuffle()
        while tempPizzaList.count < 100 {
            tempPizzaList.append(contentsOf: tempPizzaList)
        }
        for _ in 1...3 { tempPizzaList.append( Int.random(in: tempLowerNum...tempUpperNum))
        }
        pizzaNum = tempPizzaList.last ?? 0
        pizzaList = tempPizzaList
        showPizza = true
        wheelSpin()
    }
    
    var body: some View {
        
        VStack {
            VStack {
                Text("Pizza").font(.custom("Recoleta-Bold", size: 56))
                Text("Roulette").font(.custom("Recoleta-Bold", size: 56)).offset(y: -20)
            }
            .padding(.top, 40)
            Spacer()
            if !showPizza {
                Text("Input pizza ranges below...").font(.custom("Recoleta-Medium", size: 24))
            } else {
                GeometryReader { scrollView in
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(pizzaList, id: \.self) { pizza in
                                ZStack {
                                    Text("\(pizza)").font(.custom("Cubano-Regular", size: 96))
                                        .frame(width: 170, height: 200)
                                        .background(Color(red: 247/255, green: 201/255, blue: 141/255))
                                        .cornerRadius(20)
                                }
                            }
                        }
                        .background(
                            GeometryReader { proxy in
                                Color.clear.onAppear {
                                    self.proxy = proxy
                                }
                            }
                        )
                        .offset(x: offset)
                    }
                    .scrollDisabled(true)
                    .frame(width: scrollView.size.width, height: scrollView.size.height)
                    .overlay {
                        LinearGradient(gradient: Gradient(stops: [
                            .init(color: .white, location: 0.0),
                            .init(color: .clear, location: 0.1),
                            .init(color: .clear, location: 0.9),
                            .init(color: .white, location: 1.0),
                        ]), startPoint: .leading, endPoint: .trailing)
                    }
                    .onAppear {
                        self.scrollView = scrollView
                        wheelSpin()
                    }
                }
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
                    getPizza(min: Int(lowerNumber) ?? 0, max: Int(upperNumber) ?? 0)
                    //Haptic sequence is hardcoded to fit 10 sec duration. Dynamic approach is TODO
                    hapticSequence(types: ["heavy", "heavy", "medium", "light"], pctIndices: [35,15,5,4], amount: pizzaList.count, delay: 0.05)
                    self.hideKeyboard()
                } label: {
                    Text("Prøv lykken!")
                        .font(.custom("Recoleta-SemiBold", size: 24))
                        .padding(20)
                }
                .frame(maxWidth: .infinity)
                .background(Color(red: 255/255, green: 110/255, blue: 64/255))
                .cornerRadius(20)
                .foregroundColor(.black)
                .shadow(color: Color(red: 255/255, green: 110/255, blue: 64/255, opacity: 0.7), radius: 10, y: 10)
            }
            .padding(.leading, 40)
            .padding(.trailing, 40)
            .onTapGesture {
                self.hideKeyboard()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
