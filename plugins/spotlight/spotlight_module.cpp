#include "spotlight_module.h"

#include "core/version.h"

#if VERSION_MAJOR == 4
#include "core/config/engine.h"
#else
#include "core/engine.h"
#endif

#include "spotlight.h"

static Spotlight *spotlight = NULL;

void godot_spotlight_init()
{
	spotlight = memnew(Spotlight);
	Engine::get_singleton()->add_singleton(Engine::Singleton("Spotlight", spotlight));

}

void godot_spotlight_deinit()
{
	if (spotlight) {
		memdelete(spotlight);
	}

}