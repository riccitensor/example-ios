import Visualix
import UIKit

final class List: UIView {
    private class Item: UIControl {
        let item: Visualix.Item
        let index: Int
        
        fileprivate init(_ item: (Int, Visualix.Item, Data?)) {
            self.item = item.1
            self.index = item.0
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            
            let border = UIView()
            border.isUserInteractionEnabled = false
            border.translatesAutoresizingMaskIntoConstraints = false
            border.backgroundColor = UIColor(white: 0, alpha: 0.1)
            addSubview(border)
            
            let image = UIImageView()
            image.translatesAutoresizingMaskIntoConstraints = false
            image.clipsToBounds = true
            image.contentMode = .scaleAspectFit
            addSubview(image)
            
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = .systemFont(ofSize: 14, weight: .regular)
            label.textColor = .black
            label.text = item.1.name
            addSubview(label)
            
            if item.2 != nil, item.1.type == .image {
                image.image = UIImage(data: item.2!)
            }
            
            heightAnchor.constraint(equalToConstant: 50).isActive = true
            
            image.leftAnchor.constraint(equalTo: leftAnchor, constant: 6).isActive = true
            image.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
            image.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
            image.widthAnchor.constraint(equalToConstant: 60).isActive = true
            
            label.leftAnchor.constraint(equalTo: image.rightAnchor, constant: 5).isActive = true
            label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            
            border.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
            border.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
            border.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            border.heightAnchor.constraint(equalToConstant: 1).isActive = true
        }
        
        required init?(coder: NSCoder) { return nil }
        
        override var isHighlighted: Bool { didSet {
            backgroundColor = isHighlighted ? #colorLiteral(red: 0.09985234588, green: 0.2915372252, blue: 0.4192180037, alpha: 0.2) : .clear
        } }
    }
    
    var onCancel: (() -> Void)!
    var onSelect: ((Int) -> Void)!
    private weak var scroll: UIScrollView!
    private weak var bottom: NSLayoutConstraint? { willSet { bottom?.isActive = false } didSet { bottom?.isActive = true } }
    
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .white
        layer.borderWidth = 1
        layer.cornerRadius = 6
        layer.borderColor = UIColor(white: 0, alpha: 0.3).cgColor
        clipsToBounds = true
        
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.indicatorStyle = .black
        scroll.alwaysBounceVertical = true
        scroll.clipsToBounds = true
        addSubview(scroll)
        self.scroll = scroll
        
        let border = UIView()
        border.translatesAutoresizingMaskIntoConstraints = false
        border.backgroundColor = UIColor(white: 0, alpha: 0.3)
        border.isUserInteractionEnabled = false
        addSubview(border)
        
        let cancel = UIButton()
        cancel.translatesAutoresizingMaskIntoConstraints = false
        cancel.addTarget(self, action: #selector(self.cancel), for: .touchUpInside)
        cancel.setTitle(.local("List.cancel"), for: [])
        cancel.setTitleColor(.black, for: .normal)
        cancel.setTitleColor(UIColor(white: 0, alpha: 0.2), for: .highlighted)
        cancel.titleLabel!.font = .systemFont(ofSize: 13, weight: .medium)
        addSubview(cancel)
        
        scroll.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        scroll.topAnchor.constraint(equalTo: topAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: border.topAnchor).isActive = true
        
        border.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        border.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        border.heightAnchor.constraint(equalToConstant: 1).isActive = true
        border.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -45).isActive = true
        
        cancel.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        cancel.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        cancel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        cancel.topAnchor.constraint(equalTo: border.bottomAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) { return nil }
    
    func add(_ items: [(Int, Visualix.Item, Data?)]) {
        scroll.subviews.forEach({ $0.removeFromSuperview() })
        var top = scroll.topAnchor
        items.forEach {
            let item = Item($0)
            item.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
            scroll.addSubview(item)
            
            item.topAnchor.constraint(equalTo: top).isActive = true
            item.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            item.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
            top = item.bottomAnchor
        }
        bottom = scroll.bottomAnchor.constraint(greaterThanOrEqualTo: top, constant: 20)
    }
    
    @objc private func cancel() { onCancel() }
    
    @objc private func click(_ item: Item) { onSelect(item.index) }
}
