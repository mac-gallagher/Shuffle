import Foundation

extension Array {
    
    mutating func shift(withDistance distance: Int = 1) {
        let offsetIndex = distance >= 0
            ? index(startIndex, offsetBy: distance, limitedBy: endIndex)
            : index(endIndex, offsetBy: distance, limitedBy: startIndex)
        guard let index = offsetIndex else { return }
        self = Array(self[index ..< endIndex] + self[startIndex ..< index])
    }
}
