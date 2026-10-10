#include "SkyUI.h"
#include "PCH.h"

namespace MyPlugin::integrations
{
    bool SkyUI::Available() const
    {
        const auto* form = RE::TESForm::LookupByEditorID("SKI_ConfigManagerInstance");
        return form != nullptr;
    }
}
