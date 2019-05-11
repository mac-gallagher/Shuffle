//
//  Array+Extensions.swift
//  Shuffle
//
//  Created by Mac Gallagher on 6/9/19.
//  Copyright © 2019 Mac Gallagher. All rights reserved.
//

import Foundation

extension Array {
    func shift(withDistance distance: Int = 1) -> Array<Element> {
        let offsetIndex = distance >= 0
            ? index(startIndex, offsetBy: distance, limitedBy: endIndex)
            : index(endIndex, offsetBy: distance, limitedBy: startIndex)
        guard let index = offsetIndex else { return self }
        return Array(self[index ..< endIndex] + self[startIndex ..< index])
    }
}
