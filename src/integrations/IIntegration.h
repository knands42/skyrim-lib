#pragma once

class IIntegration {
public:
    virtual ~IIntegration() = default;
    virtual const char* Name() const = 0;
    virtual bool Available() const = 0;
    virtual void Init() = 0;
};