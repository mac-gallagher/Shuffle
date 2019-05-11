//
//  TinderButton.swift
//  ShuffleExample
//
//  Created by Mac Gallagher on 12/2/18.
//  Copyright © 2018 Mac Gallagher. All rights reserved.
//

import PopBounceButton

class TinderButton: PopBounceButton {
    override init() {
        super.init()
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        adjustsImageWhenHighlighted = false
        backgroundColor = .white
        layer.masksToBounds = true
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        layer.cornerRadius = frame.width / 2
    }
}
