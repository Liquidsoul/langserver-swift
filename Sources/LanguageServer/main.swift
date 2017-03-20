import BaseProtocol
import Dispatch
import Foundation
import LanguageServerProtocol
import enum Result.NoError
import ReactiveSwift

let signal = Signal<Data, NoError> { observer in
    let no = NotificationCenter.default.addObserver(forName: .NSFileHandleDataAvailable, object: FileHandle.standardInput, queue: OperationQueue.main) { _ in
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

signal.observeCompleted {
    exit(0)
}

signal.observeValues({
    dump($0)
})

FileHandle.standardInput.waitForDataInBackgroundAndNotify()


// When new data is available
//var dataAvailable : NSObjectProtocol!
//dataAvailable = NotificationCenter.default.addObserver(forName: .NSFileHandleDataAvailable, object: stdin, queue: main) { (notification) -> Void in
//    let buffer = stdin.availableData
//
//    guard !buffer.isEmpty else {
//        return stdin.waitForDataInBackgroundAndNotify()
//    }
//
////    requests.append(buffer)
////
////    for requestBuffer in requests {
////        do {
////            let request = try Request(requestBuffer)
////            let response = handle(request)
////            /// If the request id is null then it is a notification and not a request
////            switch request {
////            case .request(_, _, _):
////                let toSend = response.data(header)
////                FileHandle.standardOutput.write(toSend)
////            default: ()
////            }
////        } catch let error as PredefinedError {
////            fatalError(error.description)
////        } catch {
////            fatalError("TODO: Better error handeling. \(error)")
////        }
////    }
////
////    return stdin.waitForDataInBackgroundAndNotify()
//}

// Launch the task
RunLoop.main.run()
