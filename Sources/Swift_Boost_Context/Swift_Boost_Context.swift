import C_Boost_Context_fcontext

import Foundation

struct Swift_Boost_Context {
    var text = "Hello, Swift Boost Context!"
}

class BoostTransfer<INPUT, OUTPUT>: CustomDebugStringConvertible, CustomStringConvertible {

    public let fromContext: BoostContext<INPUT, OUTPUT>

    public let data: OUTPUT

    init(_ fromContext: BoostContext<INPUT, OUTPUT>, _ data: OUTPUT) {
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

/*
public protocol BoostContext: class, CustomDebugStringConvertible, CustomStringConvertible {
    associatedtype INPUT
    associatedtype OUTPUT

    @discardableResult
    func jump(data: INPUT) -> BoostTransfer<INPUT, OUTPUT>
}
*/
class BoostContext<INPUT, OUTPUT> {

    @discardableResult
    func jump(data: INPUT) -> BoostTransfer<INPUT, OUTPUT> {
        fatalError("Method has to be overriden this is an abstract class")
    }

}

class BoostContextProxy<INPUT, OUTPUT>: BoostContext<INPUT, OUTPUT>, CustomDebugStringConvertible, CustomStringConvertible {
    /*
    public typealias INPUT = INPUT
    public typealias OUTPUT = OUTPUT
    */

    let _fctx: fcontext_t

    init(_ fctx: fcontext_t) {
        self._fctx = fctx
    }

    @discardableResult
    override
    public func jump(data: INPUT) -> BoostTransfer<INPUT, OUTPUT> {
        let input: UnsafeMutablePointer<INPUT> = UnsafeMutablePointer.allocate(capacity: 1)
        input.initialize(repeating: data, count: 1)

        let tf: transfer_t = jump_fcontext(self._fctx, input)

        let output: UnsafeMutablePointer<OUTPUT> = tf.data!.bindMemory(to: OUTPUT.self, capacity: 1)
        defer {
            output.deinitialize(count: 1)
            output.deallocate()
        }
        let result: OUTPUT = output.pointee
        return BoostTransfer<INPUT, OUTPUT>(BoostContextProxy(tf.fctx), result)
    }

    public var description: String {
        return "BoostContextProxy(_fctx: \(_fctx))"
    }

    public var debugDescription: String {
        return "BoostContextProxy(_fctx: \(_fctx))"
    }
}

typealias CCallBack = (fcontext_t) -> Void

typealias FContextStack = UnsafeMutableRawPointer

public typealias FN_YIELD<INPUT, OUTPUT> = (INPUT) -> OUTPUT

public typealias FN<INPUT, OUTPUT> = (INPUT, @escaping FN_YIELD<OUTPUT, INPUT>) -> OUTPUT

func cFn(_ tf: transfer_t) -> Void {
    let input: UnsafeMutablePointer<CCallBack>? = tf.data?.bindMemory(to: CCallBack.self, capacity: 1)
    if let input = input {
        let callback = input.pointee
        input.deinitialize(count: 1)
        input.deallocate()
        callback(tf.fctx)
    }
}

class BoostContextImpl<INPUT, OUTPUT>: BoostContext<INPUT, OUTPUT>, CustomDebugStringConvertible, CustomStringConvertible {
    /*
    public typealias INPUT = INPUT
    public typealias OUTPUT = OUTPUT
    */

    private let _fn: FN<INPUT, OUTPUT>

    private let _spSize: Int

    private let _sp: FContextStack

    private let _fctx: fcontext_t

    private var _yieldBoostContextInSide: BoostContext<OUTPUT, INPUT>!

    private var _yieldBoostContextOutSide: BoostContext<INPUT, OUTPUT>!

    deinit {
        _yieldBoostContextInSide = nil
        _yieldBoostContextOutSide = nil
        _sp.deallocate()
        //print("BoostContextImpl.deinit: _spSize: \(_spSize), _sp: \(_sp), _fctx: \(_fctx), .pageSize: \(Int.pageSize)")
    }

    init(_ fn: @escaping FN<INPUT, OUTPUT>) {
        //let spSize: Int = 1 << 18 /* 256 KiB*/
        //let spSize: Int = 1 << 17 /* 128 KiB*/
        //let spSize: Int = 1 << 16 /* 64 KiB*/
        let spSize: Int = .pageSize * 16
        let sp: FContextStack = .allocate(byteCount: spSize, alignment: .pageSize)
        self._fn = fn
        self._spSize = spSize
        self._sp = sp
        self._fctx = make_fcontext(sp + spSize, spSize, cFn)
        super.init()
        self._yieldBoostContextOutSide = self
    }

    /// simulate sugar syntax `yield` inside `_fn` scope
    @inline(__always)
    @discardableResult
    private func yieldInside(_ data: OUTPUT) -> INPUT {
        let btf: BoostTransfer<OUTPUT, INPUT> = self._yieldBoostContextInSide.jump(data: data)
        self._yieldBoostContextInSide = btf.fromContext
        return btf.data
    }

    /// simulate sugar syntax `yield` outside `_fn` scope
    @inline(__always)
    @discardableResult
    fileprivate func yieldOutside(_ data: INPUT) -> OUTPUT {
        let btf: BoostTransfer<INPUT, OUTPUT>
        btf = _yieldBoostContextOutSide.jump(data: data)
        _yieldBoostContextOutSide = btf.fromContext
        return btf.data
    }

    @discardableResult
    override
    public func jump(data: INPUT) -> BoostTransfer<INPUT, OUTPUT> {
        let callback: CCallBack = { [unowned self] (fromContext: fcontext_t) in
            let fromBoostContext: BoostContext<OUTPUT, INPUT> = BoostContextProxy(fromContext)
            self._yieldBoostContextInSide = fromBoostContext

            let result: OUTPUT = self._fn(data, self.yieldInside)

            self._yieldBoostContextInSide.jump(data: result)
        }

        let input: UnsafeMutablePointer<CCallBack> = UnsafeMutablePointer.allocate(capacity: 1)
        input.initialize(repeating: callback, count: 1)

        let tf: transfer_t = jump_fcontext(self._fctx, input)

        let output: UnsafeMutablePointer<OUTPUT> = tf.data!.bindMemory(to: OUTPUT.self, capacity: 1)
        defer {
            output.deinitialize(count: 1)
            output.deallocate()
        }
        let result: OUTPUT = output.pointee
        return BoostTransfer<INPUT, OUTPUT>(BoostContextProxy(tf.fctx), result)
    }

    public var description: String {
        return "BoostContextImpl(_spSize: \(_spSize), _sp: \(_sp), _fctx: \(_fctx))"
    }
    public var debugDescription: String {
        return "BoostContextImpl(_spSize: \(_spSize), _sp: \(_sp), _fctx: \(_fctx))"
    }
}

public func makeBoostContext<INPUT, OUTPUT>(_ fn: @escaping FN<INPUT, OUTPUT>) -> FN_YIELD<INPUT, OUTPUT> {
    return BoostContextImpl(fn).yieldOutside
}


