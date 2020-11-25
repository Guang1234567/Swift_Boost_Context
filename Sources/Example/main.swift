import Swift_Boost_Context
import Foundation

let queue = DispatchQueue(label: "TestCoroutine"/*, attributes: .concurrent*/)


func main() throws {
    //registerSignalHanlder()

    /*for idx in 1...10_000 {
        let t = Tester()
        queue.async {
            t.start(idx)
        }
    }

    Thread.sleep(forTimeInterval: 5)*/

    //try example_04()

    let t = Tester()
    t.start(7)
}

do {
    try main()
} catch {
    print("main : \(error)")
}


class Tester: CustomStringConvertible, CustomDebugStringConvertible {
    deinit {
        print("Tester deint")
    }

    init() {

    }

    func f1(_ fromCtx: BoostContext, _ data: Int) -> Void {
        defer {
            print("f1 finish")
            print("f1 never reach defer block too !")
            print("So donot dispose your res alloced before here !")
        }
        print("main ----> f1  fromCtx = \(fromCtx)  data = \(data)")

        let _: BoostTransfer<Void> = fromCtx.jump(data: "7654321")
        print("f1 never reach here")
    }

    func f2(_ fromCtx: BoostContext, _ data: String) -> Void {
        defer {
            print("f2 finish")
        }
        print("queue ----> f2  fromCtx = \(fromCtx)")

        let _: BoostTransfer<Void> = fromCtx.jump(data: "1234567")
    }

    func start(_ idx: Int) {
        let bc1: BoostContext = makeBoostContext(self.f1)
        print("bc1 = \(bc1)  --  \(idx)")
        let resultF1ToMain: BoostTransfer<String> = bc1.jump(data: 123)
        print("resultF1ToMain = \(resultF1ToMain)  --  \(idx)")
        let pointer = Unmanaged.passUnretained(self).toOpaque()
        let _ = Unmanaged<Tester>.fromOpaque(pointer).takeRetainedValue()
        print("main <---- f1 resultF1ToMain = \(resultF1ToMain.data)  --  \(idx)")
    }

    var description: String {
        return "Tester(321)"
    }
    var debugDescription: String {
        return "Tester(321)"
    }
}

func example_04() throws {
    // Example-04
    // ===================
    print("Example-04 =============================")
    var sum: Int = 0
    for i in (1...1000) {
        print("@@@ --------------------   makeCoFuture_01_\(i) --- await -- before")
        sum += try makeCoFuture_01("makeCoFuture_01_\(i)", i).await()
        print("@@@ --------------------   makeCoFuture_01_\(i) --- await -- end")
    }
    print("sum = \(sum)")
}

func makeCoFuture_01(_ name: String, _ i: Int) -> CoFuture<Int> {
    return CoFuture(name) {
        var sum: Int = 0
        for j in (1...100) {
            print("--------------------   makeCoFuture_02_\(j) --- await -- before")
            sum += try makeCoFuture_02("makeCoFuture_02_\(j)", j).await()
            //sum += j
            print("--------------------   makeCoFuture_02_\(j) --- await -- end")
        }
        return sum
    }
}

func makeCoFuture_02(_ name: String, _ i: Int) -> CoFuture<Int> {
    return CoFuture(name) {
        //try co.delay(.milliseconds(5))
        return i
    }
}