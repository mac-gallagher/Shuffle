.. Shuffle Docs documentation master file, created by
   sphinx-quickstart on Wed Aug 28 15:21:47 2019.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Welcome to Shuffle Docs's documentation!
========================================

.. toctree::
   :maxdepth: 2
.. contents:: :local:

########
Features
########

- 💡 Advanced swipe recognition based on velocity and card position
- 💡 Manual and programmatic actions
- 💡 Smooth card overlay view transitions
- 💡 Fluid and customizable animations
- 💡 Dynamic card loading using data source pattern


#######
Example
#######

To run the example project, clone the repo and run the ``ShuffleExample`` target.

###########
Basic Usage
###########

1. Create your own card by subclassing SwipeCard. The card below displays an image, can be swiped left or right, and has overlay views for both directions:

.. sourcecode:: swift 

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



  
2. Initialize your card data and place a ``SwipeCardStack`` on your view:

.. code-block:: swift

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


3. Conform your class to the ``SwipeCardStackDataSource`` protocol and set your card stack's ``dataSource``:

.. code-block:: swift
  func numberOfCards(in cardStack: SwipeCardStack) -> Int {
   return cardImages.count
}

func cardStack(_ cardStack: SwipeCardStack, cardForIndexAt index: Int) -> SwipeCard {
   return SampleCard(image: cardImages[index])
}
    


4. Conform to the ``SwipeCardStackDelegate`` protocol to subscribe to any of the following events:

.. sourcecode:: swift 

 func didSwipeAllCards(_ cardStack: SwipeCardStack)
 func cardStack(_ cardStack: SwipeCardStack, didSwipeCardAt index: Int, with direction: SwipeDirection)
 func cardStack(_ cardStack: SwipeCardStack, didUndoCardAt index: Int, from direction: SwipeDirection)
 func cardStack(_ cardStack: SwipeCardStack, didSelectCardAt index: Int)

Note: ``didSwipeCardAt`` and ``didSwipeAllCards`` are called regardless if a card is swiped programmatically or by the user.


============
Card Actions
============

The following methods are available on ``SwipeCardStack``.

*****
Swipe
*****

Performs a swipe programmatically in the given direction.

.. sourcecode:: swift

    func swipe(_ direction: SwipeDirection, animated: Bool)

.. image:: https://raw.githubusercontent.com/mac-gallagher/Shuffle/master/Images/swipe.gif

.. sourcecode:: swift
   func swipe(_ direction: SwipeDirection, animated: Bool)

****
Undo
****
Restores the card stack to its state before the last swipe.

.. sourcecode:: swift

 func undoLastSwipe(animated: Bool)

.. image:: https://raw.githubusercontent.com/mac-gallagher/Shuffle/master/Images/undo.gif


*****
Shift
*****

Shifts the card stack's cards by the given distance. Any swiped cards are skipped over.

.. sourcecode:: swift
  
 func shift(withDistance distance: Int = 1, animated: Bool)

.. image:: https://raw.githubusercontent.com/mac-gallagher/Shuffle/master/Images/shift.gif


==============
Advanced Usage
==============

For more advanced usage, including

- `Animations <https://github.com/mac-gallagher/Shuffle/blob/master/Documentation/AdvancedUsage.md#animations>`_

- `Card Layout <https://github.com/mac-gallagher/Shuffle/blob/master/Documentation/AdvancedUsage.md#card-layout>`_


- `Swipe Recognition <https://github.com/mac-gallagher/Shuffle/blob/master/Documentation/AdvancedUsage.md#swipe-recognition>`_

- visit the document `here <https://github.com/mac-gallagher/Shuffle/blob/master/Documentation/AdvancedUsage.md>`_


============
Installation
============

*********
CocoaPods
*********
Shuffle is available through `CocoaPods <https://cocoapods.org>`_
. To install it, simply add the following line to your ``Podfile``:

pod 'Shuffle-iOS'

********
Carthage
********

Shuffle is available through `Carthage <https://github.com/Carthage/Carthage>`_
. To install it, simply add the following line to your Cartfile:

github "mac-gallagher/Shuffle"

*********************
Swift Package Manager
*********************

MultiProgressView is available through `Swift PM. <https://swift.org/package-manager>`_

. To install it, simply add the package as a dependency in ``Package.swift``:

.. sourcecode:: swift

 dependencies: [
  .package(url: "https://github.com/mac-gallagher/Shuffle.git", from: "0.1.0"),
 ]

******
Manual
******

Download and drop the ``Shuffle`` directory into your project.

************
Requirements
************

- iOS 9.0+
- Xcode 10.2+
- Swift 5.0+

==================
Apps Using Shuffle
==================

We love to hear about apps that use Shuffle - feel free to submit a pull request and share yours here!


Made with ❤️  by `Mac Gallagher <https://github.com/mac-gallagher>`_ 

(Graphic designed by `Mazen Ghani <mailto:mghani@uwm.edu>`_)

(Read the docs by `Doug Purcell <mailto:purcellconsult@gmail.com>`_)
