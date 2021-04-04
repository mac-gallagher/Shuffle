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

import UIKit

class TinderCardContentView: UIView {

  private let backgroundView: UIView = {
    let background = UIView()
    background.clipsToBounds = true
    background.layer.cornerRadius = 10
    return background
  }()

  private let imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFill
    return imageView
  }()

  private let gradientLayer: CAGradientLayer = {
    let gradient = CAGradientLayer()
    gradient.colors = [UIColor.black.withAlphaComponent(0.01).cgColor,
                       UIColor.black.withAlphaComponent(0.8).cgColor]
    gradient.startPoint = CGPoint(x: 0.5, y: 0)
    gradient.endPoint = CGPoint(x: 0.5, y: 1)
    return gradient
  }()

  init(withImage image: UIImage?) {
    super.init(frame: .zero)
    imageView.image = image
    initialize()
  }

  required init?(coder aDecoder: NSCoder) {
    return nil
  }

  private func initialize() {
    addSubview(backgroundView)
    backgroundView.anchorToSuperview()
    backgroundView.addSubview(imageView)
    imageView.anchorToSuperview()
    applyShadow(radius: 8, opacity: 0.2, offset: CGSize(width: 0, height: 2))
    backgroundView.layer.insertSublayer(gradientLayer, above: imageView.layer)
  }

  override func draw(_ rect: CGRect) {
    super.draw(rect)
    let heightFactor: CGFloat = 0.35
    gradientLayer.frame = CGRect(x: 0,
                                 y: (1 - heightFactor) * bounds.height,
                                 width: bounds.width,
                                 height: heightFactor * bounds.height)
  }
}
