//
//  RouletteView.swift
//  PizzaRoulette
//
//  Created by Philip Fisker on 02/05/2023.
//

import Foundation
import UIKit
import SwiftUI

struct RouletteView: UIViewRepresentable {
    @Binding var selectedIndex: Int
    
    func makeUIView(context: Context) -> UICollectionView {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int,
            layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            //                                    Text("\(pizza)").font(.custom("Cubano-Regular", size: 96))
            //                                        .frame(width: 170, height: 200)
            //                                        .background(Color(red: 247/255, green: 201/255, blue: 141/255))
            //                                        .cornerRadius(20)

            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .fractionalHeight(0.5))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .fractionalHeight(1.0))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 20
            section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
            
            return section
        }
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "My-cell")
        
        collectionView.dataSource = context.coordinator
        collectionView.isPagingEnabled = false
        collectionView.alwaysBounceVertical = false
        
        return collectionView
    }
    
    func updateUIView(_ uiView: UICollectionView, context: Context) {
        
        // withAnimation(Animation.timingCurve(0, 0.8, 0.2, 1, duration: 10))
        
        let timingCurve = UICubicTimingParameters(controlPoint1: CGPoint(x: 0.25, y: 0.1), controlPoint2: CGPoint(x: 0.25, y: 1.0))
        let animator = UIViewPropertyAnimator(duration: 5, timingParameters: timingCurve)

        animator.addAnimations {
            uiView.scrollToItem(at: .init(item: selectedIndex, section: 0), at: .centeredHorizontally, animated: false)
        }

        animator.startAnimation()
        
//        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 1, delay: 0, options: .curveEaseInOut, animations: {
//            uiView.scrollToItem(at: .init(item: selectedIndex, section: 0), at: .centeredHorizontally, animated: false)
//        }, completion: nil)
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    
    class Coordinator: NSObject, UICollectionViewDataSource {
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            50
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "My-cell", for: indexPath)
            cell.backgroundColor = .gray
            print(indexPath)
            return cell
        }
        
        
    }
    
    typealias UIViewType = UICollectionView
    
}
