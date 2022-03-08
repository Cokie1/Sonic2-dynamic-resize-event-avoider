--S2ExploreLevel

--- Overrides camera RAM values of min max X and Y during dynamic level resizing, thus allowing you
--- to explore whole level.
--- Set RESTORE_CAMERA_ON_SCRIPT_END to true to have the program reset the CAMERA'S X/Y Min/MAX values to its current real 
--- values when the script ends
-- Code Tested On Git Hub Build Of Sonic 2 Revision 01. Havent checked if revision will effect register of subroutines 
-- at certains addresses
-- Cokie

--- RESTORE_CAMERA_ON_SCRIPT_END to true to have the program reset the X/Y Min/MAX values
--- to its current real values when the script ends
RESTORE_CAMERA_ON_SCRIPT_END = true

-- END OF LEVELSIZELOAD Subroutine address, AT THIS STATE ALL THE CAMERA X/Y MIN/MAX RAM M SHOULD BE SET,
-- SO I CAN GATHER THEM
EX_ENDOFLEVELSIZELOAD = 0XC1CE


-- CONSTANTS OF ALL THE CAMERA X/Y MIN/MAX VALUES THE SCRIPT OVERIDES THEM TO BE
CAMERA_MIN_X_POS_VALUE = 0X0000
CAMERA_MAX_X_POS_VALUE = 0x4640
CAMERA_MIN_Y_POS_VALUE = 0x0000
CAMERA_MAX_Y_POS_VALUE = 0x0A00

-- CONSTANTS Indexes  
INDEX_CAMERA_MIN_X_POS = 1
INDEX_CAMERA_MAX_X_POS = 2
INDEX_CAMERA_MIN_Y_POS = 3
INDEX_CAMERA_MAX_Y_POS = 4
INDEX_CAMERA_MAX_Y_POS_NOW  = 5

-- CONSTANTS Table of all the ADDRESSES IN RAM that store the Camera X/Y Min/Max 
CameraAddresses = {}

CameraAddresses[INDEX_CAMERA_MIN_X_POS] = 0xFFEEC8
CameraAddresses[INDEX_CAMERA_MAX_X_POS] = 0xFFEECA
CameraAddresses[INDEX_CAMERA_MIN_Y_POS] = 0xFFEECC
CameraAddresses[INDEX_CAMERA_MAX_Y_POS] = 0xFFEEC6
CameraAddresses[INDEX_CAMERA_MAX_Y_POS_NOW] = 0xFFEECE

-- A table of all Camera X/Y Min/Max values that will overide the Sonic 2 Games current value
CameraOveriddenValues = {}

CameraOveriddenValues[INDEX_CAMERA_MIN_X_POS] = CAMERA_MIN_X_POS_VALUE
CameraOveriddenValues[INDEX_CAMERA_MAX_X_POS] = CAMERA_MAX_X_POS_VALUE
CameraOveriddenValues[INDEX_CAMERA_MIN_Y_POS] = CAMERA_MIN_Y_POS_VALUE
CameraOveriddenValues[INDEX_CAMERA_MAX_Y_POS] = CAMERA_MAX_Y_POS_VALUE
CameraOveriddenValues[INDEX_CAMERA_MAX_Y_POS_NOW] = CAMERA_MAX_Y_POS_VALUE

-- A table of all the REAL current Camera X/Y Min/Max values. Stored and used for orienting where we are releative to this.
-- And for drawing a representation of that orientation. And for potentional RESTORING the X/Y MIN/MAX to these
-- values when the script ends if the user sets appropriate flag, RESTORE_CAMERA_ON_SCRIPT_END.
CameraRealValues = {}

-- Try To Get The CameraRealValues and set the Overridden values when the script starts
-- if the values read for the camera X/Y MIN/MAX are some odd value (0) becuase LEVELSIZELOAD
-- hasnt been called or we are not playing a level or whatever reason makes this code fail,
-- then it will just be the wrong value untill LEVELSIZELOAD is called and the call back 
-- function below this will be called 
gens.registerstart(function()
	for i,v in ipairs(CameraAddresses) do
		CameraRealValues[i] = memory.readword(CameraAddresses[i])
		memory.writeword(CameraAddresses[i],CameraOveriddenValues[i])
	end
	gui.redraw()
end)

-- register a callback function to be called if RESTORE_CAMERA_ON_SCRIPT_END is true, to set all Camera X/Y Min Max to the
-- value they would really be at this time. The value it would really be is kept track by variables.
if RESTORE_CAMERA_ON_SCRIPT_END then
gens.registerexit(function()
	for i,v in ipairs(CameraAddresses) do
		memory.writeword(CameraAddresses[i],CameraRealValues[i])
	end
	gui.redraw()
end)
end

-- at the end of  LEVELSIZELOAD all the Camera's X/Y MIN/MAX SHOULD BE Set
-- GATHER and store all these values in to the table CameraRealValuess
-- then override the all the RAM memory for Camera X/Y Min/Max to our overriddend values
memory.registerexec(EX_ENDOFLEVELSIZELOAD,1,function()
	for i,v in ipairs(CameraAddresses) do
		CameraRealValues[i] = memory.readword(CameraAddresses[i])
		memory.writeword(CameraAddresses[i],CameraOveriddenValues[i])
	end
	gui.redraw()
end)


-- If the program writes to the Cameras X/Y MIN/MAX store that value in CameraRealValues table 
-- and then overwrite that memory address with the overridden value
for i,v in ipairs(CameraAddresses) do

memory.registerwrite(CameraAddresses[i],1,function(address)

if memory.readword(address) ~= CameraOveriddenValues[i] then
	CameraRealValues[i] = memory.readword(address)
	memory.writeword(address,CameraOveriddenValues[i])
	end
	gui.redraw()
end)
end

gui.register(function()
	gui.text(300,10,"Camera Real Value","yellow","black")
	local TextY = 20
	for i,v in ipairs(CameraAddresses) do
		gui.text(300,TextY,string.format("%0x",CameraRealValues[i]),"yellow","black")
		TextY = TextY + 10
	end
	
	gui.text(300,80,"Camera Overide Value","cyan","black")
	local TextY = 90
	for i,v in ipairs(CameraAddresses) do
		gui.text(300,TextY,string.format("%0x",CameraOveriddenValues[i]),"cyan","black")
		TextY = TextY + 10
	end

end)