# muzy — Design Tokens & SwiftUI Mapping

All values are from the HTML reference (`tokens.css` + `app.css`). Light-mode hex are listed; define **dark** equivalents from the same Radix step in the dark palette so the app follows the system appearance (spec §11). Source: [Radix Colors](https://www.radix-ui.com/colors) — accent = **indigo**, gray = **default gray**, plus **gold / jade / amber / red** for semantics.

---

## 1. Color steps used (Radix, light)

### Indigo (accent)
| Step | Hex | Used for |
|---|---|---|
| indigo-3 (a3) | `#EDF2FE` (~8% alpha) | soft selection (Artists), Preferences active tab, empty glyph bg |
| indigo-9 | `#3E63DD` | **primary**: solid buttons, table selection, now-playing eq, toggles on, progress fill |
| indigo-10 | `#3358D4` | solid button hover |
| indigo-11 | `#3A5BC7` | accent text & icons, links |
| indigo-12 | `#1F2D5C` | (reserved, high-contrast accent text) |

### Gray (neutral)
| Step | Hex | Used for |
|---|---|---|
| gray-1 | `#FCFCFC` | dark-mode window bg / zebra base |
| gray-2 | `#F9F9F9` | panel-solid (dark) |
| gray-3 | `#F0F0F0` | placeholder cover bg |
| gray-4 | `#E8E8E8` | cover fallback |
| gray-8 | `#BBBBBB` | lossy dot, placeholder glyph |
| gray-10 | `#838383` | `fgTertiary` |
| gray-11 | `#646464` | `fgSecondary` |
| gray-12 | `#202020` | `fgPrimary` |
| gray-a1…a8 | black at ~2/4/6/8/10/16/… % | zebra, hover, hairlines, borders, input shadows |

### Semantic quality colors
| Tier | Dot hex | Text hex | Radix |
|---|---|---|---|
| Hi-Res | `#978365` | `#71624B` | gold-9 / gold-11 |
| Lossless | `#29A383` | `#208368` | jade-9 / jade-11 |
| Lossy | `#BBBBBB` | `#646464` | gray-8 / gray-11 |
| Warning / unavailable | `#FFC53D` | `#AD5700` | amber-9 / amber-11; banner text amber-12 `#4F3422` |
| Destructive | — | `#CE2C31` | red-11 (alert badge bg = red-9 `#E5484D`) |

### Surfaces
| Token | Light | Notes |
|---|---|---|
| `windowBg` / `color-background` | `#FFFFFF` | content area |
| `sidebarBg` | `#F6F6F8` | under vibrancy; in SwiftUI prefer `.regularMaterial` and skip the literal |
| `panelSolid` | `#FFFFFF` | dialogs/sheets |
| `panelTranslucent` | `rgba(255,255,255,0.7)` | sheet footer |
| `overlay` | `black-a6` (~30% black) | modal scrim |

> **Native shortcut**: for the sidebar, player, and context-menu backgrounds, use SwiftUI `Material` (`.regularMaterial` / `.bar`) instead of these literals — it gives correct vibrancy in both appearances for free. Use the literals only as the fallback solid color.

---

## 2. Spacing — 4px scale

`4 · 8 · 12 · 16 · 24 · 32 · 40 · 48 · 64`

Common usages: row vertical padding 6–7, content padding 18–22, hero padding 24–28, card gaps 18–22, sidebar item height 28, table row height 30.

## 3. Radius (medium mode)

`radius-1 3 · radius-2 4 · radius-3 6 · radius-4 8 · radius-5 12 · radius-6 16`

Sidebar items / segmented 4 · table rows 4–6 · cover thumbs 3–4 · cards 6–8 · hero art 12 · dialogs & sheets 12 · avatars `.full` (circle).

## 4. Type scale

System font. Sizes (px) / weight:
`12 · 14 · 16 · 18 · 20 · 24 · 28 · 35 · 60`, weights light 300 / regular 400 / medium 500 / bold 700. Letter-spacing tightens at large sizes (≈ -0.01em at 32–35, -0.025em at 60).

| Role | px / weight |
|---|---|
| Hero title | 32–34 / 700 |
| Screen H1 | 22 / 700 |
| Section title | 16 / 700 |
| Inspector title | 17 / 700 |
| Body / row | 13 / 400–500 |
| Secondary | 12–13 / 400 |
| Label / caption | 11 / 500 (often UPPERCASE +0.04em) |
| Hi-Res pill | 9 / 700 UPPERCASE +0.04em |

Tabular figures (`.monospacedDigit()`) on all numbers.

## 5. Shadows / elevation

| Token | Role | SwiftUI |
|---|---|---|
| shadow-1 | input inset hairline | `.overlay(RoundedRectangle().stroke(borderSubtle))` |
| shadow-2 | card / cover | `.shadow(color: .black.opacity(0.10), radius: 3, y: 1)` |
| shadow-3 | hover / dropdown | `.shadow(color: .black.opacity(0.14), radius: 12, y: 4)` |
| shadow-5/6 | dialog / sheet / menu | free from `.sheet`, `Menu`, `Settings`, `.alert` |

## 6. Motion

Curve `cubic-bezier(0.16, 1, 0.3, 1)` ≈ `.spring(response: 0.35, dampingFraction: 0.85)` or `.easeOut`. Open 160ms / close 100ms. Honor `accessibilityReduceMotion`. Only ambient motion = now-playing equalizer (~0.9s loop), frozen under Reduce Motion.

---

## 7. SwiftUI Color scaffold (paste & adjust)

Define color sets in an **Asset Catalog** with Any/Dark appearances, then expose them semantically. Example using code-defined colors (replace with asset-backed colors for proper dark mode):

```swift
import SwiftUI

extension Color {
    // Accent (Radix Indigo)
    static let mzAccent       = Color(red: 0.243, green: 0.388, blue: 0.867) // #3E63DD indigo-9
    static let mzAccentHover  = Color(red: 0.200, green: 0.345, blue: 0.831) // #3358D4 indigo-10
    static let mzAccentText   = Color(red: 0.227, green: 0.357, blue: 0.780) // #3A5BC7 indigo-11

    // Text (gray)
    static let mzFgPrimary    = Color(red: 0.125, green: 0.125, blue: 0.125) // #202020 gray-12
    static let mzFgSecondary  = Color(red: 0.392, green: 0.392, blue: 0.392) // #646464 gray-11
    static let mzFgTertiary   = Color(red: 0.514, green: 0.514, blue: 0.514) // #838383 gray-10

    // Quality tiers
    static let mzHiRes        = Color(red: 0.592, green: 0.514, blue: 0.396) // #978365 gold-9
    static let mzHiResText    = Color(red: 0.443, green: 0.384, blue: 0.294) // #71624B gold-11
    static let mzLossless     = Color(red: 0.161, green: 0.639, blue: 0.514) // #29A383 jade-9
    static let mzLosslessText = Color(red: 0.125, green: 0.514, blue: 0.408) // #208368 jade-11
    static let mzLossy        = Color(red: 0.733, green: 0.733, blue: 0.733) // #BBBBBB gray-8
    static let mzWarn         = Color(red: 1.000, green: 0.773, blue: 0.239) // #FFC53D amber-9
    static let mzWarnText     = Color(red: 0.678, green: 0.341, blue: 0.000) // #AD5700 amber-11
    static let mzDestructive  = Color(red: 0.808, green: 0.173, blue: 0.192) // #CE2C31 red-11

    // Surfaces — prefer Material in views; these are fallbacks
    static let mzWindowBg     = Color(NSColor.textBackgroundColor)   // ≈ white / dark
    static let mzSidebarBg    = Color(NSColor.windowBackgroundColor) // under .regularMaterial
}

enum MZRadius { static let item: CGFloat = 4, card: CGFloat = 8, hero: CGFloat = 12, dialog: CGFloat = 12 }
enum MZSpace { static let s1: CGFloat = 4, s2 = 8, s3 = 12, s4 = 16, s5 = 24, s6 = 32 }
```

> The hardcoded RGB above is for quick spikes only. For shipping, create **Color Sets in `Assets.xcassets`** with explicit light + dark values (pull the dark steps from Radix's dark palette), and reference them by name — that's what gives you correct automatic dark mode (spec §11 mandates Asset Catalog management).

### Quality pill example

```swift
struct HiResPill: View {
    var body: some View {
        Text("HI-RES")
            .font(.system(size: 9, weight: .bold))
            .tracking(0.4)
            .foregroundStyle(Color.mzHiResText)
            .padding(.horizontal, 5).frame(height: 15)
            .background(Color.mzHiRes.opacity(0.12), in: RoundedRectangle(cornerRadius: 3))
            .overlay(RoundedRectangle(cornerRadius: 3).stroke(Color.mzHiRes.opacity(0.4), lineWidth: 0.5))
    }
}
```
