# Automatic Makefile made by make4js by N.J.M.

#URI=http://localhost:8090/testBinary
#URI=http://localhost/g/ws/r/wsTestBinary/testBinary
URI=https://generodemos.dynu.net/g/ws/r/wsTestBinary/testBinary


fgl_obj1 =  \
	 g2_logging.$(4GLOBJ) \
	 g2_ws.$(4GLOBJ) \
	 getData.$(4GLOBJ) \
	 src_server.$(4GLOBJ) 

fgl_obj2 = \
	 src_client.$(4GLOBJ) \
	 testBinary.$(4GLOBJ)

fgl_frm1 = 

testBinary.4gl:
	fglrestful $(URI)?openapi.json

PRG1=wsTestBinary.42r
PRG2=client.42r

cleanextra=rm -f bin_client/*.png distbin/*.gar

include ./Make_fjs.inc

