local E = unpack(ElvUI); --Import: Engine
local AtrocityUI = E:NewModule('AtrocityUI', 'AceHook-3.0', 'AceEvent-3.0', 'AceTimer-3.0');
local addonName, atrocityUIData = ...

local EP = LibStub("LibElvUIPlugin-1.0")

local expresswayFontLocation = "Interface\\Addons\\AtrocityMedia\\Fonts\\Expressway.TTF"

InstallationSoundFile = "Interface\\AddOns\\AtrocityMedia\\Sounds\\Info.ogg"

-- Stores exported data for bigwigs 1080p/1440p settings
atrocityUIData.BigWigs3DB = {}

-- Stores exported data for DBM 1080p/1440p settings
atrocityUIData.DBM_AllSavedOptions = {}
atrocityUIData.DBM_MinimapIcon = {}
atrocityUIData.DBT_AllPersistentOptions = {}

-- Stores exported details profile string for 1080p/1440p settings
atrocityUIData.DetailsProfileString = {}

-- Stores exported data for ElvUI 1080p/1440p settings
atrocityUIData.ElvDBProfile = {}
atrocityUIData.ElvPrivateDB = {}

-- Stores exported data for MRT 1080p/1440p settings
atrocityUIData.VMRT = {}

-- Stores exported data for OmniCD 1080/1440p settings
atrocityUIData.OmniCDDB = {}

-- Stores exported data for Plater 1080/1440p settings
atrocityUIData.PlaterDB = {}

-- Stores exported data for WeakAuras 1080/1440p settings
atrocityUIData.WeakAurasSaved = {}

-- Stores exported data for GladiusEx 1080/1440p settings
atrocityUIData.GladiusExDB = {}

-- Returns the index into the configuration data array
-- based on the user's resolution.
function GetResolution()
	horizontal, vertical = GetPhysicalScreenSize()
	if vertical <= 1200 then
		return "1080p"
	else
		return "1440p"
	end
end

-- Returns the current version of the addon
function GetAddonVersion()
	return GetAddOnMetadata("AtrocityUI", "Version")
end

-- Returns the current version of the dependency addon
function GetAddonInstalledVersion(addonName)
	return GetAddOnMetadata("AtrocityUI", "X-" .. addonName)
end

function GetAddonSavedVersion(addonName)
	if AtrocityUIDB.InstalledVersions[addonName] == nil then
		return "not Imported"
	else 
		return AtrocityUIDB.InstalledVersions[addonName]
	end
end

-- Returns true if the module is installed
function IsModuleInstalled(addonName)
	return AtrocityUIDB.InstalledVersions[addonName] ~= nil
end

-- Returns true if the module is loaded and out of date
-- else False
function IsModuleOutOfDate(addonName)
	addonFileName = addonName
	if addonName == "DBM" then
		addonFileName = "DBM-Core"
	end
	return (AtrocityUIDB.InstalledVersions[addonName] == nil or AtrocityUIDB.InstalledVersions[addonName] < GetAddonInstalledVersion(addonName)) and IsAddOnLoaded(addonFileName)
end

-- Returns true if the addon version is larger than the
-- latest installed version.
function IsAddonOutOfDate(installedVersion)
	if installedVersion == nil then
		return true
	end
	return GetAddonVersion() > installedVersion
end

-- Function that pops up a confirmation box
local function ConfirmInstallation(text, fn, cancelFn)
	StaticPopupDialogs["ProfileOverrideConfirm"] = {
		button1 = "Apply",
		button2 = "No",
		OnAccept = fn,
		OnCancel = cancelFn,
		text = text,
		whileDead = true,
	}

	StaticPopup_Show("ProfileOverrideConfirm")
end

-- Function that pops up a confirmation box
local function ConfirmOverwriteInstall(text, fn, cancelFn)
	-- If installed, pop up a dialogue box
	if AtrocityUIDB ~= nil and AtrocityUIDB.InstalledChars[UnitName("player") .. "-" .. GetRealmName()] ~= nil then
		StaticPopupDialogs["ProfileOverrideConfirm"] = {
			button1 = "Yes",
			button2 = "No",
			OnAccept = fn,
			OnCancel = cancelFn,
			text = text,
			whileDead = true,
		}
	
		StaticPopup_Show("ProfileOverrideConfirm")
	else
		fn()
	end
end

-- Function that gets the class color of the current logged in user
function ClassColor(text)
	local _, englishClass, _ = UnitClass("player")
	local _, _, _, hex = GetClassColor(englishClass)
	return string.format("|cff%s%s|r", string.sub(hex, 3), text)
end

