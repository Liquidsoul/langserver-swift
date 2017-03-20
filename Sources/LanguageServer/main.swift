import BaseProtocol
import Dispatch
import Foundation
import LanguageServerProtocol

private let header: [String : String] = [
    "Content-Type": "application/vscode-jsonrpc; charset=utf8"
]

enum Result<R> {
    case Success(R)
    case Failure(Error)
}

typealias Async<A, B> = (_ a: A, _ handler: @escaping (Result<B>) -> Void) -> Void

infix operator •

func •<A, B, C>(f: @escaping Async<A, B>, g: @escaping Async<B, C>) -> Async<A, C> {
    return { a, handler in
        f(a, { result in
            switch result {
            case .Success(let b): g(b, handler)
            case .Failure(let e): handler(.Failure(e))
            }
        })
    }
}

func f(input: FileHandle, h: @escaping (Result<Data>) -> ()) {
    let main = OperationQueue.main
    let dataAvailable = NotificationCenter.default.addObserver(forName: .NSFileHandleDataAvailable, object: input, queue: main) { (notification) -> () in
//        sleep(2000)
//        NotificationCenter.default.removeObserver(dataAvailable)
        h(.Success(input.availableData))
    }

    input.waitForDataInBackgroundAndNotify()
}

func g(buffer: RequestBuffer? = nil) -> (Data, (Result<RequestBuffer>) -> ()) -> () {
    return { (i: Data, handler: (Result<RequestBuffer>) -> ()) in
        switch buffer {
        case .some(let b):
            b.append(i)
            handler(Result.Success(b))
        case .none:
            handler(Result.Success(RequestBuffer(i)))
        }
    }
}

let chained = f • g()

chained(FileHandle.standardInput) { result in
    switch result {
    case .Success(let request):
        dump(request)
//        exit(0)
    case .Failure(let e):
        NSLog(e.localizedDescription)
    }
}

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
