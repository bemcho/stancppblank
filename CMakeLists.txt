cmake_minimum_required(VERSION 3.0)
project(stansandbox C CXX)
set(CMAKE_CXX_STANDARD 14)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake/Modules/")
set (CMAKE_CXX_FLAGS "-v -m64  -Weverything  -Wno-c++98-compat -Wno-global-constructors -Wno-exit-time-destructors -Wno-padded -Wno-missing-prototypes -Wno-missing-variable-declarations")

file(GLOB SOURCE_MAIN
        "${CMAKE_SOURCE_DIR}/include/*.hpp"
        "${CMAKE_SOURCE_DIR}/src/*.cpp"
        )

find_package(Threads REQUIRED)

find_package(Eigen REQUIRED)
if(Eigen_FOUND)
    include_directories(${EIGEN_INCLUDE_DIRS})
endif()

find_package(Boost REQUIRED)
if(Boost_FOUND)
    include_directories(${Boost_INCLUDE_DIRS})
endif()

find_package(Stan REQUIRED)
if(Stan_FOUND)
    include_directories(${STAN_INCLUDE_DIRS})
endif()


set(LIBS  ${LIBS} ${Boost_LIBS} ${Eigen_LIBS} ${Stan_LIBS} Threads::Threads)
add_executable(stansandbox ${SOURCE_MAIN})
target_link_libraries(stansandbox  ${LIBS})