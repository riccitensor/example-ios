import Visualix
import SwiftyZeroMQ
import Foundation

final class Socket: Visualix.Socket {
    private var context: SwiftyZeroMQ.Context?
    private var sender: SwiftyZeroMQ.Socket?
    private var receiver: SwiftyZeroMQ.Socket?
    
    deinit {
        try? SwiftyZeroMQ.Context().close()
    }
    
    override func connect(sender: String) {
        open()
        do {
            self.sender = try context?.socket(.pair)
            try self.sender?.connect(sender)
        } catch { App.shared.alert(.local("Alert.error"), message: error.localizedDescription) }
    }
    
    override func connect(receiver: String) {
        open()
        do {
            self.receiver = try context?.socket(.pair)
            try self.receiver?.connect(receiver)
        } catch { App.shared.alert(.local("Alert.error"), message: error.localizedDescription) }
    }
    
    override func close() {
        disconnect()
        try? context?.close()
    }
    
    override func disconnect() {
        try? sender?.close()
        try? receiver?.close()
    }
    
    override func send(_ data: Data) {
        do {
            try sender?.send(data: data)
        } catch { App.shared.alert(.local("Alert.error"), message: error.localizedDescription) }
    }
    
    override func receive(_ result: ((String) -> Void)) {
        if let message = try? receiver?.recv(bufferLength: 1_000_000, options: .dontWait) {
            result(message)
        }
    }
    
    private func open() {
        if context == nil {
            do {
                context = try SwiftyZeroMQ.Context()
            } catch { App.shared.alert(.local("Alert.error"), message: error.localizedDescription) }
        }
    }
}
