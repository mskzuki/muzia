# Handoff: muzy — macOS Music App UI

## Overview

**muzy** is a local-first, lightweight, audio-quality-focused macOS music player. This handoff covers the complete v1.0 UI: library browsing (Songs / Albums / Artists / Genres), detail views (Artist / Album / Playlist), search & editing (incremental search, context menu, multi-select bulk edit), and edge/system states (empty library, import progress, missing files, duplicate review, data-error alert, Preferences window).

The design follows the product specs: **macOS HIG-native, "subtraction" minimalism, smart defaults over settings, full light/dark support, and a tasteful emphasis on audio quality (Hi-Res / Lossless).**

---

## About the Design Files

The files in `reference_html/` are **design references created in HTML/CSS/React** — prototypes that show the intended look, layout, and behavior. **They are not production code to port directly.**

The target environment is **SwiftUI on macOS** (per the product specs: SwiftUI, MVVM-ish ViewState, SQLite/GRDB, AVAudioEngine). Your task is to **recreate these designs natively in SwiftUI**, using AppKit/SwiftUI's built-in components wherever they match — `NavigationSplitView`, `Table`, `.searchable`, `.contextMenu`, the `Settings` scene, `.alert`, `.sheet`, and `Material` backgrounds for vibrancy. Reach for native controls first; only fall back to custom views when the design genuinely diverges from a stock control.

The HTML mocks intentionally hand-draw some chrome (traffic-light buttons, toolbar, scrollbars) that you get **for free** from the OS — do not reimplement those. They exist only to make the mock read as a Mac window.

## Fidelity

**High-fidelity.** Colors, typography, spacing, and component states are final and intentional. Recreate the UI to match — but prefer native macOS materials and system metrics where the mock approximates them (e.g. sidebar vibrancy, menu blur, focus rings). When a hardcoded value in the mock conflicts with a standard macOS metric, **trust the platform**.

---

## Design Language System

Before building screens, establish these foundations as reusable SwiftUI primitives.

### Layout skeleton

```
┌─────────────────────────────────────────────────────────────┐
│ Toolbar (unified, 52px)   ‹ › | Title · count   …   [search] │  ← .toolbar on NavigationSplitView
├──────────┬──────────────────────────────────┬───────────────┤
│ Sidebar  │ Content (Table / grid / detail)  │ Inspector     │
│ 224px    │ flexible                         │ 300px         │  ← NavigationSplitView 3-column
│ vibrant  │ white / system bg                │ optional      │
├──────────┴──────────────────────────────────┴───────────────┤
│ Player (footer, 74px)  cover · title  | transport | quality  │  ← custom bar, always present
└─────────────────────────────────────────────────────────────┘
```

- **Window**: 1280×800 design size, min ~1040×640. Standard titlebar with **unified toolbar** (`.toolbar` + `.toolbarBackground`). The sidebar/inspector are `NavigationSplitView` columns; the player is a fixed bottom bar outside the split (e.g. the split view in a `VStack` above the player).
- **Sidebar**: translucent (`.regularMaterial` / sidebar material). Width 224px. Two sections: **Library** (Songs/Artists/Albums/Genres with item counts) and **Playlists**.
- **Content**: opaque window background (`white` light / `gray-1` dark).
- **Inspector**: 300px trailing column, opaque. Only used for Album Info now — single-song tag editing moved to a centered dialog (see Songs section).
- **Player**: 74px fixed bottom bar, vibrant material matching the sidebar.

### Color — accent + grays

The app uses the **Radix Indigo** accent on a **neutral gray** scale. Implement as **Asset Catalog color sets with light + dark variants** so the app follows the system appearance automatically (spec §11). Define a semantic layer; never scatter raw hex in views.

