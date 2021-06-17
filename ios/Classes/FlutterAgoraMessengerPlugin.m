#import "FlutterAgoraMessengerPlugin.h"
#if __has_include(<flutter_agora_messenger/flutter_agora_messenger-Swift.h>)
#import <flutter_agora_messenger/flutter_agora_messenger-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_agora_messenger-Swift.h"
#endif

@implementation FlutterAgoraMessengerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterAgoraMessengerPlugin registerWithRegistrar:registrar];
}
@end