-- Change the default color of the UI elements (deep blue/purple)
function Color(text)
	return string.format("|cff7381ff%s|r", text)
end

function Green(text)
	return string.format("|cff00ff00%s|r", text)
end

-- Default RED (warning/error) color
function Red(text)
	return string.format("|cffff0000%s|r", text)
end

function AtrocityUI:FinishInstallation()
	if atrocityUIData.PlaterEnabled then
		Plater.db:SetProfile("AtrocityUI")
	end
	AtrocityUIDB.InstalledVersion = GetAddonVersion()
	AtrocityUIDB.InstalledResolution = GetResolution()
	E.global.ignoreIncompatible = false
	E.private["nameplates"]["enable"] = false
	AtrocityUIDB.InstalledChars[UnitName("player") .. "-" .. GetRealmName()] = GetAddonVersion()
	DEFAULT_CHAT_FRAME.editBox:SetText("/details show") ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
	ReloadUI()
end

function TextSetOrInstall(isInstall, text)
	if (isInstall) then
		return string.format("Import %s", text)
	else
		return string.format("Load %s", text)
	end
end

local addOns = {
	[1] = "ElvUI",
	[2] = "Details",
	[3] = "MRT",
	[4] = "OmniCD",
	[5] = "Plater",
	[6] = "WeakAuras",
	[7] = "GladiusEx",
}

local updatePage = function()
	PluginInstallFrame.SubTitle:SetFormattedText("Update Addons")
	PluginInstallFrame.Desc1:SetText("It looks like you have a new version of AtrocityUI. This installer will update your addons which are out of date. If you do not wish to update, you can skip this.")
	PluginInstallFrame.Option1:Show()
	PluginInstallFrame.Option1:SetScript("OnClick", AtrocityUI.FinishInstallation)
	PluginInstallFrame.Option1:SetText("Skip")
end

