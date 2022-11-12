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
    @State var upperNumber = "10"
    @State var pizzaNum = 0
    @State var pizzaList:[Int] = []
    
    @State var proxy: GeometryProxy?
    @State var scrollView: GeometryProxy?
    @State var offset: CGFloat = 0
    
    var body: some View {
        
        VStack {
            Spacer()
            if !showPizza {
                Text("Input pizza ranges...")
            } else {
                GeometryReader { scrollView in
                    ScrollView {
                        VStack {
                            ForEach(pizzaList, id: \.self) { pizza in
                                Text("\(pizza)").font(.system(size: 200))
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
                            .init(color: .clear, location: 0.05),
                            .init(color: .clear, location: 0.95),
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
                TextField("Lower number", text: $lowerNumber)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .background(Color(.systemFill))
                    .cornerRadius(6)
                    .onReceive(Just(lowerNumber)) { newValue in
                        let filtered = newValue.filter { "0123456789".contains($0) }
                        if filtered != newValue {
                            self.lowerNumber = filtered
                        }
                    }
                    .padding(.leading, 40)
                    .padding(.trailing, 40)
                
                TextField("Upper number", text: $upperNumber)
                    .keyboardType(.numberPad)
                    .background(Color(.systemFill))
                    .cornerRadius(6)
                    .multilineTextAlignment(.center)
                    .onReceive(Just(upperNumber)) { newValue in
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
                showPizza = true
                var tempPizzaList = Array(0...(Int(upperNumber) ?? 0))
                tempPizzaList.shuffle()
                while tempPizzaList.count < 100 {
                    tempPizzaList.append(contentsOf: tempPizzaList)
                }
                pizzaNum = tempPizzaList.last ?? 0
                pizzaList = tempPizzaList
                offset = 0
                    withAnimation(Animation.timingCurve(0, 0.8, 0.2, 1, duration: 10)) {
                        offset = CGFloat(-(proxy?.size.height ?? 0) + (scrollView?.size.height ?? 0))
                    }
            } label: {
                Text("Prøv lykken!")
                    .padding(20)
            }
            .background(Color(red: 247/255, green: 201/255, blue: 141/255))
            .cornerRadius(12)
            .foregroundColor(.black)
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