| Semantic name | Role | Light hex | Source step |
|---|---|---|---|
| `accent` | primary actions, selection, now-playing | `#3E63DD` | indigo-9 |
| `accentHover` | hover/pressed solid | `#3358D4` | indigo-10 |
| `accentText` | accent-colored text/icons | `#3A5BC7` | indigo-11 |
| `fgPrimary` | body text | `#202020` | gray-12 |
| `fgSecondary` | secondary text | `#646464` | gray-11 |
| `fgTertiary` | placeholder / metadata | `#838383` | gray-10 |
| `windowBg` | content background | `#FFFFFF` | white |
| `sidebarBg` | sidebar / player (under vibrancy) | `#F6F6F8` | custom |
| `rowStripe` | even-row zebra | `gray-a1` (~2% black) | gray alpha |
| `rowHover` | row hover | `gray-a3` (~6% black) | gray alpha |
| `borderSubtle` | hairlines / dividers | `gray-a6` (~16% black) | gray alpha |

Selection: solid `accent` background, white text (`#FFFFFF`), white icons.

**Audio-quality accent colors** (used for the quality column, badges, and dots):

| Tier | Dot / pill color | Light hex | Source |
|---|---|---|---|
| Hi-Res (>16-bit / >48kHz) | warm gold | dot `#978365`, text `#71624B` | gold-9 / gold-11 |
| Lossless (FLAC/ALAC 16/44.1) | jade/teal | dot `#29A383`, text `#208368` | jade-9 / jade-11 |
| Lossy (AAC/MP3) | neutral gray | dot `gray-8` `#BBBBBB` | gray-8 |
| Warning / unavailable | amber | dot `#FFC53D`, text `#AD5700` | amber-9 / amber-11 |
| Destructive | red | text `#CE2C31` | red-11 |

The **"Hi-Res" pill** is a small uppercase chip: gold-a3 background (~12% gold), gold-11 text, 0.5px gold-a6 inset border, radius 3px, font 9px/700 uppercase, letter-spacing 0.04em.

### Typography

System font throughout (`SF Pro` → use `.font(.system(...))`; do **not** ship a custom font). The mock's `--default-font-family` is just the web equivalent of the system stack.

| Token | Size / weight | Used for |
|---|---|---|
| Window title | 14 / bold (`.headline`) | toolbar title |
| Screen H1 | 22 / bold (`.title2`-ish) | content headers (Albums, Artists, Genres) |
| Hero H1 | 32–34 / bold, tracking -0.01em (`.largeTitle`) | Playlist / Artist / Album hero titles |
| Body / row | 13 / regular (`.callout`-ish, `.body` at 13) | table rows, list items |
| Row title | 13 / medium | song titles |
| Secondary | 12–13 / regular, `fgSecondary` | artist/album sub-text |
| Label / caption | 11 / medium, `fgTertiary`, sometimes UPPERCASE +0.04em | column headers, section labels, kicker |
| Numerics | tabular figures | track #, durations, sample rates, sizes, counts |

Apply `.monospacedDigit()` to every duration, track number, sample-rate, file-size, and count.

### Spacing & radius

4px-based scale: **4 / 8 / 12 / 16 / 24 / 32 / 40 / 48 / 64**. Radius (medium mode): **3 / 4 / 6 / 8 / 12 / 16**. Common: row radius 4–6, cards 6–8, hero art 12, dialogs 12, sidebar items 4.

### Shadows / elevation

- Inputs: inset hairline (`shadow-1`).
- Cards / cover art: subtle (`shadow-2`); hover lifts to `shadow-3`.
- Dialogs / sheets / context menu: deep (`shadow-5`/`shadow-6`). In SwiftUI these mostly come free from `.sheet`, `Menu`, and `Settings`.

### Motion

Spring-like `cubic-bezier(0.16, 1, 0.3, 1)`, open 160ms / close 100ms. Use the default SwiftUI transitions for sheets/menus; honor **Reduce Motion**.

---

## Screens / Views

> Reference: open `reference_html/design_canvas.html` to see all 19 frames laid out on a canvas. Each frame is a 1280×800 window. **Static PNGs of every screen are in `screenshots/`** (numbered to match the list below) — use those for a quick visual reference without running the prototype.