local pages = {
	["Intro"] = function(profileLoad, resolution)
		if (profileLoad) then
			PluginInstallFrame.SubTitle:SetFormattedText(string.format("%s Profile Loader", Color(addonName)))
			PluginInstallFrame.Desc1:SetText("This process will load the AUI profiles for your new character -- it will not reinstall anything.\nPlease be sure to hit Finish at the end to properly load everything.")
			PluginInstallFrame.Option1:Show()
			PluginInstallFrame.Option1:SetScript("OnClick", AtrocityUI.FinishInstallation)
			PluginInstallFrame.Option1:SetText("Skip")
		else
			PluginInstallFrame.SubTitle:SetFormattedText(string.format("Welcome to the %s %s Installation!", Color(addonName), Color(resolution)))
			PluginInstallFrame.Desc1:SetText(string.format("%s: this process will overwrite settings for all the addons that you choose to import in the following steps. Exit now if you'd like to keep the settings you've changed.\nSettings will only be changed for addons you choose to import, don't worry!", Red("WARNING")))
			PluginInstallFrame.Desc2:SetText(string.format("If you'd like to reinstall the UI at any point, please run %s\n\n%s", Red("/atrocityui install"), Color("Some changes may not be applied until you finish the installation process.")))
			PluginInstallFrame.Option1:Show()
			PluginInstallFrame.Option1:SetScript("OnClick", AtrocityUI.FinishInstallation)
			PluginInstallFrame.Option1:SetText("Skip")
		end
	end,
	["ElvUI"] = function(shouldImport, forceReImport, resolution)
		return function()
			PluginInstallFrame.SubTitle:SetFormattedText("ElvUI Profile")
			PluginInstallFrame.Desc1:SetText("Select the ElvUI Class profile you'd like to use.")
			if forceReImport then
				PluginInstallFrame.Desc2:SetText(Red(string.format("This will import ElvUI %s.", GetAddonInstalledVersion("ElvUI"))))
			elseif shouldImport then
				PluginInstallFrame.Desc2:SetText(string.format("Your version of ElvUI is %s but the latest is %s. The below button will update the ElvUI profiles and load them.", Red(GetAddonSavedVersion("ElvUI")), Green(GetAddonInstalledVersion("ElvUI"))))
			else
				PluginInstallFrame.Desc2:SetText(string.format("Your version of ElvUI is %s, which is the latest. The below button will just load the profile.", Green(GetAddonSavedVersion("ElvUI"))))
			end
			PluginInstallFrame.Option1:Show()
			PluginInstallFrame.Option1:SetScript("OnClick", function() atrocityUIData:SetElvUI(false, resolution, shouldImport) end)
			PluginInstallFrame.Option1:SetText("Normal")
			PluginInstallFrame.Option2:Show()
			PluginInstallFrame.Option2:SetScript("OnClick", function() atrocityUIData:SetElvUI(true, resolution, shouldImport) end)
			PluginInstallFrame.Option2:SetText(string.format(ClassColor("Class Color")))
		end
	end,
	-- ["DBM"] = function(shouldImport, forceReImport, resolution)
	-- 	return function()
	-- 		PluginInstallFrame.SubTitle:SetFormattedText("DBM Profile")
	-- 		PluginInstallFrame.Desc1:SetText("Click below to import the DBM profile.")
	-- 		if forceReImport then
	-- 			PluginInstallFrame.Desc2:SetText(Red(string.format("This will import DBM %s.", GetAddonInstalledVersion("DBM"))))
	-- 		elseif shouldImport then
	-- 			PluginInstallFrame.Desc2:SetText(string.format("Your version of DBM is %s but the latest is %s. The below button will update the DBM profile and load it.", Red(GetAddonSavedVersion("DBM")), Green(GetAddonInstalledVersion("DBM"))))
	-- 		else
	-- 			PluginInstallFrame.Desc2:SetText(string.format("Your version of DBM is %s, which is the latest. The below button will just load the profile.", Green(GetAddonSavedVersion("DBM"))))
	-- 		end
	-- 		PluginInstallFrame.Option1:Show()
	-- 		PluginInstallFrame.Option1:SetScript("OnClick", function() atrocityUIData:SetDBM(resolution, shouldImport) end)
	-- 		PluginInstallFrame.Option1:SetText(TextSetOrInstall((shouldImport or forceReImport), "DBM"))
	-- 	end
	-- end,
	["BigWigs"] = function(shouldImport, forceReImport, resolution)
		return function()
			PluginInstallFrame.SubTitle:SetFormattedText("BigWigs Profile")
			PluginInstallFrame.Desc1:SetText("Click below to import the BigWigs profile.")
			if forceReImport then
				PluginInstallFrame.Desc2:SetText(Red(string.format("This will import BigWigs %s.", GetAddonInstalledVersion("BigWigs"))))
			elseif shouldImport then
				PluginInstallFrame.Desc2:SetText(string.format("Your version of BigWigs is %s but the latest is %s. The below button will update the BigWigs profile and load it.", Red(GetAddonSavedVersion("BigWigs")), Green(GetAddonInstalledVersion("BigWigs"))))
			else
				PluginInstallFrame.Desc2:SetText(string.format("Your version of BigWigs is %s, which is the latest. The below button will just load the profile.", Green(GetAddonSavedVersion("BigWigs"))))
			end
			PluginInstallFrame.Option1:Show()
			PluginInstallFrame.Option1:SetScript("OnClick", function() atrocityUIData:SetBigWigs(resolution, shouldImport) end)
			PluginInstallFrame.Option1:SetText(TextSetOrInstall((shouldImport or forceReImport), "BigWigs"))
		end
	end,
	["Details"] = function(shouldImport, forceReImport, resolution)
		return function()
			PluginInstallFrame.SubTitle:SetFormattedText("Details Profile")
			PluginInstallFrame.Desc1:SetText("Click below to import the Details profile.")
			if forceReImport then
				PluginInstallFrame.Desc2:SetText(Red(string.format("This will import Details %s.", GetAddonInstalledVersion("Details"))))
			elseif shouldImport then
				PluginInstallFrame.Desc2:SetText(string.format("Your version of Details is %s but the latest is %s. The below button will update the Details profile and load it.", Red(GetAddonSavedVersion("Details")), Green(GetAddonInstalledVersion("Details"))))
			else
				PluginInstallFrame.Desc2:SetText(string.format("Your version of Details is %s, which is the latest. The below button will just load the profile.", Green(GetAddonSavedVersion("Details"))))
			end
			PluginInstallFrame.Option1:Show()
			PluginInstallFrame.Option1:SetScript("OnClick", function() atrocityUIData:SetDetails(resolution, shouldImport) end)
			PluginInstallFrame.Option1:SetText(TextSetOrInstall((shouldImport or forceReImport), "Details"))
		end
	end,
	["MRT"] = function(shouldImport, forceReImport, resolution)
		return function()
			PluginInstallFrame.SubTitle:SetFormattedText("MRT Profile")
			PluginInstallFrame.Desc1:SetText("Click below to import the MRT profile.")
			if forceReImport then
				PluginInstallFrame.Desc2:SetText(Red(string.format("This will import MRT %s.", GetAddonInstalledVersion("MRT"))))
			elseif shouldImport then
				PluginInstallFrame.Desc2:SetText(string.format("Your version of MRT is %s but the latest is %s. The below button will update the MRT profile and load it.", Red(GetAddonSavedVersion("MRT")), Green(GetAddonInstalledVersion("MRT"))))
			else
				PluginInstallFrame.Desc2:SetText(string.format("Your version of MRT is %s, which is the latest. The below button will just load the profile.", Green(GetAddonSavedVersion("MRT"))))
			end
			PluginInstallFrame.Option1:Show()
			PluginInstallFrame.Option1:SetScript("OnClick", function() atrocityUIData:SetMRT(resolution, shouldImport) end)
			PluginInstallFrame.Option1:SetText(TextSetOrInstall((shouldImport or forceReImport), "MRT"))
		end
	end,
	["OmniCD"] = function(shouldImport, forceReImport, resolution)
		return function()
			PluginInstallFrame.SubTitle:SetFormattedText("OmniCD Profile")
			PluginInstallFrame.Desc1:SetText("Click below to import the OmniCD profile.")
			if forceReImport then
				PluginInstallFrame.Desc2:SetText(Red(string.format("This will import OmniCD %s.", GetAddonInstalledVersion("OmniCD"))))
			elseif shouldImport then
				PluginInstallFrame.Desc2:SetText(string.format("Your version of OmniCD is %s but the latest is %s. The below button will update the OmniCD profile and load it.", Red(GetAddonSavedVersion("OmniCD")), Green(GetAddonInstalledVersion("OmniCD"))))
			else
				PluginInstallFrame.Desc2:SetText(string.format("Your version of OmniCD is %s, which is the latest. The below button will just load the profile.", Green(GetAddonSavedVersion("OmniCD"))))
			end
			PluginInstallFrame.Option1:Show()
			PluginInstallFrame.Option1:SetScript("OnClick", function() atrocityUIData:SetOmniCD(resolution, shouldImport) end)
			PluginInstallFrame.Option1:SetText(TextSetOrInstall((shouldImport or forceReImport), "OmniCD"))
		end
	end,
	["Plater"] = function(shouldImport, forceReImport, resolution)
		return function()
			PluginInstallFrame.SubTitle:SetFormattedText("Plater Profile")
			PluginInstallFrame.Desc1:SetText("Click below to import the Plater profile.")
			if forceReImport then
				PluginInstallFrame.Desc2:SetText(Red(string.format("This will import Plater %s.", GetAddonInstalledVersion("Plater"))))
			elseif shouldImport then
				PluginInstallFrame.Desc2:SetText(string.format("Your version of Plater is %s but the latest is %s. The below button will update the Plater profile and load it.", Red(GetAddonSavedVersion("Plater")), Green(GetAddonInstalledVersion("Plater"))))
			else
				PluginInstallFrame.Desc2:SetText(string.format("Your version of Plater is %s, which is the latest. The below button will just load the profile.", Green(GetAddonSavedVersion("Plater"))))
			end
			PluginInstallFrame.Option1:Show()
			PluginInstallFrame.Option1:SetScript("OnClick", function() atrocityUIData:SetPlater(resolution, shouldImport) end)
			PluginInstallFrame.Option1:SetText(TextSetOrInstall((shouldImport or forceReImport), "Plater"))
		end
	end,
	["WeakAuras"] = function(shouldImport, forceReImport, resolution)
		return function()
			PluginInstallFrame.SubTitle:SetFormattedText("WeakAuras")
			PluginInstallFrame.Desc1:SetText("Click below to import WeakAuras profile.")
			if forceReImport then
				PluginInstallFrame.Desc2:SetText(Red(string.format("This will import WeakAuras %s.", GetAddonInstalledVersion("WeakAuras"))))
				PluginInstallFrame.Option1:SetScript("OnClick", function() 
					ConfirmInstallation(string.format("%s This will remove all of your WeakAuras. If you would like to save any of your current auras, export them now and re-import them after installing.", Red("WARNING!")), function() atrocityUIData:SetWeakAuras(resolution, shouldImport) end, function() PluginInstallFrame.Next:Enable() end) 
					PluginInstallFrame.Next:Disable();
				end)
				PluginInstallFrame.Option1:SetText(TextSetOrInstall((shouldImport or forceReImport), "WeakAuras"))
				PluginInstallFrame.Option1:Show()
			elseif shouldImport then
				PluginInstallFrame.Desc2:SetText(string.format("Your version of WeakAuras is %s but the latest is %s. The below button will update WeakAuras.", Red(GetAddonSavedVersion("WeakAuras")), Green(GetAddonInstalledVersion("WeakAuras"))))
				PluginInstallFrame.Option1:SetScript("OnClick", function() 
					ConfirmInstallation(string.format("%s This will remove all of your WeakAuras. If you would like to save any of your current auras, export them now and re-import them after installing.", Red("WARNING!")), function() atrocityUIData:SetWeakAuras(resolution, shouldImport) end,  function() PluginInstallFrame.Next:Enable() end) 
					PluginInstallFrame.Next:Disable();
				end)
				PluginInstallFrame.Option1:SetText(TextSetOrInstall((shouldImport or forceReImport), "WeakAuras"))
				PluginInstallFrame.Option1:Show()
			else
				PluginInstallFrame.Desc2:SetText("WeakAuras have been skipped since you've already imported them. If you'd like to force import them, please run /aui install.")
			end
		end
	end,
	["GladiusEx"] = function(shouldImport, forceReImport, resolution)
		return function()
			PluginInstallFrame.SubTitle:SetFormattedText("GladiusEx Profile")
			PluginInstallFrame.Desc1:SetText("Click below to import the GladiusEx profile.")
			if forceReImport then
				PluginInstallFrame.Desc2:SetText(Red(string.format("This will import GladiusEx %s.", GetAddonInstalledVersion("GladiusEx"))))
			elseif shouldImport then
				PluginInstallFrame.Desc2:SetText(string.format("Your version of GladiusEx is %s but the latest is %s. The below button will update the GladiusEx profile and load it.", Red(GetAddonSavedVersion("GladiusEx")), Green(GetAddonInstalledVersion("GladiusEx"))))
			else
				PluginInstallFrame.Desc2:SetText(string.format("Your version of GladiusEx is %s, which is the latest. The below button will just load the profile.", Green(GetAddonSavedVersion("GladiusEx"))))
			end
			PluginInstallFrame.Option1:Show()
			PluginInstallFrame.Option1:SetScript("OnClick", function() atrocityUIData:SetGladiusEx(resolution, shouldImport) end)
			PluginInstallFrame.Option1:SetText(TextSetOrInstall((shouldImport or forceReImport), "GladiusEx"))
		end
	end,
	["Finish"] = function()
		PluginInstallFrame.SubTitle:SetFormattedText("Finish")
		PluginInstallFrame.Desc1:SetText("All done! Press Finish below to reload your UI and complete the installation.")
		PluginInstallFrame.Option1:SetScript("OnClick", AtrocityUI.FinishInstallation)
		PluginInstallFrame.Option1:SetText("Finish")
		PluginInstallFrame.Option1:Show()
	end,
}

