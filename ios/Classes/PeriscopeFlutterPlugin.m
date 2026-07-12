#import "PeriscopeFlutterPlugin.h"

#if __has_include(<periscope_flutter/periscope_flutter-Swift.h>)
#import <periscope_flutter/periscope_flutter-Swift.h>
#else
#import "periscope_flutter-Swift.h"
#endif

@implementation PeriscopeFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftPeriscopeFlutterPlugin registerWithRegistrar:registrar];
}
@end
