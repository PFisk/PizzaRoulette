//
//  ScrollOffsetPreferenceKey.swift
//  PizzaRoulette
//
//  Created by Philip Fisker on 17/11/2022.
//
import SwiftUI

struct ScrollOffsetPreferenceKey: PreferenceKey {
    typealias Value = [CGFloat]
    
    static var defaultValue: [CGFloat] = [0]
    
    static func reduce(value: inout [CGFloat], nextValue: () -> [CGFloat]) {
        value.append(contentsOf: nextValue())
    }
}
