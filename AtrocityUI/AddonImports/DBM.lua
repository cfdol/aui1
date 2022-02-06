local atrocityUI = select(2, ...)

function atrocityUI:SetDBM(resolution, forceImport)
    if (forceImport) then
        DBM_AllSavedOptions = atrocityUI.DBM_AllSavedOptions[resolution]
        DBM_MinimapIcon = atrocityUI.DBM_MinimapIcon[resolution]
        DBT_AllPersistentOptions = atrocityUI.DBT_AllPersistentOptions[resolution]
        AtrocityUIDB.InstalledVersions["DBM"] = GetAddonInstalledVersion("DBM")
    end

    DBM:ApplyProfile("AtrocityUI")

    UIErrorsFrame:SetScale(2);
    PlaySoundFile(InstallationSoundFile)
    UIErrorsFrame:AddMessage("Imported DBM", 1.0, 1.0, 1.0, 53, 5);
end
