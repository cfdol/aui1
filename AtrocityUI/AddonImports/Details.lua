local atrocityUI = select(2, ...)

function atrocityUI:SetDetails(resolution, forceImport)
    if (forceImport) then
        _detalhes:EraseProfile("AtrocityUI")
        _detalhes:ImportProfile(atrocityUI.DetailsProfileString[resolution], "AtrocityUI")
        AtrocityUIDB.InstalledVersions["Details"] = GetAddonInstalledVersion("Details")
    end
    
    _detalhes:ApplyProfile("AtrocityUI", false, false)

    DEFAULT_CHAT_FRAME.editBox:SetText("/details show") ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
    
    UIErrorsFrame:SetScale(2);
    PlaySoundFile(InstallationSoundFile)
    UIErrorsFrame:AddMessage("Imported Details", 1.0, 1.0, 1.0, 53, 5);
end