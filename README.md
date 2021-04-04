<p align="center">
<img src="https://raw.githubusercontent.com/mac-gallagher/Shuffle/master/Assets/logo.png" width="650">
</p>

</br>

<p align="center">
<a href="https://cocoapods.org/pods/Shuffle-iOS"><img alt="Platform" src="https://img.shields.io/cocoapods/p/Shuffle-iOS.svg"/></a>
<a href="https://swift.org"><img alt="Swift Version" src="https://img.shields.io/badge/swift-5.x.x-223344.svg?logo=swift&labelColor=FA7343&logoColor=white"/></a>
<a href="https://travis-ci.org/mac-gallagher/Shuffle"><img alt="Build Status" src="https://travis-ci.org/mac-gallagher/Shuffle.svg?branch=master"/></a>
<a href="https://swift.org/package-manager"><img alt="Swift Package Manager" src="https://img.shields.io/badge/swift pm-compatible-yellow.svg"/></a>
<a href="https://cocoapods.org/pods/Shuffle-iOS"><img alt="CocoaPods" src="https://img.shields.io/cocoapods/v/Shuffle-iOS.svg"/></a>
<a href="https://github.com/Carthage/Carthage"><img alt="Carthage" src="https://img.shields.io/badge/carthage-compatible-blue.svg?style=flat)"/></a>
<a href="https://codecov.io/gh/mac-gallagher/Shuffle"><img alt="Code Coverage" src="https://codecov.io/gh/mac-gallagher/Shuffle/branch/master/graph/badge.svg"></a>
<a href="https://github.com/mac-gallagher/Shuffle/blob/master/LICENSE"><img alt="LICENSE" src="https://img.shields.io/cocoapods/l/Shuffle-iOS"></a>
</p>

<p align="center">
Made with ❤️ by <a href="https://github.com/mac-gallagher">Mac Gallagher</a>
</p>

## Features

💡 Advanced swipe recognition based on velocity and card position

💡 Manual and programmatic actions

💡 Smooth card overlay view transitions

💡 Fluid and customizable animations

💡 Dynamic card loading using data source pattern

## Example
To run the example project, clone the repo and run the `ShuffleExample` target.

<p align="left">
<img src="https://raw.githubusercontent.com/mac-gallagher/Shuffle/master/Assets/swipe_example.gif" width="280">
</p>

## Basic Usage

1.  Create your own card by either subclassing `SwipeCard` or setting its properties directly:

    
    ```swift
    func card(fromImage image: UIImage) -> SwipeCard {
      let card = SwipeCard()
      card.swipeDirections = [.left, .right]
      card.content = UIImageView(image: image)
      
      let leftOverlay = UIView()
      leftOverlay.backgroundColor = .green
      
      let rightOverlay = UIView()
      rightOverlay.backgroundColor = .red
      
      card.setOverlays([.left: leftOverlay, .right: rightOverlay])
      
      return card
    }
    ```
    The card returned from `card(fromImage:)` displays an image, can be swiped left or right, and has overlay views for both directions.

2. Initialize your card data and place a `SwipeCardStack` on your view:

    ```swift
    class ViewController: UIViewController {
      let cardStack = SwipeCardStack()
      
      let cardImages = [
          UIImage(named: "cardImage1"),
          UIImage(named: "cardImage2"),
          UIImage(named: "cardImage3")
      ]
      
      override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(cardStack)
        cardStack.frame = view.safeAreaLayoutGuide.layoutFrame
      }
    }
    ```
    
3. Conform your class to `SwipeCardStackDataSource` and set your card stack's `dataSource`:
    
    ```swift
    func cardStack(_ cardStack: SwipeCardStack, cardForIndexAt index: Int) -> SwipeCard {
      return card(fromImage: cardImages[index])
    }
    
    func numberOfCards(in cardStack: SwipeCardStack) -> Int {
      return cardImages.count
    }
    ```
    ```swift
    cardStack.dataSource = self
    ```
    
3. Conform to `SwipeCardStackDelegate` to subscribe to any of the following events:

   ```swift
    func cardStack(_ cardStack: SwipeCardStack, didSelectCardAt index: Int)
    func cardStack(_ cardStack: SwipeCardStack, didSwipeCardAt index: Int, with direction: SwipeDirection)
    func cardStack(_ cardStack: SwipeCardStack, didUndoCardAt index: Int, from direction: SwipeDirection)
    func didSwipeAllCards(_ cardStack: SwipeCardStack)
   ```
   
   **Note**: `didSwipeCardAt` and `didSwipeAllCards`  are called regardless if a card is swiped programmatically or by the user.

## Card Stack Actions
The following methods are available on `SwipeCardStack`.

### Swipe
Performs a swipe programmatically in the given direction.

```swift
func swipe(_ direction: SwipeDirection, animated: Bool)
```

