// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(error) => "Could not add: ${error}";

  static String m1(interval) => "Auto-update every ${interval}";

  static String m2(interval) => "Updates in background every ${interval}";

  static String m3(count) => "Copied ${count} lines";

  static String m4(count) =>
      "${Intl.plural(count, one: '1 day ago', other: '${count} days ago')}";

  static String m5(count) => "${count} days";

  static String m6(days) => "${days} days left";

  static String m7(error) => "Could not delete: ${error}";

  static String m8(label) =>
      "Are you sure you want to delete the selected ${label}?";

  static String m9(label) =>
      "Are you sure you want to delete the current ${label}?";

  static String m10(label) => "${label} details";

  static String m11(label) => "${label} cannot be empty";

  static String m12(count) => "${count} entries";

  static String m13(label) => "Current ${label} already exists";

  static String m14(name) => "${name} skipped";

  static String m15(name) => "${name} updated";

  static String m16(name) => "Updating ${name}...";

  static String m17(count) =>
      "${Intl.plural(count, one: '1 hour ago', other: '${count} hours ago')}";

  static String m18(count) => "${count} hours";

  static String m19(target) => "${target} is an invalid policy";

  static String m20(proxyName) => "${proxyName} is an invalid proxy";

  static String m21(providerName) =>
      "${providerName} is an invalid proxy provider";

  static String m22(subRule) => "${subRule} is an invalid SUB_RULE";

  static String m23(count) => "Added ${count} keys";

  static String m24(count) => "Keys: ${count}";

  static String m25(label) => "Keys — ${label}";

  static String m26(left, total) => "${left} of ${total}";

  static String m27(appName) =>
      "1. Open System Settings > Privacy & Security\n2. Choose Location Services\n3. Find and check ${appName} in the right list\n\nAfter completing the setup, return to the app and use it normally. Thank you for your cooperation.";

  static String m28(count) =>
      "${Intl.plural(count, one: '1 minute ago', other: '${count} minutes ago')}";

  static String m29(count) => "${count} minutes";

  static String m30(count) =>
      "${Intl.plural(count, one: '1 month ago', other: '${count} months ago')}";

  static String m31(label) => "No ${label} yet";

  static String m32(label) => "${label} must be a number";

  static String m33(label) => "${label} must be between 1024 and 49151";

  static String m34(error) => "Could not save: ${error}";

  static String m35(count) => "${count} seconds";

  static String m36(count) => "${count} items have been selected";

  static String m37(error) => "Could not update: ${error}";

  static String m38(label) => "${label} must be a url";

  static String m39(size) => "Used ${size}";

  static String m40(used, total) => "Used ${used} of ${total}";

  static String m41(count) =>
      "${Intl.plural(count, one: '1 year ago', other: '${count} years ago')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about": MessageLookupByLibrary.simpleMessage("About"),
    "aboutDesc": MessageLookupByLibrary.simpleMessage(
      "Version, GitHub, and updates",
    ),
    "accessControl": MessageLookupByLibrary.simpleMessage("AccessControl"),
    "accessControlAllow": MessageLookupByLibrary.simpleMessage(
      "Allow selected",
    ),
    "accessControlAllowDesc": MessageLookupByLibrary.simpleMessage(
      "Only allow selected app to enter VPN",
    ),
    "accessControlDesc": MessageLookupByLibrary.simpleMessage(
      "Configure application access proxy",
    ),
    "accessControlEmpty": MessageLookupByLibrary.simpleMessage("Nothing found"),
    "accessControlNotAllow": MessageLookupByLibrary.simpleMessage(
      "Exclude selected",
    ),
    "accessControlNotAllowDesc": MessageLookupByLibrary.simpleMessage(
      "The selected application will be excluded from VPN",
    ),
    "accessControlReconnectHint": MessageLookupByLibrary.simpleMessage(
      "Changes will be applied after reconnecting",
    ),
    "accessControlSearchHint": MessageLookupByLibrary.simpleMessage(
      "Search apps...",
    ),
    "accessControlSettings": MessageLookupByLibrary.simpleMessage(
      "Access Control Settings",
    ),
    "accessControlShowNonInternet": MessageLookupByLibrary.simpleMessage(
      "Show apps without internet",
    ),
    "accessControlShowSystemApps": MessageLookupByLibrary.simpleMessage(
      "Show system apps",
    ),
    "accessControlSortDefault": MessageLookupByLibrary.simpleMessage("Default"),
    "accessControlSortName": MessageLookupByLibrary.simpleMessage("Name"),
    "accessControlSortTime": MessageLookupByLibrary.simpleMessage("Time"),
    "account": MessageLookupByLibrary.simpleMessage("Account"),
    "action": MessageLookupByLibrary.simpleMessage("Action"),
    "action_mode": MessageLookupByLibrary.simpleMessage("Switch mode"),
    "action_proxy": MessageLookupByLibrary.simpleMessage("System proxy"),
    "action_start": MessageLookupByLibrary.simpleMessage("Start/Stop"),
    "action_tun": MessageLookupByLibrary.simpleMessage("TUN"),
    "action_view": MessageLookupByLibrary.simpleMessage("Show/Hide"),
    "activateSubscriptionFirst": MessageLookupByLibrary.simpleMessage(
      "Activate a subscription first",
    ),
    "add": MessageLookupByLibrary.simpleMessage("Add"),
    "addFailed": m0,
    "addKey": MessageLookupByLibrary.simpleMessage("Add key"),
    "addProfile": MessageLookupByLibrary.simpleMessage("Add Profile"),
    "addProxies": MessageLookupByLibrary.simpleMessage("Add proxies"),
    "addProxyGroup": MessageLookupByLibrary.simpleMessage("Add proxy group"),
    "addProxyProviders": MessageLookupByLibrary.simpleMessage(
      "Add proxy providers",
    ),
    "addRule": MessageLookupByLibrary.simpleMessage("Add rule"),
    "addSsid": MessageLookupByLibrary.simpleMessage("Add SSID"),
    "addSubscription": MessageLookupByLibrary.simpleMessage("Add subscription"),
    "addToFavorites": MessageLookupByLibrary.simpleMessage("Add to favorites"),
    "addedRules": MessageLookupByLibrary.simpleMessage("Added rules"),
    "additionalParameters": MessageLookupByLibrary.simpleMessage(
      "Additional parameters",
    ),
    "address": MessageLookupByLibrary.simpleMessage("Address"),
    "addressHelp": MessageLookupByLibrary.simpleMessage(
      "WebDAV server address",
    ),
    "addressTip": MessageLookupByLibrary.simpleMessage(
      "Please enter a valid WebDAV address",
    ),
    "advancedConfig": MessageLookupByLibrary.simpleMessage(
      "Advanced configuration",
    ),
    "advancedConfigDesc": MessageLookupByLibrary.simpleMessage(
      "Provide diverse configuration options",
    ),
    "agree": MessageLookupByLibrary.simpleMessage("Agree"),
    "allowBypass": MessageLookupByLibrary.simpleMessage(
      "Allow applications to bypass VPN",
    ),
    "allowBypassDesc": MessageLookupByLibrary.simpleMessage(
      "Some apps can bypass VPN when turned on",
    ),
    "allowLan": MessageLookupByLibrary.simpleMessage("AllowLan"),
    "allowLanDesc": MessageLookupByLibrary.simpleMessage(
      "Allow access proxy through the LAN",
    ),
    "allowLanHelp": MessageLookupByLibrary.simpleMessage(
      "Allow other devices on the local network to connect to the core.",
    ),
    "app": MessageLookupByLibrary.simpleMessage("App"),
    "appAccessControl": MessageLookupByLibrary.simpleMessage(
      "App access control",
    ),
    "appendSystemDns": MessageLookupByLibrary.simpleMessage(
      "Append System DNS",
    ),
    "appendSystemDnsDesc": MessageLookupByLibrary.simpleMessage(
      "Add system:// into nameserver",
    ),
    "appendSystemDnsHelp": MessageLookupByLibrary.simpleMessage(
      "Blends Windows system resolvers into the core\'s DNS servers.",
    ),
    "appendSystemDnsTip": MessageLookupByLibrary.simpleMessage(
      "Forcefully append system DNS to the configuration",
    ),
    "application": MessageLookupByLibrary.simpleMessage("Application"),
    "applicationDesc": MessageLookupByLibrary.simpleMessage(
      "Modify application related settings",
    ),
    "author": MessageLookupByLibrary.simpleMessage("Author"),
    "authorized": MessageLookupByLibrary.simpleMessage("Authorized"),
    "auto": MessageLookupByLibrary.simpleMessage("Auto"),
    "autoCheckUpdate": MessageLookupByLibrary.simpleMessage(
      "Auto check updates",
    ),
    "autoCheckUpdateDesc": MessageLookupByLibrary.simpleMessage(
      "Auto check for updates when the app starts",
    ),
    "autoCloseConnections": MessageLookupByLibrary.simpleMessage(
      "Auto close connections",
    ),
    "autoCloseConnectionsDesc": MessageLookupByLibrary.simpleMessage(
      "Auto close connections after change node",
    ),
    "autoLaunch": MessageLookupByLibrary.simpleMessage("Auto launch"),
    "autoLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "Follow the system self startup",
    ),
    "autoLaunchHelp": MessageLookupByLibrary.simpleMessage(
      "Adds the app to Windows auto-start.",
    ),
    "autoRun": MessageLookupByLibrary.simpleMessage("AutoRun"),
    "autoRunDesc": MessageLookupByLibrary.simpleMessage(
      "Auto run when the application is opened",
    ),
    "autoRunFork": MessageLookupByLibrary.simpleMessage(
      "Auto connect on startup",
    ),
    "autoRunForkDesc": MessageLookupByLibrary.simpleMessage(
      "Bring the connection up right when the app starts",
    ),
    "autoSetSystemDns": MessageLookupByLibrary.simpleMessage(
      "Auto set system DNS",
    ),
    "autoUpdate": MessageLookupByLibrary.simpleMessage("Auto update"),
    "autoUpdateEvery": m1,
    "autoUpdateInterval": MessageLookupByLibrary.simpleMessage(
      "Auto update interval (minutes)",
    ),
    "autoscrollOff": MessageLookupByLibrary.simpleMessage("Autoscroll: off"),
    "autoscrollOn": MessageLookupByLibrary.simpleMessage("Autoscroll: on"),
    "backgroundUpdate": m2,
    "backup": MessageLookupByLibrary.simpleMessage("Backup"),
    "backupAndRestore": MessageLookupByLibrary.simpleMessage(
      "Backup and Restore",
    ),
    "backupAndRestoreDesc": MessageLookupByLibrary.simpleMessage(
      "Sync data via WebDAV or files",
    ),
    "backupSuccess": MessageLookupByLibrary.simpleMessage("Backup success"),
    "basicConfig": MessageLookupByLibrary.simpleMessage("Basic configuration"),
    "basicConfigDesc": MessageLookupByLibrary.simpleMessage(
      "Modify the basic configuration globally",
    ),
    "basicInfo": MessageLookupByLibrary.simpleMessage("Basic info"),
    "basicStrategy": MessageLookupByLibrary.simpleMessage("Basic strategy"),
    "batteryOptimizationDesc": MessageLookupByLibrary.simpleMessage(
      "To ensure background operation, please disable battery optimization for this app. Tap to go to settings.",
    ),
    "batteryOptimizationStatusTip": MessageLookupByLibrary.simpleMessage(
      "Affected by the system, this status may not always be accurate.",
    ),
    "bind": MessageLookupByLibrary.simpleMessage("Bind"),
    "blacklistMode": MessageLookupByLibrary.simpleMessage("Blacklist mode"),
    "bypassDomain": MessageLookupByLibrary.simpleMessage("Bypass domain"),
    "bypassDomainDesc": MessageLookupByLibrary.simpleMessage(
      "Domains that bypass the system proxy",
    ),
    "bypassDomainHelp": MessageLookupByLibrary.simpleMessage(
      "Domains in the list bypass the system proxy.",
    ),
    "cacheCorrupt": MessageLookupByLibrary.simpleMessage(
      "The cache is corrupt. Do you want to clear it?",
    ),
    "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "cancelSelectAll": MessageLookupByLibrary.simpleMessage(
      "Cancel select all",
    ),
    "checkUpdate": MessageLookupByLibrary.simpleMessage("Check for updates"),
    "checkUpdateError": MessageLookupByLibrary.simpleMessage(
      "The current application is already the latest version",
    ),
    "checkUpdates": MessageLookupByLibrary.simpleMessage("Check for updates"),
    "checkUpdatesDesc": MessageLookupByLibrary.simpleMessage(
      "Check for a new app version",
    ),
    "checkUpdatesTitle": MessageLookupByLibrary.simpleMessage(
      "Check for updates",
    ),
    "checkUpdatesTitleHelp": MessageLookupByLibrary.simpleMessage(
      "Automatically check for new app versions.",
    ),
    "clear": MessageLookupByLibrary.simpleMessage("Clear"),
    "clearData": MessageLookupByLibrary.simpleMessage("Clear Data"),
    "clipboardEmpty": MessageLookupByLibrary.simpleMessage(
      "Clipboard is empty",
    ),
    "clipboardExport": MessageLookupByLibrary.simpleMessage("Export clipboard"),
    "clipboardImport": MessageLookupByLibrary.simpleMessage("Clipboard import"),
    "close": MessageLookupByLibrary.simpleMessage("Close"),
    "closeConnectionsExit": MessageLookupByLibrary.simpleMessage(
      "Close connections on exit",
    ),
    "closeConnectionsExitHelp": MessageLookupByLibrary.simpleMessage(
      "Closes active connections and stops the core when the app exits.",
    ),
    "color": MessageLookupByLibrary.simpleMessage("Color"),
    "colorSchemes": MessageLookupByLibrary.simpleMessage("Color schemes"),
    "columns": MessageLookupByLibrary.simpleMessage("Columns"),
    "compatible": MessageLookupByLibrary.simpleMessage("Compatibility mode"),
    "configDataDetected": MessageLookupByLibrary.simpleMessage(
      "Data detected in configuration",
    ),
    "configEditor": MessageLookupByLibrary.simpleMessage("Config editor"),
    "configSavedApplied": MessageLookupByLibrary.simpleMessage(
      "Config saved and applied",
    ),
    "configuration": MessageLookupByLibrary.simpleMessage("Configuration"),
    "confirm": MessageLookupByLibrary.simpleMessage("Confirm"),
    "confirmClearAllData": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to clear all data?",
    ),
    "confirmDeleteProxyGroup": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to delete the current proxy group?",
    ),
    "confirmExitWindow": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to exit the current window?",
    ),
    "confirmForceCrashCore": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to force crash the core?",
    ),
    "confirmOverwriteTip": MessageLookupByLibrary.simpleMessage(
      "Existing data will be overwritten after confirmation",
    ),
    "connected": MessageLookupByLibrary.simpleMessage("Connected"),
    "connecting": MessageLookupByLibrary.simpleMessage("Connecting..."),
    "connection": MessageLookupByLibrary.simpleMessage("Connection"),
    "connections": MessageLookupByLibrary.simpleMessage("Connections"),
    "connectionsDesc": MessageLookupByLibrary.simpleMessage(
      "View current connections data",
    ),
    "connectivity": MessageLookupByLibrary.simpleMessage("Connectivity："),
    "content": MessageLookupByLibrary.simpleMessage("Content"),
    "contentNotEmpty": MessageLookupByLibrary.simpleMessage(
      "Content cannot be empty",
    ),
    "contentScheme": MessageLookupByLibrary.simpleMessage("Content"),
    "controlGlobalAddedRules": MessageLookupByLibrary.simpleMessage(
      "Control global added rules",
    ),
    "copiedLines": m3,
    "copy": MessageLookupByLibrary.simpleMessage("Copy"),
    "copyAll": MessageLookupByLibrary.simpleMessage("Copy all"),
    "copyEnvVar": MessageLookupByLibrary.simpleMessage(
      "Copying environment variables",
    ),
    "copyIp": MessageLookupByLibrary.simpleMessage("Copy IP"),
    "copyLink": MessageLookupByLibrary.simpleMessage("Copy link"),
    "copySuccess": MessageLookupByLibrary.simpleMessage("Copy success"),
    "core": MessageLookupByLibrary.simpleMessage("Core"),
    "coreCategory": MessageLookupByLibrary.simpleMessage("Core · mihomo"),
    "coreLogs": MessageLookupByLibrary.simpleMessage("Core logs"),
    "coreStatus": MessageLookupByLibrary.simpleMessage("Core status"),
    "countTrafficThroughProxy": MessageLookupByLibrary.simpleMessage(
      "Count traffic through the proxy only",
    ),
    "country": MessageLookupByLibrary.simpleMessage("Country"),
    "crashTest": MessageLookupByLibrary.simpleMessage("Crash test"),
    "crashlytics": MessageLookupByLibrary.simpleMessage("Crash Analysis"),
    "crashlyticsTip": MessageLookupByLibrary.simpleMessage(
      "When enabled, automatically uploads crash logs without sensitive information when the app crashes",
    ),
    "create": MessageLookupByLibrary.simpleMessage("Create"),
    "createProfile": MessageLookupByLibrary.simpleMessage("Create Profile"),
    "creationTime": MessageLookupByLibrary.simpleMessage("Creation time"),
    "currentInterval": MessageLookupByLibrary.simpleMessage("Current interval"),
    "custom": MessageLookupByLibrary.simpleMessage("Custom"),
    "cut": MessageLookupByLibrary.simpleMessage("Cut"),
    "dark": MessageLookupByLibrary.simpleMessage("Dark"),
    "dashboard": MessageLookupByLibrary.simpleMessage("Dashboard"),
    "dataChangedSave": MessageLookupByLibrary.simpleMessage(
      "Data changes detected, do you want to save?",
    ),
    "dataCollectionContent": MessageLookupByLibrary.simpleMessage(
      "This app uses Firebase Crashlytics to collect crash information to improve app stability.\nThe collected data includes device information and crash details, but does not contain personal sensitive data.\nYou can disable this feature in settings.",
    ),
    "dataCollectionTip": MessageLookupByLibrary.simpleMessage(
      "Data Collection Notice",
    ),
    "days1": MessageLookupByLibrary.simpleMessage("1 day"),
    "days3": MessageLookupByLibrary.simpleMessage("3 days"),
    "days7": MessageLookupByLibrary.simpleMessage("7 days"),
    "daysAgo": m4,
    "daysCountLs": m5,
    "daysLeftCount": m6,
    "defaultNameserver": MessageLookupByLibrary.simpleMessage(
      "Default nameserver",
    ),
    "defaultNameserverDesc": MessageLookupByLibrary.simpleMessage(
      "For resolving DNS server",
    ),
    "defaultNameserverHelp": MessageLookupByLibrary.simpleMessage(
      "Resolvers for queries not covered by nameserver-policy.",
    ),
    "defaultText": MessageLookupByLibrary.simpleMessage("Default"),
    "delay": MessageLookupByLibrary.simpleMessage("Delay"),
    "delayTest": MessageLookupByLibrary.simpleMessage("Delay Test"),
    "delete": MessageLookupByLibrary.simpleMessage("Delete"),
    "deleteFailed": m7,
    "deleteKey": MessageLookupByLibrary.simpleMessage("Delete key"),
    "deleteMultipTip": m8,
    "deleteSubDesc": MessageLookupByLibrary.simpleMessage(
      "Remove the subscription from this device",
    ),
    "deleteTip": m9,
    "desc": MessageLookupByLibrary.simpleMessage(
      "A multi-platform proxy client based on ClashMeta, simple and easy to use, open-source and ad-free.",
    ),
    "destination": MessageLookupByLibrary.simpleMessage("Destination"),
    "destinationGeoIP": MessageLookupByLibrary.simpleMessage(
      "Destination GeoIP",
    ),
    "destinationIPASN": MessageLookupByLibrary.simpleMessage(
      "Destination IPASN",
    ),
    "details": m10,
    "detectionTip": MessageLookupByLibrary.simpleMessage(
      "Relying on third-party api is for reference only",
    ),
    "developerMode": MessageLookupByLibrary.simpleMessage("Developer mode"),
    "developerModeEnableTip": MessageLookupByLibrary.simpleMessage(
      "Developer mode is enabled.",
    ),
    "direct": MessageLookupByLibrary.simpleMessage("Direct"),
    "disableUDP": MessageLookupByLibrary.simpleMessage("Disable UDP"),
    "disclaimer": MessageLookupByLibrary.simpleMessage("Disclaimer"),
    "disclaimerDesc": MessageLookupByLibrary.simpleMessage(
      "This software is only used for non-commercial purposes such as learning exchanges and scientific research. It is strictly prohibited to use this software for commercial purposes. Any commercial activity, if any, has nothing to do with this software.",
    ),
    "disconnected": MessageLookupByLibrary.simpleMessage("Disconnected"),
    "discoverNewVersion": MessageLookupByLibrary.simpleMessage(
      "Discover the new version",
    ),
    "dnsCategory": MessageLookupByLibrary.simpleMessage("DNS"),
    "dnsDesc": MessageLookupByLibrary.simpleMessage(
      "Update DNS related settings",
    ),
    "dnsHijacking": MessageLookupByLibrary.simpleMessage("DNS hijacking"),
    "dnsListen": MessageLookupByLibrary.simpleMessage("Listen"),
    "dnsListenDesc": MessageLookupByLibrary.simpleMessage(
      "Built-in DNS server address",
    ),
    "dnsListenHelp": MessageLookupByLibrary.simpleMessage(
      "Address:port on which the core listens for DNS queries.",
    ),
    "dnsMode": MessageLookupByLibrary.simpleMessage("DNS mode"),
    "dnsModeHelp": MessageLookupByLibrary.simpleMessage(
      "Fake IP — domains get virtual addresses; Redir Host — rewrites the Host in DNS responses.",
    ),
    "doYouWantToPass": MessageLookupByLibrary.simpleMessage(
      "Do you want to pass",
    ),
    "domain": MessageLookupByLibrary.simpleMessage("Domain"),
    "download": MessageLookupByLibrary.simpleMessage("Download"),
    "edit": MessageLookupByLibrary.simpleMessage("Edit"),
    "editConfig": MessageLookupByLibrary.simpleMessage("Edit config"),
    "editGlobalRules": MessageLookupByLibrary.simpleMessage(
      "Edit global rules",
    ),
    "editProxy": MessageLookupByLibrary.simpleMessage("Edit proxy"),
    "editProxyGroup": MessageLookupByLibrary.simpleMessage("Edit proxy group"),
    "editRule": MessageLookupByLibrary.simpleMessage("Edit rule"),
    "editSsid": MessageLookupByLibrary.simpleMessage("Edit SSID"),
    "emptyTip": m11,
    "en": MessageLookupByLibrary.simpleMessage("English"),
    "enterKey": MessageLookupByLibrary.simpleMessage("Enter a key"),
    "enterKeyHint": MessageLookupByLibrary.simpleMessage(
      "hysteria2://... vless://... trojan://...",
    ),
    "enterUrlManually": MessageLookupByLibrary.simpleMessage(
      "Enter URL manually",
    ),
    "entries": MessageLookupByLibrary.simpleMessage(" entries"),
    "entriesCount": m12,
    "exclude": MessageLookupByLibrary.simpleMessage("Hidden from recent tasks"),
    "excludeDesc": MessageLookupByLibrary.simpleMessage(
      "When the app is in the background, the app is hidden from the recent task",
    ),
    "excludeProxyFilter": MessageLookupByLibrary.simpleMessage(
      "Exclude proxy filter",
    ),
    "excludeSsids": MessageLookupByLibrary.simpleMessage("Exclude SSIDs"),
    "excludeSsidsDesc": MessageLookupByLibrary.simpleMessage(
      "When connected to an excluded SSID Wi-Fi, the app running state will be automatically switched.",
    ),
    "excludeType": MessageLookupByLibrary.simpleMessage("Exclude type"),
    "existsTip": m13,
    "exit": MessageLookupByLibrary.simpleMessage("Exit"),
    "expand": MessageLookupByLibrary.simpleMessage("Standard"),
    "expectedStatus": MessageLookupByLibrary.simpleMessage("Expected status"),
    "exportFile": MessageLookupByLibrary.simpleMessage("Export file"),
    "exportLogs": MessageLookupByLibrary.simpleMessage("Export logs"),
    "exportSuccess": MessageLookupByLibrary.simpleMessage("Export Success"),
    "expressiveScheme": MessageLookupByLibrary.simpleMessage("Expressive"),
    "externalController": MessageLookupByLibrary.simpleMessage(
      "ExternalController",
    ),
    "externalControllerApiDesc": MessageLookupByLibrary.simpleMessage(
      "Core HTTP API (127.0.0.1:9090)",
    ),
    "externalControllerDesc": MessageLookupByLibrary.simpleMessage(
      "Once enabled, the Clash kernel can be controlled on port 9090",
    ),
    "externalControllerHelp": MessageLookupByLibrary.simpleMessage(
      "External API to control the core (e.g. via third-party dashboards).",
    ),
    "externalFetch": MessageLookupByLibrary.simpleMessage("External fetch"),
    "externalLink": MessageLookupByLibrary.simpleMessage("External link"),
    "fakeipFilter": MessageLookupByLibrary.simpleMessage("Fakeip filter"),
    "fakeipFilterHelp": MessageLookupByLibrary.simpleMessage(
      "Domains in the list are resolved to real IPs instead of fake-ip (e.g. *.lan).",
    ),
    "fakeipRange": MessageLookupByLibrary.simpleMessage("Fakeip range"),
    "fakeipRangeHelp": MessageLookupByLibrary.simpleMessage(
      "Subnet for fake-ip addresses. Only used in Fake IP mode.",
    ),
    "fallback": MessageLookupByLibrary.simpleMessage("Fallback"),
    "fallbackDesc": MessageLookupByLibrary.simpleMessage(
      "Generally use offshore DNS",
    ),
    "fallbackFilter": MessageLookupByLibrary.simpleMessage("Fallback filter"),
    "fallbackHelp": MessageLookupByLibrary.simpleMessage(
      "Resolvers for queries handled separately (e.g. when the main DNS is blocked).",
    ),
    "fidelityScheme": MessageLookupByLibrary.simpleMessage("Fidelity"),
    "file": MessageLookupByLibrary.simpleMessage("File"),
    "fileDesc": MessageLookupByLibrary.simpleMessage("Directly upload profile"),
    "fileIsUpdate": MessageLookupByLibrary.simpleMessage(
      "The file has been modified. Do you want to save the changes?",
    ),
    "findProcessMode": MessageLookupByLibrary.simpleMessage("Find process"),
    "findProcessModeDesc": MessageLookupByLibrary.simpleMessage(
      "Detects the process that owns a connection",
    ),
    "findProcessModeHelp": MessageLookupByLibrary.simpleMessage(
      "Needed for PROCESS-NAME rules. Always — always detect; Off — disabled (lower load).",
    ),
    "fontFamily": MessageLookupByLibrary.simpleMessage("FontFamily"),
    "forceRestartCoreTip": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to force restart the core?",
    ),
    "fromClipboard": MessageLookupByLibrary.simpleMessage("From clipboard"),
    "fromClipboardDesc": MessageLookupByLibrary.simpleMessage(
      "Paste a copied link or config",
    ),
    "fromFile": MessageLookupByLibrary.simpleMessage("From a file"),
    "fromFileDesc": MessageLookupByLibrary.simpleMessage(
      "Import .yaml / .yml / .json",
    ),
    "fruitSaladScheme": MessageLookupByLibrary.simpleMessage("FruitSalad"),
    "general": MessageLookupByLibrary.simpleMessage("General"),
    "geoAutoUpdate": MessageLookupByLibrary.simpleMessage("Auto Update"),
    "geoAutoUpdateInterval": MessageLookupByLibrary.simpleMessage(
      "Auto Update Interval",
    ),
    "geoAutoUpdateIntervalTip": MessageLookupByLibrary.simpleMessage(
      "Auto update interval must be greater than 0",
    ),
    "geoOptions": MessageLookupByLibrary.simpleMessage("Geo Options"),
    "geoResources": MessageLookupByLibrary.simpleMessage("Geo Resources"),
    "geoSkipped": m14,
    "geoUpdated": m15,
    "geoUpdating": m16,
    "geodataLoader": MessageLookupByLibrary.simpleMessage(
      "Geo Low Memory Mode",
    ),
    "geodataLoaderDesc": MessageLookupByLibrary.simpleMessage(
      "Enabling will use the Geo low memory loader",
    ),
    "geodataLoaderHelp": MessageLookupByLibrary.simpleMessage(
      "Memory — geo data in RAM (faster start); Standard — from disk (less memory).",
    ),
    "geoipCode": MessageLookupByLibrary.simpleMessage("Geoip code"),
    "global": MessageLookupByLibrary.simpleMessage("Global"),
    "go": MessageLookupByLibrary.simpleMessage("Go"),
    "goDownload": MessageLookupByLibrary.simpleMessage("Go to download"),
    "goToConfigureScript": MessageLookupByLibrary.simpleMessage(
      "Go to configure script",
    ),
    "hasCacheChange": MessageLookupByLibrary.simpleMessage(
      "Do you want to cache the changes?",
    ),
    "hideFromList": MessageLookupByLibrary.simpleMessage("Hide from list"),
    "host": MessageLookupByLibrary.simpleMessage("Host"),
    "hostsDesc": MessageLookupByLibrary.simpleMessage("Add Hosts"),
    "hotkeyConflict": MessageLookupByLibrary.simpleMessage("Hotkey conflict"),
    "hotkeyManagement": MessageLookupByLibrary.simpleMessage(
      "Hotkey Management",
    ),
    "hotkeyManagementDesc": MessageLookupByLibrary.simpleMessage(
      "Use keyboard to control applications",
    ),
    "hour1": MessageLookupByLibrary.simpleMessage("1 hour"),
    "hour12": MessageLookupByLibrary.simpleMessage("12 hours"),
    "hour6": MessageLookupByLibrary.simpleMessage("6 hours"),
    "hours": MessageLookupByLibrary.simpleMessage("hours"),
    "hoursAgo": m17,
    "hoursCount": m18,
    "icon": MessageLookupByLibrary.simpleMessage("Icon"),
    "iconRecords": MessageLookupByLibrary.simpleMessage("Icon records"),
    "iconStyle": MessageLookupByLibrary.simpleMessage("Icon style"),
    "iconUrl": MessageLookupByLibrary.simpleMessage("Icon URL"),
    "ignoreBatteryOptimization": MessageLookupByLibrary.simpleMessage(
      "Ignore Battery Optimization",
    ),
    "import": MessageLookupByLibrary.simpleMessage("Import"),
    "importFile": MessageLookupByLibrary.simpleMessage("Import from file"),
    "importFromURL": MessageLookupByLibrary.simpleMessage("Import from URL"),
    "importUrl": MessageLookupByLibrary.simpleMessage("Import from URL"),
    "includeAllProxies": MessageLookupByLibrary.simpleMessage(
      "Include all proxies",
    ),
    "includeAllProxiesTip": MessageLookupByLibrary.simpleMessage(
      "Import all proxies not containing proxy groups, additional proxy groups can be added below",
    ),
    "includeAllProxyProviders": MessageLookupByLibrary.simpleMessage(
      "Include all proxy providers",
    ),
    "includeAllProxyProvidersTip": MessageLookupByLibrary.simpleMessage(
      "When enabled, it will override the imported proxy providers",
    ),
    "infiniteTime": MessageLookupByLibrary.simpleMessage("Long term effective"),
    "init": MessageLookupByLibrary.simpleMessage("Init"),
    "inputCorrectHotkey": MessageLookupByLibrary.simpleMessage(
      "Please enter the correct hotkey",
    ),
    "inputProxyGroupName": MessageLookupByLibrary.simpleMessage(
      "Input proxy group name",
    ),
    "inputRuleContent": MessageLookupByLibrary.simpleMessage(
      "Input rule content",
    ),
    "intelligentSelected": MessageLookupByLibrary.simpleMessage(
      "Intelligent selection",
    ),
    "internet": MessageLookupByLibrary.simpleMessage("Internet"),
    "interval": MessageLookupByLibrary.simpleMessage("Interval"),
    "intranetIP": MessageLookupByLibrary.simpleMessage("Intranet IP"),
    "invalidBackupFile": MessageLookupByLibrary.simpleMessage(
      "Invalid backup file",
    ),
    "invalidPolicy": m19,
    "invalidProxy": m20,
    "invalidProxyProvider": m21,
    "invalidSubRule": m22,
    "ipcidr": MessageLookupByLibrary.simpleMessage("Ipcidr"),
    "ipv6Desc": MessageLookupByLibrary.simpleMessage(
      "When turned on it will be able to receive IPv6 traffic",
    ),
    "ipv6DnsHelp": MessageLookupByLibrary.simpleMessage(
      "Answer AAAA queries with the built-in DNS server.",
    ),
    "ipv6EnabledHelp": MessageLookupByLibrary.simpleMessage(
      "Allow IPv6 traffic through the core.",
    ),
    "ipv6InboundDesc": MessageLookupByLibrary.simpleMessage(
      "Allow IPv6 inbound",
    ),
    "justNow": MessageLookupByLibrary.simpleMessage("Just now"),
    "keepAlive": MessageLookupByLibrary.simpleMessage("Keep-alive"),
    "keepAliveIntervalDesc": MessageLookupByLibrary.simpleMessage(
      "Connection check interval, sec",
    ),
    "key": MessageLookupByLibrary.simpleMessage("Key"),
    "keysAdded": m23,
    "keysCount": m24,
    "keysList": MessageLookupByLibrary.simpleMessage("Keys"),
    "keysTitle": m25,
    "language": MessageLookupByLibrary.simpleMessage("Language"),
    "languageSystem": MessageLookupByLibrary.simpleMessage("System"),
    "launchWithSystem": MessageLookupByLibrary.simpleMessage(
      "Launch with the system",
    ),
    "layout": MessageLookupByLibrary.simpleMessage("Layout"),
    "leftOfTotal": m26,
    "light": MessageLookupByLibrary.simpleMessage("Light"),
    "list": MessageLookupByLibrary.simpleMessage("List"),
    "listen": MessageLookupByLibrary.simpleMessage("Listen"),
    "loadTest": MessageLookupByLibrary.simpleMessage("Load test"),
    "loading": MessageLookupByLibrary.simpleMessage("Loading..."),
    "local": MessageLookupByLibrary.simpleMessage("Local"),
    "localBackupDesc": MessageLookupByLibrary.simpleMessage(
      "Backup local data to local",
    ),
    "localSource": MessageLookupByLibrary.simpleMessage("Local source"),
    "locationPermission": MessageLookupByLibrary.simpleMessage(
      "Location Permission",
    ),
    "locationPermissionDeniedMessage": MessageLookupByLibrary.simpleMessage(
      "Location permission was denied, so the current Wi-Fi name cannot be obtained. Please open location permission manually in system settings.",
    ),
    "locationPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "According to system requirements, obtaining the Wi-Fi name requires you to grant location permission.",
    ),
    "locationPermissionGuide": m27,
    "locationPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "Location Permission Required",
    ),
    "locations": MessageLookupByLibrary.simpleMessage("LOCATIONS"),
    "log": MessageLookupByLibrary.simpleMessage("Log"),
    "logLevel": MessageLookupByLibrary.simpleMessage("LogLevel"),
    "logcat": MessageLookupByLibrary.simpleMessage("Logcat"),
    "logcatDesc": MessageLookupByLibrary.simpleMessage(
      "Disabling will hide the log entry",
    ),
    "logs": MessageLookupByLibrary.simpleMessage("Logs"),
    "logsDesc": MessageLookupByLibrary.simpleMessage("Log capture records"),
    "logsExported": MessageLookupByLibrary.simpleMessage("Logs exported"),
    "logsTest": MessageLookupByLibrary.simpleMessage("Logs test"),
    "loopback": MessageLookupByLibrary.simpleMessage("Loopback unlock tool"),
    "loopbackDesc": MessageLookupByLibrary.simpleMessage(
      "Used for UWP loopback unlocking",
    ),
    "loose": MessageLookupByLibrary.simpleMessage("Loose"),
    "mainCategory": MessageLookupByLibrary.simpleMessage("Main"),
    "manualUpdate": MessageLookupByLibrary.simpleMessage("Updates manually"),
    "matchSourceIp": MessageLookupByLibrary.simpleMessage("Match source IP"),
    "maxFailedTimes": MessageLookupByLibrary.simpleMessage("Max failed times"),
    "memoryInfo": MessageLookupByLibrary.simpleMessage("Memory info"),
    "messageTest": MessageLookupByLibrary.simpleMessage("Message test"),
    "messageTestTip": MessageLookupByLibrary.simpleMessage(
      "This is a message.",
    ),
    "min": MessageLookupByLibrary.simpleMessage("Min"),
    "minimizeOnClose": MessageLookupByLibrary.simpleMessage(
      "Minimize on close",
    ),
    "minimizeOnExit": MessageLookupByLibrary.simpleMessage("Minimize on exit"),
    "minimizeOnExitDesc": MessageLookupByLibrary.simpleMessage(
      "Modify the default system exit event",
    ),
    "minimizeOnExitForkDesc": MessageLookupByLibrary.simpleMessage(
      "Closing the window sends the app to the tray",
    ),
    "minutes30": MessageLookupByLibrary.simpleMessage("30 minutes"),
    "minutesAgo": m28,
    "minutesCountLs": m29,
    "mixedPort": MessageLookupByLibrary.simpleMessage("Mixed Port"),
    "mobileInterface": MessageLookupByLibrary.simpleMessage(
      "Interface like on Android",
    ),
    "mobileInterfaceDesc": MessageLookupByLibrary.simpleMessage(
      "Use the Android-style layout while keeping all desktop settings",
    ),
    "mode": MessageLookupByLibrary.simpleMessage("Mode"),
    "monochromeScheme": MessageLookupByLibrary.simpleMessage("Monochrome"),
    "monthsAgo": m30,
    "more": MessageLookupByLibrary.simpleMessage("More"),
    "mtu": MessageLookupByLibrary.simpleMessage("MTU"),
    "mtuHelp": MessageLookupByLibrary.simpleMessage(
      "Maximum packet size in TUN. Default is 9000; try 1500 if you have connection issues.",
    ),
    "mtuReapplyRestart": MessageLookupByLibrary.simpleMessage(
      "Applied on core restart",
    ),
    "name": MessageLookupByLibrary.simpleMessage("Name"),
    "nameserver": MessageLookupByLibrary.simpleMessage("Nameserver"),
    "nameserverDesc": MessageLookupByLibrary.simpleMessage(
      "For resolving domain",
    ),
    "nameserverHelp": MessageLookupByLibrary.simpleMessage(
      "Main DNS resolvers for regular queries.",
    ),
    "nameserverPolicy": MessageLookupByLibrary.simpleMessage(
      "Nameserver policy",
    ),
    "nameserverPolicyDesc": MessageLookupByLibrary.simpleMessage(
      "Specify the corresponding nameserver policy",
    ),
    "nameserverPolicyHelp": MessageLookupByLibrary.simpleMessage(
      "Resolver-selection rules by domain (e.g. geosite:cn → Chinese DoH).",
    ),
    "network": MessageLookupByLibrary.simpleMessage("Network"),
    "networkCategory": MessageLookupByLibrary.simpleMessage("Network"),
    "networkDesc": MessageLookupByLibrary.simpleMessage(
      "Modify network-related settings",
    ),
    "networkDetection": MessageLookupByLibrary.simpleMessage(
      "Network detection",
    ),
    "networkException": MessageLookupByLibrary.simpleMessage(
      "Network exception, please check your connection and try again",
    ),
    "networkSpeed": MessageLookupByLibrary.simpleMessage("Network speed"),
    "networkType": MessageLookupByLibrary.simpleMessage("Network type"),
    "neutralScheme": MessageLookupByLibrary.simpleMessage("Neutral"),
    "noActiveSubscription": MessageLookupByLibrary.simpleMessage(
      "No active subscription",
    ),
    "noData": MessageLookupByLibrary.simpleMessage("No data"),
    "noHotKey": MessageLookupByLibrary.simpleMessage("No HotKey"),
    "noInfo": MessageLookupByLibrary.simpleMessage("No info"),
    "noKeys": MessageLookupByLibrary.simpleMessage("No keys"),
    "noLocationsAvailable": MessageLookupByLibrary.simpleMessage(
      "No locations available",
    ),
    "noLogs": MessageLookupByLibrary.simpleMessage("No logs yet"),
    "noLongerRemind": MessageLookupByLibrary.simpleMessage(
      "Don\'t remind again",
    ),
    "noNetwork": MessageLookupByLibrary.simpleMessage("No network"),
    "noNetworkApp": MessageLookupByLibrary.simpleMessage("No network APP"),
    "noRecords": MessageLookupByLibrary.simpleMessage("No records"),
    "noResolve": MessageLookupByLibrary.simpleMessage("No resolve IP"),
    "noResolveHostname": MessageLookupByLibrary.simpleMessage(
      "No resolve hostname",
    ),
    "noSubscriptions": MessageLookupByLibrary.simpleMessage(
      "No subscriptions yet",
    ),
    "noTrafficData": MessageLookupByLibrary.simpleMessage("No traffic data"),
    "none": MessageLookupByLibrary.simpleMessage("none"),
    "notSelectedTip": MessageLookupByLibrary.simpleMessage(
      "The current proxy group cannot be selected.",
    ),
    "nullProfileDesc": MessageLookupByLibrary.simpleMessage(
      "No profile, Please add a profile",
    ),
    "nullTip": m31,
    "numberTip": m32,
    "off": MessageLookupByLibrary.simpleMessage("Off"),
    "on": MessageLookupByLibrary.simpleMessage("On"),
    "onDemand": MessageLookupByLibrary.simpleMessage("On Demand"),
    "onDemandDesc": MessageLookupByLibrary.simpleMessage(
      "Configure the program running state for specific scenarios",
    ),
    "onlyIcon": MessageLookupByLibrary.simpleMessage("Icon"),
    "onlyStatisticsProxy": MessageLookupByLibrary.simpleMessage(
      "Only statistics proxy",
    ),
    "onlyStatisticsProxyDesc": MessageLookupByLibrary.simpleMessage(
      "When turned on, only statistics proxy traffic",
    ),
    "openExternalEditor": MessageLookupByLibrary.simpleMessage(
      "Open in external editor",
    ),
    "openRepository": MessageLookupByLibrary.simpleMessage("Open repository"),
    "optional": MessageLookupByLibrary.simpleMessage("Optional"),
    "options": MessageLookupByLibrary.simpleMessage("Options"),
    "other": MessageLookupByLibrary.simpleMessage("Other"),
    "otherContributors": MessageLookupByLibrary.simpleMessage(
      "Other contributors",
    ),
    "outboundMode": MessageLookupByLibrary.simpleMessage("Outbound mode"),
    "override": MessageLookupByLibrary.simpleMessage("Override"),
    "overrideDns": MessageLookupByLibrary.simpleMessage("Override Dns"),
    "overrideDnsDesc": MessageLookupByLibrary.simpleMessage(
      "Turning it on will override the DNS options in the profile",
    ),
    "overrideMode": MessageLookupByLibrary.simpleMessage("Override mode"),
    "overrideScript": MessageLookupByLibrary.simpleMessage("Override script"),
    "overwriteTypeCustom": MessageLookupByLibrary.simpleMessage("Custom"),
    "overwriteTypeCustomDesc": MessageLookupByLibrary.simpleMessage(
      "Custom mode, fully customize proxy groups and rules",
    ),
    "palette": MessageLookupByLibrary.simpleMessage("Palette"),
    "password": MessageLookupByLibrary.simpleMessage("Password"),
    "paste": MessageLookupByLibrary.simpleMessage("Paste"),
    "pickQrImageDesc": MessageLookupByLibrary.simpleMessage(
      "Choose an image with a QR code",
    ),
    "pleaseBindWebDAV": MessageLookupByLibrary.simpleMessage(
      "Please bind WebDAV",
    ),
    "pleaseEnterScriptName": MessageLookupByLibrary.simpleMessage(
      "Please enter a script name",
    ),
    "pleaseInputAdminPassword": MessageLookupByLibrary.simpleMessage(
      "Please enter the admin password",
    ),
    "pleaseUploadValidQrcode": MessageLookupByLibrary.simpleMessage(
      "Please upload a valid QR code",
    ),
    "port": MessageLookupByLibrary.simpleMessage("Port"),
    "portConflictTip": MessageLookupByLibrary.simpleMessage(
      "Please enter a different port",
    ),
    "portTip": m33,
    "ports": MessageLookupByLibrary.simpleMessage("Ports"),
    "portsHelp": MessageLookupByLibrary.simpleMessage(
      "Ports the core listens on for proxy protocols. 0 — port disabled.",
    ),
    "preferH3Desc": MessageLookupByLibrary.simpleMessage(
      "Prioritize the use of DOH\'s http/3",
    ),
    "preferH3Help": MessageLookupByLibrary.simpleMessage(
      "Use HTTP/3 (QUIC) for DoH resolvers where supported.",
    ),
    "prerequisites": MessageLookupByLibrary.simpleMessage("Prerequisites"),
    "presets": MessageLookupByLibrary.simpleMessage("Presets"),
    "pressKeyboard": MessageLookupByLibrary.simpleMessage(
      "Please press the keyboard.",
    ),
    "pressToAddConfig": MessageLookupByLibrary.simpleMessage(
      "Press to add a config",
    ),
    "pressToConnect": MessageLookupByLibrary.simpleMessage("Press to connect"),
    "preview": MessageLookupByLibrary.simpleMessage("Preview"),
    "process": MessageLookupByLibrary.simpleMessage("Process"),
    "profile": MessageLookupByLibrary.simpleMessage("Profile"),
    "profileAutoUpdateIntervalInvalidValidationDesc":
        MessageLookupByLibrary.simpleMessage(
          "Please input a valid interval time format",
        ),
    "profileAutoUpdateIntervalNullValidationDesc":
        MessageLookupByLibrary.simpleMessage(
          "Please enter the auto update interval time",
        ),
    "profileHasUpdate": MessageLookupByLibrary.simpleMessage(
      "The profile has been modified. Do you want to disable auto update?",
    ),
    "profileNameNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Please input the profile name",
    ),
    "profileNotFound": MessageLookupByLibrary.simpleMessage(
      "Profile not found",
    ),
    "profileUrlInvalidValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Please input a valid profile URL",
    ),
    "profileUrlNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Please input the profile URL",
    ),
    "profiles": MessageLookupByLibrary.simpleMessage("Profiles"),
    "profilesSort": MessageLookupByLibrary.simpleMessage("Profiles sort"),
    "project": MessageLookupByLibrary.simpleMessage("Project"),
    "providers": MessageLookupByLibrary.simpleMessage("Providers"),
    "proxies": MessageLookupByLibrary.simpleMessage("Proxies"),
    "proxiesEmpty": MessageLookupByLibrary.simpleMessage("Proxies is empty"),
    "proxyChains": MessageLookupByLibrary.simpleMessage("Proxy chains"),
    "proxyDetectedAbnormal": MessageLookupByLibrary.simpleMessage(
      "Detected selected proxies are abnormal",
    ),
    "proxyFilter": MessageLookupByLibrary.simpleMessage("Proxy filter"),
    "proxyGroup": MessageLookupByLibrary.simpleMessage("Proxy group"),
    "proxyGroupDetectedAbnormal": MessageLookupByLibrary.simpleMessage(
      "Detected current proxy group is abnormal",
    ),
    "proxyGroupEmpty": MessageLookupByLibrary.simpleMessage(
      "Proxy group is empty",
    ),
    "proxyGroupNameDuplicate": MessageLookupByLibrary.simpleMessage(
      "Proxy group name is duplicate",
    ),
    "proxyGroupNameEmpty": MessageLookupByLibrary.simpleMessage(
      "Proxy group name cannot be empty",
    ),
    "proxyNameserver": MessageLookupByLibrary.simpleMessage("Proxy nameserver"),
    "proxyNameserverDesc": MessageLookupByLibrary.simpleMessage(
      "Domain for resolving proxy nodes",
    ),
    "proxyNameserverHelp": MessageLookupByLibrary.simpleMessage(
      "Resolvers for proxy-server domain names.",
    ),
    "proxyPort": MessageLookupByLibrary.simpleMessage("ProxyPort"),
    "proxyProviderDetectedAbnormal": MessageLookupByLibrary.simpleMessage(
      "Detected selected proxy providers are abnormal",
    ),
    "proxyProviders": MessageLookupByLibrary.simpleMessage("Proxy providers"),
    "proxyProvidersEmpty": MessageLookupByLibrary.simpleMessage(
      "Proxy providers is empty",
    ),
    "proxyProvidersNotEmpty": MessageLookupByLibrary.simpleMessage(
      "Proxy providers cannot be empty",
    ),
    "proxyType": MessageLookupByLibrary.simpleMessage("Proxy type"),
    "pruneCache": MessageLookupByLibrary.simpleMessage("Prune cache"),
    "pureBlackMode": MessageLookupByLibrary.simpleMessage("Pure black mode"),
    "qrcode": MessageLookupByLibrary.simpleMessage("QR code"),
    "qrcodeDesc": MessageLookupByLibrary.simpleMessage(
      "Scan QR code to obtain profile",
    ),
    "quickFill": MessageLookupByLibrary.simpleMessage("Quick fill"),
    "rainbowScheme": MessageLookupByLibrary.simpleMessage("Rainbow"),
    "rawKey": MessageLookupByLibrary.simpleMessage("Raw key"),
    "rawKeyHint": MessageLookupByLibrary.simpleMessage(
      "vless:// trojan:// ss:// — your keys",
    ),
    "redirPort": MessageLookupByLibrary.simpleMessage("Redir Port"),
    "redo": MessageLookupByLibrary.simpleMessage("redo"),
    "refresh": MessageLookupByLibrary.simpleMessage("Refresh"),
    "remnawaveSubscriptionLink": MessageLookupByLibrary.simpleMessage(
      "Remnawave subscription link",
    ),
    "remote": MessageLookupByLibrary.simpleMessage("Remote"),
    "remoteBackupDesc": MessageLookupByLibrary.simpleMessage(
      "Backup local data to WebDAV",
    ),
    "remoteDestination": MessageLookupByLibrary.simpleMessage(
      "Remote destination",
    ),
    "remove": MessageLookupByLibrary.simpleMessage("Remove"),
    "removeFromFavorites": MessageLookupByLibrary.simpleMessage(
      "Remove from favorites",
    ),
    "rename": MessageLookupByLibrary.simpleMessage("Rename"),
    "renameDesc": MessageLookupByLibrary.simpleMessage(
      "Change the displayed name",
    ),
    "renameSubscription": MessageLookupByLibrary.simpleMessage(
      "Rename subscription",
    ),
    "request": MessageLookupByLibrary.simpleMessage("Request"),
    "requests": MessageLookupByLibrary.simpleMessage("Requests"),
    "requestsDesc": MessageLookupByLibrary.simpleMessage(
      "View recently request records",
    ),
    "reset": MessageLookupByLibrary.simpleMessage("Reset"),
    "resetChanges": MessageLookupByLibrary.simpleMessage("Discard changes"),
    "resetPageChangesTip": MessageLookupByLibrary.simpleMessage(
      "The current page has changes. Are you sure you want to reset?",
    ),
    "resetTip": MessageLookupByLibrary.simpleMessage("Make sure to reset"),
    "resources": MessageLookupByLibrary.simpleMessage("Resources"),
    "resourcesDesc": MessageLookupByLibrary.simpleMessage(
      "External resource related info",
    ),
    "respectRules": MessageLookupByLibrary.simpleMessage("Respect rules"),
    "respectRulesDesc": MessageLookupByLibrary.simpleMessage(
      "Respect rules for DNS queries",
    ),
    "restart": MessageLookupByLibrary.simpleMessage("Restart"),
    "restartCoreTip": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to restart the core?",
    ),
    "restore": MessageLookupByLibrary.simpleMessage("Restore"),
    "restoreAllData": MessageLookupByLibrary.simpleMessage("Restore all data"),
    "restoreException": MessageLookupByLibrary.simpleMessage(
      "Recovery exception",
    ),
    "restoreFromFileDesc": MessageLookupByLibrary.simpleMessage(
      "Restore data via file",
    ),
    "restoreFromWebDAVDesc": MessageLookupByLibrary.simpleMessage(
      "Restore data via WebDAV",
    ),
    "restoreOnlyConfig": MessageLookupByLibrary.simpleMessage(
      "Restore configuration files only",
    ),
    "restoreStrategy": MessageLookupByLibrary.simpleMessage("Restore strategy"),
    "restoreStrategy_compatible": MessageLookupByLibrary.simpleMessage(
      "Compatible",
    ),
    "restoreStrategy_override": MessageLookupByLibrary.simpleMessage(
      "Override",
    ),
    "restoreSuccess": MessageLookupByLibrary.simpleMessage("Restore success"),
    "routeAddress": MessageLookupByLibrary.simpleMessage("Route address"),
    "routeAddressDesc": MessageLookupByLibrary.simpleMessage(
      "Config listen route address",
    ),
    "routeMode": MessageLookupByLibrary.simpleMessage("Routing mode"),
    "routeModeDirect": MessageLookupByLibrary.simpleMessage("Direct"),
    "routeModeGlobal": MessageLookupByLibrary.simpleMessage("Global"),
    "routeModeHelp": MessageLookupByLibrary.simpleMessage(
      "Rules — traffic follows the config rules; Global — all traffic goes through the proxy; Direct — no proxy.",
    ),
    "routeModeRule": MessageLookupByLibrary.simpleMessage("Rules"),
    "routeMode_bypassPrivate": MessageLookupByLibrary.simpleMessage(
      "Bypass private route address",
    ),
    "routeMode_config": MessageLookupByLibrary.simpleMessage("Use config"),
    "ru": MessageLookupByLibrary.simpleMessage("Russian"),
    "rule": MessageLookupByLibrary.simpleMessage("Rule"),
    "ruleActionAndDesc": MessageLookupByLibrary.simpleMessage(
      "Logical rule AND",
    ),
    "ruleActionDomainDesc": MessageLookupByLibrary.simpleMessage(
      "Match full domain",
    ),
    "ruleActionDomainKeywordDesc": MessageLookupByLibrary.simpleMessage(
      "Match domain keyword",
    ),
    "ruleActionDomainRegexDesc": MessageLookupByLibrary.simpleMessage(
      "Wildcard match, only supports * and ? wildcards",
    ),
    "ruleActionDomainSuffixDesc": MessageLookupByLibrary.simpleMessage(
      "Match domain suffix",
    ),
    "ruleActionDscpDesc": MessageLookupByLibrary.simpleMessage(
      "Match DSCP mark (tproxy udp inbound only)",
    ),
    "ruleActionDstPortDesc": MessageLookupByLibrary.simpleMessage(
      "Match request target port range",
    ),
    "ruleActionGeoipDesc": MessageLookupByLibrary.simpleMessage(
      "Match IP\'s country code",
    ),
    "ruleActionGeositeDesc": MessageLookupByLibrary.simpleMessage(
      "Match domains within Geosite",
    ),
    "ruleActionInNameDesc": MessageLookupByLibrary.simpleMessage(
      "Match inbound name",
    ),
    "ruleActionInPortDesc": MessageLookupByLibrary.simpleMessage(
      "Match inbound port",
    ),
    "ruleActionInTypeDesc": MessageLookupByLibrary.simpleMessage(
      "Match inbound type",
    ),
    "ruleActionInUserDesc": MessageLookupByLibrary.simpleMessage(
      "Match inbound username, supports multiple usernames separated by /",
    ),
    "ruleActionIpAsnDesc": MessageLookupByLibrary.simpleMessage(
      "Match IP\'s ASN",
    ),
    "ruleActionIpCidr6Desc": MessageLookupByLibrary.simpleMessage(
      "Match IP address range, IP-CIDR6 is just an alias",
    ),
    "ruleActionIpCidrDesc": MessageLookupByLibrary.simpleMessage(
      "Match IP address range",
    ),
    "ruleActionIpSuffixDesc": MessageLookupByLibrary.simpleMessage(
      "Match IP suffix range",
    ),
    "ruleActionMatchDesc": MessageLookupByLibrary.simpleMessage(
      "Match all requests, no conditions needed",
    ),
    "ruleActionNetworkDesc": MessageLookupByLibrary.simpleMessage(
      "Match TCP or UDP",
    ),
    "ruleActionNotDesc": MessageLookupByLibrary.simpleMessage(
      "Logical rule NOT",
    ),
    "ruleActionOrDesc": MessageLookupByLibrary.simpleMessage("Logical rule OR"),
    "ruleActionProcessNameDesc": MessageLookupByLibrary.simpleMessage(
      "Match using process name, matches package name on Android",
    ),
    "ruleActionProcessNameRegexDesc": MessageLookupByLibrary.simpleMessage(
      "Match using process name regex, matches package name on Android",
    ),
    "ruleActionProcessPathDesc": MessageLookupByLibrary.simpleMessage(
      "Match using full process path",
    ),
    "ruleActionProcessPathRegexDesc": MessageLookupByLibrary.simpleMessage(
      "Match using process path regex",
    ),
    "ruleActionRuleSetDesc": MessageLookupByLibrary.simpleMessage(
      "Reference rule set, requires rule-providers configuration",
    ),
    "ruleActionSrcGeoipDesc": MessageLookupByLibrary.simpleMessage(
      "Match source IP\'s country code",
    ),
    "ruleActionSrcIpAsnDesc": MessageLookupByLibrary.simpleMessage(
      "Match source IP\'s ASN",
    ),
    "ruleActionSrcIpCidrDesc": MessageLookupByLibrary.simpleMessage(
      "Match source IP address range",
    ),
    "ruleActionSrcIpSuffixDesc": MessageLookupByLibrary.simpleMessage(
      "Match source IP suffix range",
    ),
    "ruleActionSrcPortDesc": MessageLookupByLibrary.simpleMessage(
      "Match request source port range",
    ),
    "ruleActionSubRuleDesc": MessageLookupByLibrary.simpleMessage(
      "Match to sub-rule, pay attention to the use of parentheses",
    ),
    "ruleActionUidDesc": MessageLookupByLibrary.simpleMessage(
      "Match Linux USER ID",
    ),
    "ruleEmpty": MessageLookupByLibrary.simpleMessage("Rule is empty"),
    "ruleName": MessageLookupByLibrary.simpleMessage("Rule name"),
    "ruleProviders": MessageLookupByLibrary.simpleMessage("Rule providers"),
    "ruleSet": MessageLookupByLibrary.simpleMessage("Rule set"),
    "ruleTarget": MessageLookupByLibrary.simpleMessage("Rule target"),
    "running": MessageLookupByLibrary.simpleMessage("Running"),
    "save": MessageLookupByLibrary.simpleMessage("Save"),
    "saveAndApply": MessageLookupByLibrary.simpleMessage("Save and apply"),
    "saveChanges": MessageLookupByLibrary.simpleMessage(
      "Do you want to save the changes?",
    ),
    "saveFailed": m34,
    "scanQrCode": MessageLookupByLibrary.simpleMessage("Scan with the camera"),
    "script": MessageLookupByLibrary.simpleMessage("Script"),
    "scriptModeDesc": MessageLookupByLibrary.simpleMessage(
      "Script mode, use external extension scripts, provide one-click override configuration capability",
    ),
    "search": MessageLookupByLibrary.simpleMessage("Search"),
    "searchLocations": MessageLookupByLibrary.simpleMessage(
      "Search locations...",
    ),
    "seconds": MessageLookupByLibrary.simpleMessage("Seconds"),
    "secondsCount": m35,
    "selectAll": MessageLookupByLibrary.simpleMessage("Select all"),
    "selectProxies": MessageLookupByLibrary.simpleMessage("Select proxies"),
    "selectProxyProviders": MessageLookupByLibrary.simpleMessage(
      "Select proxy providers",
    ),
    "selectRuleSet": MessageLookupByLibrary.simpleMessage(
      "Please select rule set",
    ),
    "selectSplitStrategy": MessageLookupByLibrary.simpleMessage(
      "Please select split strategy",
    ),
    "selectSubRule": MessageLookupByLibrary.simpleMessage(
      "Please select sub rule",
    ),
    "selected": MessageLookupByLibrary.simpleMessage("Selected"),
    "selectedCountTitle": m36,
    "settings": MessageLookupByLibrary.simpleMessage("Settings"),
    "show": MessageLookupByLibrary.simpleMessage("Show"),
    "shrink": MessageLookupByLibrary.simpleMessage("Shrink"),
    "silentLaunch": MessageLookupByLibrary.simpleMessage("SilentLaunch"),
    "silentLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "Start in the background",
    ),
    "size": MessageLookupByLibrary.simpleMessage("Size"),
    "snifferDesc": MessageLookupByLibrary.simpleMessage(
      "Domain detection via TLS SNI / HTTP Host",
    ),
    "snifferHelp": MessageLookupByLibrary.simpleMessage(
      "Detects the domain in encrypted traffic — needed for domain rules to work correctly.",
    ),
    "socksPort": MessageLookupByLibrary.simpleMessage("Socks Port"),
    "sort": MessageLookupByLibrary.simpleMessage("Sort"),
    "source": MessageLookupByLibrary.simpleMessage("Source"),
    "sourceIp": MessageLookupByLibrary.simpleMessage("Source IP"),
    "specialProxy": MessageLookupByLibrary.simpleMessage("Special proxy"),
    "specialRules": MessageLookupByLibrary.simpleMessage("special rules"),
    "speedStatistics": MessageLookupByLibrary.simpleMessage("Speed statistics"),
    "splitStrategy": MessageLookupByLibrary.simpleMessage("Split strategy"),
    "splitStrategyNotEmpty": MessageLookupByLibrary.simpleMessage(
      "Split strategy cannot be empty",
    ),
    "ssidsEmpty": MessageLookupByLibrary.simpleMessage("SSIDs is empty"),
    "stackMode": MessageLookupByLibrary.simpleMessage("Stack mode"),
    "standard": MessageLookupByLibrary.simpleMessage("Standard"),
    "standardModeDesc": MessageLookupByLibrary.simpleMessage(
      "Standard mode, override basic configuration, provide simple rule addition capability",
    ),
    "start": MessageLookupByLibrary.simpleMessage("Start"),
    "startVpn": MessageLookupByLibrary.simpleMessage("Starting VPN..."),
    "statReceive": MessageLookupByLibrary.simpleMessage("Receive"),
    "statTime": MessageLookupByLibrary.simpleMessage("Time"),
    "statTransmit": MessageLookupByLibrary.simpleMessage("Transmit"),
    "staticHostsDesc": MessageLookupByLibrary.simpleMessage(
      "Static DNS records",
    ),
    "status": MessageLookupByLibrary.simpleMessage("Status"),
    "statusDesc": MessageLookupByLibrary.simpleMessage(
      "System DNS will be used when turned off",
    ),
    "stop": MessageLookupByLibrary.simpleMessage("Stop"),
    "stopVpn": MessageLookupByLibrary.simpleMessage("Stopping VPN..."),
    "stopped": MessageLookupByLibrary.simpleMessage("Stopped"),
    "strictRoute": MessageLookupByLibrary.simpleMessage("Strict route"),
    "strictRouteDesc": MessageLookupByLibrary.simpleMessage(
      "All traffic goes through TUN, no route bypass",
    ),
    "style": MessageLookupByLibrary.simpleMessage("Style"),
    "subRule": MessageLookupByLibrary.simpleMessage("Sub rule"),
    "subRuleEmpty": MessageLookupByLibrary.simpleMessage("Sub rule is empty"),
    "subRuleNotEmpty": MessageLookupByLibrary.simpleMessage(
      "Sub rule cannot be empty",
    ),
    "submit": MessageLookupByLibrary.simpleMessage("Submit"),
    "subscriptionExpired": MessageLookupByLibrary.simpleMessage(
      "Subscription expired",
    ),
    "subscriptionUrlTitle": MessageLookupByLibrary.simpleMessage(
      "Subscription link",
    ),
    "subscriptions": MessageLookupByLibrary.simpleMessage("Subscriptions"),
    "suspended": MessageLookupByLibrary.simpleMessage("Suspended..."),
    "sync": MessageLookupByLibrary.simpleMessage("Sync"),
    "system": MessageLookupByLibrary.simpleMessage("System"),
    "systemApp": MessageLookupByLibrary.simpleMessage("System APP"),
    "systemProxy": MessageLookupByLibrary.simpleMessage("System proxy"),
    "systemProxyDesc": MessageLookupByLibrary.simpleMessage(
      "Attach HTTP proxy to VpnService",
    ),
    "systemProxyForkDesc": MessageLookupByLibrary.simpleMessage(
      "Route system traffic through the core\'s mixed port",
    ),
    "tab": MessageLookupByLibrary.simpleMessage("Tab"),
    "tabAnimation": MessageLookupByLibrary.simpleMessage("Tab animation"),
    "tabAnimationDesc": MessageLookupByLibrary.simpleMessage(
      "Effective only in mobile view",
    ),
    "tapToAuthorize": MessageLookupByLibrary.simpleMessage("Tap to authorize"),
    "tcpConcurrent": MessageLookupByLibrary.simpleMessage("TCP concurrent"),
    "tcpConcurrentDesc": MessageLookupByLibrary.simpleMessage(
      "Enabling it will allow TCP concurrency",
    ),
    "tcpConcurrentForkDesc": MessageLookupByLibrary.simpleMessage(
      "Parallel TCP connection attempts for speed",
    ),
    "tcpConcurrentForkHelp": MessageLookupByLibrary.simpleMessage(
      "Speeds up connection setup with parallel attempts but may increase data usage.",
    ),
    "testAllServers": MessageLookupByLibrary.simpleMessage(
      "Test delay for all servers",
    ),
    "testInterval": MessageLookupByLibrary.simpleMessage("Test interval"),
    "testUrl": MessageLookupByLibrary.simpleMessage("Test url"),
    "testUrlDesc": MessageLookupByLibrary.simpleMessage(
      "URL used to measure latency",
    ),
    "testUrlHelp": MessageLookupByLibrary.simpleMessage(
      "The URL the core uses to measure server latency.",
    ),
    "testWhenUsed": MessageLookupByLibrary.simpleMessage("Test when used"),
    "textScale": MessageLookupByLibrary.simpleMessage("Text Scaling"),
    "theme": MessageLookupByLibrary.simpleMessage("Theme"),
    "themeColor": MessageLookupByLibrary.simpleMessage("Theme color"),
    "themeDesc": MessageLookupByLibrary.simpleMessage(
      "Set dark mode,adjust the color",
    ),
    "themeMode": MessageLookupByLibrary.simpleMessage("Theme mode"),
    "tight": MessageLookupByLibrary.simpleMessage("Tight"),
    "time": MessageLookupByLibrary.simpleMessage("Time"),
    "timeout": MessageLookupByLibrary.simpleMessage("Timeout"),
    "tip": MessageLookupByLibrary.simpleMessage("tip"),
    "toggle": MessageLookupByLibrary.simpleMessage("Toggle"),
    "tonalSpotScheme": MessageLookupByLibrary.simpleMessage("TonalSpot"),
    "tools": MessageLookupByLibrary.simpleMessage("Tools"),
    "tproxyPort": MessageLookupByLibrary.simpleMessage("Tproxy Port"),
    "trafficExhausted": MessageLookupByLibrary.simpleMessage(
      "Traffic exhausted",
    ),
    "trafficUsage": MessageLookupByLibrary.simpleMessage("Traffic usage"),
    "tun": MessageLookupByLibrary.simpleMessage("TUN"),
    "tunDesc": MessageLookupByLibrary.simpleMessage(
      "only effective in administrator mode",
    ),
    "tunMode": MessageLookupByLibrary.simpleMessage("TUN mode"),
    "tunModeDesc": MessageLookupByLibrary.simpleMessage(
      "Intercepts all system traffic through a virtual adapter. When enabled, the core will request administrator privileges.",
    ),
    "tunStack": MessageLookupByLibrary.simpleMessage("TUN stack"),
    "tunStackHelp": MessageLookupByLibrary.simpleMessage(
      "gVisor — best compatibility; System — higher performance; Mixed — hybrid of both.",
    ),
    "turnOff": MessageLookupByLibrary.simpleMessage("Turn Off"),
    "turnOn": MessageLookupByLibrary.simpleMessage("Turn On"),
    "uaDesc": MessageLookupByLibrary.simpleMessage(
      "User-Agent used when updating subscriptions",
    ),
    "undo": MessageLookupByLibrary.simpleMessage("undo"),
    "unifiedDelay": MessageLookupByLibrary.simpleMessage("Unified delay"),
    "unifiedDelayDesc": MessageLookupByLibrary.simpleMessage(
      "Remove extra delays such as handshaking",
    ),
    "unifiedDelayForkDesc": MessageLookupByLibrary.simpleMessage(
      "Unified latency measurement method",
    ),
    "unifiedDelayForkHelp": MessageLookupByLibrary.simpleMessage(
      "All groups use one measurement method so readings are comparable.",
    ),
    "unknown": MessageLookupByLibrary.simpleMessage("Unknown"),
    "unknownNetworkError": MessageLookupByLibrary.simpleMessage(
      "Unknown network error",
    ),
    "unnamed": MessageLookupByLibrary.simpleMessage("Unnamed"),
    "update": MessageLookupByLibrary.simpleMessage("Update"),
    "updateAllSubs": MessageLookupByLibrary.simpleMessage(
      "Update all subscriptions",
    ),
    "updateFailed": m37,
    "updateIntervalTitle": MessageLookupByLibrary.simpleMessage(
      "Update interval",
    ),
    "upload": MessageLookupByLibrary.simpleMessage("Upload"),
    "url": MessageLookupByLibrary.simpleMessage("URL"),
    "urlDesc": MessageLookupByLibrary.simpleMessage(
      "Obtain profile through URL",
    ),
    "urlTip": m38,
    "useHosts": MessageLookupByLibrary.simpleMessage("Use hosts"),
    "useHostsHelp": MessageLookupByLibrary.simpleMessage(
      "Respect the hosts file in the config when resolving.",
    ),
    "useSystemHosts": MessageLookupByLibrary.simpleMessage("Use system hosts"),
    "useSystemHostsHelp": MessageLookupByLibrary.simpleMessage(
      "Respect Windows system hosts when resolving.",
    ),
    "usedOf": m39,
    "usedOfTotal": m40,
    "userAgent": MessageLookupByLibrary.simpleMessage("User-Agent"),
    "value": MessageLookupByLibrary.simpleMessage("Value"),
    "vibrantScheme": MessageLookupByLibrary.simpleMessage("Vibrant"),
    "view": MessageLookupByLibrary.simpleMessage("View"),
    "vpnConfigChangeDetected": MessageLookupByLibrary.simpleMessage(
      "VPN configuration change detected",
    ),
    "vpnEnableDesc": MessageLookupByLibrary.simpleMessage(
      "Auto routes all system traffic through VpnService",
    ),
    "vpnTip": MessageLookupByLibrary.simpleMessage(
      "Changes take effect after restarting the VPN",
    ),
    "webDAVConfiguration": MessageLookupByLibrary.simpleMessage(
      "WebDAV configuration",
    ),
    "whitelistMode": MessageLookupByLibrary.simpleMessage("Whitelist mode"),
    "yearsAgo": m41,
  };
}
