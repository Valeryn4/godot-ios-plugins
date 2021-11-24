#include "register_types.h"

#include "core/version.h"

#if VERSION_MAJOR == 4
#include "core/config/engine.h"
#else
#include "core/engine.h"
#endif

#include "spotlight.h"

static Spotlight *spotlight = NULL;

void register_spotlight_types() {
	spotlight = memnew(Spotlight);
	Engine::get_singleton()->add_singleton(Engine::Singleton("Spotlight", spotlight));
}

void unregister_spotlight_types() {
	if (spotlight) {
		memdelete(spotlight);
	}
}