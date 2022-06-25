//
//  BoardGameController.swift
//  Cards_game
//
//  Created by Слава Шестаков on 15.05.2022.
//

import UIKit

class BoardGameController: UIViewController {

    // количество пар уникальных карточек
    var cardsPairsCount = 8
    // сущность Игра
    lazy var game: Game = getNewGame()
    // кнопка для запуска/перезапуска игры
    lazy var startButtonView = getStartButtonView()
    // игровое поле
    lazy var boardGameView = getBoardGameView()
    // кнопка настроек игры
    lazy var settingButtonView = getSettingButtonView()
    // кнопка для переворота всех карт
    lazy var flipButtonView = getFlipButton()
    // размеры карточек
    private var cardSize: CGSize {
        CGSize(width: 80, height: 120)
    }
    // предельные координаты размещения карточки
    private var cardMaxXCoordinate: Int {
        Int(boardGameView.frame.width - cardSize.width)
    }
    private var cardMaxYCoordinate: Int {
        Int(boardGameView.frame.height - cardSize.height)
    }
    // игральные карточки
    var cardViews = [UIView]()
    // ссылки на перевернутые карточки
    private var flippedCards = [UIView]()
    
    override func loadView() {
        super.loadView()
        // button
        view.addSubview(startButtonView)
        // gameBoard
        view.addSubview(boardGameView)
        view.addSubview(settingButtonView)
        view.addSubview(flipButtonView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createSettingButtonConstraint()
        createFlipButtonConstraint()
        
    }
    
    private func createSettingButtonConstraint() {
        settingButtonView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.safeAreaInsets.top + 50).isActive = true
        settingButtonView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: view.safeAreaInsets.right).isActive = true
        settingButtonView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        settingButtonView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
    }
    
    private func getNewGame() -> Game {
        let game = Game()
        game.cardsCount = self.cardsPairsCount
        game.generateCards()
        return game
    }
    
    private func getFlipButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Flip", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .systemGray4
        button.addTarget(self, action: #selector(flipButtonPressed(_:)), for: .touchUpInside)
        button.layer.cornerRadius = 10
       
        return button
    }
    
    private func createFlipButtonConstraint() {
        flipButtonView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.safeAreaInsets.top + 50).isActive = true
        flipButtonView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: view.safeAreaInsets.left).isActive = true
        flipButtonView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        flipButtonView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
    }
    
    @objc func flipButtonPressed(_ sender: UIButton) {
        print("test")
        var countFront = 0
        var countBack = 0
        for card in cardViews {
            if (card as! FlippableView).isFlipped {
                countFront += 1
            } else {
                countBack += 1
            }
        }
        for card in cardViews {
            (card as! FlippableView).flipPressedButton(countFront > countBack)
        }
    }
    
    private func getSettingButtonView() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(.add, for: .normal)
        button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 50), forImageIn: .normal)
        button.clipsToBounds = true
        button.layer.cornerRadius = 10
        
        button.addTarget(nil, action: #selector(settingButtonPres(_:)), for: .touchUpInside)
        
        return button
    }
    
    @objc func settingButtonPres(_ sender: UIButton) {
        let settingVC = SettingsViewController()
        settingVC.modalPresentationStyle = .fullScreen
        self.present(settingVC, animated: true)
    }
    
    private func getStartButtonView() -> UIButton {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        button.center.x = view.center.x
        
        let window = UIApplication.shared.windows[0]
        // определяекм отступ сверху от границ окна до сайф ареа
        let topPadding = window.safeAreaInsets.top
        
        button.frame.origin.y = topPadding
        
        button.setTitle("Начать игру", for: .normal)
        button.setTitleColor(.black, for: .normal)
        // цвет кнопки для нажатого состояния
        button.setTitleColor(.gray, for: .highlighted)
        button.backgroundColor = .systemGray4
        button.layer.cornerRadius = 10
        
        // подключаем обработчик нажатия на кнопку
        button.addTarget(nil, action: #selector(startGame(_:)), for: .touchUpInside)
        
        return button
    }
   
    @objc func startGame(_ sender: UIButton) {
        game = getNewGame()
        let cards = getCardsBy(modelData: game.cards)
        placeCardsOnBoard(cards)
    }
    
    private func getBoardGameView() -> UIView {
        // отступ игрового поля от ближайших элементов
        let margin: CGFloat = 10
        
        let boardView = UIView()
        // указываем координаты х
        boardView.frame.origin.x = margin
        // y
        let window = UIApplication.shared.windows[0]
        let topPaddinig = window.safeAreaInsets.top
        boardView.frame.origin.y = topPaddinig + startButtonView.frame.height + margin
        
        // рассчитываем ширину
        boardView.frame.size.width = UIScreen.main.bounds.width - margin*2
        // рассчитываем высоту с учетом нижнего отступа
        let bottomPadding = window.safeAreaInsets.bottom
        boardView.frame.size.height = UIScreen.main.bounds.height - boardView.frame.origin.y - margin - bottomPadding
        
        // изменяем стиль игрового поля
        boardView.layer.cornerRadius = 5
        boardView.backgroundColor = UIColor(red: 0.1, green: 0.9, blue: 0.1, alpha: 0.3)
        
        return boardView
    }
    
    // генерация массива карточек на основе данных Модели
    private func getCardsBy(modelData: [Card]) -> [UIView] {
        // хранилище для представлений карточек
        var cardViews = [UIView]()
        // фабрика карточек
        let cardViewFactory = CardViewFactory()
        // перебираем массив карточек в Модели
        for (index, modelCard) in modelData.enumerated() {
            // добавляем первый экземпляр карты
            let cardOne = cardViewFactory.get(modelCard.type, withSize: cardSize, andColor: modelCard.color)
            cardOne.tag = index
            cardViews.append(cardOne)
            
            // добавляем второй экземпляр карты
            let cardTwo = cardViewFactory.get(modelCard.type, withSize: cardSize, andColor: modelCard.color)
            cardTwo.tag = index
            cardViews.append(cardTwo)
        }
        // добавляем всем картам обработчик переворота
        for card in cardViews {
            (card as! FlippableView).flipCompletionHandler = { [self] flippedCard in
                // переносим карточку вверх иерархии
                flippedCard.superview?.bringSubviewToFront(flippedCard)
                
                // добавялем или удаляем карточку
                if flippedCard.isFlipped {
                    self.flippedCards.append(flippedCard)
                } else {
                    if let cardIndex = self.flippedCards.firstIndex(of: flippedCard) {
                        self.flippedCards.remove(at: cardIndex)
                    }
                }
                // если перевернуто 2 карточки
                if self.flippedCards.count == 2 {
                    // получаем карточки изз данных модели
                    let firstCard = game.cards[self.flippedCards.first!.tag]
                    let secondCard = game.cards[self.flippedCards.last!.tag]
                    
                    // если карточки одинаковые
                    if game.checkCards(firstCard, secondCard) {
                        // сперва анимировано скрываем их
                        UIView.animate(withDuration: 0.3, animations:  {
                            self.flippedCards.first!.layer.opacity = 0
                            self.flippedCards.last!.layer.opacity = 0
                            // после чего удаляем из иерархии
                        }, completion:  { _ in
                            self.flippedCards.first!.removeFromSuperview()
                            self.flippedCards.last!.removeFromSuperview()
                            self.flippedCards = []
                        })
                    } else {
                        for card in self.flippedCards {
                            (card as! FlippableView).flip()
                        }
                    }
                }
            }
        }
        return cardViews
        
    }
    
    private func placeCardsOnBoard(_ cards: [UIView]) {
        // удаляем все имеющиеся на игровом поле карточки
        for card in cardViews {
            card.removeFromSuperview()
        }
        cardViews = cards
        // перебираем карточки
        for card in cardViews {
            // для каждой карточки генерируем случайные координаты
            let randomXCoordinate = Int.random(in: 0...cardMaxXCoordinate)
            let randomYCoordinate = Int.random(in: 0...cardMaxYCoordinate)
            card.frame.origin = CGPoint(x: randomXCoordinate, y: randomYCoordinate)
            // размещаем карточку на игровом поле
            boardGameView.addSubview(card)
        }
    }
}
