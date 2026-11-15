<p align="center">
  <img src="docs/banner.svg" alt="WalletFX — an animated credit card experience, built with Flutter" width="100%" />
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-3.9+-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart 3.9+" />
  <img src="https://img.shields.io/badge/Material-3-7C4DFF?style=for-the-badge&logo=materialdesign&logoColor=white" alt="Material 3" />
  <img src="https://img.shields.io/badge/Platforms-Android%20%7C%20Web%20%7C%20Windows-1C1C1E?style=for-the-badge" alt="Platforms: Android, Web, Windows" />
</p>

<p align="center">
  <a href="https://github.com/HammasT1/WalletFX/releases/latest"><img src="https://img.shields.io/github/v/release/HammasT1/WalletFX?style=for-the-badge&label=Download%20APK&logo=android&logoColor=white&color=3DDC84" alt="Download the latest APK" /></a>
  <a href="https://github.com/HammasT1/WalletFX/actions/workflows/release-apk.yml"><img src="https://img.shields.io/github/actions/workflow/status/HammasT1/WalletFX/release-apk.yml?style=for-the-badge&label=APK%20build&logo=githubactions&logoColor=white" alt="APK build status" /></a>
</p>

<p align="center">
  <a href="#-demo">Demo</a> ·
  <a href="#-download">Download</a> ·
  <a href="#-features">Features</a> ·
  <a href="#-gestures">Gestures</a> ·
  <a href="#-animation-breakdown">Animations</a> ·
  <a href="#-theme-library">Themes</a> ·
  <a href="#-project-structure">Structure</a> ·
  <a href="#-getting-started">Getting Started</a> ·
  <a href="#-releasing-a-new-version">Releasing</a>
</p>

---

## 💡 About

**WalletFX** is a Flutter app built around one thing: a credit card that feels good to touch. The card flips in 3D, tilts under your finger, catches a sweep of light, and reveals its digits one flip at a time, all on a dark interface whose ambient glow follows the theme you pick.

It is a UI and motion showcase. The card details are placeholder data, and nothing is stored or sent anywhere.

---

## 🎬 Demo

<p align="center">
  <img src="assets/WalletFX_GIF.gif" alt="WalletFX in motion" width="300" />
</p>

<table align="center">
  <tr>
    <th>Front</th>
    <th>Themed</th>
    <th>Back</th>
    <th>Saved looks</th>
  </tr>
  <tr>
    <td><img src="App%20Front.png" alt="Card front" width="200" /></td>
    <td><img src="App%20Front%202.png" alt="Card front with another theme" width="200" /></td>
    <td><img src="App%20Back.png" alt="Card back" width="200" /></td>
    <td><img src="App%20Save%20Feature.png" alt="Saved looks row" width="200" /></td>
  </tr>
</table>

---

## 📲 Download

Want to try the app without building it? Grab the ready-made Android APK:

