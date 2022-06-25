//
//  CardViewFactory.swift
//  Cards_game
//
//  Created by Слава Шестаков on 16.05.2022.
//

import UIKit

class CardViewFactory {
    func get(_ shape: CardType, withSize size: CGSize, andColor color: CardColor) -> UIView {
        //  на основе размеров определяем фрейм
        let frame = CGRect(origin: .zero, size: size)
        // определяем UI-цвет на основе цвета моделиэ
        let viewColor = getViewColorBy(modelColor: color)
        
        // генерируем и возвращаем карточку
        switch shape {
        case .circle:
            return CardView<CircleShape>(frame: frame, color: viewColor)
        case .cross:
            return CardView<CrossShape>(frame: frame, color: viewColor)
        case .square:
            return CardView<SquareShape>(frame: frame, color: viewColor)
        case .fill:
            return CardView<FillShape>(frame: frame, color: viewColor)
        }
    }
    
    // преобразуем цвет Модели в цвет Представления
    private func getViewColorBy(modelColor: CardColor) -> UIColor {
        switch modelColor {
        case .red:
            return .red
        case .green:
            return .green
        case .black:
            return .black
        case .gray:
            return .gray
        case .brown:
            return .brown
        case .yellow:
            return .yellow
        case .purple:
            return .purple
        }
    }
}
