#include "SKSE/API.h"
namespace
{
	void InitializeLog()
	{
#ifndef NDEBUG
		auto sink = std::make_shared<spdlog::sinks::msvc_sink_mt>();
#else
		auto path = logger::log_directory();
		if (!path) {
			util::report_and_fail("Failed to find standard logging directory"sv);
		}

		*path /= fmt::format("{}.log"sv, Plugin::NAME);
		auto sink = std::make_shared<spdlog::sinks::basic_file_sink_mt>(path->string(), true);
#endif

#ifndef NDEBUG
		const auto level = spdlog::level::trace;
#else
		const auto level = spdlog::level::info;
#endif

		auto log = std::make_shared<spdlog::logger>("global log"s, std::move(sink));
		log->set_level(level);
		log->flush_on(level);

		spdlog::set_default_logger(std::move(log));
		spdlog::set_pattern("%g(%#): [%^%l%$] %v"s);
	}
}



// -------------------------------------------------------------------------
// Plugin metadata (CommonLibSSE-NG / Address Library)
// -------------------------------------------------------------------------
SKSE_PLUGIN_VERSION = []() {
	SKSE::PluginVersionData v;
	v.PluginVersion(Plugin::VERSION);
	v.PluginName(Plugin::NAME);
	v.UsesAddressLibrary();
	v.UsesNoStructs();
	return v;
}();

// -------------------------------------------------------------------------
// Entry point
// -------------------------------------------------------------------------
SKSE_PLUGIN_LOAD(const SKSE::LoadInterface* a_skse)
{
	InitializeLog();
	logger::info("{} v{}"sv, Plugin::NAME, Plugin::VERSION.string());

	SKSE::Init(a_skse);

	// Register Papyrus natives
	const auto* papyrus = SKSE::GetPapyrusInterface();
	if (!papyrus) {
		logger::error("Could not obtain PapyrusInterface");
		return false;
	}
	papyrus->Register(Heartstrings::papyrus::RegisterMCM);

	// Subscribe to the data-loaded message to probe integrations.
	const auto* messaging = SKSE::GetMessagingInterface();
	if (!messaging) {
		logger::error("Could not obtain MessagingInterface");
		return false;
	}
	messaging->RegisterListener(OnSKSEMessage);

	return true;
}
