
import C_Boost_Context_fcontext

import Foundation

struct Swift_Boost_Context {
    var text = "Hello, World!"
}

public class BoostTransfer<OUTPUT>: CustomDebugStringConvertible, CustomStringConvertible {

    public let fromContext: BoostContext

    public let data: OUTPUT

    init(_ fromContext: BoostContext, _ data: OUTPUT) {
        self.fromContext = fromContext
        self.data = data
    }

    public var description: String {
        return "BoostTransfer(fromContext: \(fromContext))"
    }
    public var debugDescription: String {
        return "BoostTransfer(fromContext: \(fromContext))"
    }
}

public protocol BoostContext: class, CustomDebugStringConvertible, CustomStringConvertible {

    func jump<INPUT, OUTPUT>(data: INPUT) -> BoostTransfer<OUTPUT>

    func jump<OUTPUT>() -> BoostTransfer<OUTPUT>
}

class BoostContextProxy: BoostContext {

    let _fctx: fcontext_t

    init(_ fctx: fcontext_t) { self._fctx = fctx }


    func jump<INPUT, OUTPUT>(data: INPUT) -> BoostTransfer<OUTPUT> {
        let input: UnsafeMutablePointer<INPUT> = UnsafeMutablePointer.allocate(capacity: 1)
        input.initialize(repeating: data, count: 1)

        //print("BoostContextProxy.jump : _fctx = \(self._fctx)")
        let tf: transfer_t = jump_fcontext(self._fctx, input)
        //print("BoostContextProxy.jump : tf = \(tf)")
        let output: UnsafeMutablePointer<OUTPUT> = tf.data!.bindMemory(to: OUTPUT.self, capacity: 1)
        defer {
            output.deinitialize(count: 1)
            output.deallocate()
        }
        let result: OUTPUT = output.pointee
        return BoostTransfer(BoostContextProxy(tf.fctx), result)
    }

    func jump<OUTPUT>() -> BoostTransfer<OUTPUT> {
        return self.jump(data: ())
    }

    var description: String {
        return "BoostContextProxy(_fctx: \(_fctx))"
    }

    var debugDescription: String {
        return "BoostContextProxy(_fctx: \(_fctx))"
    }
}

typealias CCallBack = (fcontext_t) -> Void

private func cFn(_ tf: transfer_t) -> Void {
    let input: UnsafeMutablePointer<CCallBack>? = tf.data?.bindMemory(to: CCallBack.self, capacity: 1)
    if let input = input {
        let callback = input.pointee
        input.deinitialize(count: 1)
        input.deallocate()
        callback(tf.fctx)
    }
}

typealias FContextStack = UnsafeMutableRawPointer

class BoostContextImpl<_IN>: BoostContext {

    typealias FN = (BoostContext, _IN) -> Void

    private let _fn: FN

    private let _spSize: Int

    private let _sp: FContextStack

    private let _fctx: fcontext_t

    deinit {
        _sp.deallocate()
        //print("BoostContextImpl.deinit: _spSize: \(_spSize), _sp: \(_sp), _fctx: \(_fctx), .pageSize: \(Int.pageSize)")
    }

    init(_ fn: @escaping FN) {
        //let spSize: Int = 1 << 18 /* 256 KiB*/
        //let spSize: Int = 1 << 17 /* 128 KiB*/
        //let spSize: Int = 1 << 16 /* 64 KiB*/
        let spSize: Int = .pageSize * 16
        let sp: FContextStack = .allocate(byteCount: spSize, alignment: .pageSize)
        self._fn = fn
        self._spSize = spSize
        self._sp = sp
        self._fctx = make_fcontext(sp + spSize, spSize, cFn)
        //print("_fctx = \(_fctx)")
    }


    func jump<INPUT, OUTPUT>(data: INPUT) -> BoostTransfer<OUTPUT> {
        let callback: CCallBack = { [unowned self] (fromContext: fcontext_t) in
            let fromBoostContext: BoostContextProxy = BoostContextProxy(fromContext)
            self._fn(fromBoostContext, data as! _IN)
        }

        let input: UnsafeMutablePointer<CCallBack> = UnsafeMutablePointer.allocate(capacity: 1)
        input.initialize(repeating: callback, count: 1)
        /*
        defer {
            input.deinitialize(count: 1)
            input.deallocate()
        }
        */
        //print("jump : _fctx = \(self._fctx)")
        let tf: transfer_t = jump_fcontext(self._fctx, input)
        //print("jump : tf = \(tf)")
        let output: UnsafeMutablePointer<OUTPUT> = tf.data!.bindMemory(to: OUTPUT.self, capacity: 1)
        defer {
            output.deinitialize(count: 1)
            output.deallocate()
        }
        let result: OUTPUT = output.pointee
        return BoostTransfer(BoostContextProxy(tf.fctx), result)
    }

    func jump<_OUT>() -> BoostTransfer<_OUT> {
        return self.jump(data: ())
    }

    var description: String {
        return "BoostContextImpl(_spSize: \(_spSize), _sp: \(_sp), _fctx: \(_fctx))"
    }
    var debugDescription: String {
        return "BoostContextImpl(_spSize: \(_spSize), _sp: \(_sp), _fctx: \(_fctx))"
    }
}

public func makeBoostContext<INPUT>(_ fn: @escaping (BoostContext, INPUT) -> Void) -> BoostContext {
    return BoostContextImpl(fn)
}


