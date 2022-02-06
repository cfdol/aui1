local atrocityUI = select(2, ...)
local E = unpack(ElvUI);

function atrocityUI:SetPlater(resolution, forceImport)
    if (forceImport) then
        PlaterDB = atrocityUI.PlaterDB[resolution]
        AtrocityUIDB.InstalledVersions["Plater"] = GetAddonInstalledVersion("Plater")
    end

    -- PlaterDB["profiles"]["AtrocityUI"] = atrocityUI.PlaterDB["profiles"]["AtrocityUI"]
    PlaterDB["profileKeys"][UnitName("player") .. " - ".. GetRealmName()] = "AtrocityUI"

    -- Don't do this here, do this in the main function right before the user finishes install
    -- Plater.db:SetProfile("AtrocityUI")
    atrocityUI.PlaterEnabled = true

    UIErrorsFrame:SetScale(2);
    PlaySoundFile(InstallationSoundFile)
    UIErrorsFrame:AddMessage("Imported Plater", 1.0, 1.0, 1.0, 53, 5);
end
