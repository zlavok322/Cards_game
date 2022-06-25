//
//  Card.swift
//  Cards_game
//
//  Created by Слава Шестаков on 15.05.2022.
//

import UIKit

// типы фигуры карт
enum CardType: CaseIterable {
    case circle
    case cross
    case square
    case fill
}

// цвет карт
enum CardColor: CaseIterable {
    case red
    case green
    case black
    case gray
    case brown
    case yellow
    case purple
}

// игральная карточка
typealias Card = (type: CardType, color: CardColor)
