local atrocityUI = select(2, ...)

function atrocityUI:SetOmniCD(resolution, forceImport)
    if (forceImport) then
        OmniCDDB = atrocityUI.OmniCDDB[resolution]
        AtrocityUIDB.InstalledVersions["OmniCD"] = GetAddonInstalledVersion("OmniCD")
    end

    LibStub("AceDB-3.0"):New(OmniCDDB):SetProfile("AtrocityUI")

    -- Set dual spec profiles
    local className, _ = UnitClass("player");
    OmniCDDB["namespaces"]["LibDualSpec-1.0"]["char"][UnitName("player") .. " - " .. GetRealmName()] = GetDualSpecConfigFromClass(className, false)

    UIErrorsFrame:SetScale(2);
    PlaySoundFile(InstallationSoundFile)
    UIErrorsFrame:AddMessage("Imported OmniCD", 1.0, 1.0, 1.0, 53, 5);
end
