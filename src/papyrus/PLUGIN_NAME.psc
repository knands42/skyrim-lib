scriptname MyPlugin extends SKI_ConfigBase hidden

bool function IsEnabled() global native

int oidEnabledToggle

event OnConfigInit()
    Pages = new string[1]
    Pages[0] = "General"
endEvent

event OnVersionUpdate(int a_version)
    ; Future: handle settings migration here.
endEvent

event OnPageReset(string page)
    if page == "General"
        SetCursorFillMode(TOP_TO_BOTTOM)
        AddHeaderOption("MyPlugin")
        ; Seed the toggle from the DLL's current state.
        oidEnabledToggle = AddToggleOption("Mod active", IsEnabled())
    endIf
endEvent

event OnOptionSelect(int option)
    if option == oidEnabledToggle
        ; Skeleton: just show a notification for now.
        ; Later this will call into the DLL to enable/disable the framework.
        Debug.Notification("MyPlugin: toggle pressed — not yet implemented")
        ; Re-read state from DLL so the checkbox stays in sync.
        SetToggleOptionValue(oidEnabledToggle, IsEnabled())
    endIf
endEvent

event OnOptionHighlight(int option)
    if option == oidEnabledToggle
        SetInfoText("Enables or disables the MyPlugin relationship framework.")
    endIf
endEvent
