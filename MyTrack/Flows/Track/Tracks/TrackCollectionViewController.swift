//
//  TrackCollectionViewController.swift
//  MyTrack
//
//  Created by Denis Dmitriev on 02.02.2023.
//

import UIKit
import RealmSwift

private let reuseIdentifier = "TrackCell"
private let supplementaryIdentifier = "TracksHeader"

class TrackCollectionViewController: UICollectionViewController {
    
    var toTrack: ((Track?) -> Void)?
    
    var realmService: RealmService?
    
    var tracks: [Track] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        fetchTracks()
    }
    
    private func configure() {
        // Register cell classes
        self.collectionView.register(UINib(nibName: "TrackCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        realmService = RealmService()
    }
    
    private func fetchTracks() {
        tracks = realmService?.getTracks(sorting: .new) ?? []
    }

    
    // MARK: - Navigation
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let isTracking = try? Session.shared.isTracking.value()
        switch isTracking {
        case true:
            alertIsTracking {
                self.dismiss(animated: true)
            }
        default:
            let track = tracks[indexPath.item]
            toTrack?(track)
        }
    }

    @IBAction func closeDidTaped(_ sender: UIButton) {
        toTrack?(nil)
    }
    
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return tracks.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TrackCollectionViewCell
    
        let track = tracks[indexPath.item]
        cell.set(for: track)
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
    
    func alertIsTracking(operation: @escaping (() -> ())) {
        let alertController = UIAlertController(
            title: "You are in tracking",
            message: "Before opening the last track you must finish the current.",
            preferredStyle: .alert
        )
        let action = UIAlertAction(title: "Ok", style: .default) { _ in
            operation()
        }
        alertController.addAction(action)
        
        self.present(alertController, animated: true)
    }

}

extension TrackCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    enum Layout {
        static let items: CGFloat = 2
        static let separator: CGFloat = 8
    }
    
    //Размер ячеек
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let layoutSpaces = collectionView.layoutMargins.left + collectionView.layoutMargins.right + ((Layout.items - 1) * Layout.separator)
                
        let width = (collectionView.frame.width - layoutSpaces) / Layout.items
        
        return CGSize(width: width, height: width)
    }
    
    //отсутпы строк
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return Layout.separator
    }
    
    //отступы столбов
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return Layout.separator
    }
}
