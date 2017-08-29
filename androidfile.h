#ifndef ANDROIDFILE_H
#define ANDROIDFILE_H

#include <QObject>
#include <QUrl>
#include <QAndroidActivityResultReceiver>
#include <qDebug>



class Receiver : public QAndroidActivityResultReceiver {
public:
    Receiver() : QAndroidActivityResultReceiver() {}

    virtual void handleActivityResult(int receiverRequestCode, int resultCode, const QAndroidJniObject &data) override {
        QAndroidJniObject uri = data.callObjectMethod("getData", "()Landroid/net/Uri;");
        qDebug() << uri.toString();
    }
};

class AndroidFile : public QObject
{
    Q_OBJECT
public:
    explicit AndroidFile(QObject *parent = nullptr);

    Q_INVOKABLE QUrl fileOpen();
    Q_INVOKABLE QUrl fileCreate();

protected:
    Receiver m_receiver;

signals:

public slots:
};

#endif // ANDROIDFILE_H