local stepTitles = {
	["Intro"] = "Introduction",
	["ElvUI"] = "ElvUI Profile",
	-- ["DBM"] = "DBM Profile",
	["BigWigs"] = "BigWigs Profile",
	["Details"] = "Details Profile",
	["MRT"] = "MRT Profile",
	["OmniCD"] = "OmniCD Profile",
	["Plater"] = "Plater Profile",
	["WeakAuras"] = "Weakauras Profile",
	["GladiusEx"] = "GladiusEx Profile",
	["Finish"] = "Finish",
}

local function SetFont()
	local libSharedMedia = LibStub("LibSharedMedia-3.0")
	libSharedMedia:Register("font", "AtrocityUI Expressway", expresswayFontLocation)
	E.db["general"]["font"] = "AtrocityUI Expressway"
	E:UpdateMedia()
	E:UpdateFontTemplates()
end

-- ForceReinstall is run when they're reimport via /aui install
function AtrocityUI:ForceReinstall(resolution)
	local newPages = {}
	local newStepTitles = {}

	table.insert(newPages, function() pages["Intro"](false, resolution) end)
	table.insert(newStepTitles, stepTitles["Intro"])

	for _, addonName in ipairs(addOns) do
		table.insert(newPages, pages[addonName](true, true, resolution))
		table.insert(newStepTitles, stepTitles[addonName])
	end

	table.insert(newPages, pages["Finish"])
	table.insert(newStepTitles, stepTitles["Finish"])

	return {
		tutorialImage = "Interface\\Addons\\AtrocityMedia\\StatusBars\\logo.tga",
		Title = Color(addonName),
		Name = string.format("%s Installation", Color(addonName)),
		Pages = newPages,
		StepTitles = newStepTitles,
		StepTitlesColor = {1, 1, 1},
		StepTitlesColorSelected = {115/255, 129/255, 255/255},
		StepTitleWidth = 200,
		StepTitleButtonWidth = 200,
		StepTitleTextJustification = "CENTER",
	}
