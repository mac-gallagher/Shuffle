# Advanced Usage

* [Animations](#animations)
* [Card Layout](#card-layout)
* [Swipe Recognition](#swipe-recognition)

## Animations
// TODO

## Card Layout
Each `SwipeCard` consists of three UI components: its *content view*, *footer view*, and *overlay view(s)*.

### Content
The content view is the card's primary view. You can include your own card template here. The content view is set assigning the `content` variable.

### Footer
The card's footer view is set just below the card's content view. If the footer is transparent, the card's content continue past the footer view. The footer's height is modified with `footerHeight`. The card's footer is set by assigning the `footer` variable.

### Overlays
An overlay view is the view whose alpha value reacts to the user's dragging. The overlays are laid out above the card's footer, regardless if the footer is transparent or not. 

The card's overlays are set by assigning the `leftOverlay`, `upOverlay`, `rightOverlay`, and `downOverlay` variables.

## Swipe Recognition
// TODO
