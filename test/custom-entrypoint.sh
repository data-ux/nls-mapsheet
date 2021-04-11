#!/bin/bash
set -e

run_test() {
    echo "Running nls_mapsheet test! Loading function to DB."
    psql -U postgres -f $1/nls_mapsheet.sql
    echo "Restoring test data to DB."
	pg_restore -d postgres $1/test/data.dump
    echo "Testing all mapsheets"
    psql -d postgres -c "do \$\$ begin assert (SELECT count(*) FROM mapsheet WHERE NOT st_equals(geom, nls_mapsheet(grid_ref))) = 0, 'Not all mapsheets pass!';end;\$\$;"
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
run_test "$@"

exit 0