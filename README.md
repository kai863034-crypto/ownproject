# FreeFireFileManager

A small SwiftUI iOS 26-compatible starter project for replacing a file inside a directory that the user explicitly grants access to through the iOS Files/document picker.

## What it does

- Pick an accessible folder using the iOS document picker.
- Pick a replacement file.
- If a same-named destination file exists, create a `.backup` copy first.
- Copy the replacement file into the selected folder.
- Show success/error status.

## Important limitation

A normal iOS app cannot automatically access another app's private container. This project intentionally does not bypass iOS sandbox protections, exploit vulnerabilities, or modify protected Free Fire data.

## Xcode setup

1. Open Xcode on macOS.
2. Create a new **iOS App** project named `FreeFireFileManager`.
3. Select **SwiftUI** and **Swift**.
4. Replace the generated Swift files with the files in this folder.
5. Set the deployment target to iOS 26 (or a compatible target available in your Xcode).
6. Build and run on a device/simulator.

For App Store distribution, review Apple's current file-access and entitlement requirements.
