#include "IntegrationChecker.h"
#include "skyui/SkyUI.h"

namespace MyPlugin::integrations
{
    namespace
    {
        std::map<IntegrationType, bool> g_integrationAvailability;
    }

    void IntegrationChecker::CheckAvailability()
    {
        const SkyUI skyUIIntegration;
        g_integrationAvailability[IntegrationType::SKYUI] = skyUIIntegration.Available();
    }

    const std::map<IntegrationType, bool>& IntegrationChecker::GetIntegrationAvailability()
    {
        return g_integrationAvailability;
    }
}