import Visualix
import UIKit

final class User: Visualix.User {
    private weak var indicator: UIImageView!
    private weak var list: List!
    private weak var show: UIButton!
    private weak var stop: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        socket = Socket()
        
        status.listen(.download) { [weak self] _ in
            self?.indicator.image = #imageLiteral(resourceName: "download.pdf")
            self?.stop.isHidden = true
        }
        
        status.listen(.navigate) { [weak self] _ in
            self?.indicator.image = #imageLiteral(resourceName: "navigate.pdf")
            self?.stop.isHidden = false
        }
        
        status.listen(.off) { [weak self] _ in
            self?.indicator.image = #imageLiteral(resourceName: "off.pdf")
            self?.show.isHidden = true
            self?.list.isHidden = true
            self?.stop.isHidden = true
        }
        
        status.listen(.localize) { [weak self] _ in
            self?.indicator.image = #imageLiteral(resourceName: "localize.pdf")
        }
        
        status.listen(.on) { [weak self] _ in
            self?.show.isHidden = false
            self?.indicator.image = #imageLiteral(resourceName: "on.pdf")
            self?.stop.isHidden = true
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
        
        let show = UIButton()
        show.translatesAutoresizingMaskIntoConstraints = false
        show.setImage(#imageLiteral(resourceName: "list.pdf"), for: [])
        show.isHidden = true
        show.imageView!.clipsToBounds = true
        show.imageView!.contentMode = .center
        show.addTarget(self, action: #selector(showList), for: .touchUpInside)
        view.addSubview(show)
        self.show = show
        
        let stop = UIButton()
        stop.translatesAutoresizingMaskIntoConstraints = false
        stop.setImage(#imageLiteral(resourceName: "stopNavigating.pdf"), for: [])
        stop.isHidden = true
        stop.imageView!.clipsToBounds = true
        stop.imageView!.contentMode = .center
        stop.addTarget(self, action: #selector(stopNavigating), for: .touchUpInside)
        view.addSubview(stop)
        self.stop = stop
        
        let list = List()
        list.isHidden = true
        
        list.onCancel = { [weak self] in self?.hideList() }
        
        list.onSelect = { [weak self] in
            self?.hideList()
            self?.navigate($0)
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
        
        show.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        show.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        show.widthAnchor.constraint(equalToConstant: 60).isActive = true
        show.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        stop.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        stop.centerYAnchor.constraint(equalTo: show.centerYAnchor).isActive = true
        stop.widthAnchor.constraint(equalToConstant: 60).isActive = true
        stop.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        list.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        list.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
        list.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        list.topAnchor.constraint(equalTo: close.bottomAnchor, constant: 5).isActive = true
    }
    
    @objc private func close() { navigationController?.popViewController(animated: true) }
    
    @objc private func showList() {
        list.add(
            graph.items.enumerated().filter({ !$0.element.id.isEmpty })
                .map({ content in (content.offset,
                                   items.first(where: { content.element.id == $0.id })!, material[content.element.id]) }))
        show.isHidden = true
        list.isHidden = false
    }
    
    @objc private func hideList() {
        show.isHidden = false
        list.isHidden = true
    }
    
    @objc private func stopNavigating() {
        status.mode = .on
    }
}
