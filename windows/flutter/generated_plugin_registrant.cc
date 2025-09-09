//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <audioplayers_windows/audioplayers_windows_plugin.h>
#include <firebase_analytics/firebase_analytics_plugin_c_api.h>
#include <firebase_core/firebase_core_plugin_c_api.h>
#include <share_plus/share_plus_plugin_c_api.h>
#include <shared_preferences_windows/shared_preferences_windows_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  AudioplayersWindowsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("AudioplayersWindowsPlugin"));
  FirebaseAnalyticsPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FirebaseAnalyticsPluginCApi"));
  FirebaseCorePluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FirebaseCorePluginCApi"));
  SharePlusPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("SharePlusPluginCApi"));
  SharedPreferencesWindowsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("SharedPreferencesWindowsPlugin"));
}
