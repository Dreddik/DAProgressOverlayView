DAProgressOverlayView
=====================

A UIView subclass displaying download progress. Looks similarly to springboard icons of apps being downloaded in iOS 7.

![Animated example](DAProgressExample.gif)

Installing
=====================

You can install the library with Cocoapods
```
platform :ios, '5.0'
pod "DAProgressOverlayLayeredView"
```

Usage
=====================

1) Create overlay view with your view bounds, and add it:
```
self.progressOverlayView = [[DAProgressOverlayView alloc] initWithFrame:self.imageView.bounds]; //Create new view
[self.imageView addSubview:self.progressOverlayView]; //Add as subview
[self.progressOverlayView displayOperationWillTriggerAnimation]; //Play start animation
```

2) Update overlay progress level:
```
self.progressOverlayView.progress = progress;
```

3) Catch animation finish:
```
__weak DAViewController *wself = self;
    [self.progressOverlayView setAnimationCompletionHandler:^(DAProgressOverlayAnimationType type) {
        if (type == DAProgressOverlayAnimationFinish) {
            wself.progressOverlayView = nil;
        }
    }];
```
