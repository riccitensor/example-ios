import Visualix
import UIKit

final class Place: Visualix.Place {
    private weak var indicator: UIImageView!
    private weak var add: UIButton!
    private weak var connect: UIButton!
    private weak var save: UIButton!
    private weak var list: List!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        socket = Socket()
        
        status.listen(.download) { [weak self] _ in self?.indicator.image = #imageLiteral(resourceName: "download.pdf") }
        
        status.listen(.off) { [weak self] _ in
            self?.indicator.image = #imageLiteral(resourceName: "off.pdf")
            self?.add.isHidden = true
            self?.connect.isHidden = true
            self?.save.isHidden = true
            self?.list.isHidden = true
            self?.hideConnect()
        }
        
        status.listen(.localize) { [weak self] _ in
            self?.indicator.image = #imageLiteral(resourceName: "localize.pdf")
        }
        
        status.listen(.on) { [weak self] _ in
            self?.indicator.image = #imageLiteral(resourceName: "on.pdf")
            self?.connect.isHidden = false
            self?.save.isHidden = false
            self?.add.isHidden = false
        }
        
        let indicator = UIImageView(image: #imageLiteral(resourceName: "off.pdf"))
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.clipsToBounds = true
        indicator.contentMode = .center
        view.addSubview(indicator)
        self.indicator = indicator
        
        let close = UIButton()
        close.translatesAutoresizingMaskIntoConstraints = false
        close.setImage(#imageLiteral(resourceName: "close.pdf"), for: [])
        close.addTarget(self, action: #selector(self.close), for: .touchUpInside)
        close.imageView!.clipsToBounds = true
        close.imageView!.contentMode = .center
        view.addSubview(close)
        
        let add = UIButton()
        add.translatesAutoresizingMaskIntoConstraints = false
        add.setImage(#imageLiteral(resourceName: "add.pdf"), for: [])
        add.isHidden = true
        add.imageView!.clipsToBounds = true
        add.imageView!.contentMode = .center
        add.addTarget(self, action: #selector(showList), for: .touchUpInside)
        view.addSubview(add)
        self.add = add
        
        let connect = UIButton()
        connect.translatesAutoresizingMaskIntoConstraints = false
        connect.setImage(#imageLiteral(resourceName: "connect.pdf"), for: [])
        connect.isHidden = true
        connect.imageView!.clipsToBounds = true
        connect.imageView!.contentMode = .center
        connect.addTarget(self, action: #selector(showConnect), for: .touchUpInside)
        view.addSubview(connect)
        self.connect = connect
        
        let save = UIButton()
        save.translatesAutoresizingMaskIntoConstraints = false
        save.setImage(#imageLiteral(resourceName: "save.pdf"), for: [])
        save.isHidden = true
        save.imageView!.clipsToBounds = true
        save.imageView!.contentMode = .center
        save.addTarget(self, action: #selector(send), for: .touchUpInside)
        view.addSubview(save)
        self.save = save
        
        let list = List()
        list.isHidden = true
        
        list.onCancel = { [weak self] in self?.hideList() }
        
        list.onSelect = { [weak self] in
            guard let item = self?.items[$0] else { return }
            self?.hideList()
            self?.add(item)
            App.shared.alert(.local("Alert.success"), message: .local("Place.added") + item.name)
        }
        
        view.addSubview(list)
        self.list = list
        
        indicator.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        indicator.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        indicator.widthAnchor.constraint(equalToConstant: 50).isActive = true
        indicator.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        close.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        close.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        close.widthAnchor.constraint(equalToConstant: 50).isActive = true
        close.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        add.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        add.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        add.widthAnchor.constraint(equalToConstant: 80).isActive = true
        add.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        connect.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
        connect.centerYAnchor.constraint(equalTo: add.centerYAnchor).isActive = true
        connect.widthAnchor.constraint(equalToConstant: 60).isActive = true
        connect.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        save.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        save.centerYAnchor.constraint(equalTo: add.centerYAnchor).isActive = true
        save.widthAnchor.constraint(equalToConstant: 60).isActive = true
        save.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        list.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        list.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
        list.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        list.topAnchor.constraint(equalTo: close.bottomAnchor, constant: 5).isActive = true
    }
    
    @objc private func close() { navigationController?.popViewController(animated: true) }
    
    @objc private func showList() {
        list.add(items.enumerated().map({ ($0.0, $0.1, material[$0.1.id]) }))
        add.isHidden = true
        connect.isHidden = true
        save.isHidden = true
        list.isHidden = false
    }
    
    @objc private func hideList() {
        add.isHidden = false
        connect.isHidden = false
        save.isHidden = false
        list.isHidden = true
    }
    
    @objc private func send() {
        add.isHidden = true
        connect.isHidden = true
        save.isHidden = true
        list.isHidden = true
        upload { [weak self] in
            self?.add.isHidden = false
            self?.connect.isHidden = false
            self?.save.isHidden = false
            App.shared.alert(.local("Alert.success"), message: .local("Place.saved"))
        }
    }
}
