#pragma once

#include "../IIntegration.h"

namespace MyPlugin::integrations
{
    class SkyUI final : public IIntegration
    {
    public:
        [[nodiscard]] const char* Name() const noexcept override { return "SkyUI"; }

        [[nodiscard]] bool Available() const override;

        void Init() override {}
    };
}
