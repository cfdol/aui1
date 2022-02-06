local atrocityUI = select(2, ...)

function atrocityUI:SetMRT(resolution, forceImport)
    if (forceImport) then
        VMRT = atrocityUI.VMRT[resolution]
        AtrocityUIDB.InstalledVersions["MRT"] = GetAddonInstalledVersion("MRT")
    end
    
    -- ExRT strips spaces from the realm name for whatever reason
    -- so make sure we're doing that too
    local realmName = GetRealmName()
    local realmNameSpacesRemoved = realmName:gsub(" ", "")
    AtrocityUIDB.AddonData.MRT.ProfileKeys[UnitName("player") .. "-" .. realmNameSpacesRemoved] = "AtrocityUI"
    
    -- Store the profile keys locally since we're overwriting them on an install
    VMRT["ProfileKeys"] = AtrocityUIDB.AddonData.MRT.ProfileKeys
    
    UIErrorsFrame:SetScale(2);
    PlaySoundFile(InstallationSoundFile)
    UIErrorsFrame:AddMessage("Imported Method Raid Tools", 1.0, 1.0, 1.0, 53, 5);
end