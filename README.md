# DesktopCountdownsSwiftUI
This repo contains a rewrite of the DesktopCountdowns macos app that shows the reminders you have scheduled in the Apple Reminders app as countdowns on your desktop. see: [https://github.com/Daij-Djan/DesktopCountdowns](https://github.com/Daij-Djan/DesktopCountdowns)

### The actual functionality of the app is less interesting than the multiplatform setup!
the setup is the meaningful part that I hope helps someone :)

## Change to use SwiftUI multiplatform approach
The original app is using UIKit while the rwrite aims to use a SwiftUI multi-platform codebase.
At the time of writing (2/3/2025) this allows the app to cover _every_ apple platform currently available with a single cofebase.

- macos via AppKit
![Screenshot](https://github.com/Daij-Djan/DesktopCountdownsSwiftUI/raw/main/README-Files/mac.jpg)
- ios via UIKit (iPhone, iPad, Vision & AppleTV)
![Screenshot](https://github.com/Daij-Djan/DesktopCountdownsSwiftUI/raw/main/README-Files/iphone.jpg)
![Screenshot](https://github.com/Daij-Djan/DesktopCountdownsSwiftUI/raw/main/README-Files/ipad.jpg)
![Screenshot](https://github.com/Daij-Djan/DesktopCountdownsSwiftUI/raw/main/README-Files/vision.jpg)
![Screenshot](https://github.com/Daij-Djan/DesktopCountdownsSwiftUI/raw/main/README-Files/appletv.jpg)
- watchos via WatchKit
![Screenshot](https://github.com/Daij-Djan/DesktopCountdownsSwiftUI/raw/main/README-Files/watch.jpg)

## How much is shared
The codebase is 9% shared fully. That includes Assets, Info.plist and all Code between the 6 platforms EXCEPT for 3 different @AppDelegateAdaptor classes that allow hooking into the different sdk's app lifecycles.

![Screenshot](https://github.com/Daij-Djan/DesktopCountdownsSwiftUI/raw/main/README-Files/xcode-code.jpg)

From a perspective of the IDE experience, the 6 platforms require 2 targets in xcode that share 100% of the files:
- 1. Multi-Platform (everything BUT watch)
- 2. WatchOS App

I expect apple to merge watchos into the multiplatform template given it is already 99% the same and totally compatible in terms of source code.
The explanation (and only downside here) is that the two targets might be unable to share build caches behind the scenes at the moment.

![Screenshot](https://github.com/Daij-Djan/DesktopCountdownsSwiftUI/raw/main/README-Files/xcode-targets.jpg)

SwiftUI Previews work fine for all 6 platforms! 
