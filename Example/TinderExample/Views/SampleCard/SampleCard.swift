//
//  SampleCard.swift
//  ShuffleExample
//
//  Created by Mac Gallagher on 7/12/18.
//  Copyright © 2018 Mac Gallagher. All rights reserved.
//

import UIKit
import Shuffle

class SampleCard: SwipeCard {
    
    override var swipeDirections: [SwipeDirection] {
        return [.left, .up, .right]
    }
    
    init(model: SampleCardModel) {
        super.init(frame: .zero)
        initialize()
        configure(model: model)
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    private func initialize() {
        footerHeight = 80
    }
    
    override func overlay(forDirection direction: SwipeDirection) -> UIView? {
        switch direction {
        case .left:
            return SampleCardOverlay.left()
        case .up:
            return SampleCardOverlay.up()
        case.right:
            return SampleCardOverlay.right()
        default:
            return nil
        }
    }
    private func configure(model: SampleCardModel) {
        content = SampleCardContentView(image: model.image)
        footer = SampleCardFooterView(title: "\(model.name), \(model.age)", subtitle: model.occupation)
    }
}
