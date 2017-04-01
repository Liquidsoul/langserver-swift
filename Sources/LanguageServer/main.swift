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

//let a: [Data] = []
//Data.init(a.joined())
//a.joined()

extension SignalProtocol where Value == Data {

    func foo() -> Signal<Request, PredefinedError> {
        return Signal { observer in
            let state = RequestBuffer()

            return self.observe { event in
                switch event {
                case .value(let value):
                    state.append(value)
                    while let msg = state.next() {
                        if msg.isEmpty { continue }
                        do {
                            let str = String(data: msg, encoding: .utf8)!
                            try observer.send(value: Request(msg))
                        } catch {
                            observer.send(error: PredefinedError.parse)
                        }
                    }
                case .completed:
                    while let msg = state.next() {
                        if msg.isEmpty { continue }
                        do {
                            try observer.send(value: Request(msg))
                        } catch {
                            observer.send(error: PredefinedError.parse)
                        }
                    }
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
let bar = mocStdin.foo()

//bar.observeCompleted {
//    exit(0)
//}
    bar
    .observeResult { result in
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

mocStdin.observeCompleted {
    exit(0)
}

// Launch the task
//FileHandle.standardInput.waitForDataInBackgroundAndNotify()
RunLoop.main.run()
