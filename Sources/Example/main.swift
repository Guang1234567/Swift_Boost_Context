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


class Tester {
    deinit {
        print("Tester deinit")
    }

    init() {

    }

    func f1(data: Int, yield: FN_YIELD<String, Int>) -> String {
        defer {
            print("f1 finish")
        }

        print("main ----> f1    data = \(data)")

        let data1: Int = yield("1234567")
        print("main ----> f1    data = \(data1)")

        let data2: Int = yield("7654321")
        print("main ----> f1    data = \(data2)")

        return "9876543"
    }

    func start(_ idx: Int) {
        let yield: FN_YIELD<Int, String> = makeBoostContext(self.f1)

        let data1: String = yield(123)
        print("main <---- f1    data = \(data1)")

        let data2: String = yield(765)
        print("main <---- f1    data = \(data2)")

        let data3: String = yield(987)
        print("main <---- f1    data = \(data3)")
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
