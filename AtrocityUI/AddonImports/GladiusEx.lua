local atrocityUI = select(2, ...)

function atrocityUI:SetGladiusEx(resolution, forceImport)
    if (forceImport) then
        GladiusExDB = atrocityUI.GladiusExDB[resolution]
        AtrocityUIDB.InstalledVersions["GladiusEx"] = GetAddonInstalledVersion("GladiusEx")
    end

    LibStub("AceDB-3.0"):New(GladiusExDB):SetProfile("AtrocityUI")

    UIErrorsFrame:SetScale(2);
    PlaySoundFile(InstallationSoundFile)
    UIErrorsFrame:AddMessage("Imported GladiusEX", 1.0, 1.0, 1.0, 53, 5);
end