### Screenshot index (`screenshots/`)
`01-songs` · `02-albums` · `03-artists` · `04-genres` · `05-artist-detail` · `06-album-detail` · `07-playlist` · `08-empty` · `09-import` · `10-missing` · `11-duplicate` · `12-error` · `13-preferences` · `14-search` · `15-context-menu` · `16-song-edit` · `17-multi-select` · `18-bulk-dialog` · `19-bulk-confirm`

> **Album bulk-edit is a three-frame flow** (§14): `17-multi-select` (selection bar appears) → `18-bulk-dialog` (the album-info **dialog** opens, centered over a dimmed window) → `19-bulk-confirm` (confirm dialog before applying).

### 1. Songs (Table) + Song Edit Dialog
- **Purpose**: the main library list; browse/sort/select/play tracks. Tag editing for a single song is **no longer an Inspector drawer** — it's a centered modal dialog opened from the right-click context menu.
- **Layout**: full-width `Table`, no trailing inspector column. Columns: **#** (40px, right, tabular) · **Title** (sortable; each row has a 22px cover thumbnail) · **Artist** · **Album** · **♥** (favorite, narrow) · **Quality** (150px) · **Time** (56px, right, tabular). Sticky header, 30px rows, zebra striping (`rowStripe` on even rows), hover `rowHover`.
- **Now-playing row**: title text in `accentText`; the **# cell swaps to a 3-bar animated equalizer**.
- **Selected row**: solid `accent` fill, white text/icons.
- **Quality cell**: colored tier dot + format (e.g. "FLAC") + rate ("96/24 kHz") + optional gold "Hi-Res" pill.
- **Favorite (♥) column**: filled accent heart on favorited tracks; empty otherwise.
- **Toolbar**: a trailing **⋯** (more) button; the search field is shown focused (placeholder text "midnight").
- **Context menu** (right-click a row, `screenshots/15-context-menu.png`): just **曲を再生 / 曲を編集…(⌘I) / ライブラリから削除…** (destructive, red) — pared down from the old full menu.
- **Song Edit Dialog** (`screenshots/16-song-edit.png`, source: `screens2.jsx` `SongDialog`/`SongEditScreen`): a centered modal (~470px) over a dimmed window, same chrome family as the album bulk-edit dialog. Header: small cover + song/album identity. Fields: **曲名** (focused, with caret) · **アーティスト** · **アルバム** (2-col) · **トラック / リリース年** (narrow, 96px each) · **ジャンル** (text + suggestion chips). No comment field, no per-field "Edited" badges. Footer: **キャンセル** / **保存**.
- **SwiftUI**: `Table` with `TableColumn`s and `.contextMenu`; the edit dialog is a `.sheet` with plain `TextField`s, mirroring the bulk-edit sheet's structure. Drop `.inspector(isPresented:)` for this screen entirely.

### 2. Albums (Grid)
- **Purpose**: browse albums as artwork.
- **Layout**: 5-column grid, 22×20px gaps, 18–22px padding. Card = square cover (radius 8, `shadow-2`, lifts on hover) + album name (12.5/medium) + artist (12/secondary) + a footer row with year (left) and a tier badge (right: "Hi-Res" pill or jade "Lossless").
- **Toolbar**: grid/list segmented toggle (grid active). A content header with "Albums", count + sort description, and a "Sort" button.
- **SwiftUI**: `LazyVGrid` with adaptive/fixed columns inside a `ScrollView`. Segmented control = `Picker(.segmented)`.

### 3. Artists (List)
- **Purpose**: browse artists.
- **Layout**: rows, 7px vertical padding, 18px horizontal. Each: 46px circular avatar (`shadow-2`) + name (14/medium) + meta ("3 albums · 41 songs", 12/secondary) + trailing chevron. Hover `gray-a2`; selected `accent-a3` (soft tint, not solid).
- **SwiftUI**: `List` with custom rows, or `Table` single-column. Selected state here is a **soft** accent tint (use `accent` at ~12% alpha), distinct from the Songs table's solid selection.

