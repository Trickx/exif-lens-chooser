property lensMap : {¬
	{DisplayName:"Sigma 70mm F2.8", Lens:"70mm F2.8 DG MACRO | Art 018", LensType:"Sigma 14-24mm f/2.8 DG HSM | A or other Sigma Lens", ImgAperture:"6.4", ImgFocalLength:"70", LensMake:"Sigma", LensMaxAperture:"2.8", LensMinAperture:"23.0", LensMinFocalLength:"70", LensMaxFocalLength:"70"}, ¬
	{DisplayName:"Helios 44-2 58mm f/2", Lens:"Helios 44-2 58mm f/2", LensType:"Helios 44-2 58mm f/2", ImgAperture:"2.0", ImgFocalLength:"58", LensMaxAperture:"2.0", LensMinAperture:"16.0", LensMinFocalLength:"70", LensMaxFocalLength:"70"} ¬
		}

on main(aliasList)
	set lensAttr to getLens()
	repeat with aAlias in aliasList
		set quotedFilePosix to quoted form of (POSIX path of aAlias)
		
		set shCmd to ¬
			"/usr/local/bin/exiftool -overwrite_original" & space & ¬
			"-FNumber=" & quoted form of (ImgAperture of lensAttr) & space & ¬
			"-ApertureValue=" & quoted form of (ImgAperture of lensAttr) & space & ¬
			"-FocalLength=" & quoted form of (ImgFocalLength of lensAttr) & space & ¬
			"-LensInfo=" & quoted form of (Lens of lensAttr) & space & ¬
			"-LensModel=" & quoted form of (Lens of lensAttr) & space & ¬
			"-MinFocalLength=" & quoted form of (LensMinFocalLength of lensAttr) & space & ¬
			"-MaxFocalLength=" & quoted form of (LensMaxFocalLength of lensAttr) & space & ¬
			"-LensType=" & quoted form of (LensType of lensAttr) & space & ¬
			"-MinAperture=" & quoted form of (LensMinAperture of lensAttr) & space & ¬
			"-MaxAperture=" & quoted form of (LensMaxAperture of lensAttr) & space & ¬
			quotedFilePosix
		
		--			"-DNGLensInfo=" & quoted form of (Lens of lensAttr) & space & ¬
		--			"-EffectiveMaxAperture=" & quoted form of (LensMaxAperture of lensAttr) & space & ¬
		--			"-LensMaxAperture=" & quoted form of (LensMaxAperture of lensAttr) & space & ¬
		--			"-Lens=" & quoted form of (Lens of lensAttr) & space & ¬
		--			"-LensMake=" & quoted form of (LensMake of lensAttr) & space & ¬
		--			"-MinAperture=" & quoted form of (LensMinAperture of lensAttr) & space & ¬
		--			"-MaxAperture=" & quoted form of (LensMaxAperture of lensAttr) & space & ¬
		--			"-MaxApertureAtMaxFocal=" & quoted form of (LensMaxAperture of lensAttr) & space & ¬
		--			"-MaxApertureAtMinFocal=" & quoted form of (LensMaxAperture of lensAttr) & space & ¬
		--			"-MaxImgAperture=" & quoted form of (LensMaxAperture of lensAttr) & space & ¬
		
		--		      "-LensID='0'" & space & ¬
		--			"-LensType='MF'" & space & ¬
		--			"-LensType='None'" & space & ¬
		
		
		try
			do shell script shCmd
			-- get shCmd
		on error e
			set alertMsg to ¬
				"Error: " & e & return & return & ¬
				"File: " & quotedFilePosix & return & return & ¬
				"Command: " & shCmd
			display alert "Ooops… iFail." message alertMsg as warning buttons {"Continue", "Cancel"} default button 1 cancel button 2
		end try
	end repeat
end main

on getLens()
	set cflList to {}
	repeat with aItem in my lensMap
		set cflList to cflList & DisplayName of aItem
	end repeat
	
	set cflPrompt to "Wähle ein Objektiv aus der Liste." & return
	
	set chosenLens to (choose from list cflList with prompt cflPrompt)
	if chosenLens is false then ¬
		display alert "Canceled by user" as warning buttons {"OK"} default button 1 cancel button 1
	
	repeat with aItem in my lensMap
		tell aItem
			if (its DisplayName as string) = (chosenLens as string) then return aItem
		end tell
	end repeat
end getLens

on run {input, parameters}
	-- set aliasList to (choose file with multiple selections allowed)
	-- main(aliasList)
	main(input)
end run

on open (droppedFiles)
	--droplet
	main(droppedFiles)
end open