end

-- Sets profiles for addons they've already installed
function AtrocityUI:SetProfiles()
	local newPages = {}
	local newStepTitles = {}

	table.insert(newPages, function() pages["Intro"](true, nil) end)
	table.insert(newStepTitles, stepTitles["Intro"])

	for _, addonName in ipairs(addOns) do
		if IsModuleInstalled(addonName) then
			table.insert(newPages, pages[addonName](false, false, resolution))
			table.insert(newStepTitles, stepTitles[addonName])
		end
	end

	table.insert(newPages, pages["Finish"])
	table.insert(newStepTitles, stepTitles["Finish"])

	return {
		tutorialImage = "Interface\\Addons\\AtrocityMedia\\StatusBars\\logo.tga",
		Title = Color(addonName),
		Name = string.format("%s Installation", Color(addonName)),
		Pages = newPages,
		StepTitles = newStepTitles,
		StepTitlesColor = {1, 1, 1},
		StepTitlesColorSelected = {115/255, 129/255, 255/255},
		StepTitleWidth = 200,
		StepTitleButtonWidth = 200,
		StepTitleTextJustification = "CENTER",
	}
end

-- Install sets profiles if they're already installed, importing if they're not installed or out of date
function AtrocityUI:Install(resolution)
	local newPages = {}
	local newStepTitles = {}

	table.insert(newPages, function() pages["Intro"](false, resolution) end)
	table.insert(newStepTitles, stepTitles["Intro"])

	for _, addonName in ipairs(addOns) do
		if IsModuleOutOfDate(addonName) then
			-- Force re-import if they're not installed, or out of date
			table.insert(newPages, pages[addonName](true, false, resolution))
			table.insert(newStepTitles, stepTitles[addonName])
		else
			-- Set profile if they're up to date
			table.insert(newPages, pages[addonName](false, false, resolution))
			table.insert(newStepTitles, stepTitles[addonName])
		end
	end

	table.insert(newPages, pages["Finish"])
	table.insert(newStepTitles, stepTitles["Finish"])

	return {
		tutorialImage = "Interface\\Addons\\AtrocityMedia\\StatusBars\\logo.tga",
		Title = Color(addonName),
		Name = string.format("%s Installation", Color(addonName)),
		Pages = newPages,
		StepTitles = newStepTitles,
		StepTitlesColor = {1, 1, 1},
		StepTitlesColorSelected = {115/255, 129/255, 255/255},
		StepTitleWidth = 200,
		StepTitleButtonWidth = 200,
		StepTitleTextJustification = "CENTER",
	}
