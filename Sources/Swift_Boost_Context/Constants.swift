#if os(Linux) || os(Android)

import Glibc

extension Int {

    public static let pageSize = sysconf(Int32(_SC_PAGESIZE))
    public static let processorsNumber = sysconf(Int32(_SC_NPROCESSORS_ONLN))

}

#elseif os(macOS)

import Darwin

extension Int {

    public static let pageSize = sysconf(_SC_PAGESIZE)
    public static let processorsNumber = sysconf(_SC_NPROCESSORS_ONLN)

}

#else

extension Int {

    public static let pageSize = 4096
    public static let processorsNumber = 2

}

#endif