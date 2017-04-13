import BaseProtocol
import Foundation
import LanguageServerProtocol
import enum Result.NoError
import ReactiveSwift

//let stdin = Signal<Data, NoError> { observer in
//    let no = NotificationCenter.default.addObserver(forName: .NSFileHandleDataAvailable, object: FileHandle.standardInput, queue: nil) { _ in
//        let data = FileHandle.standardInput.availableData
//        if data.isEmpty {
//            observer.sendCompleted()
//        } else {
//            observer.send(value: data)
//            FileHandle.standardInput.waitForDataInBackgroundAndNotify()
//        }
//    }
//
//    return ActionDisposable {
//        NotificationCenter.default.removeObserver(no, name: .NSFileHandleDataAvailable, object: FileHandle.standardInput)
//    }
//}

extension SignalProtocol where Value == Data {

    func requestSignal() -> Signal<Request, PredefinedError> {
        return Signal { observer in
            let state = RequestBuffer()

            func bar() {
                for msg in state where !msg.isEmpty {
                    do {
                        try observer.send(value: Request(msg))
                    } catch let error as PredefinedError {
                        observer.send(error: error)
                    } catch {
                        observer.send(error: PredefinedError.parse)
                    }
                }
            }

            return self.observe { event in
                switch event {
                case .value(let value):
                    state.append(value)
                    bar()
                case .completed:
                    bar()
                    observer.sendCompleted()
                case .failed(_):
                    observer.send(error: PredefinedError.internalError)
                case .interrupted:
                    observer.sendInterrupted()
                }
            }
        }
    }

}

let (mocStdin, foo) = Signal<Data, NoError>.pipe()
let bar = mocStdin.requestSignal()
let state: Server? = nil

bar.observeCompleted {
    exit(0)
}

bar.map { (request: Request) -> Response in

}

bar.observeResult { result in
    switch result {
    case .success(let request):
        dump(request)
    case .failure(let error):
        print(error)
    }
}

foo.send(value: "Content-Length: 185\r\n".data(using: .utf8)!)
foo.send(value: "\r\n{\"jsonrpc\":\"2.0\",\"id\":0,\"method\":\"initialize\",".data(using: .utf8)!)
foo.send(value: "\"params\":{\"processId\":65017,\"rootPath\":\"/Users/ryan/Source/langserver".data(using: .utf8)!)
foo.send(value: "-swift/Fixtures/ValidLayouts/Simple\",\"capabilities\":{},\"trace\":\"off\"}}".data(using: .utf8)!)
foo.send(value: "Content-Length: 58\r\n".data(using: .utf8)!)
foo.send(value: "Content-Type: application/vscode-jsonrpc; charset=utf8\r\n".data(using: .utf8)!)
foo.send(value: "\r\n".data(using: .utf8)!)
foo.send(value: "{\"method\":\"shutdown\",\"params\":null,\"id\":1,\"jsonrpc\":\"2.0\"}".data(using: .utf8)!)
foo.sendCompleted()

// Launch the task
//FileHandle.standardInput.waitForDataInBackgroundAndNotify()
RunLoop.main.run()
