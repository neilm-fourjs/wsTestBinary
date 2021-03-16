IMPORT security
IMPORT FGL testBinary

TYPE t_rec RECORD
	rowno    SMALLINT,
	fileName STRING,
	data     BYTE,
	data_len INTEGER
END RECORD

MAIN
	DEFINE l_rec  getAllDataResponseBodyType
	DEFINE l_arr2 DYNAMIC ARRAY OF t_rec
	DEFINE x      SMALLINT
	DEFINE l_stat SMALLINT
	DEFINE l_uri  STRING

	LET l_uri = ARG_VAL(1)
	IF l_uri.getLength() > 1 THEN
		LET Endpoint.Address.Uri = l_uri
	END IF

	CALL testBinary.getAllData() RETURNING l_stat, l_rec.*
	DISPLAY "Client Used: ", Endpoint.Address.Uri, " Stat:",l_stat
	IF l_stat != 0 THEN EXIT PROGRAM END IF

	DISPLAY "Got ", l_rec.arr.getLength(), " rows."
	FOR x = 1 TO l_rec.arr.getLength()
		DISPLAY SFMT("Locate %1 in %2 data_len: %3 Encoded Len: %4 ",
				x, l_rec.arr[x].fileName, l_rec.arr[x].data_len, l_rec.arr[x].data.getLength())
		LET l_arr2[x].rowno    = l_rec.arr[x].rowno
		LET l_arr2[x].fileName = l_rec.arr[x].fileName
		LET l_arr2[x].data_len = l_rec.arr[x].data_len
		LOCATE l_arr2[x].data IN MEMORY

		IF l_rec.arr[x].data.getLength() > 0 THEN
			CALL security.Base64.ToByte(l_rec.arr[x].data, l_arr2[x].data)
			DISPLAY SFMT("l_arr2 data length: %1 expecting: %2", LENGTH(l_arr2[x].data), l_arr2[x].data_len)
			IF LENGTH(l_arr2[x].data) = l_arr2[x].data_len THEN
				DISPLAY SFMT("Saving file %1", l_arr2[x].fileName)
				CALL l_arr2[x].data.writeFile(l_arr2[x].fileName)
			END IF
		END IF
	END FOR
END MAIN
