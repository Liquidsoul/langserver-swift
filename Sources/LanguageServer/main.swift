import BaseProtocol
import Foundation
import LanguageServerProtocol
import enum Result.NoError
import ReactiveSwift

let stdin = Signal<Data, NoError> { observer in
    let no = NotificationCenter.default.addObserver(forName: .NSFileHandleDataAvailable, object: FileHandle.standardInput, queue: nil) { _ in
        let data = FileHandle.standardInput.availableData
        if data.isEmpty {
            observer.sendCompleted()
        } else {
            observer.send(value: data)
            FileHandle.standardInput.waitForDataInBackgroundAndNotify()
        }
    }

    return ActionDisposable {
        NotificationCenter.default.removeObserver(no, name: .NSFileHandleDataAvailable, object: FileHandle.standardInput)
    }
}

stdin.scan(RequestBuffer()) { (buffer, Data) -> RequestBuffer in
    buffer.append(Data)
    return buffer
}
.flatMap(.merge) { b -> SignalProducer<Data, NoError> in
    return SignalProducer(AnySequence { b })
}
.filter({ !$0.isEmpty })
.attemptMap({ try Request($0) })
.map(handle())
.observeResult { result in
    switch result {
    case .success(let r):
        dump(r)
    case .failure(let e):
        dump(e)
    }
}

stdin.observeCompleted {
    exit(0)
}

// Launch the task
FileHandle.standardInput.waitForDataInBackgroundAndNotify()
RunLoop.main.run()
