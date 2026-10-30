# The edits

Each change is one patch in [`../patches`](../patches), applied on top of LG's
stock home QML. Apply them in order with `git apply patches/*.patch`, or pick the ones you
want. Every edited line is tagged `// custom:` so you can find them later.

Line numbers and exact text are from a **43UP8000PUR / webOS 6.5**. Read your
own files before applying.

## `0001` — no guide, no Recent Input card, no ads

- **AdShelf.qml**: the `LastInputCard` (the "Recent Input" tile) → `visible: false`.
- **TopShelf.qml**: force the `isTopShelfGuide` guard to `false` where it gates
  the big guide overlay.
- **MainView.qml**: comment out the three promo/ad calls —
  `requestRecommendedAdData()`, `makeAdBanner()`,
  `updateContentRecommendationShelf()`.
- **ShelfList.js**: use `_initByDefault()` instead of `_initByServerData(...)` so
  the shelf list comes from the default set, not LG's server.
- **PromotionInterfaces.qml**: early `return` in `requestRecommendedAdData()`.

## `0002` — kill the guide at its source

The "Start a new experience with webOS" banner is LG's *agreements* prompt and
comes back whenever the privacy agreements are off (which, post-root, they are).
Hiding it in one view isn't enough. Set the single source property:

- **SystemProperties.qml**: `property bool isTopShelfGuide: false`.

## `0003` — one full-screen space scene

- **MainView.qml**: add one `Image { id: customSpaceBg; z: -1; anchors.fill;
  source: getImageUrl("bg_space.jpg"); fillMode: PreserveAspectCrop }` behind
  everything, cap its `sourceSize` to 1920×1080, and turn the opaque cover
  rectangles (`#000000`, `bgColor`) **transparent** and the stock top band's
  opacity to `0` so the one image shows through top and bottom as a single scene.

Drop your rendered `bg_space.jpg` into
`UserInterfaceLayer/Components/images/{2k,4k}/`.

## `0004` — hide the "no ads" filler guide

With ads gone, LG shows a `TopDefaultAppsGuide` filler (the same "new experience"
art). Hide it:

- **TopShelf.qml**: `topDefaultAppsGuide` → `visible: false`.

## `0005` — drop the Home Dashboard + mobile Connection Guide tiles

In the connection/input shelf, filter out two tile *types* before they render:

- **ConnectionsInterfaces.qml**: after the shelf array is assembled, drop items
  whose `type` is `"title"` (Home Dashboard) or `"mobile_guide"` (Connection
  Guide). AirPlay, inputs, USB and sound-out stay.

## `0006` — hide unused launcher icons

Keep the apps installed but out of the ribbon:

- **SystemServiceResponseProcessors.js**: filter the `listLaunchPoints` response
  by `id` (`customHidden` list) — LG Channels, Home Dashboard, Sports Alert,
  Web Browser, Media Player, Alexa, Who.Where.What?, Room-to-Room Share, VNC.
  Edit the list to taste.

## `0007` — dark connection tiles

The input/AirPlay tiles are white by default and clash with a dark background.

- **MobileComponent.qml**: tile background → translucent dark (`#CC151A24`,
  focused `#3A4150` with a white border), text → near-white, and a `ColorOverlay`
  tints the LG glyph icons light. Phone thumbnails (`type === "mobile"`) keep
  their real colors.

## Rolling back one step

`git revert` the patch in your copy, or restore that file from the stock tree,
then re-run the boot hook to relaunch home.