end

-- UpdateOutOfDateAddons is run when they update the addons, and only shows things that are out of date
function AtrocityUI:UpdateOutOfDateAddons(resolution)
	local newPages = {}
	local newStepTitles = {}

	table.insert(newPages, updatePage)
	table.insert(newStepTitles, stepTitles["Intro"])

	for _, addonName in ipairs(addOns) do
		-- Only update the things that are out of date, and import them
		if IsModuleOutOfDate(addonName) then
			table.insert(newPages, pages[addonName](true, false, resolution))
			table.insert(newStepTitles, stepTitles[addonName])
		end
	end

	table.insert(newPages, pages["Finish"])
	table.insert(newStepTitles, stepTitles["Finish"])

	return {
		tutorialImage = "Interface\\Addons\\AtrocityMedia\\StatusBars\\logo.tga",
		Title = Color(addonName),
		Name = string.format("%s Installation", Color(addonName)),
		Pages = newPages,
		StepTitles = newStepTitles,
		StepTitlesColor = {1, 1, 1},
		StepTitlesColorSelected = {115/255, 129/255, 255/255},
		StepTitleWidth = 200,
		StepTitleButtonWidth = 200,
		StepTitleTextJustification = "CENTER",
	}
end

function AtrocityUI:InsertOptions()
	E.Options.args.AtrocityUI = {
		order = 100,
		type = "group",
		name = Color("AtrocityUI"),
		width = "full",
		args = {
			header1 = {
				order = 1,
				type = "header",
				name = "AtrocityUI",
			},
			description1 = {
				order = 2,
				type = "description",
				name = "This is the settings page for AtrocityUI.",
			},
			spacer1 = {
				order = 3,
				type = "description",
				name = "\n\n\n",
			},
			SetProfiles = {
				order = 4,
				type = "execute",
				name = "Set Profiles",
				func = function()
					E:GetModule("PluginInstaller"):Queue(AtrocityUI:SetProfiles())
				end,
			},
			ForceReinstall1080 = {
				order = 5,
				type = "execute",
				name = "Force Reinstall (1080p)",
				func = function()
					ConfirmOverwriteInstall("It looks like you've already installed AtrocityUI. This installation will overwrite any local changes you have made. If you would like to load the profiles instead, type /aui load. Continue?", function() E:GetModule("PluginInstaller"):Queue(AtrocityUI:ForceReinstall("1080p")) end, nil)
				end,
			},
			ForceReinstall1440 = {
				order = 5,
				type = "execute",
				name = "Force Reinstall (1440p)",
				func = function()
					ConfirmOverwriteInstall("It looks like you've already installed AtrocityUI. This installation will overwrite any local changes you have made. If you would like to load the profiles instead, type /aui load. Continue?", function() E:GetModule("PluginInstaller"):Queue(AtrocityUI:ForceReinstall("1440p")) end, nil)
				end,
			},
		},
	}
