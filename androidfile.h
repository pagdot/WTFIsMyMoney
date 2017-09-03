#ifndef ANDROIDFILE_H
#define ANDROIDFILE_H

#include <QObject>
#include <QAndroidActivityResultReceiver>
#include <QAndroidJniObject>
#include <QUrl>
#include <QString>

class AndroidFile : public QObject, QAndroidActivityResultReceiver
{
    Q_OBJECT
public:
    explicit AndroidFile(QObject *parent = nullptr);

    Q_PROPERTY(QString mime MEMBER m_mime NOTIFY mimeChanged)

    Q_INVOKABLE void fileOpenDialog();
    Q_INVOKABLE void fileCreateDialog();

    Q_INVOKABLE static QString fileOpen(QUrl fileUrl);
    Q_INVOKABLE static void fileCreate(QUrl fileUrl, QString content);

    virtual void handleActivityResult(int receiverRequestCode, int resultCode, const QAndroidJniObject &data) override;

protected:

private:
    QString m_mime = "*/*";

signals:
    void opened(QUrl fileUri);
    void created(QUrl fileUri);
    void mimeChanged();

public slots:
};

#endif // ANDROIDFILE_H
