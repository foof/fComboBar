local T, C, L = unpack(Tukui);
local movable = false;

TukuiTarget:DisableElement('CPoints'); -- more needed?


--- Options ---
local LAYOUT = 2; -- 1 = Vertical, Anything else = Horizontal
local WIDTH = 40;
local HEIGHT = 10;
local SPACING = 3;
local COLORS = {
	{0, 0.6, 0},
	{0.3, 0.6, 0},
	{0.6, 0.6, 0},
	{0.6, 0.3, 0},
	{0.6, 0, 0}
}
---------------


-- Anchorframe
TukuiComboAnchor = CreateFrame("Frame", "TukuiComboAnchor", UIParent);
TukuiComboAnchor:CreatePanel("Default", 150, 13, "CENTER", UIParent, "CENTER", 0, 100);
TukuiComboAnchor.text = T.SetFontString(TukuiComboAnchor, C.media.pixel_font, 12, "MONOCHROMEOUTLINE");
TukuiComboAnchor.text:SetText("COMBO POINTS");
TukuiComboAnchor.text:SetPoint("CENTER", 0, 1);
TukuiComboAnchor:SetMovable(true);
TukuiComboAnchor:SetUserPlaced(true);
TukuiComboAnchor:RegisterForDrag("LeftButton", "RightButton");
TukuiComboAnchor:SetScript("OnDragStart", function(self)
	self:StartMoving();
end);		
TukuiComboAnchor:SetScript("OnDragStop", function(self)
	self:StopMovingOrSizing();
end);
TukuiComboAnchor:Hide();

local function CreateComboButton()
	local button = CreateFrame("Frame", nil, UIParent);
	button:SetSize(WIDTH, HEIGHT);
	button:SetTemplate("Default");
	button:CreateOverlay();
	button:CreateShadow();
	button:SetAlpha(0);
	
	function button:FadeIn()
		UIFrameFadeIn(self, (0.1 * (1-self:GetAlpha())), self:GetAlpha(), 1)
	end

	function button:FadeOut()
		UIFrameFadeOut(self, (0.1 * (0+self:GetAlpha())), self:GetAlpha(), 0)
	end
	
	return button;
end

-- Creating comboframes
for i = 1, 5 do
	tinsert(TukuiComboAnchor, CreateComboButton());
end

-- Setting up layout (double iteration wont be noticable, easier to solve perfect horizontal anchoring this way)
for i = 1, 5 do
	if (LAYOUT == 1) then
		if (i == 1) then
			TukuiComboAnchor[i]:SetPoint("BOTTOM", TukuiComboAnchor, "TOP", 0, 3);
		else
			TukuiComboAnchor[i]:SetPoint("BOTTOM", TukuiComboAnchor[i-1], "TOP", 0, SPACING);
		end
	else
		TukuiComboAnchor[3]:SetPoint("TOP", TukuiComboAnchor, "BOTTOM", 0, -SPACING);
		TukuiComboAnchor[2]:SetPoint("RIGHT", TukuiComboAnchor[3], "LEFT", -SPACING, 0);
		TukuiComboAnchor[1]:SetPoint("RIGHT", TukuiComboAnchor[2], "LEFT", -SPACING, 0);
		TukuiComboAnchor[4]:SetPoint("LEFT", TukuiComboAnchor[3], "RIGHT", SPACING, 0);
		TukuiComboAnchor[5]:SetPoint("LEFT", TukuiComboAnchor[4], "RIGHT", SPACING, 0);
	end
end

local function GetCPs()
	if (movable) then
		return 5;
	end
	return GetComboPoints("player", "target");
end

local function UpdateCPs()
	local cp = GetCPs();
	for i = 1, 5 do
		if cp > 0 then
			TukuiComboAnchor[i]:SetBackdropBorderColor(unpack(COLORS[cp]));
			TukuiComboAnchor[i].overlay:SetVertexColor(unpack(COLORS[cp]));
		end
		if (i > cp) then
			TukuiComboAnchor[i]:FadeOut();
		else
			TukuiComboAnchor[i]:FadeIn();
		end
	end
end

-- Eventhandling
TukuiComboAnchor:RegisterEvent("PLAYER_ENTERING_WORLD");
TukuiComboAnchor:RegisterEvent("UNIT_COMBO_POINTS");
TukuiComboAnchor:RegisterEvent("PLAYER_TARGET_CHANGED");
TukuiComboAnchor:SetScript("OnEvent", UpdateCPs)

-- SlashCmd
SLASH_TUKUICOMBO1 = "/tcp";
SlashCmdList["TUKUICOMBO"] = function()
	movable = not movable;
	
	if (movable) then
		TukuiComboAnchor:Show();
		TukuiComboAnchor:EnableMouse(true);
	else
		TukuiComboAnchor:Hide();
		TukuiComboAnchor:EnableMouse(false);
	end
	UpdateCPs();
end