#include "PCH.h"
#include "papyrus/MCM.h"
#include "core/Manager.h"

namespace MyPlugin::papyrus
{
    static constexpr auto SCRIPT_NAME = "MyPlugin"sv;

    static bool IsEnabled(RE::StaticFunctionTag*)
    {
        return true;
    }

    // ---------------------------------------------------------------------------
    bool RegisterMCM(RE::BSScript::IVirtualMachine* a_vm)
    {
        if (!a_vm) {
            logger::error("PapyrusInterface gave us a null VM — skipping MCM registration");
            return false;
        }

        a_vm->RegisterFunction("IsEnabled", SCRIPT_NAME, IsEnabled);

        logger::info("Registered Papyrus natives for {}", SCRIPT_NAME);
        return true;
    }
}
