cmake_minimum_required(VERSION 3.16)

project(MusicTheoryAnalyzer VERSION 1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

find_package(Qt6 REQUIRED COMPONENTS
    Core
    Gui
    Multimedia
    Qml
    Quick
    QuickControls2
)

find_package(PkgConfig REQUIRED)
pkg_check_modules(FLUIDSYNTH REQUIRED IMPORTED_TARGET fluidsynth)

qt_add_executable(MusicTheoryAnalyzerApp
    main.cpp
)

qt_add_qml_module(MusicTheoryAnalyzerApp
    URI MusicTheoryAnalyzer
    VERSION 1.0
    QML_FILES
        Main.qml
)

target_include_directories(MusicTheoryAnalyzerApp PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/third_party/midifile/include
)

target_sources(MusicTheoryAnalyzerApp PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/third_party/midifile/src/MidiFile.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/third_party/midifile/src/MidiEvent.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/third_party/midifile/src/MidiEventList.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/third_party/midifile/src/MidiMessage.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/third_party/midifile/src/Binasc.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/third_party/midifile/src/Options.cpp
)

target_link_libraries(MusicTheoryAnalyzerApp PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Multimedia
    Qt6::Qml
    Qt6::Quick
    Qt6::QuickControls2
    PkgConfig::FLUIDSYNTH
)

install(TARGETS MusicTheoryAnalyzerApp
    RUNTIME DESTINATION bin
)

install(
    FILES
        ${CMAKE_CURRENT_SOURCE_DIR}/packaging/io.github.userusv.MusicTheoryAnalyzer.desktop
    DESTINATION share/applications
)

install(
    FILES
        ${CMAKE_CURRENT_SOURCE_DIR}/packaging/io.github.userusv.MusicTheoryAnalyzer.metainfo.xml
    DESTINATION share/metainfo
)

install(
    FILES
        ${CMAKE_CURRENT_SOURCE_DIR}/packaging/io.github.userusv.MusicTheoryAnalyzer.svg
    DESTINATION share/icons/hicolor/scalable/apps
)
