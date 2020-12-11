// https://github.com/apple/swift-corelibs-foundation/blob/master/CoreFoundation/Base.subproj/SwiftRuntime/TargetConditionals.h


#if __ANDROID__
    #if defined(__aarch64__)
        #include "./asm/jump_arm64_aapcs_elf_gas.S"
        #include "./asm/make_arm64_aapcs_elf_gas.S"
        #include "./asm/ontop_arm64_aapcs_elf_gas.S"
    #elif defined(__arm__)
        #include "./asm/jump_arm_aapcs_elf_gas.S"
        #include "./asm/make_arm_aapcs_elf_gas.S"
        #include "./asm/ontop_arm_aapcs_elf_gas.S"
    #elif defined(__x86_64__)
        #include "./asm/jump_x86_64_sysv_elf_gas.S"
        #include "./asm/make_x86_64_sysv_elf_gas.S"
        #include "./asm/ontop_x86_64_sysv_elf_gas.S"
    #elif defined(__i386__)
        #include "./asm/jump_i386_sysv_elf_gas.S"
        #include "./asm/make_i386_sysv_elf_gas.S"
        #include "./asm/ontop_i386_sysv_elf_gas.S"
    #endif
#elif __linux__
    #if defined(__x86_64__)
        #include "./asm/jump_x86_64_sysv_elf_gas.S"
        #include "./asm/make_x86_64_sysv_elf_gas.S"
        #include "./asm/ontop_x86_64_sysv_elf_gas.S"
    #elif defined(__i386__)
        #include "./asm/jump_i386_sysv_elf_gas.S"
        #include "./asm/make_i386_sysv_elf_gas.S"
        #include "./asm/ontop_i386_sysv_elf_gas.S"
    #endif
#elif __APPLE__
    #include <TargetConditionals.h>
    #if __x86_64__
        #include "./asm/jump_x86_64_sysv_macho_gas.S"
        #include "./asm/make_x86_64_sysv_macho_gas.S"
        #include "./asm/ontop_x86_64_sysv_macho_gas.S"
    #elif __i386__
        #include "./asm/jump_i386_sysv_macho_gas.S"
        #include "./asm/make_i386_sysv_macho_gas.S"
        #include "./asm/ontop_i386_sysv_macho_gas.S"
    #elif __aarch64__
        #include "./asm/jump_arm64_aapcs_macho_gas.S"
        #include "./asm/make_arm64_aapcs_macho_gas.S"
        #include "./asm/ontop_arm64_aapcs_macho_gas.S"
    #elif __arm__
        #include "./asm/jump_arm_aapcs_macho_gas.S"
        #include "./asm/make_arm_aapcs_macho_gas.S"
        #include "./asm/ontop_arm_aapcs_macho_gas.S"
    #endif
#elif _WIN64
        #include "./asm/jump_x86_64_ms_pe_gas.asm"
        #include "./asm/make_x86_64_ms_pe_gas.asm"
        #include "./asm/ontop_x86_64_ms_pe_gas.asm"
#elif _WIN32
        #include "./asm/jump_i386_ms_pe_gas.asm"
        #include "./asm/make_i386_ms_pe_gas.asm"
        #include "./asm/ontop_i386_ms_pe_gas.asm"
#else
    #include "./asm/jump_arm64_aapcs_elf_gas.S"
#endif



