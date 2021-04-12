[![CI](https://github.com/data-ux/nls-mapsheet/actions/workflows/test.yml/badge.svg)](https://github.com/data-ux/nls-mapsheet/actions)

# NLS mapsheet geometry generator

PL/pgSQL function for generating polygon geometry for given grid reference (specified in [JHS 197](https://www.suomidigi.fi/ohjeet-ja-tuki/jhs-suositukset/jhs-197-euref-fin-koordinaattijarjestelmat-niihin-liittyvat-muunnokset-ja-karttalehtijako)). The system is also known as "UTM-lehtijako" by National Land Survey of Finland.

## Usage

Run the SQL in [nls_mapsheet.sql](nls_mapsheet.sql) in your Postgis database. Then you can use the function `nls_mapsheet`, eg. `SELECT 'K2311E4' AS id, nls_mapsheet('K2311E4') AS geom;`

The above function assumes the input is a valid JHS 197 grid reference. To validate a string, you can use the function [nls_mapsheet_isvalid.sql](nls_mapsheet_isvalid.sql), eg. `SELECT nls_mapsheet_isvalid('K2311E4');` -> TRUE

## Running test

The file test/data.dump contains [NLS supplied](https://www.maanmittauslaitos.fi/en/e-services/open-data-file-download-service) geometries for all 144,594 official mapsheets. To test all of them against the functions, run in repo root:

`docker run --rm -v $(pwd):/nls_mapsheet postgis/postgis:13-3.1 /nls_mapsheet/test/custom-entrypoint.sh`

