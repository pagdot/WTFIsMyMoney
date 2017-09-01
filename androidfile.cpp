#include <QtAndroidExtras>
#include <QtAndroid>
#include <QDebug>

#include "androidfile.h"

AndroidFile::AndroidFile(QObject *parent) : QObject(parent)
{

}

void AndroidFile::fileOpenDialog() {
    QAndroidJniObject intent("android/content/Intent", "()V");
    QAndroidJniObject action = QAndroidJniObject::fromString("android.intent.action.OPEN_DOCUMENT");
    QAndroidJniObject category = QAndroidJniObject::fromString("android.intent.category.OPENABLE");
    QAndroidJniObject mime = QAndroidJniObject::fromString("*/*");
    intent.callObjectMethod("setAction",  "(Ljava/lang/String;)Landroid/content/Intent;", action.object<jstring>());
    intent.callObjectMethod("setType", "(Ljava/lang/String;)Landroid/content/Intent;", mime.object<jstring>());
    intent.callObjectMethod("addCategory", "(Ljava/lang/String;)Landroid/content/Intent;", category.object<jstring>());
    QtAndroid::startActivity(intent.object(), 0, this);
}

void AndroidFile::fileCreateDialog() {
    QAndroidJniObject intent("android/content/Intent", "()V");
    QAndroidJniObject action = QAndroidJniObject::fromString("android.intent.action.CREATE_DOCUMENT");
    QAndroidJniObject category = QAndroidJniObject::fromString("android.intent.category.OPENABLE");
    QAndroidJniObject mime = QAndroidJniObject::fromString("*/*");
    intent.callObjectMethod("setAction",  "(Ljava/lang/String;)Landroid/content/Intent;", action.object<jstring>());
    intent.callObjectMethod("setType", "(Ljava/lang/String;)Landroid/content/Intent;", mime.object<jstring>());
    intent.callObjectMethod("addCategory", "(Ljava/lang/String;)Landroid/content/Intent;", category.object<jstring>());
    QtAndroid::startActivity(intent.object(), 1, this);
}


QString AndroidFile::fileOpen(QUrl fileUrl) {
    QAndroidJniObject context = QtAndroid::androidContext();
    QAndroidJniObject resolver = context.callObjectMethod("getContentResolver", "()Landroid/content/ContentResolver;");
    QAndroidJniObject jfileUrl = QAndroidJniObject::fromString(fileUrl.toString());
    QAndroidJniObject uri = QAndroidJniObject::callStaticObjectMethod("android/net/Uri", "parse", "(Ljava/lang/String;)Landroid/net/Uri;", jfileUrl.object<jobject>());
    QAndroidJniObject mode = QAndroidJniObject::fromString("r");
    QAndroidJniObject parcel = resolver.callObjectMethod("openFileDescriptor", "(Landroid/net/Uri;Ljava/lang/String;)Landroid/os/ParcelFileDescriptor;", uri.object<jobject>(), mode.object<jstring>());
    QAndroidJniObject file = parcel.callObjectMethod("getFileDescriptor", "()Ljava/io/FileDescriptor;");
    QAndroidJniObject stream("java/io/FileInputStream", "(Ljava/io/FileDescriptor;)V", file.object<jobject>());

    QString content;
    jint byte;
    while ((byte = stream.callMethod<jint>("read")) != -1) {
        content.append((char) byte);
    }

    parcel.callMethod<void>("close", "()V");
    return content;
}

void AndroidFile::fileCreate(QUrl fileUrl, QString content) {
    QAndroidJniObject context = QtAndroid::androidContext();
    QAndroidJniObject resolver = context.callObjectMethod("getContentResolver", "()Landroid/content/ContentResolver;");
    QAndroidJniObject jfileUrl = QAndroidJniObject::fromString(fileUrl.toString());
    QAndroidJniObject uri = QAndroidJniObject::callStaticObjectMethod("android/net/Uri", "parse", "(Ljava/lang/String;)Landroid/net/Uri;", jfileUrl.object<jobject>());
    QAndroidJniObject mode = QAndroidJniObject::fromString("rw");
    QAndroidJniObject parcel = resolver.callObjectMethod("openFileDescriptor", "(Landroid/net/Uri;Ljava/lang/String;)Landroid/os/ParcelFileDescriptor;", uri.object<jobject>(), mode.object<jstring>());
    QAndroidJniObject file = parcel.callObjectMethod("getFileDescriptor", "()Ljava/io/FileDescriptor;");
    QAndroidJniObject stream("java/io/FileOutputStream", "(Ljava/io/FileDescriptor;)V", file.object<jobject>());
    QAndroidJniObject jcontent = QAndroidJniObject::fromString(content);
    QAndroidJniObject printStream("java/io/PrintStream", "(Ljava/io/OutputStream;)V", stream.object<jobject>());

    printStream.callMethod<void>("print", "(Ljava/lang/String;)V", jcontent.object<jstring>());
    printStream.callMethod<void>("flush", "()V");

    parcel.callMethod<void>("close", "()V");
}

void AndroidFile::handleActivityResult(int receiverRequestCode, int resultCode, const QAndroidJniObject &data) {
    QAndroidJniObject uri = data.callObjectMethod("getData", "()Landroid/net/Uri;");
    if(receiverRequestCode == 0) {
        emit opened(uri.toString());
    } else if (receiverRequestCode == 1) {
        emit created(uri.toString());
    }
}
