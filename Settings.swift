import Visualix
import UIKit

final class Settings: UIViewController {
    private class Field: UITextField {
        init() {
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            font = .systemFont(ofSize: 22, weight: .light)
            textColor = .white
            tintColor = .white
            keyboardType = .numbersAndPunctuation
            keyboardAppearance = .dark
            spellCheckingType = .no
            autocorrectionType = .no
            autocapitalizationType = .none
            clearButtonMode = .never
        }
        
        required init?(coder: NSCoder) { return nil }
    }
    
    private class Ip: UIView, UITextFieldDelegate {
        private var fields = [Field]()
        private(set) weak var title: UILabel!
        
        init() {
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            
            let title = UILabel()
            title.translatesAutoresizingMaskIntoConstraints = false
            title.font = .systemFont(ofSize: 14, weight: .light)
            title.textColor = .white
            addSubview(title)
            self.title = title
            
            var left = leftAnchor
            (0 ..< 4).forEach {
                let field = Field()
                field.tag = $0
                field.delegate = self
                addSubview(field)
                fields.append(field)
                
                if $0 != 0 {
                    let dot = UIView()
                    dot.isUserInteractionEnabled = false
                    dot.translatesAutoresizingMaskIntoConstraints = false
                    dot.backgroundColor = .white
                    dot.layer.cornerRadius = 3
                    addSubview(dot)
                    
                    dot.centerXAnchor.constraint(equalTo: field.leftAnchor, constant: -26).isActive = true
                    dot.bottomAnchor.constraint(equalTo: field.bottomAnchor, constant: -5).isActive = true
                    dot.widthAnchor.constraint(equalToConstant:6).isActive = true
                    dot.heightAnchor.constraint(equalToConstant:6).isActive = true
                }
                
                field.leftAnchor.constraint(equalTo: left, constant: 20).isActive = true
                field.topAnchor.constraint(equalTo: title.bottomAnchor).isActive = true
                field.widthAnchor.constraint(equalToConstant: 65).isActive = true
                field.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
                left = field.rightAnchor
            }
            
            heightAnchor.constraint(equalToConstant: 80).isActive = true
            
            title.topAnchor.constraint(equalTo: topAnchor).isActive = true
            title.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        }
        
        required init?(coder: NSCoder) { return nil }
        
        var address: String {
            get { return fields.map({ $0.text! }).joined(separator: ".") }
            set {
                newValue.components(separatedBy: ".").enumerated().forEach {
                    if $0.0 < fields.count { fields[$0.0].text = $0.1 }
                }
            }
        }
        
        func textFieldShouldReturn(_ field: UITextField) -> Bool {
            _ = field.tag < 3 ? fields[field.tag + 1].becomeFirstResponder() : field.resignFirstResponder()
            return true
        }
        
