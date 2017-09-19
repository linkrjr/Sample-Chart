//
//  ViewController.swift
//  Sample-Chart
//
//  Created by Ronaldo Gomes on 13/9/17.
//  Copyright © 2017 Technophile. All rights reserved.
//

import UIKit
import SnapKit

struct Transaction {
    var total: Double
    var time: Int
}

class Cell: UICollectionViewCell {
    
    static let reuseIdentifier = "FlickrCell"
 
    var transaction: Transaction!
    
    private var label: UILabel = UILabel()
    
    override func layoutSubviews() {
//        self.label.text = String(self.transaction.total)
        self.backgroundColor = .blue
        
        self.addSubview(self.label)

        self.label.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(5)
            make.centerY.equalToSuperview()
        }
        
    }
    
}

class Header: UICollectionReusableView {
    
    static let reuseIdentifier = "Header"
    
    var label: UILabel = UILabel()
    
    override func layoutSubviews() {
        self.backgroundColor = .green
        self.addSubview(self.label)
        
        self.label.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(5)
            make.centerY.equalToSuperview()
        }
        
    }
    
}

class Decoration: UICollectionReusableView {

    static let reuseIdentifier = "Decoration"
    
    var label: UILabel = UILabel()
    
    override func layoutSubviews() {
        self.backgroundColor = .white
        self.addSubview(self.label)
        
        self.label.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(5)
            make.centerY.equalToSuperview()
        }
        
    }

}

class ViewController: UIViewController {
    
    fileprivate var transactions: [Transaction] = []
    
    fileprivate let sectionInsets = UIEdgeInsets(top: 50.0, left: 0.0, bottom: 50.0, right: 0.0)
    fileprivate let itemsPerRow: CGFloat = 3
    
    fileprivate var collectionView: UICollectionView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let times: [Int] = [6, 7, 8, 9, 10, 11, 12, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 1, 2, 3, 4, 5]
        
        self.transactions = times.map { time -> Transaction in
            return Transaction(total: Double(arc4random_uniform(200)), time: time)
        }
        
        let layout = CustomLayout()
        layout.delegate = self
        layout.scrollDirection = .horizontal
        layout.headerReferenceSize = CGSize(width: 0, height: 50)
        
        layout.register(Decoration.self, forDecorationViewOfKind: Decoration.reuseIdentifier)
        
        self.collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        
        self.collectionView?.backgroundColor = .yellow
        self.collectionView?.register(Cell.self, forCellWithReuseIdentifier: Cell.reuseIdentifier)
//        self.collectionView?.register(Header.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: Header.reuseIdentifier)
        self.collectionView?.dataSource = self
        self.collectionView?.delegate = self
        
        self.view.addSubview(self.collectionView!)
        
        self.collectionView!.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(100)
            make.height.equalTo(300)
        }
        
    }

    func transaction(for indexPath: IndexPath) -> Transaction {
        return self.transactions[indexPath.row]
    }

}

extension ViewController: UICollectionViewDelegate {}

extension ViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.transactions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.reuseIdentifier, for: indexPath) as! Cell
        
        cell.transaction = self.transaction(for: indexPath)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Header.reuseIdentifier, for: indexPath) as! Header
            headerView.label.text = "Header"
            return headerView
        default:
            assert(false, "Unknown kind!!!")
        }
    }
    
    
    
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 50, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return self.sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
}

extension ViewController: CustomLayoutDelegate {
    
    func collectionView(_ collectionView: UICollectionView, heightForBarAtIndexPath indexPath: IndexPath) -> CGFloat {
        return CGFloat(self.transactions[indexPath.row].total)
    }
    
    func numberOfItems() -> Int {
        return self.transactions.count
    }
}

protocol CustomLayoutDelegate: class {
    func collectionView(_ collectionView: UICollectionView, heightForBarAtIndexPath indexPath: IndexPath) -> CGFloat
    func numberOfItems() -> Int
}

class CustomLayout: UICollectionViewFlowLayout {

    weak var delegate: CustomLayoutDelegate?
    
    fileprivate var cellPadding: CGFloat = 6
    fileprivate var bottomPadding: CGFloat = 30
    
    fileprivate var cache: [UICollectionViewLayoutAttributes] = []
    
    fileprivate var contentHeight: CGFloat {
        guard let collectionView = self.collectionView else { return 0 }
        return collectionView.bounds.height
    }
    fileprivate var contentWidth: CGFloat {
        guard let collectionView = self.collectionView else { return 0 }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }
    
    override init() {
        super.init()
        self.register(Decoration.self, forDecorationViewOfKind: Decoration.reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var collectionViewContentSize: CGSize {
        return super.collectionViewContentSize
    }
    
    override func prepare() {
        
        guard self.cache.isEmpty, let collectionView = self.collectionView else { return }
        
        let numberOfItems = collectionView.numberOfItems(inSection: 0)
        
        let columnWidth: CGFloat = 50
        
        var xOffset: [CGFloat] = []
        (0..<numberOfItems).forEach { column in
            xOffset.append(CGFloat(column) * columnWidth)
        }
        var column = 0
        
        let calculatedContentHeightWithoutBottomPadding = self.contentHeight - bottomPadding
        
        (0..<numberOfItems).forEach { item in
            
            let indexPath = IndexPath(row: item, section: 0)
            
            let barHeight = self.delegate!.collectionView(collectionView, heightForBarAtIndexPath: indexPath)
            
            var height = barHeight
            if barHeight >= calculatedContentHeightWithoutBottomPadding {
                height = calculatedContentHeightWithoutBottomPadding
            }
            
            let frame = CGRect(x: xOffset[column], y: height, width: columnWidth, height: calculatedContentHeightWithoutBottomPadding - height)
            let insetFrame = frame.insetBy(dx: cellPadding, dy: 0)
            
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            cache.append(attributes)
            
            let decorationAttributes = UICollectionViewLayoutAttributes(forDecorationViewOfKind: Decoration.reuseIdentifier, with: indexPath)
            let decoFrame = CGRect(x: frame.origin.x, y: calculatedContentHeightWithoutBottomPadding, width: frame.size.width, height: bottomPadding)
            decorationAttributes.frame = decoFrame.insetBy(dx: cellPadding, dy: 0)
            cache.append(decorationAttributes)
            
            column += 1
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var visibleLayoutAttributes: [UICollectionViewLayoutAttributes] = []
        
        cache.forEach { attributes in
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        
        return visibleLayoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return self.cache[indexPath.item]
    }
    
    override func layoutAttributesForDecorationView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return self.cache[indexPath.item]
    }
    
}
