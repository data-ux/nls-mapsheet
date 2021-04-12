#!/bin/bash
set -e

run_test() {
    echo "Loading nls_mapsheet function to DB."
    psql -U postgres -f $1/nls_mapsheet.sql
    echo "Loading nls_mapsheet_isvalid function to DB."
    psql -U postgres -f $1/nls_mapsheet_isvalid.sql
    echo "Restoring test data to DB."
	pg_restore -d postgres $1/test/data.dump
    echo "Testing all mapsheets with nls_mapsheet()"
    psql -d postgres -c "do \$\$ begin assert (SELECT count(*) FROM mapsheet WHERE NOT st_equals(geom, nls_mapsheet(grid_ref))) = 0, 'Not all mapsheets pass!';end;\$\$;"
   echo "Testing all mapsheets with nls_mapsheet_isvalid()"
    psql -d postgres -c "do \$\$ begin assert (SELECT count(*) FROM mapsheet WHERE nls_mapsheet_isvalid(grid_ref) = FALSE) = 0, 'Not all mapsheets pass!';end;\$\$;"
    echo "Test PASS"
}

source "$(which docker-entrypoint.sh)"

docker_setup_env
docker_create_db_directories

if [ "$(id -u)" = '0' ]; then
    # then restart script as postgres user
    exec gosu postgres "$BASH_SOURCE" "$@"
fi

docker_init_database_dir
pg_setup_hba_conf

docker_temp_server_start
docker_setup_db
docker_process_init_files /docker-entrypoint-initdb.d/*
run_test ${1:-"/nls_mapsheet"}

exit 0