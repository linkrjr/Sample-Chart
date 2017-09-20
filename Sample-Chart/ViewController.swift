//
//  ViewController.swift
//  Sample-Chart
//
//  Created by Ronaldo Gomes on 13/9/17.
//  Copyright © 2017 Technophile. All rights reserved.
//

import UIKit
import SnapKit
import AMPopTip

struct Transaction {
    var total: Double
    var time: Int
    
    var formattedTotal: String {
        return "$\(self.total)"
    }
}

class Cell: UICollectionViewCell {
    
    static let reuseIdentifier = "FlickrCell"
    
    private var animate = true
    
    private let NUMBER_LABEL_HEIGHT: CGFloat = 20
    
    private var barViewHeight: CGFloat {
        return self.bounds.height - NUMBER_LABEL_HEIGHT
    }
    
    private let popTip:PopTip = {
        let popTip = PopTip()
        popTip.shouldDismissOnTap = true
        return popTip
    }()
    
    private let barView: UIView = UIView(frame: CGRect.zero)
    private let shadowBarView: UIView = UIView(frame: CGRect.zero)
    
    private var label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    
    var highestTransaction: Transaction!
    var transaction: Transaction!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        PopTip.appearance().bubbleColor = .green
        
        NotificationCenter.default.addObserver(self, selector: #selector(Cell.hidePopTip(notification:)), name: NSNotification.Name("HidePopTipNotification"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reset() {
        self.popTip.hide()
    }
    
    private func layerMask(_ bounds: CGRect) -> CALayer {
        
        let path = UIBezierPath(roundedRect: bounds,
                                byRoundingCorners:[.topLeft, .topRight, .bottomLeft, .bottomRight],
                                cornerRadii: CGSize(width: 20, height:  20))
        
        let maskLayer = CAShapeLayer()
        
        maskLayer.path = path.cgPath
        return maskLayer
    
    }
    
    override func layoutSubviews() {
        
        self.label.text = String(self.transaction.time)
        
        self.barView.frame = CGRect(x: Int(self.bounds.width/2)-Int(30/2), y: Int(self.barViewHeight), width: 30, height: 0)
        let newBarViewFrame = calculateBarViewRect()
        if animate {
            UIView.animate(withDuration: 2) {
                self.barView.frame = newBarViewFrame.insetBy(dx: 5, dy: 0)
            }
            self.animate = false
        } else {
            self.barView.frame = newBarViewFrame.insetBy(dx: 5, dy: 0)
        }
        self.barView.layer.mask = self.layerMask(self.barView.bounds)
        self.barView.backgroundColor = .white
        self.barView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showBallon)))

        self.addSubview(self.barView)
        self.addSubview(self.label)
        
        self.label.snp.makeConstraints { make in
            make.top.equalTo(self.barView.snp.bottom)
            make.left.right.equalToSuperview().inset(5)
            make.bottom.equalToSuperview()
        }
        
    }
    
    private func calculateBarViewRect() -> CGRect {
        let totalHeight = (self.barViewHeight * CGFloat(self.transaction.total))/CGFloat(self.highestTransaction.total)        
        let height = totalHeight <= 40 ? -40 : Int(-(totalHeight - 40))
        return CGRect(x: Int(self.bounds.width/2)-Int(30/2), y: Int(self.barViewHeight), width: 30, height: height)
    }
    
    func hidePopTip(notification: Notification) {
        self.popTip.hide()
    }
    
    func showBallon() {
//        NotificationCenter.default.post(name: NSNotification.Name("HidePopTipNotification"), object: nil)
        self.barView.backgroundColor = .green
        self.popTip.show(text: self.transaction.formattedTotal, direction: .up, maxWidth: 400, in: self, from: self.barView.frame)
    }
    
}

class ViewController: UIViewController {
    
    fileprivate var transactions: [Transaction] = []
    
    fileprivate let sectionInsets = UIEdgeInsets(top: 50.0, left: 0.0, bottom: 50.0, right: 0.0)
    fileprivate let itemsPerRow: CGFloat = 3
    
    fileprivate var collectionView: UICollectionView?
    
    fileprivate var highestTransaction: Transaction = Transaction(total: 0, time: 0)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .blue
        
        let times: [Int] = [6, 7, 8, 9, 10, 11, 12, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 1, 2, 3, 4, 5]
        
        self.transactions = times.map { time -> Transaction in
            return Transaction(total: Double(arc4random_uniform(200)), time: time)
        }
        self.highestTransaction = calculateHighestTransaction()
        
        let layout = CustomLayout()
        layout.delegate = self
        layout.scrollDirection = .horizontal
        layout.headerReferenceSize = CGSize(width: 0, height: 50)
        
        self.collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        
        self.collectionView?.backgroundColor = .clear
        self.collectionView?.register(Cell.self, forCellWithReuseIdentifier: Cell.reuseIdentifier)
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
    
    private func calculateHighestTransaction() -> Transaction {
        return self.transactions.reduce(self.transactions.first!) { (currentMaxTransaction, transaction) -> Transaction in
            if transaction.total > currentMaxTransaction.total {
                return transaction
            }
            return currentMaxTransaction
        }
    }
    
}

extension ViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.transactions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.reuseIdentifier, for: indexPath) as! Cell
        cell.reset()
        cell.transaction = self.transaction(for: indexPath)
        cell.highestTransaction = self.highestTransaction
        return cell
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
        
        (0..<numberOfItems).forEach { item in
            
            let indexPath = IndexPath(row: item, section: 0)
            let frame = CGRect(x: xOffset[column], y: 0, width: columnWidth, height: self.contentHeight)
            
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = frame
            cache.append(attributes)
            
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
    
}
