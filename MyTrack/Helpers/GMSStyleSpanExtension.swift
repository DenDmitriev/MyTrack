//
//  GMSStyleSpanExtension.swift
//  MyTrack
//
//  Created by Denis Dmitriev on 04.02.2023.
//

import Foundation
import GoogleMaps

extension GMSStyleSpan {
    static func getColor(by speed: Double) -> GMSStyleSpan {
        switch speed {
        case 0..<3:
            return GMSStyleSpan(color: .systemBlue)
        case 3..<5:
            return GMSStyleSpan(color: .systemGreen)
        case 5..<7:
            return GMSStyleSpan(color: .systemYellow)
        case 7..<10:
            return GMSStyleSpan(color: .systemOrange)
        case 10..<13:
            return GMSStyleSpan(color: .systemRed)
        case 13...:
            return GMSStyleSpan(color: .systemPurple)
        default:
            return GMSStyleSpan(color: .systemGray)
        }
    }
}
