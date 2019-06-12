import Visualix
import UIKit

final class Map: Visualix.Map {
    private weak var map: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        socket = Socket()
        
        let map = UIButton()
        map.translatesAutoresizingMaskIntoConstraints = false
        map.setImage(#imageLiteral(resourceName: "map.pdf"), for: .normal)
        map.setImage(#imageLiteral(resourceName: "stop.pdf"), for: .selected)
        map.imageView!.clipsToBounds = true
        map.imageView!.contentMode = .center
        map.addTarget(self, action: #selector(toggle), for: .touchUpInside)
        view.addSubview(map)
        self.map = map
        
        let close = UIButton()
        close.translatesAutoresizingMaskIntoConstraints = false
        close.setImage(#imageLiteral(resourceName: "close.pdf"), for: [])
        close.imageView!.clipsToBounds = true
        close.imageView!.contentMode = .center
        close.addTarget(self, action: #selector(self.close), for: .touchUpInside)
        view.addSubview(close)
        
        map.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        map.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        map.widthAnchor.constraint(equalToConstant: 80).isActive = true
        map.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        close.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        close.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        close.widthAnchor.constraint(equalToConstant: 50).isActive = true
        close.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    override func didReceiveMemoryWarning() {
        if status.mode == .map {
            toggle()
            App.shared.alert(.local("Alert.warning"), message: .local("Map.toggling"))
        }
    }
    
    @objc private func toggle() {
        map.isSelected.toggle()
        if map.isSelected {
            status.mode = .map
        } else {
            status.mode = .off
        }
    }
    
    @objc private func close() { navigationController?.popViewController(animated: true) }
}