        func textField(_ field: UITextField, shouldChangeCharactersIn: NSRange, replacementString: String) -> Bool {
            let result = field.text!.replacingCharacters(in: Range(shouldChangeCharactersIn, in: field.text!)!, with: replacementString)
            return CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: result)) && result.count <= 3
        }
    }
    
    private class Port: UIView, UITextFieldDelegate {
        private(set) weak var field: Field!
        private(set) weak var title: UILabel!
        
        init() {
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            
            let field = Field()
            field.delegate = self
            addSubview(field)
            self.field = field
            
            let title = UILabel()
            title.translatesAutoresizingMaskIntoConstraints = false
            title.font = .systemFont(ofSize: 14, weight: .light)
            title.textColor = .white
            addSubview(title)
            self.title = title
            
            heightAnchor.constraint(equalToConstant: 60).isActive = true
            
            title.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            title.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
            title.widthAnchor.constraint(equalToConstant: 130).isActive = true
            
            field.leftAnchor.constraint(equalTo: title.rightAnchor, constant: -30).isActive = true
            field.topAnchor.constraint(equalTo: topAnchor).isActive = true
            field.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            field.widthAnchor.constraint(equalToConstant: 140).isActive = true
        }
        
        required init?(coder: NSCoder) { return nil }
        
        func textFieldShouldReturn(_: UITextField) -> Bool {
            field.resignFirstResponder()
            return true
        }
        
        func textField(_: UITextField, shouldChangeCharactersIn: NSRange, replacementString: String) -> Bool {
            let result = field.text!.replacingCharacters(in: Range(shouldChangeCharactersIn, in: field.text!)!, with: replacementString)
            return CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: result)) && result.count <= 5
        }
    }
    
    private class Speed: UIView {
        private(set) weak var title: UILabel!
        private(set) weak var value: UILabel!
        private(set) weak var slider: UISlider!
        private let formatter = NumberFormatter()
        
        init() {
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            formatter.minimumFractionDigits = 1
            formatter.maximumFractionDigits = 2
            formatter.minimumIntegerDigits = 1
            
            let title = UILabel()
            title.translatesAutoresizingMaskIntoConstraints = false
            title.font = .systemFont(ofSize: 10, weight: .light)
            title.textColor = .white
            title.numberOfLines = 2
            addSubview(title)
            self.title = title
            
            let value = UILabel()
            value.translatesAutoresizingMaskIntoConstraints = false
            value.font = .systemFont(ofSize: 16, weight: .regular)
            value.textColor = .white
            addSubview(value)
            self.value = value
            
            let slider = UISlider()
            slider.translatesAutoresizingMaskIntoConstraints = false
            slider.addTarget(self, action: #selector(update), for: .valueChanged)
            addSubview(slider)
            self.slider = slider
            
            title.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            title.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
            title.widthAnchor.constraint(equalToConstant: 60).isActive = true
            
            value.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            value.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            value.widthAnchor.constraint(equalToConstant: 40).isActive = true
            
            slider.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            slider.rightAnchor.constraint(equalTo: value.leftAnchor, constant: -5).isActive = true
            slider.leftAnchor.constraint(equalTo: title.rightAnchor).isActive = true
            
            heightAnchor.constraint(equalToConstant: 60).isActive = true
        }
        
        required init?(coder: NSCoder) { return nil }
        @objc func update() { value.text = formatter.string(from: NSNumber(value: slider.value)) }
    }
    
    private weak var rest: Ip!
    private weak var socket: Ip!
    private weak var send: Port!
    private weak var receive: Port!
    private weak var request: Port!
    private weak var map: Speed!
    private weak var localize: Speed!
    private weak var resolution: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = .local("Settings.title")
        title.font = .systemFont(ofSize: 16, weight: .bold)
        title.textColor = .white
        view.addSubview(title)
        
        let rest = Ip()
        rest.title.text = .local("Settings.rest")
        rest.address = Configuration.shared.rest.address
        self.rest = rest
        
        let socket = Ip()
        socket.title.text = .local("Settings.socket")
        socket.address = Configuration.shared.socket.address
        self.socket = socket
        
        let send = Port()
        send.title.text = .local("Settings.send")
        send.field.text = "\(Configuration.shared.socket.portSend)"
        self.send = send
        
        let receive = Port()
        receive.title.text = .local("Settings.receive")
        receive.field.text = "\(Configuration.shared.socket.portReceive)"
        self.receive = receive
        
        let request = Port()
        request.title.text = .local("Settings.request")
        request.field.text = "\(Configuration.shared.rest.port)"
        self.request = request
        
        let map = Speed()
        map.title.text = .local("Settings.map")
        map.slider.value = Float(Configuration.shared.speed.map)
        map.slider.minimumValue = 0.01
        map.slider.maximumValue = 1
        map.update()
        self.map = map
        
        let localize = Speed()
        localize.title.text = .local("Settings.localize")
        localize.slider.value = Float(Configuration.shared.speed.localize)
        localize.slider.minimumValue = 0.05
        localize.slider.maximumValue = 3
        localize.update()
        self.localize = localize
        
        let resolution = UISegmentedControl(items: ["640", "800", "960", "1024", "1280", "1440", "1920"])
        resolution.translatesAutoresizingMaskIntoConstraints = false
        resolution.selectedSegmentIndex = {
            switch Configuration.shared.frame.size {
            case .x640: return 0
            case .x800: return 1
            case .x960: return 2
            case .x1024: return 3
            case .x1280: return 4
            case .x1440: return 5
            case .x1920: return 6
            }
        } ()
        view.addSubview(resolution)
        self.resolution = resolution
        
        let save = UIButton()
        save.addTarget(self, action: #selector(self.save), for: .touchUpInside)
        save.backgroundColor = .white
        save.translatesAutoresizingMaskIntoConstraints = false
        save.setTitle(.local("Settings.save"), for: [])
        save.setTitleColor(.black, for: .normal)
        save.setTitleColor(UIColor(white: 0, alpha: 0.1), for: .highlighted)
        save.titleLabel!.font = .systemFont(ofSize: 14, weight: .bold)
        save.layer.cornerRadius = 6
        view.addSubview(save)
        
        let cancel = UIButton()
        cancel.addTarget(self, action: #selector(self.cancel), for: .touchUpInside)
        cancel.translatesAutoresizingMaskIntoConstraints = false
        cancel.setTitle(.local("Settings.cancel"), for: [])
        cancel.setTitleColor(UIColor(white: 1, alpha: 0.6), for: .normal)
        cancel.setTitleColor(UIColor(white: 1, alpha: 0.1), for: .highlighted)
        cancel.titleLabel!.font = .systemFont(ofSize: 14, weight: .medium)
        view.addSubview(cancel)
        
        title.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        title.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        
        var top = resolution.bottomAnchor
        [map, localize, rest, socket, send, receive, request].forEach {
            view.addSubview($0)
            $0.topAnchor.constraint(equalTo: top).isActive = true
            $0.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
            $0.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
            top = $0.bottomAnchor
        }
        
        resolution.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 20).isActive = true
        resolution.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
        resolution.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
        
        save.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        save.bottomAnchor.constraint(equalTo: cancel.topAnchor).isActive = true
        save.widthAnchor.constraint(equalToConstant: 120).isActive = true
        save.heightAnchor.constraint(equalToConstant: 36).isActive = true
        
        cancel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        cancel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        cancel.widthAnchor.constraint(equalToConstant: 120).isActive = true
        cancel.heightAnchor.constraint(equalToConstant: 70).isActive = true
    }
    
    @objc private func save() {
        Configuration.shared.frame.size = {
            switch resolution.selectedSegmentIndex {
            case 1: return .x800
            case 2: return .x960
            case 3: return .x1024
            case 4: return .x1280
            case 5: return .x1440
            case 6: return .x1920
            default: return .x640
            }
        } ()
        Configuration.shared.rest.address = rest.address
        Configuration.shared.rest.port = Int(request.field.text!)!
        Configuration.shared.socket.address = socket.address
        Configuration.shared.socket.portSend = Int(send.field.text!)!
        Configuration.shared.socket.portReceive = Int(receive.field.text!)!
        Configuration.shared.speed.map = Double(map.slider.value)
        Configuration.shared.speed.localize = Double(localize.slider.value)
        App.shared.alert(.local("Alert.success"), message: .local("Settings.saved"))
        DispatchQueue.main.async { [weak self] in self?.cancel() }
    }
    
    @objc private func cancel() { navigationController!.popViewController(animated: true) }
}
