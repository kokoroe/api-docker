#!/bin/bash

# Initialize data directory
DATA_DIR=/data
DB=${MYSQL_DBNAME:-}

if [ ! -f $DATA_DIR/mysql ]; then
    mysql_install_db
fi

# Initialize first run
if [[ -e /.firstrun ]]; then
    /scripts/first_run.sh
fi

function loadSqlDump {
    if [ -f tests/tables.sql ]; then
        echo "Load MySQL tables..."
        mysql -u root --database=$DB < tests/tables.sql
    fi

    if [ -f tests/datas.sql ]; then
        echo "Load MySQL datas..."
        mysql -u root --database=$DB < tests/datas.sql
    fi
}

if [ -d /project ]; then
    cd /project
    loadSqlDump
    make test-functional
fi
