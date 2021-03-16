TYPE t_rec RECORD
	rowno    SMALLINT,
	fileName STRING,
	data     BYTE,
	data_len INTEGER
END RECORD

TYPE t_getAll RECORD
	rows INTEGER,
	arr DYNAMIC ARRAY OF t_rec
END RECORD

-- get a row
PUBLIC FUNCTION getData(l_no INTEGER ATTRIBUTES(WSParam))
		ATTRIBUTES(WSGet, WSPath = "/getData/{l_no}", WSDescription = "Get a Row")
    RETURNS t_rec  ATTRIBUTES(WSMedia = 'application/json')
	DEFINE l_rec t_rec
	DISPLAY SFMT("getData: %1.", l_no)
	LOCATE l_rec.data IN FILE
	SELECT * INTO l_rec.* FROM imgfiles WHERE rowno = l_no
	IF STATUS = NOTFOUND THEN
		DISPLAY SFMT("getData: %1 not found.", l_no)
	ELSE
		DISPLAY SFMT("getData: %1 found.", l_no)
	END IF
	RETURN l_rec.*
END FUNCTION
--------------------------------------------------------------------------------------------------------------
-- get all rows
PUBLIC FUNCTION getAllData() 
    ATTRIBUTES(WSGet, WSPath = "/getAllData", WSDescription = "Get all Rows")
		RETURNS t_getAll ATTRIBUTES(WSMedia = 'application/json')
	DEFINE l_rec t_getAll
	DEFINE x     SMALLINT = 1
 	SELECT COUNT(*) INTO l_rec.rows FROM imgfiles
	DISPLAY SFMT("getAllData: %1 Rows counted.", l_rec.rows)
	DECLARE cur CURSOR FOR SELECT * FROM imgfiles
	LOCATE l_rec.arr[x].data IN FILE
	FOREACH cur INTO l_rec.arr[x].*
		IF l_rec.arr[x].data IS NOT NULL THEN
			DISPLAY SFMT("getAllData: Row %1 Length: %2", x, l_rec.arr[x].data_len)
			LET x = x + 1
			LOCATE l_rec.arr[x].data IN FILE
		ELSE
			DISPLAY "getAllData: data is NULL!"
		END IF
	END FOREACH
	IF x > l_rec.rows THEN
		CALL l_rec.arr.deleteElement( l_rec.arr.getLength() ) -- delete last empty row.
	END IF
	DISPLAY SFMT("getAllData: %1 Rows in array.", l_rec.arr.getLength())
	RETURN l_rec.*
END FUNCTION
