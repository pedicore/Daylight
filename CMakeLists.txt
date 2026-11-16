cmake_minimum_required(VERSION 3.21)

project(Daylight VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 6.4 REQUIRED COMPONENTS Quick QuickControls2)

qt_add_executable(daylight
    src/main.cpp
    src/TaskManager.cpp
    src/TaskManager.h
)

qt_add_resources(daylight ui
    PREFIX "/"
    FILES qml/Main.qml
)

target_link_libraries(daylight PRIVATE
    Qt6::Quick
    Qt6::QuickControls2
)

include(CTest)

if(BUILD_TESTING)
    find_package(Qt6 REQUIRED COMPONENTS Test)

    qt_add_executable(taskmanager_tests
        tests/TaskManagerTest.cpp
        src/TaskManager.cpp
        src/TaskManager.h
    )

    target_include_directories(taskmanager_tests PRIVATE src)

    target_link_libraries(taskmanager_tests PRIVATE Qt6::Test)

    add_test(NAME taskmanager COMMAND taskmanager_tests)
endif()

install(TARGETS daylight
    RUNTIME DESTINATION bin
    BUNDLE DESTINATION .
)