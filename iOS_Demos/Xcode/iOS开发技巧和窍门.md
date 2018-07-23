## 1. Track build time in Xcode

If you don’t know the exact build time of your project, enable the following option in Xcode.

```
defaults write com.apple.dt.Xcode ShowBuildOperationDuration -bool YES

```

## 2. Improve your Swift project build time

The Xcode 9.2 release notes mentioned an experimental feature that may improve Swift build times, enabled with the “BuildSystemScheduleInherentlyParallelCommandsExclusively” user default.

```
defaults write com.apple.dt.Xcode BuildSystemScheduleInherentlyParallelCommandsExclusively -bool NO
```

Note: According to the release notes it’s an experimental feature which can “increase memory use during the build”

## 3. Use Simulator in full-screen mode with Xcode

Being able to run Xcode and iOS simulator together in full screen mode is probably my favorite feature of Xcode 9. You can just execute the following command in the terminal to enable this feature:

```
defaults write com.apple.iphonesimulator AllowFullscreenMode -bool YES
```

If you want to use more secret features in Simulator you should enable Apple hidden Internals menu. To do so you need to create an empty folder with name “AppleInternal” in the root directory. Just run this command below and restart Simulator:

```
sudo mkdir /AppleInternal
```

The new menu item should show up.

## 4. Capture iOS Simulator video

You can take a screenshot or record a video of the simulator window using the xcrun command-line utility. To record a video, execute the following command

```
xcrun simctl io booted recordVideo <filename>.<file extension>.
```

For example:
```
xcrun simctl io booted recordVideo appvideo.mov
```

Press `control + c` to stop recording the video. The default location for the created file is the current directory

## 5. Share files to Simulator from Finder

From Xcode 9, Simulator has Finder extension which allows you to share files directly from the Finder’s window. However, drag & drop file to the Simulator’s window seems much faster.


However, You can do something similar with image/video files using the simctl command below:


```
xcrun simctl addmedia booted <PATH TO FILE>
```

## 6. Use your fingerprint to sudo

If you want to use your fingerprint as your sudo password on Macbook Pro edit `/etc/pam.d/sudo` and add the following line to the top

```
auth sufficient pam_tid.so
```

You can now use your fingerprint to sudo.

## 7. Debug your AutoLayout constraints with Sound Notification


And this is a great way to debug your AutoLayout constraints. Just pass UIConstraintBasedLayoutPlaySoundOnUnsatisfiable argument on launch and it’s plays sounds when constraints are screwed at runtime.

```
-_UIConstraintBasedLayoutPlaySoundOnUnsatisfiable YES
```

## 8. Remove unavailable simulators from Xcode

This little command will remove all unavailable simulators from Xcode. Here “unavailable” means unavailable to xcode-select’s version of Xcode.

```
xcrun simctl delete unavailable
```
What are your favorites? Please add in comment section.


