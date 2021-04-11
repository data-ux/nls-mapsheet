CREATE OR REPLACE FUNCTION nls_mapsheet(IN grid_ref text)
    RETURNS public.geometry(Polygon, 3067)
    LANGUAGE 'plpgsql'
    
AS $BODY$
DECLARE
    parts text[];
    ref_len integer;
    x integer;
    y integer;
    cell_width integer := 192000;
    cell_height integer := 96000;
BEGIN
	parts := string_to_array(grid_ref, NULL);
	ref_len := array_length(parts, 1);
	if parts[1] < 'O' then
		y := (ascii(parts[1]) - 75) * cell_height + 6570000;
	else
		y := (ascii(parts[1]) - 76) * cell_height + 6570000;
	END if;
	x := parts[2]::integer * cell_width - 460000;
	if ref_len = 2 then
		return ST_MakeEnvelope(x, y, x + 192000, y + 96000, 3067);
	END if;
	for i in 3..7 loop
		if parts[i] = 'L' then
			return ST_MakeEnvelope(x, y, x + cell_width/2, y + cell_height, 3067);
		elsif parts[i] = 'R' then
			return ST_MakeEnvelope(x + cell_width/2, y, x + cell_width, y + cell_height, 3067);
		END if;
		if i = 6 then
			cell_width := cell_width / 4;
			cell_height := cell_height / 2;
			x := x + cell_width * ((ascii(parts[6]) - 65)/2);
			y := y + cell_height * ((ascii(parts[6]) - 65)%2);
		else
			cell_width := cell_width / 2;
			cell_height := cell_height / 2;
			x := x + cell_width * ((parts[i]::integer-1)/2);
			y := y + cell_height * ((parts[i]::integer-1)%2);
		END if;
    	if ref_len = i then
    		return ST_MakeEnvelope(x, y, x + cell_width, y + cell_height, 3067);
    	END if;
    end loop;
END
$BODY$;