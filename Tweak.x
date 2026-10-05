// NoFlashGPT
//
// ChatGPT's in-app camera comes up with flash on Auto every time it opens, and
// the app has no setting to change that default. Instead of fighting its UI,
// this clamps flash and torch requests at the AVFoundation layer, inside the
// ChatGPT process only (see NoFlashGPT.plist). ChatGPT's flash button may
// still show Auto; the LED just never fires.
//
// Written against iOS 17.0. Both hooked classes live in AVFCapture on iOS 17:
// AVCapturePhotoSettings is public API (iOS 10+), and AVCaptureFigVideoDevice
// is the private concrete class behind every camera AVCaptureDevice.
//
// Keep every orig call on its own line: upstream Logos drops whatever follows
// it on the same line (the bug that broke the NextUp3 and WhatAMess builds).

#import <AVFoundation/AVFoundation.h>
#import <objc/runtime.h>

// Real capture devices are instances of this private subclass, and it
// overrides the torch setters, so a hook on AVCaptureDevice itself never runs.
@interface AVCaptureFigVideoDevice : AVCaptureDevice
@end

// Photo flash. AVCapturePhotoOutput takes the flash mode from the settings
// object passed to capturePhotoWithSettings:delegate:, so pin it to Off.
%group Photo
%hook AVCapturePhotoSettings

- (void)setFlashMode:(AVCaptureFlashMode)mode {
    %orig(AVCaptureFlashModeOff);
}

- (AVCaptureFlashMode)flashMode {
    return AVCaptureFlashModeOff;
}

%end
%end

// Torch. Covers a camera that fakes flash by lighting the torch during
// capture, plus any other flashlight use inside ChatGPT.
%group Torch
%hook AVCaptureFigVideoDevice

- (void)setTorchMode:(AVCaptureTorchMode)mode {
    %orig(AVCaptureTorchModeOff);
}

- (BOOL)setTorchModeOnWithLevel:(float)level error:(NSError **)outError {
    return YES;
}

%end
%end

// Hook installation only. Nothing here touches UIKit, which isn't safe from a
// dylib constructor (the WhatAMess crash-at-launch). Each group installs only
// if its class is actually present, so a missing class means that hook is
// skipped, never a crash inside ChatGPT.
%ctor {
    if (objc_getClass("AVCapturePhotoSettings")) {
        %init(Photo);
    }
    if (objc_getClass("AVCaptureFigVideoDevice")) {
        %init(Torch);
    }
}
