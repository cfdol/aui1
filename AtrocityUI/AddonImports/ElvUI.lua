local atrocityUI = select(2, ...)
local E, L, V, P, G = unpack(ElvUI)

function atrocityUI:SetElvUI(useColor, resolution, forceImport)
    if (forceImport) then
        ElvDB["profiles"]["AtrocityUI"] = atrocityUI.ElvDBProfile[resolution]["profiles"]["AtrocityUI"]
        ElvDB["profiles"]["AtrocityUI [C]"] = atrocityUI.ElvDBProfile[resolution]["profiles"]["AtrocityUI [C]"]
        ElvDB["profiles"]["AtrocityUI Healer"] = atrocityUI.ElvDBProfile[resolution]["profiles"]["AtrocityUI Healer"]
        ElvDB["profiles"]["AtrocityUI Healer [C]"] = atrocityUI.ElvDBProfile[resolution]["profiles"]["AtrocityUI Healer [C]"]

        -- This is required for minimap data text
        E.global.datatexts.customPanels = atrocityUI.ElvDBProfile[resolution].global.datatexts.customPanels
        -- This imports all aura indicators
        E.global.unitframe.aurawatch = atrocityUI.ElvDBProfile[resolution].global.unitframe.aurawatch
        -- This imports the blacklist and turtlebuff fiters
        E.global.unitframe.aurafilters = atrocityUI.ElvDBProfile[resolution].global.unitframe.aurafilters

        ElvPrivateDB["profiles"]["AtrocityUI"] = atrocityUI.ElvPrivateDB[resolution]["profiles"]["AtrocityUI"]
        ElvPrivateDB["profiles"]["AtrocityUI [C]"] = atrocityUI.ElvPrivateDB[resolution]["profiles"]["AtrocityUI"]
        ElvPrivateDB["profiles"]["AtrocityUI Healer"] = atrocityUI.ElvPrivateDB[resolution]["profiles"]["AtrocityUI"]
        ElvPrivateDB["profiles"]["AtrocityUI Healer [C]"] = atrocityUI.ElvPrivateDB[resolution]["profiles"]["AtrocityUI"]

        if resolution == "1080p" then
            ElvDB.global.general.UIScale = 0.7111111111111111
        else
            ElvDB.global.general.UIScale = 0.5333333
        end

        AtrocityUIDB.InstalledVersions["ElvUI"] = GetAddonInstalledVersion("ElvUI")

        -- Set addonskins here
        AddOnSkinsDB = atrocityUI.AddonSkins
    end

    ElvPrivateDB["profileKeys"] = AtrocityUIDB.AddonData.ElvUI.ProfileKeys

    if useColor then
        AtrocityUIDB.AddonData.ElvUI.ProfileKeys[UnitName("player") .. " - " .. GetRealmName()] = "AtrocityUI [C]"
        E.data:SetProfile("AtrocityUI [C]")
    else
        AtrocityUIDB.AddonData.ElvUI.ProfileKeys[UnitName("player") .. " - " .. GetRealmName()] = "AtrocityUI"
        E.data:SetProfile("AtrocityUI")
    end

    E.private["nameplates"]["enable"] = false

    -- Set dual spec profiles
    local className, _ = UnitClass("player");
    ElvDB["namespaces"]["LibDualSpec-1.0"]["char"][UnitName("player") .. " - " .. GetRealmName()] = GetDualSpecConfigFromClass(className, useColor)

    UIErrorsFrame:SetScale(2);
    PlaySoundFile(InstallationSoundFile)
    UIErrorsFrame:AddMessage("Imported ElvUI", 1.0, 1.0, 1.0, 53, 5);
end
