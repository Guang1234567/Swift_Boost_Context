cmake_minimum_required(VERSION 3.15)
project(Boost_Context_DEMO LANGUAGES C ASM VERSION 1.73.0)

set(CMAKE_C_STANDARD 99)

enable_language(ASM)
set(CMAKE_ASM_CREATE_SHARED_LIBRARY ${CMAKE_C_CREATE_SHARED_LIBRARY})

set(SRC asm/jump_x86_64_sysv_macho_gas.S asm/make_x86_64_sysv_macho_gas.S asm/ontop_x86_64_sysv_macho_gas.S)

add_definitions(-DBOOST_CONTEXT_EXPORT)
#add_library(fcontext SHARED fcontext.h ${SRC})
#set_target_properties(fcontext PROPERTIES VERSION ${PROJECT_VERSION})
add_library(fcontext_static STATIC fcontext.h ${SRC})
set_target_properties(fcontext_static PROPERTIES VERSION ${PROJECT_VERSION})
SET_TARGET_PROPERTIES(fcontext_static PROPERTIES OUTPUT_NAME "fcontext")

add_executable(Boost_Context_DEMO main.c)
target_link_libraries(Boost_Context_DEMO PRIVATE fcontext_static)