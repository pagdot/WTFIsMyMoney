#include <QtAndroidExtras>

#include "androidfile.h"







AndroidFile::AndroidFile(QObject *parent) : QObject(parent)
{

}

QUrl AndroidFile::fileOpen() {
    QAndroidJniObject intent("android/content/Intent", "()V");
    QAndroidJniObject action = QAndroidJniObject::fromString("android.intent.action.OPEN_DOCUMENT");
    QAndroidJniObject category = QAndroidJniObject::fromString("android.intent.category.OPENABLE");
    QAndroidJniObject mime = QAndroidJniObject::fromString("*/*");
    intent.callObjectMethod("setAction",  "(Ljava/lang/String;)Landroid/content/Intent;", action.object<jstring>());
    intent.callObjectMethod("setType", "(Ljava/lang/String;)Landroid/content/Intent;", mime.object<jstring>());
    intent.callObjectMethod("addCategory", "(Ljava/lang/String;)Landroid/content/Intent;", category.object<jstring>());
    QtAndroid::startActivity(intent.object(), 0, &m_receiver);
    return QUrl();
}

QUrl AndroidFile::fileCreate() {

    return QUrl();
}