end

function GetDualSpecConfigFromClass(className, useColor)
    local classOptionsNormal = {
        ["Shaman"] = {
            "AtrocityUI", -- [1]
            "AtrocityUI", -- [2]
            "AtrocityUI Healer", -- [3]
            ["enabled"] = true,
        },
        ["Paladin"] = {
            "AtrocityUI Healer", -- [1]
            "AtrocityUI", -- [2]
            "AtrocityUI", -- [3]
            ["enabled"] = true,
        },
        ["Priest"] = {
			"AtrocityUI Healer", -- [1]
            "AtrocityUI Healer", -- [2]
            "AtrocityUI", -- [3]
            ["enabled"] = true,
        },
        ["Monk"] = {
            "AtrocityUI", -- [1]
            "AtrocityUI Healer", -- [2]
            "AtrocityUI", -- [3]
            ["enabled"] = true,
        },
        ["Druid"] = {
            "AtrocityUI", -- [1]
            "AtrocityUI", -- [2]
            "AtrocityUI", -- [3]
            "AtrocityUI Healer", -- [4]
            ["enabled"] = true,
        },
    }

    local classOptionsColor = {
        ["Shaman"] = {
            "AtrocityUI [C]", -- [1]
            "AtrocityUI [C]", -- [2]
            "AtrocityUI Healer [C]", -- [3]
            ["enabled"] = true,
        },
        ["Paladin"] = {
            "AtrocityUI Healer [C]", -- [1]
            "AtrocityUI [C]", -- [2]
            "AtrocityUI [C]", -- [3]
            ["enabled"] = true,
        },
        ["Priest"] = {
			"AtrocityUI Healer [C]", -- [1]
            "AtrocityUI Healer [C]", -- [2]
            "AtrocityUI [C]", -- [3]
            ["enabled"] = true,
        },
        ["Monk"] = {
            "AtrocityUI [C]", -- [1]
            "AtrocityUI Healer [C]", -- [2]
            "AtrocityUI [C]", -- [3]
            ["enabled"] = true,
        },
        ["Druid"] = {
            "AtrocityUI [C]", -- [1]
            "AtrocityUI [C]", -- [2]
            "AtrocityUI [C]", -- [3]
            "AtrocityUI Healer [C]", -- [4]
            ["enabled"] = true,
        },
    }

	if classOptionsNormal[className] == nil then
		return {
			["enabled"] = false,
		}
	end

    if useColor then
        return classOptionsColor[className]
    else 
        return classOptionsNormal[className]
    end
end

