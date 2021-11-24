
#include "register_types.h"

#include "spotlight.h"
#inclue "spotlight_module.h"

void register_spotlight_types() {
	godot_spotlight_init();
}

void unregister_spotlight_types() {
	godot_spotlight_deinit();
}