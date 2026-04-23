# Aviary Canvas — Concept Analysis

## Summary of App Idea

**Aviary Canvas** is an offline iOS planning tool for designing bird enclosures and small poultry farms. The user works on a grid-based canvas (default 15 × 15 cells, each cell = 0.25 m²) representing the floor plan of their aviary. Using a set of drawing tools (pencil, rectangle, eraser, flood-fill) they paint different functional zones directly on the grid. The app then performs automatic calculations — available floor area per bird, feeder coverage, water-source coverage, nesting space, perch length, and predator/prey zone conflict detection — and shows colour-coded feedback in real time.

Completed schemes can be saved, loaded, edited, and exported as a text description. A full gamification system (XP, ranks, streaks, achievements, trophies) keeps the user engaged.

---

## Central Theme

**Birds & Aviaries** — every screen, icon, copy line and metaphor references bird life: egg → hatchling rank progression, feather particle background, nest/perch/egg zone icons, and aviary-keeper vocabulary throughout.

---

## Proposed Screen List

| # | Screen | Description |
|---|--------|-------------|
| 1 | **Splash / Welcome** | Shown on every launch. App logo + tagline + short description. Auto-dismisses after 5 s with fade-out. Tap-to-dismiss also triggers the same animation. |
| 2 | **Main Screen** | Root scaffold with custom animated bottom navigation bar (5 tabs). Hosts all tab screens. Overlays: achievement toast (slides from top), rank-up celebration (full-screen particle burst). |
| 3 | **Canvas Screen** *(Tab 1)* | Core feature. Grid canvas with drawing tools. Tool selector (pencil, rectangle, eraser, fill). Zone-type selector (8 types with colour swatches). Bird-count bottom sheet. Auto-calculated stats panel. Save / New / Export actions. |
| 4 | **Schemes Screen** *(Tab 2)* | List of all saved aviary schemes shown as cards with thumbnail preview, name, creation date, bird count, coverage %. Swipe-to-delete, tap-to-open in Canvas. FAB to create a new scheme. |
| 5 | **Calculator Screen** *(Tab 3)* | Standalone aviary calculator. User picks species and quantities without a grid. Results show space, feeders, water, nesting, perch requirements as colour-coded rows. Also contains the perch-height / perch-spacing calculator for birds. |
| 6 | **Achievements Screen** *(Tab 4)* | Full dedicated screen. Categorised grid of all 17 achievements (locked/unlocked state). Progress indicators where applicable. Animated unlock glow on newly-earned items. |
| 7 | **Profile Screen** *(Tab 5)* | User stats: XP bar with animated fill, current rank badge, streak counter, totals (schemes, calculations, birds added, species). "View Trophies" button navigates to Trophies screen. |
| 8 | **Trophies Screen** | Dedicated full screen (pushed from Profile). 7 trophies displayed as large badges (bronze/silver/gold/diamond tiers) with locked/unlocked states and sparkle animations. |

---

## Key Technical Decisions

- **Grid representation:** `List<List<int>>` — 0 = empty, 1–8 = zone types
- **Persistence:** `shared_preferences` — all schemes and user profile serialised as JSON
- **Animations:** `flutter_animate` package + raw `AnimationController` for background particles
- **No network, no push notifications, no background services**
- **Cupertino-only widget library** throughout
