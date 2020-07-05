///
/// MIT License
///
/// Copyright (c) 2020 Mac Gallagher
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in all
/// copies or substantial portions of the Software.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
/// SOFTWARE.
///

import PopBounceButton
import Shuffle

class TinderViewController: UIViewController {

  private let cardStack = SwipeCardStack()

  private let buttonStackView = ButtonStackView()

  private let cardModels = [
    TinderCardModel(name: "Michelle",
                    age: 26,
                    occupation: "Graphic Designer",
                    image: UIImage(named: "michelle")),
    TinderCardModel(name: "Joshua",
                    age: 27,
                    occupation: "Business Services Sales Representative",
                    image: UIImage(named: "joshua")),
    TinderCardModel(name: "Daiane",
                    age: 23,
                    occupation: "Graduate Student",
                    image: UIImage(named: "daiane")),
    TinderCardModel(name: "Julian",
                    age: 25,
                    occupation: "Model/Photographer",
                    image: UIImage(named: "julian")),
    TinderCardModel(name: "Andrew",
                    age: 26,
                    occupation: nil,
                    image: UIImage(named: "andrew")),
    TinderCardModel(name: "Bailey",
                    age: 25,
                    occupation: "Software Engineer",
                    image: UIImage(named: "bailey")),
    TinderCardModel(name: "Rachel",
                    age: 27,
                    occupation: "Interior Designer",
                    image: UIImage(named: "rachel"))
  ]

  override func viewDidLoad() {
    super.viewDidLoad()
    cardStack.delegate = self
    cardStack.dataSource = self
    buttonStackView.delegate = self

    configureNavigationBar()
    layoutButtonStackView()
    layoutCardStackView()
    configureBackgroundGradient()
  }

  private func configureNavigationBar() {
    let backButton = UIBarButtonItem(title: "Back",
                                     style: .plain,
                                     target: self,
                                     action: #selector(handleShift))
    backButton.tag = 1
    backButton.tintColor = .lightGray
    navigationItem.leftBarButtonItem = backButton

    let forwardButton = UIBarButtonItem(title: "Forward",
                                        style: .plain,
                                        target: self,
                                        action: #selector(handleShift))
    forwardButton.tag = 2
    forwardButton.tintColor = .lightGray
    navigationItem.rightBarButtonItem = forwardButton

    navigationController?.navigationBar.layer.zPosition = -1
  }

  private func configureBackgroundGradient() {
    let backgroundGray = UIColor(red: 244 / 255, green: 247 / 255, blue: 250 / 255, alpha: 1)
    let gradientLayer = CAGradientLayer()
    gradientLayer.colors = [UIColor.white.cgColor, backgroundGray.cgColor]
    gradientLayer.frame = view.bounds
    view.layer.insertSublayer(gradientLayer, at: 0)
  }

  private func layoutButtonStackView() {
    view.addSubview(buttonStackView)
    buttonStackView.anchor(left: view.safeAreaLayoutGuide.leftAnchor,
                           bottom: view.safeAreaLayoutGuide.bottomAnchor,
                           right: view.safeAreaLayoutGuide.rightAnchor,
                           paddingLeft: 24,
                           paddingBottom: 12,
                           paddingRight: 24)
  }

  private func layoutCardStackView() {
    view.addSubview(cardStack)
    cardStack.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                     left: view.safeAreaLayoutGuide.leftAnchor,
                     bottom: buttonStackView.topAnchor,
                     right: view.safeAreaLayoutGuide.rightAnchor)
  }

  @objc
  private func handleShift(_ sender: UIButton) {
    cardStack.shift(withDistance: sender.tag == 1 ? -1 : 1, animated: true)
  }
}

// MARK: Data Source + Delegates

extension TinderViewController: ButtonStackViewDelegate, SwipeCardStackDataSource, SwipeCardStackDelegate {

  func cardStack(_ cardStack: SwipeCardStack, cardForIndexAt index: Int) -> SwipeCard {
    let card = SwipeCard()
    card.footerHeight = 80
    card.swipeDirections = [.left, .up, .right]
    for direction in card.swipeDirections {
      card.setOverlay(TinderCardOverlay(direction: direction), forDirection: direction)
    }

    let model = cardModels[index]
    card.content = TinderCardContentView(withImage: model.image)
    card.footer = TinderCardFooterView(withTitle: "\(model.name), \(model.age)", subtitle: model.occupation)

    return card
  }

  func numberOfCards(in cardStack: SwipeCardStack) -> Int {
    return cardModels.count
  }

  func didSwipeAllCards(_ cardStack: SwipeCardStack) {
    print("Swiped all cards!")
  }

  func cardStack(_ cardStack: SwipeCardStack, didUndoCardAt index: Int, from direction: SwipeDirection) {
    print("Undo \(direction) swipe on \(cardModels[index].name)")
  }

  func cardStack(_ cardStack: SwipeCardStack, didSwipeCardAt index: Int, with direction: SwipeDirection) {
    print("Swiped \(direction) on \(cardModels[index].name)")
  }

  func cardStack(_ cardStack: SwipeCardStack, didSelectCardAt index: Int) {
    print("Card tapped")
  }

  func didTapButton(button: TinderButton) {
    switch button.tag {
    case 1:
      cardStack.undoLastSwipe(animated: true)
    case 2:
      cardStack.swipe(.left, animated: true)
    case 3:
      cardStack.swipe(.up, animated: true)
    case 4:
      cardStack.swipe(.right, animated: true)
    case 5:
      cardStack.reloadData()
    default:
      break
    }
  }
}
