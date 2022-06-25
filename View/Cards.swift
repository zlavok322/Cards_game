//
//  Cards.swift
//  Cards_game
//
//  Created by Слава Шестаков on 15.05.2022.
//

import UIKit

protocol FlippableView: UIView {
    var isFlipped: Bool {get set}
    var flipCompletionHandler: ((FlippableView) -> Void)? {get set}
    func flip()
    func flipPressedButton(_ :Bool)
}

class CardView<ShapeType: ShapeLayerProtocol>: UIView, FlippableView {
    
    var isFlipped: Bool = false {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    var flipCompletionHandler: ((FlippableView) -> Void)?
    var color: UIColor!
    var cornerRadius = 20
    private var startTouchPoint: CGPoint!

    init(frame: CGRect, color: UIColor) {
        super.init(frame: frame)
        self.color = color
        
        setupBorders()
    }
    // настройка границу
    private func setupBorders() {
        self.clipsToBounds = true
        self.layer.cornerRadius = CGFloat(cornerRadius)
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.black.cgColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // отрисовывает в супервью дочерние вьюшки
    override func draw(_ rect: CGRect) {
        // удаляем добавленные ранее дочерние представления
        backSideView.removeFromSuperview()
        frontSideView.removeFromSuperview()
        
        // добавляем новые представления
        if isFlipped {
            self.addSubview(backSideView)
            self.addSubview(frontSideView)
        } else {
            self.addSubview(frontSideView)
            self.addSubview(backSideView)
        }
    }
    
    // внутренний отступ представления
    private let margin: Int = 10
    
    // представление с лицевой стороной карты
    lazy var frontSideView: UIView = self.getFrontSideView()
    // представление с обратной стороной карты
    lazy var backSideView: UIView = self.getBackSideView()
    
    // возвращает представление для лицевой стороны карточки
    private func getFrontSideView() -> UIView {
        let view = UIView(frame: self.bounds)
        view.backgroundColor = .white
        
        let shapeView = UIView(frame: CGRect(x: margin, y: margin, width: Int(self.bounds.width)-margin*2, height: Int(self.bounds.height)-margin*2))
        view.addSubview(shapeView)
        
        // создание слоя с фигурой
        let shapeLayer = ShapeType(size: shapeView.frame.size, fillColor: color.cgColor)
        shapeView.layer.addSublayer(shapeLayer)
        
        // скругляем углы корневого слоя
        view.layer.masksToBounds = true
        view.layer.cornerRadius = CGFloat(cornerRadius)
        
        return view
    }
    
    // возвращает вью для обратной стороны карточки
    private func getBackSideView() -> UIView {
        let view = UIView(frame: self.bounds)
        view.backgroundColor = .white
        
        // выбор случайного узора для рубашки
        switch ["circle", "line"].randomElement()! {
        case "circle":
            let layer = BackSideCircle(size: self.bounds.size, fillColor: UIColor.black.cgColor)
            view.layer.addSublayer(layer)
        case "line":
            let layer = BackSideLine(size: self.bounds.size, fillColor: UIColor.black.cgColor)
            view.layer.addSublayer(layer)
        default:
            break
        }
        // скругляем углы корневого слоя
        view.layer.masksToBounds = true
        view.layer.cornerRadius = CGFloat(cornerRadius)
        return view
    }
   
    // точка привязки
    private var anchorPoint: CGPoint = CGPoint(x: 0, y: 0)
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // измеряем координаты точки привязки
        anchorPoint.x = touches.first!.location(in: window).x - frame.minX
        anchorPoint.y = touches.first!.location(in: window).y - frame.minY
        
        // сохраняем исходные координаты
        startTouchPoint = frame.origin
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // рассчитывание frame
        self.frame.origin.x = touches.first!.location(in: window).x - anchorPoint.x
        self.frame.origin.y = touches.first!.location(in: window).y - anchorPoint.y
        
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.frame.origin == startTouchPoint {
            flip()
        }
        let rect = BoardGameController().boardGameView.bounds
        
        if self.frame.minY < rect.minY || self.frame.maxY > rect.maxY || self.frame.minX < rect.minX || self.frame.maxX > rect.maxX {
            UIView.animate(withDuration: 0.2) {
                self.frame.origin = self.startTouchPoint
            }
        } 
    }
    
    func flip() {
        // определяем между каким представлениями осуществлять переход
        let fromView = isFlipped ? frontSideView : backSideView
        let toView = isFlipped ? backSideView : frontSideView
        // запускаем анимированный переход
        UIView.transition(from: fromView, to: toView, duration: 0.5, options: [.transitionFlipFromTop], completion: { _ in
            // обработчик переворота
            self.flipCompletionHandler?(self)
        })
        isFlipped.toggle() // isF = !isF
    }
    
    func flipPressedButton(_ toView: Bool) {
        let toView = toView
        if toView {
            UIView.transition(from: backSideView, to: frontSideView, duration: 0.5, options: [.transitionFlipFromTop], completion: { _ in
                // обработчик переворота
                self.flipCompletionHandler?(self)
        })
        isFlipped.toggle()
        } else {
            UIView.transition(from: frontSideView, to: backSideView, duration: 0.5, options: [.transitionFlipFromTop], completion: { _ in
                // обработчик переворота
                self.flipCompletionHandler?(self)
        })
            isFlipped.toggle()
        }
    }
}
