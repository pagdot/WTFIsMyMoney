QT += qml quick quickcontrols2 core \
    svg xml sql

CONFIG += c++11

INCLUDEPATH += inc

SOURCES += src/main.cpp

RESOURCES += src/qml/qml.qrc \
    icons/icons.qrc \
    translations/translations.qrc

VERSION = 1.1

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# The following define makes your compiler emit warnings if you use
# any feature of Qt which as been marked deprecated (the exact warnings
# depend on your compiler). Please consult the documentation of the
# deprecated API in order to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

# You can also make your code fail to compile if you use deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

TRANSLATIONS = translations/wtfismymoney_en.ts\
    translations/wtfismymoney_de.ts

android: {
    QT += androidextras
    SOURCES += src/androidfile.cpp
    HEADERS += inc/androidfile.h

    CONFIG += qzxing_qml
    CONFIG += qzxing_multimedia

    include(lib/QZXing/QZXing.pri)

    DISTFILES += \
        android/AndroidManifest.xml \
        android/gradle/wrapper/gradle-wrapper.jar \
        android/gradlew \
        android/res/values/libs.xml \
        android/build.gradle \
        android/gradle/wrapper/gradle-wrapper.properties \
        android/gradlew.bat \
        android/res/values/libs.xml \
        android/res/mipmap-hdpi/ic_launcher.png \
        android/res/mipmap-mdpi/ic_launcher.png \
        android/res/mipmap-xhdpi/ic_launcher.png \
        android/res/mipmap-xxhdpi/ic_launcher.png \
        android/res/mipmap-xxxhdpi/ic_launcher.png

    ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android
}

windows: {
    HEADERS += inc/fileio.h
    SOURCES += src/fileio.cpp
}

HEADERS += \
    inc/translations.h
