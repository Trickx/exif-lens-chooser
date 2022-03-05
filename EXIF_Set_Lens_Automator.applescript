-- This applescript file writes lens information into EXIF structures via exiftool.
-- Distribution (https://github.com/Trickx/exif-lens-chooser).
-- Copyright (C) 2022 Sven Kopetzki
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <https:--www.gnu.org/licenses/>.

-- NOTES
-- exiftool may list an incorrect LensType because it is limited to predefined list
-- e.g. for Canon: https://exiftool.org/TagNames/Canon.html#LensType
-- therefore Canon:LensType is set to 65535 = n/a

property lensMap : {Â
	{DisplayName:"MMZ Helios 44-2 58mm F/2.0", Lens:"Helios 44-2 58mm F2.0", ImgAperture:"2.0", ImgFocalLength:"58", LensMake:"MMZ BelOMO", LensMaxAperture:"2.0", LensMinAperture:"16.0", MaxApertureAtMinFocal:"2.0", MaxApertureAtMaxFocal:"2.0", LensMinFocalLength:"58", LensMaxFocalLength:"58", LensSerialNumber:"1007193"}, Â
	{DisplayName:"KMZ Jupiter-9 85mm  F/2.0", Lens:"Jupiter-9 85mm F2.0", ImgAperture:"2.0", ImgFocalLength:"85", LensMake:"KMZ Krasnogorsky Zavod", LensMaxAperture:"2.0", LensMinAperture:"16.0", MaxApertureAtMinFocal:"2.0", MaxApertureAtMaxFocal:"2.0", LensMinFocalLength:"85", LensMaxFocalLength:"85", LensSerialNumber:"0"} Â
		}

on main(aliasList)
	set lensAttr to getLens()
	repeat with aAlias in aliasList
		set quotedFilePosix to quoted form of (POSIX path of aAlias)
		
		set shCmd to Â
			"/usr/local/bin/exiftool -overwrite_original -n" & space & Â
			"-FNumber=" & quoted form of (ImgAperture of lensAttr) & space & Â
			"-ApertureValue=" & quoted form of (ImgAperture of lensAttr) & space & Â
			"-FocalLength=" & quoted form of (ImgFocalLength of lensAttr) & space & Â
			"-LensInfo=" & quoted form of (LensMinFocalLength of lensAttr & space & LensMaxFocalLength of lensAttr & space & Â
			MaxApertureAtMinFocal of lensAttr & space & MaxApertureAtMaxFocal of lensAttr) & space & Â
			"-LensModel=" & quoted form of (Lens of lensAttr) & space & Â
			"-LensMake=" & quoted form of (LensMake of lensAttr) & space & Â
			"-LensSerialNumber=" & quoted form of (LensSerialNumber of lensAttr) & space & Â
			"-MinFocalLength=" & quoted form of (LensMinFocalLength of lensAttr) & space & Â
			"-MaxFocalLength=" & quoted form of (LensMaxFocalLength of lensAttr) & space & Â
			"-MinAperture=" & quoted form of (LensMinAperture of lensAttr) & space & Â
			"-MaxAperture=" & quoted form of (LensMaxAperture of lensAttr) & space & Â
			"-Canon:LensType=65535" & space & Â
			quotedFilePosix
		
		try
			do shell script shCmd
			-- get shCmd -- Enable for debugging in Automator
		on error e
			set alertMsg to Â
				"Error: " & e & return & return & Â
				"File: " & quotedFilePosix & return & return & Â
				"Command: " & shCmd
			display alert "Error occured." message alertMsg as warning buttons {"Continue", "Cancel"} default button 1 cancel button 2
		end try
	end repeat
end main

on getLens()
	set cflList to {}
	repeat with aItem in my lensMap
		set cflList to cflList & DisplayName of aItem
	end repeat
	
	set cflPrompt to "WŠhle ein Objektiv aus der Liste." & return
	
	set chosenLens to (choose from list cflList with prompt cflPrompt)
	if chosenLens is false then Â
		display alert "Canceled by user" as warning buttons {"OK"} default button 1 cancel button 1
	
	repeat with aItem in my lensMap
		tell aItem
			if (its DisplayName as string) = (chosenLens as string) then return aItem
		end tell
	end repeat
end getLens

on run {input, parameters}
	if input is in {{}, {""}, ""} then
		set aliasList to (choose file with multiple selections allowed)
		main(aliasList)
	else
		main(input)
	end if
end run