-- This function is run when the Addon is loaded
-- We'll only want to run the installer if the person has NOT run it before
function AtrocityUI:Initialize()
	Details:SetTutorialCVar("STREAMER_PLUGIN_FIRSTRUN", true)
	Details.auto_open_news_window = false
	Details:SetTutorialCVar("version_announce", 1)
	Details.character_first_run = false
	Details.is_first_run = false

	if IsAddOnLoaded("BigWigs") then
		addOns[#addOns+1] = "BigWigs"
	end

	-- Force their DB to nil if the installed version isn't set
	-- This is a hack for before versioning
	if AtrocityUIDB ~= nil and AtrocityUIDB.InstalledVersion == nil then
		PreviouslyInstalled = true
		AtrocityUIDB = nil
	end

	if AtrocityUIDB == nil then
		SetFont()
		
		SetCVar("ScriptErrors", "0");

		AtrocityUIDB = {}
		AtrocityUIDB.InstalledVersion = nil
		AtrocityUIDB.InstalledVersions = {}
		AtrocityUIDB.InstalledChars = {}

		AtrocityUIDB.AddonData = {}
		AtrocityUIDB.AddonData.ElvUI = {}
		AtrocityUIDB.AddonData.ElvUI.ProfileKeys = {}
		AtrocityUIDB.AddonData.MRT = {}
		AtrocityUIDB.AddonData.MRT.ProfileKeys = {}

		if IsAddOnLoaded("Details") then
			Details:Disable()
			Details:DisablePlugin("DETAILS_PLUGIN_STREAM_OVERLAY")
		end
	
		-- Hide GladiusEx on run
		if IsAddOnLoaded("GladiusEx") then
			GladiusEx:Disable()
		end
	end

	if AtrocityUIDB.InstalledChars[UnitName("player") .. "-" .. GetRealmName()] == nil then
		SetFont()
	end

	-- Skip ElvUI installation process
	E.private.install_complete = E.version

	-- Ignore ElvUI warnings
	E.global.ignoreIncompatible = true

	if IsAddOnLoaded("OmniCD") then
		OmniCDDB.global.disableElvMsg = true
	end

	-- If they haven't run the installer before, or switched resolutions, do a force install
	if AtrocityUIDB.InstalledVersion == nil then
		DEFAULT_CHAT_FRAME.editBox:SetText("/details hide") ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
		E:GetModule("PluginInstaller"):Queue(AtrocityUI:Install(GetResolution()))
	elseif AtrocityUIDB.InstalledResolution ~= GetResolution() then
		DEFAULT_CHAT_FRAME.editBox:SetText("/details hide") ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
		E:GetModule("PluginInstaller"):Queue(AtrocityUI:ForceReinstall(GetResolution()))
	-- Else if they log in and their addon is out of date, run the normal Installer (skips whatever is not updated)
	elseif IsAddonOutOfDate(AtrocityUIDB.InstalledVersion) then
		DEFAULT_CHAT_FRAME.editBox:SetText("/details hide") ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
		shouldRunInstaller = false
		for _, addon in pairs(addOns) do
			if IsModuleOutOfDate(addon) then
				shouldRunInstaller = true
				break
			end
		end
		if (shouldRunInstaller) then
			E:GetModule("PluginInstaller"):Queue(AtrocityUI:UpdateOutOfDateAddons(GetResolution()))
		else
			-- Silently update to the latest version
			AtrocityUIDB.InstalledVersion = GetAddonVersion()
			AtrocityUIDB.InstalledResolution = GetResolution()
		end
	-- Else if that character has not installed the addon before, run it
	elseif AtrocityUIDB.InstalledChars[UnitName("player") .. "-" .. GetRealmName()] == nil then
		DEFAULT_CHAT_FRAME.editBox:SetText("/details hide") ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
		E:GetModule("PluginInstaller"):Queue(AtrocityUI:SetProfiles())
	end

	EP:RegisterPlugin("AtrocityUI", AtrocityUI.InsertOptions)
end

-- The command that the person runs to force the installer to run
SLASH_ATROCITYUI1 = "/atrocityui"
SLASH_ATROCITYUI2 = "/aui"

-- Ran when the person types /atrocityui
function RunAtrocityUI(msg, _)
	local tokens = SplitStr(msg)
	if tokens[1] == "install" then
		if (tokens[2] ~= nil and tokens[2] == "1080p") then
			ConfirmOverwriteInstall("It looks like you've already installed AtrocityUI. This installation will overwrite any local changes you have made. If you would like to load the profiles instead, type /aui load. Continue?", function() E:GetModule("PluginInstaller"):Queue(AtrocityUI:ForceReinstall("1080p")) end, nil)
		elseif (tokens[2] ~= nil and tokens[2] == "1440p") then
			ConfirmOverwriteInstall("It looks like you've already installed AtrocityUI. This installation will overwrite any local changes you have made. If you would like to load the profiles instead, type /aui load. Continue?", function() E:GetModule("PluginInstaller"):Queue(AtrocityUI:ForceReinstall("1440p")) end, nil)
		else
			ConfirmOverwriteInstall("It looks like you've already installed AtrocityUI. This installation will overwrite any local changes you have made. If you would like to load the profiles instead, type /aui load. Continue?", function() E:GetModule("PluginInstaller"):Queue(AtrocityUI:ForceReinstall(GetResolution())) end, nil)
		end
	elseif tokens[1] == "load" then
		E:GetModule("PluginInstaller"):Queue(AtrocityUI:SetProfiles())
	else
		print("|cffffffffWelcome to AtrocityUI")
		print("To completely re-install the UI, please run /aui install")
		print("If you'd like to install a specific resolution, please run /aui install 1080p OR /aui install 1440p")
		print("If you have already installed and would just like to load profiles on your new character, run /aui load|r")
	end	
end

function SplitStr(s)
	local chunks = {}
	for substring in s:gmatch("%S+") do
	   table.insert(chunks, substring)
	end
	return chunks
end

SlashCmdList["ATROCITYUI"] = RunAtrocityUI

E:RegisterModule(AtrocityUI:GetName())