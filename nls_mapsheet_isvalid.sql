CREATE OR REPLACE FUNCTION nls_mapsheet_isvalid(IN grid_ref text)
    RETURNS boolean
    LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
	return grid_ref ~ '^[K-NP-X][2-6]([1-4LR]|[1-4][1-4LR]|[1-4][1-4][1-4LR]|[1-4][1-4][1-4][LRA-H]|[1-4][1-4][1-4][A-H][1-4])?$';
END
$BODY$;