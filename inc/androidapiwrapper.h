#ifndef ANDROIDAPIWRAPPER_H
#define ANDROIDAPIWRAPPER_H

#include <QObject>

class AndroidAPIWrapper : public QObject
{
    Q_OBJECT
public:
    explicit AndroidAPIWrapper(QObject *parent = nullptr);

    Q_INVOKABLE void requestPermission(QString permission);

signals:
    void permissionResponse(QString permission, bool approved);

public slots:


};

#endif // ANDROIDAPIWRAPPER_H
