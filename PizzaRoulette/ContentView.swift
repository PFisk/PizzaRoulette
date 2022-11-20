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
//
//    func hapticSeq(type: String, amount: Int, delay: Double) -> Void {
//
//        var pattern = ""
//
//        switch (type) {
//        case "heavy":
//            for _ in 0...amount {
//                pattern += "O-"
//            }
//            Haptic.play(pattern, delay: delay)
//        case "medium":
//            for _ in 0...amount {
//                pattern += "o-"
//            }
//            Haptic.play(pattern, delay: delay)
//        case "light":
//            for _ in 0...amount {
//                pattern += ".-"
//            }
//            Haptic.play(pattern, delay: delay)
//        case "rigid":
//            for _ in 0...amount {
//                pattern += "X-"
//            }
//            Haptic.play(pattern, delay: delay)
//        case "soft":
//            for _ in 0...amount {
//                pattern += "x-"
//            }
//            Haptic.play(pattern, delay: delay)
//        default:
//            return
//        }
//    }
    
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
            Spacer()
            if !showPizza {
                Text("Input pizza ranges...").font(.system(size: 24))
            } else {
                GeometryReader { scrollView in
                    ScrollView {
                        VStack {
                            ForEach(pizzaList, id: \.self) { pizza in
                                Text("\(pizza)").font(.custom("Cubano-Regular", size: 200))
                                //Text("Global : (\(Int(scrollView.frame(in: .global).midX)), \(Int(scrollView.frame(in: .global).midY))) Local: (\(Int(scrollView.frame(in: .local).midX)), \(Int(scrollView.frame(in: .local).midY)))")
                            }
                        }
                        .background(
                            GeometryReader { proxy in
                                Color.clear.onAppear {
                                    self.proxy = proxy
                                }
                            }
                        )
                        .offset(y: offset)
                    }
                    .scrollDisabled(true)
                    .frame(width: scrollView.size.width, height: scrollView.size.height)
                    .overlay {
                        LinearGradient(gradient: Gradient(stops: [
                            .init(color: .white, location: 0.0),
                            .init(color: .clear, location: 0.2),
                            .init(color: .clear, location: 0.8),
                            .init(color: .white, location: 1.0),
                        ]), startPoint: .top, endPoint: .bottom)
                    }
                    .onAppear {
                        self.scrollView = scrollView
                    }
                }
            }
            Spacer()
            HStack {
                TextField("Min", text: $lowerNumber)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 24))
                    .background( RoundedRectangle(cornerRadius: 12) .fill(Color.init(red: 0.9, green: 0.9, blue: 0.9)))
                    .onReceive(Just(lowerNumber)) { newValue in
                        lowerNumber = limitText(textLimit, input: lowerNumber)
                        let filtered = newValue.filter { "0123456789".contains($0) }
                        if filtered != newValue {
                            self.lowerNumber = filtered
                        }
                    }
                    .padding(.leading, 40)
                    .padding(.trailing, 40)
                
                TextField("Max", text: $upperNumber)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 24))
                    .background( RoundedRectangle(cornerRadius: 12) .fill(Color.init(red: 0.9, green: 0.9, blue: 0.9)))
                    .onReceive(Just(upperNumber)) { newValue in
                        upperNumber = limitText(textLimit, input: upperNumber)
                        let filtered = newValue.filter { "0123456789".contains($0) }
                        if filtered != newValue {
                            self.upperNumber = filtered
                        }
                    }
                    .padding(.leading, 40)
                    .padding(.trailing, 40)
            }
            .padding(.bottom, 20)
            Button {
                var tempPizzaList:[Int] = []
                let tempLowerNum:Int = (Int(lowerNumber) ?? 0)
                let tempUpperNum:Int = (Int(upperNumber) ?? 0)
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
                offset = 0
                    withAnimation(Animation.timingCurve(0, 0.8, 0.2, 1, duration: 10)) {
                        offset = CGFloat(-(proxy?.size.height ?? 0) + (scrollView?.size.height ?? 0)) + 70
                    }
//                hapticSeq(type: "heavy", amount: 35, delay: 0.05)
//                hapticSeq(type: "medium", amount: 35, delay: 0.1)
//                hapticSeq(type: "light", amount: 20, delay: 0.14)
//                hapticSeq(type: "light", amount: 10, delay: 0.2)
                hapticSequence(types: ["heavy", "heavy", "medium", "light"], pctIndices: [35,15,5,4], amount: pizzaList.count, delay: 0.05)
                showPizza = true
                self.hideKeyboard()
            } label: {
                Text("Prøv lykken!")
                    .padding(20)
            }
            .background(Color(red: 247/255, green: 201/255, blue: 141/255))
            .cornerRadius(12)
            .foregroundColor(.black)
        }
        .padding()
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
