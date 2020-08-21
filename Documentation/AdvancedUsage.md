# Advanced Usage

* [Animations](#animations)
* [Inserting and Deleting Cards](#inserting-and-deleting-cards)
* [Swipe Recognition](#swipe-recognition)

## Animations
// TODO

## Inserting and Deleting Cards

If you're using an external API to retrieve your `SwipeCard` data models, chances are you'll need to update the card stack occasionally as new models come in. As of version [0.4.0](https://github.com/mac-gallagher/Shuffle/releases/tag/v0.4.0), Shuffle includes the following methods on `SwipeCardStack`:

```swift
func insertCard(atIndex index: Int, position: Int)
func appendCards(atIndices indices: [Int]) // Index refers to the index of the card in the data source
```
```swift
func deleteCards(atIndices indices: [Int])
func deleteCards(atPositions positions: [Int]) // Position refers to the position of the card in the stack
```

Using the insert methods in particular, we can give the illusion of an "infinite" card stack. Let's look at an example.

### External API Example
Suppose we have a utility which fetches raw data models and decodes them into an array of `CardModels`:

```swift
struct NetworkUtility {
  static func fetchNewCardModels(@escaping completion: ([CardModel]) -> ()) {
    // Decode network models into array of CardModels and return result in completion block
  }
}
```

The following view controller displays a `SwipeCardStack` and holds a reference to the card models. In this example, the new models are fetched and added to the card stack after every 10 swipes:

```swift
class ViewController: UIViewController: SwipeCardStackDataSource, SwipeCardStackDelegate {

  let cardStack = SwipeCardStack()
  var cardModels: [CardModel]
  var swipedCount: Int = 0
	
  func viewDidLoad() {
    super.viewDidLoad()
    cardStack.dataSource = self
    cardStack.delegate = self
    
    // Layout cardStack on view
    
    addCards()
  }
	
  // MARK: SwipeCardStackDataSource
	
  func numberOfCards(in cardStack: SwipeCardStack) -> Int {
    return cardModels.count
  }
	
  func cardStack(_ cardStack: SwipeCardStack, cardForIndexAt index: Int) -> SwipeCard {
    let card = SwipeCard()
    card.model = cardModels[index]
    return card
  }
	
  // MARK: SwipeCardStackDelegate
	
  func didSwipeCard(atIndex index: Int) {
    swipedCount += 1
    if swipedCount % 10 == 0 {
      addCards()
    }
  }
	
  private func addCards() {
    NetworkUtility.fetchNewCardModels { [weak self] newModels in
      guard let strongSelf = self else { return }
        
      let oldModelsCount = strongSelf.cardModels.count
      let newModelsCount = oldModelCount + newModels.count
        
      DispatchQueue.main.async {
        strongSelf.cardModels.append(contentsOf: newModels)
          
        let newIndices = Array(oldModelsCount..<newModelsCount)
        strongSelf.cardStack.appendCards(atIndices: newIndices)
      }
    }
  }
}
```

Here, we use the `appendCards:` method to append the new cards to the bottom of the card stack. If instead we wanted to add the cards to the top of the stack, we could do something like

```swift
NetworkUtility.fetchNewCardModels { [weak self] newModels in
  guard let strongSelf = self else { return }
	
  DispatchQueue.main.async {
    // Insert in reverse order so that newModels.first is the model for the topmost card
    for model in newModels.reversed() {
      strongSelf.cardModels.insert(model, at: 0)
      strongSelf.cardStack.insertCard(atIndex: 0, position: 0)
    }
  }
}
```

### Common pitfalls
If you are familar with the common pitfalls of the insert/delete row methods on `UITableView`, the exact same pitfalls apply here. There is, however, one crucial difference between the two insert methods:

```swift
// UITableView
func insertRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation)
```

```swift
// SwipeCardStack
func insertCard(atIndex: Int, position: Int)
```

The `insertCard` method has an additional `position` parameter which represents the inserted position in the card stack, whereas the `index` parameter represents the index of the card/model in the data source. The `position` is dynamic based on the number of cards remaining (not swiped) in the stack. **Note**: For a `UITableView`, the `indexPath` and `index/position` parameters are equavalent.

Since the number of remaining cards is subject to change, be sure to calculate the `position` based on the value returned from the `numberOfRemainingCards:` method on `SwipeCardStack`.

## Swipe Recognition
// TODO
