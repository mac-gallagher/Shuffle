import Foundation

typealias Swipe = (index: Int, direction: SwipeDirection)

/// An internal data structure to represent the current state of the card stack.
///
/// A new state is created each time a user *swipes*, *shifts*, or *undos* a card on the stack.
/// Each state contains a reference to the state before it.
class CardStackState: Equatable {
    
    /// The initial state of the card stack.
    static var emptyState: CardStackState {
        return CardStackState(remainingIndices: [])
    }
    
    /// The indices of the data source which have yet to be swiped.
    ///
    /// This array reflects the current order of the card stack, with the first element equal
    /// to the index of the top card in the data source. The order of this array accounts
    /// for both swiped and shifted cards in the stack.
    let remainingIndices: [Int]
    
    /// The swipe which occured in the previous state.
    let previousSwipe: Swipe?
    
    /// A reference to the previous card stack state.
    let previousState: CardStackState?
    
    init(remainingIndices: [Int],
         previousSwipe: Swipe? = nil,
         previousState: CardStackState? = nil) {
        self.remainingIndices = remainingIndices
        self.previousSwipe = previousSwipe
        self.previousState = previousState
    }
    
    // MARK: - Equatable
    
    static func ==(lhs: CardStackState, rhs: CardStackState) -> Bool {
        return lhs.remainingIndices == rhs.remainingIndices
            && lhs.previousState == rhs.previousState
            && lhs.previousSwipe?.index == rhs.previousSwipe?.index
            && lhs.previousSwipe?.direction == rhs.previousSwipe?.direction
    }
}
