local atrocityUI = select(2, ...)

function atrocityUI:SetWeakAuras(resolution, forceImport)
    if (forceImport) then
        WeakAurasSaved = atrocityUI.WeakAurasSaved[resolution]
        AtrocityUIDB.InstalledVersions["WeakAuras"] = GetAddonInstalledVersion("WeakAuras")
    end

    UIErrorsFrame:SetScale(2);
    PlaySoundFile(InstallationSoundFile)
    UIErrorsFrame:AddMessage("Imported WeakAuras", 1.0, 1.0, 1.0, 53, 5);
    PluginInstallFrame.Next:Enable();
end
