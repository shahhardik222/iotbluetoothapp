import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
//    @IBOutlet weak var btnOn: UIButton!
//    @IBOutlet weak var btnOff: UIButton!
//    @IBOutlet weak var btnPlus: UIButton!
//    @IBOutlet weak var btnMinus: UIButton!

}

extension TableViewCell {

    func setCollectionViewDataSourceDelegate(dataSourceDelegate: UICollectionViewDataSource, dataViewDelegate: UICollectionViewDelegate, forRow row: Int) {

        collectionView.delegate = dataViewDelegate
        collectionView.dataSource = dataSourceDelegate
        collectionView.tag = row
        collectionView.setContentOffset(collectionView.contentOffset, animated:false) // Stops collection view if it was scrolling.
        collectionView.reloadData()
    }

    var collectionViewOffset: CGFloat {
        set {
            collectionView.contentOffset.x = newValue
        }

        get {
            return collectionView.contentOffset.x
        }
    }
}

