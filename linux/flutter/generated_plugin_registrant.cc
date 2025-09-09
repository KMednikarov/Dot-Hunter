//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <audioplayers_linux/audioplayers_linux_plugin.h>
#include <firebase_analytics/firebase_analytics_plugin_c_api.h>
#include <firebase_core/firebase_core_plugin_c_api.h>
#include <share_plus/share_plus_plugin.h>
#include <shared_preferences_linux/shared_preferences_linux_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) audioplayers_linux_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "AudioplayersLinuxPlugin");
  audioplayers_linux_plugin_register_with_registrar(audioplayers_linux_registrar);
  g_autoptr(FlPluginRegistrar) firebase_analytics_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "FirebaseAnalyticsPluginCApi");
  firebase_analytics_plugin_c_api_register_with_registrar(firebase_analytics_registrar);
  g_autoptr(FlPluginRegistrar) firebase_core_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "FirebaseCorePluginCApi");
  firebase_core_plugin_c_api_register_with_registrar(firebase_core_registrar);
  g_autoptr(FlPluginRegistrar) share_plus_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "SharePlusPlugin");
  share_plus_plugin_register_with_registrar(share_plus_registrar);
  g_autoptr(FlPluginRegistrar) shared_preferences_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "SharedPreferencesLinuxPlugin");
  shared_preferences_linux_plugin_register_with_registrar(shared_preferences_registrar);
}
