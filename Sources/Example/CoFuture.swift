import Foundation
import Swift_Boost_Context

public enum CoFutureError: Error {
    case canceled
}

public class CoFuture<R>: CustomDebugStringConvertible, CustomStringConvertible {

    let _name: String

    let _task: () throws -> R

    var _result: Result<R, Error>?

    var _bctx: BoostContext!

    deinit {
        print("\(self) : deinit")
    }

    public init(_ name: String, _ task: @escaping () throws -> R) {
        self._name = name
        self._task = task
        self._result = nil

        // no memory leak!
        /*self._bctx = makeBoostContext { (fromCtx: BoostContext, data: Void) -> Void in
            let result: Result<R, Error> = Result {
                try task()
            }
            let _: BoostTransfer<Void> = fromCtx.jump(data: result)
        }*/

        self._bctx = makeBoostContext { [unowned self] (fromCtx: BoostContext, data: Void) -> Void in
            let result: Result<R, Error> = Result { [unowned self] in
                try self._task()
            }

            let _: BoostTransfer<Void> = fromCtx.jump(data: result)
        }
    }

    @discardableResult
    public func await() throws -> R {
        //let pSelf: UnsafeMutableRawPointer = Unmanaged.passUnretained(self).toOpaque()
        let btf: BoostTransfer<Result<R, Error>> = self._bctx.jump(data: ())
        return try btf.data.get()
    }

    public func cancel() -> Void {
        if self._result == nil {
            self._result = .failure(CoFutureError.canceled)
        }
    }

    public var isCanceled: Bool {
        if case .failure(let error as CoFutureError)? = self._result {
            return error == .canceled
        }
        return false
    }

    public var debugDescription: String {
        return "CoFuture(_name: \(_name))"
    }

    public var description: String {
        return "CoFuture(_name: \(_name))"
    }
}
