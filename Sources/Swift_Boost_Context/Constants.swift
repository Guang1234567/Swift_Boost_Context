#if os(Linux) || os(Android)

import Glibc

extension Int {

    public static let pageSize = sysconf(Int32(_SC_PAGESIZE))
    public static let processorsNumber = sysconf(Int32(_SC_NPROCESSORS_ONLN))

}

#else

import Darwin

extension Int {

    public static let pageSize = sysconf(_SC_PAGESIZE)
    public static let processorsNumber = sysconf(_SC_NPROCESSORS_ONLN)

}

#endif