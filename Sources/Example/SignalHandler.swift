#if !os(Windows)

import Foundation


func signalHandler(signal: Int32) -> Void {
    var stackTrace = String();
    for symbol in Thread.callStackSymbols {
        stackTrace = stackTrace.appending("%@\r\n\(symbol)");
    }
    print("**********************************************\n")
    print("\(stackTrace)")
    print("**********************************************\n")
    exit(signal);
}

func unregisterSignalHandler() {
    signal(SIGINT, SIG_DFL);
    signal(SIGSEGV, SIG_DFL);
    signal(SIGTRAP, SIG_DFL);
    signal(SIGABRT, SIG_DFL);
    signal(SIGILL, SIG_DFL);
}

func registerSignalHanlder() {
    signal(SIGINT, signalHandler);
    signal(SIGSEGV, signalHandler);
    signal(SIGTRAP, signalHandler);
    signal(SIGABRT, signalHandler);
    signal(SIGILL, signalHandler);
}

#endif