### 4. Genres (Mosaic)
- **Purpose**: browse genres.
- **Layout**: 3-column grid. Each tile = 16:10 mosaic of **4 cover thumbnails** (2×2) with a dark bottom gradient scrim and the genre name overlaid bottom-left (17/bold, white, text-shadow). Song count below (12/tertiary).
- **SwiftUI**: `LazyVGrid`; mosaic is a 2×2 grid clipped to a rounded rect with a `LinearGradient` overlay and overlaid `Text`.

### 5. Artist Detail
- **Purpose**: one artist's albums + top songs.
- **Layout**: hero (124px circular avatar + kicker "ARTIST" + 34px name + meta line + Play/Shuffle/♥ actions), then **Albums** section (4-up horizontal cards) and **Top Songs** section (numbered rows: index, 28px cover, title, album, duration).
- **SwiftUI**: `ScrollView` + sections. Hero title is single-line, truncating.

### 6. Album Detail
- **Purpose**: one album's tracklist.
- **Layout**: hero (184px square cover + kicker "ALBUM" + 32px title + artist + meta "2024 · 11 songs · 44 min" + "Hi-Res" pill + Play/Shuffle), then a simplified tracklist `Table` with columns **# / Title / ♥ / Time** — no artist/album columns (implied by the album). The now-playing row swaps its # for the equalizer; favorited tracks show the accent heart. Toolbar has an inspector-toggle button; the Inspector variant shows **Album Info** + an **Album Summary** spec grid.
- **SwiftUI**: same `Table` patterns; fewer columns.