1. Open the [latest release](https://github.com/HammasT1/WalletFX/releases/latest).
2. Under **Assets**, download `WalletFX-vX.Y.Z.apk`.
3. Open the file on your Android phone and allow installs from that source when asked.

Every APK there is built automatically by [GitHub Actions](.github/workflows/release-apk.yml) from the tagged source code.

---

## ✨ Features

| | Feature | What it does |
| :---: | :--- | :--- |
| 🔄 | **3D card flip** | Tap the card to rotate it around the Y axis with real perspective and a slight overshoot. |
| 🖐️ | **Touch tilt** | Drag across the card and it leans toward your finger, then settles back when you let go. |
| ✨ | **Shine sweep** | A band of light crosses the card on entry and every time the theme changes. |
| 👁️ | **Number peek** | The eye button reveals the masked digits with a staggered flip; the last four stay visible. |
| 🔐 | **CVV reveal** | Tap the CVV box on the back to show or hide the code. |
| 🎨 | **Theme library** | Five gradient themes, each paired with a card network logo. |
| 🔖 | **Save this look** | Bookmark themes into an animated row, tap one to apply it, long-press to remove it. |
| 🌌 | **Ambient glow** | The blurred background glow cross-fades to match the selected theme. |
| 📳 | **Haptic feedback** | Light haptics on theme selection, saving, and removal. |
| 📐 | **Responsive layout** | The card keeps the standard 1.586 aspect ratio and caps its width on large screens. |

---

## 👆 Gestures

| Gesture | Where | Result |
| :--- | :--- | :--- |
| **Tap** | Card | Flip between front and back |
| **Drag** | Card | Tilt in 3D, following your finger |
| **Tap** | Eye icon (front) | Peek or hide the full card number |
| **Tap** | CVV box (back) | Show or hide the CVV |
| **Tap** | Theme swatch | Switch the card gradient and background glow |
| **Tap** | *Save this look* | Add the current theme to your saved row |
| **Tap** | Saved thumbnail | Apply that look again |
| **Long-press** | Saved thumbnail | Remove it from the row |

---

## 🎥 Animation Breakdown

Every motion in the app is hand-tuned. The card itself is driven by three explicit `AnimationController`s merged into a single `AnimatedBuilder`; the rest uses Flutter's implicit animations.

| Animation | Duration | Curve | Technique |
| :--- | :---: | :--- | :--- |
| Card entry (fade, lift, scale) | 900 ms | `easeOutCubic` | `AnimationController` + `Transform` |
| Shine sweep | 10–85% of entry | `easeInOut` | `Interval` on the entry controller |
| Card flip | 700 ms | `easeInOutBack` | `Matrix4` with perspective, `rotateY` 0 → π |
| Touch tilt | follows the finger | — | `rotateX` / `rotateY` from the pan position |
| Number peek | 760 ms | `easeInOutCubic`, staggered per digit | Per-digit 3D flip |
| Card gradient change | 500 ms | `easeOutCubic` / `easeInCubic` | `AnimatedSwitcher` |
| Ambient glow change | 520 ms | `easeOutCubic` / `easeInCubic` | `AnimatedSwitcher` + `BackdropFilter` blur |
| Swatch selection | 180–220 ms | `easeOut` | `AnimatedScale`, `AnimatedContainer`, `AnimatedOpacity` |
| CVV and eye icon swap | 220 ms | `easeOutCubic` / `easeInCubic` | `ScaleTransition` + `FadeTransition` |
| Saved look insert | list default | `easeOutBack` | `AnimatedList` with size, fade and scale |
| Saved look removal | 280 ms | linear | `AnimatedList.removeItem` |

<details>
<summary><b>How the 3D flip works</b></summary>
<br />

Both faces of the card sit in the same `Stack`. Each gets a `Matrix4` with a perspective entry, the current tilt, and a Y rotation. The back face is offset by π, so it is always the mirror of the front, and the face that is pointing away from the viewer is hidden at the halfway mark.

```dart
final baseMatrix = Matrix4.identity()
  ..setEntry(3, 2, 0.0015)      // perspective
  ..rotateX(_tiltOffset.dy)     // touch tilt
  ..rotateY(_tiltOffset.dx);

final frontMatrix = baseMatrix.clone()..rotateY(flipValue);
final backMatrix  = baseMatrix.clone()..rotateY(flipValue + math.pi);
```

</details>

---

## 🎨 Theme Library

<p align="center">
  <img src="docs/themes.svg" alt="The five WalletFX card themes" width="100%" />
</p>

| Theme | Gradient | Network |
| :--- | :--- | :--- |
| **Midnight Purple** | `#0F0C29` → `#302B63` → `#24243E` | Visa |
| **Sunset Orange** | `#FF512F` → `#F09819` | Mastercard |
| **Ocean Blue** | `#2193B0` → `#6DD5ED` | American Express |
| **Emerald Green** | `#134E5E` → `#71B280` | Discover |
| **Rose Gold** | `#B76E79` → `#E8C4C4` | Visa |

Adding a theme is one entry in [lib/models/card_gradient_theme.dart](lib/models/card_gradient_theme.dart):

```dart
CardGradientTheme(
  name: 'Arctic Mint',
  colors: [Color(0xFF00B09B), Color(0xFF96C93D)],
  assetPath: 'assets/visa.svg',
),
```

---

## 🧱 Tech Stack

| Layer | Choice |
| :--- | :--- |
| **Framework** | Flutter, Material 3, dark theme |
| **Language** | Dart `^3.9.2` |
| **State** | `StatefulWidget` + `setState`, no external state library |
| **Animation** | Explicit `AnimationController`s, `Matrix4` transforms, implicit animated widgets, `AnimatedList` |
| **Drawing** | `CustomPainter` for the card surface and chip |
| **Assets** | SVG network logos rendered with [`flutter_svg`](https://pub.dev/packages/flutter_svg) |

---

## 📂 Project Structure

```text
lib/
├── main.dart                        # App shell, theme library, saved looks, ambient glow
├── models/
│   └── card_gradient_theme.dart     # Theme model and the five built-in gradients
├── utils/
│   └── card_number_formatter.dart   # Groups card digits in blocks of four
└── widgets/
    ├── credit_card_widget.dart      # Card faces, flip, tilt, peek, shine, chip
    ├── card_painter.dart            # CustomPainter for the card surface
    └── gradient_swatch_picker.dart  # Animated theme swatches

assets/                              # Network logos (SVG), app icon, demo GIF
docs/                                # README artwork
.github/workflows/release-apk.yml    # Builds and publishes the APK on every version tag
```

---

## 🚀 Getting Started

**Prerequisites:** the [Flutter SDK](https://docs.flutter.dev/get-started/install), version 3.35.4 (Dart 3.9.2). This is the version the project and its release workflow are built with.

```bash
# 1. Clone the repository
git clone https://github.com/HammasT1/WalletFX.git

# 2. Move into the project
cd WalletFX

# 3. Install dependencies
flutter pub get

# 4. Run on a connected device or emulator
flutter run
```

Run on a specific platform:

```bash
flutter run -d chrome     # Web
flutter run -d windows    # Windows desktop
```

Build a release APK:

```bash
flutter build apk --release
```

---

## 📦 Releasing a New Version

Pushing a version tag is all it takes. The [Release APK](.github/workflows/release-apk.yml) workflow builds the APK, creates a GitHub Release for the tag, and attaches `WalletFX-vX.Y.Z.apk` to it.

```bash
# 1. Make sure everything you want in the release is committed and pushed
git push origin main

# 2. Create an annotated tag (the version after "v" becomes the app version)
git tag -a v1.0.0 -m "WalletFX v1.0.0"

# 3. Push the tag to GitHub, which starts the build
git push origin v1.0.0
```

A few minutes later the APK appears on the [Releases](https://github.com/HammasT1/WalletFX/releases) page. You can follow the build in the [Actions](https://github.com/HammasT1/WalletFX/actions) tab.

Tags must start with `v` (`v1.0.0`, `v1.1.0`, `v2.0.0-beta.1`) to trigger the workflow. To redo a release, delete the tag and push it again:

```bash
git tag -d v1.0.0                  # delete the tag locally
git push origin --delete v1.0.0    # delete the tag on GitHub
```

The workflow can also be started by hand from the Actions tab with **Run workflow**. A manual run does not create a release; the APK is saved as a downloadable artifact on that run.

---

## 👤 Author

**Muhammad Hammas Rasheed** — [@HammasT1](https://github.com/HammasT1)

If WalletFX was useful or fun to play with, a ⭐ on the repo is appreciated.
