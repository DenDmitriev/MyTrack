//
//  AppError.swift
//  MyTrack
//
//  Created by Denis Dmitriev on 11.02.2023.
//

import Foundation

protocol AppError: LocalizedError {
    var title: String { get }
    var description: String? { get }
}