### 7. Playlist (Hi-Res Showcase)
- **Purpose**: a user playlist.
- **Layout**: hero (172px cover, radius 12 + kicker "PLAYLIST" + 33px name + description, max 470px + stat line "28 songs · 2 hr 14 min · 6.8 GB" + Play (solid) / Shuffle (soft) / ⋯ actions), then the tracklist Table (# / Title with inline artist / Album / Quality / Time).
- **SwiftUI**: `ScrollView`; the hero art and buttons pin above the `Table`.

### 8. Empty Library (First-run)
- **Purpose**: zero-state before any music is added.
- **Layout**: centered. 96px rounded accent-tinted glyph (music note), H2 "Your library is empty", explanatory paragraph (max 380px), a **drag-drop zone** (420×132, dashed border; **active/hot** state = accent border + accent-a2 fill + accent text), and actions "Add Folder…" (solid) + "Import from Music.app" (soft).
- **SwiftUI**: `ContentUnavailableView` is a great starting point, customized with the drop zone. Wire `.dropDestination` for folder drops.

### 9. Import Progress
- **Purpose**: scanning/analyzing a library.
- **Layout**: centered card (460px, `shadow-4`). Spinner + "Importing your library…" + sub-status ("Reading tags and analyzing audio · 62%") + Pause. Determinate progress bar. A stats row: **Imported / Remaining / Hi-Res found / Estimated** (big tabular numbers + caption labels). Current-file line at the bottom with a jade dot.
- **SwiftUI**: `ProgressView(value:)`; spinner is an indeterminate `ProgressView` or rotating symbol (freeze under Reduce Motion).

### 10. Missing / Unavailable Files
- **Purpose**: some tracks' files moved or were deleted since the last scan (spec: re-identify via `fileHash`; files are referenced in place, never copied).
- **Layout**: an **amber warning banner** under the toolbar — warning icon + "**3 songs are unavailable.** Their files moved or were deleted since the last scan." + "Locate…" / "Remove" actions + dismiss ✕. In the table, affected rows are **dimmed** (text → tertiary, mini-cover grayscaled to ~50%), the Quality cell shows an amber "Unavailable" flag, and Time shows "—".
- **SwiftUI**: derive row state from a `isAvailable` flag on the track. "Locate…" opens an `NSOpenPanel` to re-link; matching is by `fileHash`.

### 11. Duplicate Review (Sheet over Import)
- **Purpose**: during import, files matching existing songs (same `filePath`/`fileHash` — both UNIQUE in the schema) are flagged for review.
- **Layout**: a centered modal **sheet** (560px) over the dimmed import card. Header: amber icon + "4 duplicates found" + explanation ("…same audio fingerprint. muzy skips duplicates by default."). A list of duplicate rows (cover, title, source file path in tertiary mono-ish text) each with a **Skip / Import anyway** segmented control (Skip default; "Import anyway" highlights jade when chosen). Footer: summary "3 to skip · 1 to import" + "Apply to all ▾" + "Continue Import" (solid).
- **SwiftUI**: `.sheet`; per-row `Picker(.segmented)`; sheet is **window-modal** (attached), not a separate window.

### 12. Data Error Alert
- **Purpose**: the library database is damaged and can't be read (spec §9.3: data-corruption errors must be surfaced explicitly).
- **Layout**: a centered macOS **alert** (296px) over the dimmed/desaturated library. App icon with a red warning badge, title "muzy can't open your library", message ("…Your music files are untouched — rebuilding will re-scan them."), then stacked buttons: **Rebuild Library…** (primary/solid), **Quit** (secondary), **Show in Finder** (link).
- **SwiftUI**: use a real `.alert` / `NSAlert` — do **not** hand-build this; the mock only approximates the system alert. Map buttons to roles (default / cancel).

### 13. Preferences Window
- **Purpose**: settings live in a separate standard macOS Preferences window (spec §2.1; "smart defaults over settings" — keep it minimal).
- **Layout**: standalone 540px window with a **toolbar tab bar** (General / Library / Playback / Import, each icon + label; Library active = accent-a3 tint). Form uses right-aligned labels (168px) + controls: **Music folders** (removable path fields + "Add Folder…"), **Watch for changes** (toggle on + hint), **Keep files in place** (toggle on + hint), a divider, **When tags change** (radio group: "Update the library only" / "Also write tags back to files"), **Artwork** (pop-up button).
- **SwiftUI**: the `Settings` scene with `TabView(.tabBarStyle)`; `Toggle`, `Picker`, `Form`. Toggles/radios/menus are stock controls.

### 14. Album Bulk Edit (multi-select) — three-frame flow

> Screenshots: `17-multi-select.png` → `18-bulk-dialog.png` → `19-bulk-confirm.png`. Source: `reference_html/screens2.jsx` (`MultiSelectScreen`, `BulkEditScreen` → `AlbumDialog`, `BulkConfirmScreen`). **This is the source of truth for bulk tag editing.**

- **Purpose**: edit **album-level** tags across many selected songs at once. Deliberately narrow scope per product direction.
- **Scope (hard rule)**: only **Album name**, **Release year (YYYY)**, and **Genre** are bulk-editable. **Title and track number are excluded by design** (bulk-setting them would collapse distinct tracks into duplicates — the schema keeps `filePath`/`fileHash` UNIQUE and titles per-track). Artist is also not offered here. A persistent note states this verbatim: "曲名とトラック番号は、重複を避けるため一括編集できません。"

**Frame 1 — selection (`17-multi-select`)**
- When 2+ rows are selected, a **selection bar** drops in directly below the toolbar: light indigo (`accent-a3`) background, **"N 曲を選択中"** on the left, and on the right a single solid-indigo **"一括編集"** button (pencil icon). **There is no "select all" link.**
- The table here shows columns **# / Title / Artist / Album / Quality / Time / ⋮** — selected rows use the solid `accent` fill + white text, and every row carries a vertical **kebab (⋮)** in the far-right column. The now-playing row still swaps its # for the equalizer.

**Frame 2 — dialog (`18-bulk-dialog`)**
- Pressing **一括編集** opens a **centered modal dialog** (~440px) over a **dimmed window** (`--color-overlay` scrim) — not a side drawer, and the rest of the window is not interactive. Header: title **"アルバム情報の一括編集"** + close ✕; a **scope line** = an indigo chip **"N 曲を選択中"** + a source descriptor (e.g. `Parallel Lines` — the album name). Below the header sits the persistent exclusion note.
- **All four fields are always visible, each just a label + input — there are no per-field checkboxes.**
  - **アーティスト (Artist)**: text input, listed first — bulk-replaces the artist name across the selection.
  - **アルバム名 (Album name)**: text input (placeholder = current album name). Below it, a checkbox **"選択していない同じアルバムの曲も含めて変更する"** (include the album's unselected tracks) — by default a partial selection **splits** off into a new album; checking the box **renames** the whole album instead.
  - **リリース年 (Release year)**: a narrow **4-digit `YYYY`** input (placeholder when empty).
  - **ジャンル (Genre)**: **single-select** — one text input + clickable chips of existing library genres. **No replace/add/remove modes and no comma-separated multi-value entry** (a track has exactly one genre here).
- Footer: **キャンセル** + solid **保存**.

**Frame 3 — confirm (`19-bulk-confirm`)**
- **変更を確認** opens a smaller centered **confirm dialog** "次の変更を適用します" listing each change as a bullet (e.g. *"選択した 3 曲だけを「Parallel Lines (Deluxe)」へ分割します。残り 8 曲は「Parallel Lines」のままです。"*), with the reassurance **"ファイルには書き込まれません（編集はライブラリ内にのみ保存されます）。"** and **戻る / 適用** actions.
- **Renaming onto an existing album name should be blocked** with an error ("「X」という名前のアルバムが既に存在します。") — merges are intentionally not silent.

- **SwiftUI**: drive from `Set<Track.ID>`. Show the selection bar when `selection.count > 1`; present the editor as a **`.sheet`** (centered modal) on **一括編集**, not an inspector/drawer. All four fields (Artist, Album name, Release year, Genre) stay visible (no opt-in checkboxes); the only checkbox is "include unselected tracks" under Album name, which toggles split vs. full-album rename. Genre is a single-value `TextField` + suggestion chips (or a `Picker` over known genres), **not** a segmented multi-mode control. Compute rename vs. split by comparing the selection against each album's full membership. The confirm step is a `.confirmationDialog`/`.alert` summarizing the changes. Apply as one undoable transaction (`⌘Z`); writes go to the user-edited column of the spec's two-column `*FromTag` / `*Edited` model.

---

## Interactions & Behavior

- **Navigation**: sidebar selection drives the content column. Artist/Album rows push detail views (`NavigationStack` inside the content column). Back/forward chevrons in the toolbar.
- **Selection**: single-click selects (solid accent in tables). ⌘-click / ⇧-click extend to multi-select → a **selection bar** appears and **一括編集** opens the album bulk-edit dialog (see §14). Double-click a song = play.
- **Now playing**: the playing row shows the equalizer animation and accent title; the footer player reflects the current track, quality badge, and scrubber position.
- **Context menu** (right-click a track): **曲を再生 / 曲を編集…(⌘I) / ライブラリから削除…** (destructive, red). Use `.contextMenu`.
- **Search** (`⌘F` focuses the toolbar search): incremental, prefix-based, diacritic/case-insensitive (spec §6). Results are **grouped** (Albums, Songs…) with the matched substring **highlighted** (gold-a4 background). Use `.searchable` + `.searchScopes` if scoping by type.
- **Song editing**: 曲を編集… opens a centered `.sheet` dialog (曲名 / アーティスト / アルバム / トラック / リリース年 / ジャンル — all plain editable fields, no "Edited" badges). Edits support Undo/Redo (`⌘Z`/`⌘⇧Z`).
- **Multi-select bulk edit** (full spec in **§14**): when 2+ tracks are selected, a **selection bar** drops in atop the table ("N 曲を選択中" + a solid **一括編集** button — no "select all"). Pressing **一括編集** opens a **centered modal dialog** (`アルバム情報の一括編集`) over a dimmed window. Four **album-level** fields exist — **Artist / Album name / Release year / Genre** — all always visible. **Title and track number are intentionally excluded.** Genre is single-select. **保存** applies after a confirm dialog.
- **Drag & drop**: dropping a music folder onto the empty state (or window) starts an import. Active drop zone gets the accent "hot" treatment.
- **Quality display**: every track surfaces its tier (Hi-Res / Lossless / Lossy) consistently across table, badges, and the player.

---

## State Management (ViewState)

Per the spec's architecture, model these as observable view-state:
- **Library selection**: current sidebar item (library section or playlist id).
- **Navigation path**: per content column (for Artist/Album detail push).
- **Row selection**: `Set<Track.ID>` → drives single-song edit dialog vs. multi (bulk-edit) dialog.
- **Inspector**: visible? (Album Info only now). Single-song edit and bulk edit are both centered dialogs, not inspector modes — see §1 and §14.
- **Now playing**: current track, play/pause, position, repeat/shuffle, volume, output quality.
- **Search**: query, scope, grouped results.
- **Import**: idle / scanning(progress, counts, currentFile) / paused-for-review(duplicates) / done; plus partial-failure summary.
- **Library health**: unavailable-tracks count (drives the missing-files banner); database-error (drives the alert).
- **Edits**: dirty fields, "edited" flags, undo stack.

## Design Tokens

See **`DESIGN_TOKENS.md`** in this folder for the full token tables (color steps with hex, spacing, radius, type, shadows) and a **ready-to-paste SwiftUI `Color`/asset mapping**.

## Assets

- **Icons**: the mock hand-draws SF-Symbol-equivalent strokes. In SwiftUI, use real **SF Symbols** instead. Mapping suggestions: Songs `music.note` · Artists `music.mic` / `person` · Albums `square.stack` / `opticaldisc` · Genres `guitars` · Playlist `music.note.list` · play `play.fill` · pause `pause.fill` · prev/next `backward.fill`/`forward.fill` · shuffle `shuffle` · repeat `repeat` · volume `speaker.wave.2.fill` · queue `list.bullet` · airplay `airplayaudio` · search `magnifyingglass` · sidebar `sidebar.left` · inspector `sidebar.right` · favorite `heart` / `heart.fill` · warning `exclamationmark.triangle` · settings `gearshape` · folder `folder` · unavailable `exclamationmark.triangle.fill` · sort `arrow.up.arrow.down` · more `ellipsis`.
- **Cover art**: the mock uses generated abstract gradients as placeholders. Real artwork comes from embedded tags / folder images per the spec (`artworkHash` → `Artwork/<hash>.jpg`). Provide a tasteful generated placeholder for art-less albums.
- **App icon**: the alert's app glyph is a placeholder; use the real app icon.
- **No emoji** anywhere (matches both the product spec and the design-system rule).

## Files

Everything lives in `reference_html/` — the single source of truth is **`design_canvas.html`**. (There are no standalone bundles or clickable prototypes in this handoff; earlier prototype files were removed because they drifted from the canvas.)

- `design_canvas.html` — entry point; lays out all 18 frames on a pannable canvas.
- `app.css` — all component styling (the source of truth for exact px/colors/states).
- `tokens.css` — the Radix token layer (spacing, type, radius, shadows, semantic colors).
- `shell.jsx` — window shell: icons, generated cover art, sidebar, toolbar, footer player.
- `screens.jsx` — Songs, Albums, Artists, Playlist, Empty, Import.
- `screens2.jsx` — Genres, Artist detail, Album detail, Search, Context menu, the **song edit dialog** (`SongEditScreen`/`SongDialog`), and the **album bulk-edit flow** (`MultiSelectScreen`, `BulkEditScreen`/`AlbumDialog`, `BulkConfirmScreen`).
- `screens3.jsx` — Missing files, Duplicate review, Data error, Preferences.
- `design-canvas.jsx` — the pan/zoom canvas harness that lays the frames out (presentation only; ignore for the SwiftUI implementation).

To view: open `design_canvas.html` in a browser (it loads React + Radix colors from CDN, so it needs network access on first load).
