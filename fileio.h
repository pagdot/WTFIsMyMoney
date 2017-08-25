#ifndef FILEIO_H
#define FILEIO_H

#include <QObject>
#include <QString>
#include <QUrl>

class FileIO : public QObject
{
    Q_OBJECT

public:
    explicit FileIO(QObject *parent = 0);

    Q_INVOKABLE QString read(QUrl const &fName);
    Q_INVOKABLE bool write(QUrl const &fName, const QString& data);

signals:
    void error(const QString& msg);
};

#endif // FILEIO_H
