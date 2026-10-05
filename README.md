# NoFlashGPT

Rootless tweak for iOS 17.0 that keeps the ChatGPT app's camera flash off.
ChatGPT's in-app camera resets to Auto flash every time it opens; this pins the
flash mode to Off at the AVFoundation layer, inside ChatGPT only. It also blocks
ChatGPT from turning on the torch. Control Center's flashlight is untouched.

- Filter: `com.openai.chat`
- Hooks: `AVCapturePhotoSettings` flash mode, `AVCaptureFigVideoDevice` torch setters
- Arch: arm64 only. iOS 17.0 runs App Store apps as arm64, and the Linux
  toolchain's arm64e slice is unsafe on this device. CI refuses to publish a deb
  that contains an arm64e slice.
- Build: push to `main`. GitHub Actions builds the rootless deb and publishes it
  under Releases.

ChatGPT's flash button may still show Auto. The LED won't fire.
