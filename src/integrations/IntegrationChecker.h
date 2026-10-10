#pragma once

#include <map>

namespace MyPlugin::integrations
{
    enum class IntegrationType
    {
        SKYUI
    };

    class IntegrationChecker
    {
    public:
        static void CheckAvailability();

        [[nodiscard]] static const std::map<IntegrationType, bool>& GetIntegrationAvailability();
    };
}
