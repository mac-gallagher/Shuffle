<img src="https://raw.githubusercontent.com/mac-gallagher/Shuffle/master/Images/swipe_example.gif" width="230" align="right">

</br>

<p align="center">
<img src="https://raw.githubusercontent.com/mac-gallagher/Shuffle/master/Images/header.png" width="400">

<H4 align="center">
🔥 A multi-directional card swiping library inspired by Tinder.
</H4>
</p>

<p align="center">
<a href="https://developer.apple.com/swift"><img alt="Swift 5" src="https://img.shields.io/badge/language-Swift_5-orange.svg"/></a>
<a href="https://cocoapods.org/pods/Shuffle-iOS"><img alt="CocoaPods" src="https://img.shields.io/cocoapods/v/Shuffle-iOS.svg"/></a>
<a href="https://github.com/Carthage/Carthage"><img alt="Carthage" src="https://img.shields.io/badge/carthage-compatible-4BC51D.svg?style=flat)"/></a>
<a href="https://swift.org/package-manager"><img alt="Swift Package Manager" src="https://img.shields.io/badge/swift pm-compatible-yellow.svg"/></a>
</br>
<a href="https://travis-ci.org/mac-gallagher/Shuffle"><img alt="Build Status" src="https://travis-ci.org/mac-gallagher/Shuffle.svg?branch=master"/></a>
<a href="https://cocoapods.org/pods/Shuffle-iOS"><img alt="Platform" src="https://img.shields.io/cocoapods/p/Shuffle-iOS.svg"/></a>
<a href="https://codecov.io/gh/mac-gallagher/Shuffle"><img alt="Code Coverage" src="https://codecov.io/gh/mac-gallagher/Shuffle/branch/master/graph/badge.svg"></a>
<a href="https://github.com/mac-gallagher/Shuffle/blob/master/LICENSE"><img alt="LICENSE" src="https://img.shields.io/cocoapods/l/Shuffle-iOS"></a>
</p>

<p align="center">
Made with ❤️ by <a href="https://github.com/mac-gallagher">Mac Gallagher</a>
</p>

</br>


## Features

💡 Advanced swipe recognition based on velocity and card position

💡 Manual and programmatic actions

💡 Smooth card overlay view transitions

💡 Fluid and customizable animations

💡 Dynamic card loading using data source pattern

## Example
To run the example project, clone the repo and run the `ShuffleExample` target.

## Basic Usage

1. Create your own card by subclassing `SwipeCard`. The card below displays an image, can be swiped left or right, and has overlay views for both directions:

    ```swift
    class SampleCard: SwipeCard {
       override var swipeDirections {
          return [.left, .right]
       }
       
       init(image: UIImage) {
            content = UIImageView(image: image)
            leftOverlay = UIView()
            rightOverlay = UIView()
            
            leftoverlay.backgroundColor = .green
            rightOverlay.backgroundColor = .red
       }
    }
    ```

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
            cardStack.frame = view.safeAreaLayoutGuide
                                  .bounds.insetBy(dx: 10, dy: 50)
        }
    }
    ```
3. Conform your class to the `SwipeCardStackDataSource` protocol and set your card stack's `dataSource`:
    
    ```swift
    func numberOfCards(in cardStack: SwipeCardStack) -> Int {
       return cardImages.count
    }
    
    func cardStack(_ cardStack: SwipeCardStack, cardForIndexAt index: Int) -> SwipeCard {
       return SampleCard(image: cardImages[index])
    }
    ```
    ```swift
    cardStack.dataSource = self
    ```
3. Conform to the `SwipeCardStackDelegate` protocol to subscribe to any of the following events:

   ```swift
    func didSwipeAllCards(_ cardStack: SwipeCardStack)
    func cardStack(_ cardStack: SwipeCardStack, didSwipeCardAt index: Int, with direction: SwipeDirection)
    func cardStack(_ cardStack: SwipeCardStack, didUndoCardAt index: Int, from direction: SwipeDirection)
    func cardStack(_ cardStack: SwipeCardStack, didSelectCardAt index: Int)

   ```
   
   **Note**:  `didSwipeCardAt` and `didSwipeAllCards`  are called regardless if a card is swiped programmatically or by the user.

## Card Actions
The following methods are available on `SwipeCardStack`.

### Swipe
Performs a swipe programmatically in the given direction.

```swift
func swipe(_ direction: SwipeDirection, animated: Bool)
```

<img src="https://raw.githubusercontent.com/mac-gallagher/Shuffle/master/Images/swipe.gif" width="200">

### Undo
Restores the card stack to its state before the last swipe.

```swift
func undoLastSwipe(animated: Bool)
```

<img src="https://raw.githubusercontent.com/mac-gallagher/Shuffle/master/Images/undo.gif" width="200">

### Shift
Shifts the card stack's cards by the given distance. Any swiped cards are skipped over.

```swift
func shift(withDistance distance: Int = 1, animated: Bool)
```

<img src="https://raw.githubusercontent.com/mac-gallagher/Shuffle/master/Images/shift.gif" width="200">

## Advanced Usage
For more advanced usage, including

* [Animations](Documentation/AdvancedUsage.md#animations)
* [Card Layout](Documentation/AdvancedUsage.md#card-layout)
* [Swipe Recognition](Documentation/AdvancedUsage.md#swipe-recognition)

visit the document [here](Documentation/AdvancedUsage.md).

## Installation

### CocoaPods
Shuffle is available through [CocoaPods](<https://cocoapods.org/>). To install it, simply add the following line to your `Podfile`:

	pod 'Shuffle-iOS'

### Carthage

Shuffle is available through [Carthage](<https://github.com/Carthage/Carthage>). To install it, simply add the following line to your Cartfile:

	github "mac-gallagher/Shuffle"

### Swift Package Manager
MultiProgressView is available through [Swift PM](<https://swift.org/package-manager/>). To install it, simply add the package as a dependency in `Package.swift`:

```swift
dependencies: [
  .package(url: "https://github.com/mac-gallagher/Shuffle.git", from: "0.1.0"),
]
```

### Manual
Download and drop the `Shuffle` directory into your project.

## Requirements
* iOS 9.0+
* Xcode 10.2+
* Swift 5.0+

## Apps Using Shuffle
We love to hear about apps that use Shuffle - feel free to submit a pull request and share yours here!

</br>

---

<p align="center">
Made with ❤️ by <a href="https://github.com/mac-gallagher">Mac Gallagher</a>
</br>
(Graphic designed by <a href="mailto:mghani@uwm.edu">Mazen Ghani</a>)
</p>