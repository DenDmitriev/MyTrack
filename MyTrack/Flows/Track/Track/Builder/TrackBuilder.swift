//
//  TrackBuilder.swift
//  MyTrack
//
//  Created by Denis Dmitriev on 20.06.2023.
//

import UIKit

struct TrackBuilder {
    static func build() -> TrackViewController {
        let viewModel = TrackViewModel()
        let storyboard = UIStoryboard(name: "Track", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "TrackViewController") as? TrackViewController
        viewController?.viewModel = viewModel
        
        viewModel.viewController = viewController
        return viewController ?? TrackViewController()
    }
}
