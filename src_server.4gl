IMPORT os
IMPORT FGL g2_ws
IMPORT FGL g2_logging

TYPE t_rec RECORD
	rowno    SMALLINT,
	fileName STRING,
	data     BYTE,
	data_len INTEGER
END RECORD
DEFINE m_imgs        STRING = "../pics"
PUBLIC DEFINE g2_log g2_logging.logger
MAIN

	TRY
		DATABASE njm_demo310
	CATCH
		DISPLAY SQLERRMESSAGE
		EXIT PROGRAM
	END TRY
	IF NOT checkDB() THEN
		EXIT PROGRAM
	END IF

	CALL g2_ws.start("getData", "testBinary", g2_log)

	CALL g2_log.logIt("Program Finished.")

END MAIN
--------------------------------------------------------------------------------------------------------------
FUNCTION checkDB() RETURNS BOOLEAN
	DEFINE x SMALLINT = 0
--	DROP TABLE imgfiles
	TRY
		SELECT COUNT(*) INTO x FROM imgfiles
	CATCH
		CREATE TABLE imgfiles(rowno SMALLINT, fileName VARCHAR(50), data BYTE, data_len INTEGER)
	END TRY
	IF x = 0 THEN
		IF NOT loadData() THEN
			CALL g2_log.logIt("Failed to load test data")
			RETURN FALSE
		END IF
	END IF
	SELECT COUNT(*) INTO x FROM imgfiles
	CALL g2_log.logIt(SFMT("%1 rows of test data found.", x))
	IF x = 0 THEN
		RETURN FALSE
	END IF
	RETURN TRUE
END FUNCTION
--------------------------------------------------------------------------------------------------------------
FUNCTION loadData() RETURNS BOOLEAN
	DEFINE l_rec  t_rec
	DEFINE x, d   SMALLINT
	DEFINE l_ext  STRING
	DEFINE l_path STRING
	CALL os.Path.dirSort("name", 1)
	LET d = os.Path.dirOpen(m_imgs)
	IF d < 1 THEN
		RETURN FALSE
	END IF
	LET x = 0
	WHILE TRUE
		LET l_path = os.Path.dirNext(d)
		IF l_path IS NULL THEN
			EXIT WHILE
		END IF

		IF os.path.isDirectory(l_path) THEN
			--DISPLAY "Dir:",path
			CONTINUE WHILE
		ELSE
			--DISPLAY "Fil:",path
		END IF

		LET l_ext = os.path.extension(l_path)
		IF l_ext IS NULL OR l_ext != "png" THEN
			CONTINUE WHILE
		END IF
		LET x              = x + 1
		LET l_rec.rowno    = x
		LET l_rec.fileName = l_path
		LOCATE l_rec.data IN FILE os.path.join(m_imgs, l_rec.fileName)
		LET l_rec.data_len = LENGTH(l_rec.data)
		INSERT INTO imgfiles VALUES(l_rec.*)
	END WHILE
	CALL g2_log.logIt(SFMT("Loaded %1 rows into table.", x))
	RETURN TRUE

END FUNCTION
