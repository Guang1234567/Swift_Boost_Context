import Foundation
import Swift_Boost_Context

public enum CoFutureError: Error {
    case canceled
}

public class CoFuture<R>: CustomDebugStringConvertible, CustomStringConvertible {

    let _name: String

    let _task: () throws -> R

    var _result: Result<R, Error>?

    var _yield: FN_YIELD<Void, Result<R, Error>>

    deinit {
        print("\(self) : deinit")
    }

    public init(_ name: String, _ task: @escaping () throws -> R) {
        self._name = name
        self._task = task
        self._result = nil

        // no memory leak!
        self._yield = makeBoostContext { (data, yield) -> Result<R, Error> in
            let result: Result<R, Error> = Result {
                try task()
            }

            return result
        }
    }

    @discardableResult
    public func await() throws -> R {
        let data: Result<R, Error> = self._yield(())
        return try data.get()
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