<img src="https://raw.githubusercontent.com/mac-gallagher/Shuffle/master/Assets/swipe.gif" width="200">

### Shift
Shifts the card stack's cards by the given distance. Any swiped cards are skipped over.

```swift
func shift(withDistance distance: Int = 1, animated: Bool)
```

<img src="https://raw.githubusercontent.com/mac-gallagher/Shuffle/master/Assets/shift.gif" width="200">

### Undo
Returns the most recently swiped card to the top of the card stack.

```swift
func undoLastSwipe(animated: Bool)
```

<img src="https://raw.githubusercontent.com/mac-gallagher/Shuffle/master/Assets/undo.gif" width="200">

## Card Layout
Each `SwipeCard` consists of three UI components: its *content*, *footer*, and *overlay(s)*.

### Content
The content is the card's primary view. You can include your own card template here.

```swift
var content: UIView? { get set }
```

### Footer
The footer is an axuilliary view on the bottom of the card. It is laid out above the content in the view hierarchy if the footer is transparent. Otherwise, the footer is drawn just below the content.

<p align="center">
<img src="https://raw.githubusercontent.com/mac-gallagher/Shuffle/master/Assets/footer_layout.png" width="700">
</p>

```swift
var footer: UIView? { get set }
var footerHeight: CGFloat { get set }
```

### Overlays
An overlay is a view whose alpha value reacts to the user's dragging. The overlays are laid out above the footer, regardless if the footer is transparent or not. 

```swift
func overlay(forDirection direction: SwipeDirection) -> UIView?
func setOverlay(_ overlay: UIView?, forDirection direction: SwipeDirection)
func setOverlays(_ overlays: [SwipeDirection: UIView])
```

## Advanced Usage
For more advanced usage, including

* [Animations](Documentation/AdvancedUsage.md#animations)
* [Inserting and Deleting Cards](Documentation/AdvancedUsage.md#inserting-and-deleting-cards)
* [Swipe Recognition](Documentation/AdvancedUsage.md#swipe-recognition)

visit the document [here](Documentation/AdvancedUsage.md).

## Installation

### CocoaPods
Shuffle is available through [CocoaPods](<https://cocoapods.org/>). To install it, simply add the following line to your `Podfile`:

	pod 'Shuffle-iOS'

The import statement in this case will be

```swift
import Shuffle_iOS
```

### Carthage

Shuffle is available through [Carthage](<https://github.com/Carthage/Carthage>). To install it, simply add the following line to your Cartfile:

	github "mac-gallagher/Shuffle"

### Swift Package Manager
Shuffle is available through [Swift PM](<https://swift.org/package-manager/>). To install it, simply add the package as a dependency in `Package.swift`:

```swift
dependencies: [
  .package(url: "https://github.com/mac-gallagher/Shuffle.git", from: "0.1.0"),
]
```

### Manual
Download and drop the `Sources` directory into your project.

## Requirements
* iOS 9.0+
* Xcode 10.2+
* Swift 5.0+

## Apps Using Shuffle
We love to hear about apps that use Shuffle - feel free to submit a pull request and share yours here!

<p>
<a href="https://www.dropinapp.net">
<img src="https://raw.githubusercontent.com/mac-gallagher/Shuffle/master/Assets/AppIcons/drop_in_app_icon.png" title="Drop In for Fortnite" width="80" align="center"></a>

<a href="https://apps.apple.com/us/app/ovia-pregnancy-tracker/id719135369">
<img src="https://raw.githubusercontent.com/mac-gallagher/Shuffle/master/Assets/AppIcons/ovia_app_icon.png" title="Ovia Pregnancy Tracker" width="80" align="center"></a>

<a href="https://apps.apple.com/us/app/topface-dating-app-and-chat/id505446332">
<img src="https://raw.githubusercontent.com/mac-gallagher/Shuffle/master/Assets/AppIcons/topface_app_icon.png" title="Topface" width="80" align="center"></a>

<a href="https://apps.apple.com/bw/app/dankr/id1478419632">
<img src="https://raw.githubusercontent.com/mac-gallagher/Shuffle/master/Assets/AppIcons/dankr_app_icon.png" title="Dankr" width="80" align="center"></a>

<a href="https://apps.apple.com/us/app/id1516742129">
<img src="https://raw.githubusercontent.com/mac-gallagher/Shuffle/master/Assets/AppIcons/eternal_app_icon.png" title="Eternal" width="80" align="center"></a>

<a href="https://apps.apple.com/us/app/kanji-memo/id1552701832">
<img src="Assets/AppIcons/KanjiMemo_app_icon.png" title="Kanji-Memo" width="80" align="center"></a>
</p>

---

<p align="center">
Made with ❤️ by <a href="https://github.com/mac-gallagher">Mac Gallagher</a>
