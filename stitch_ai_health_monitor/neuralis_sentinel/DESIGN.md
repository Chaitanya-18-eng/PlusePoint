# Design System: Neural Health & Surveillance

## 1. Overview & Creative North Star
**Creative North Star: "The Sentient Observer"**

This design system is not a dashboard; it is a cinematic interface that feels alive, intelligent, and unobtrusive. Inspired by high-end neuro-technology, the aesthetic moves away from "app-like" layouts toward a "surveillance-grade" editorial experience. 

The system breaks the traditional rigid grid through **Bento-style asymmetry** and **Tonal Depth**. By layering surfaces of varying dark tones rather than using lines, we create an environment that feels like a singular, fluid organism. The goal is to convey absolute precision and professional medical authority while maintaining a "Neuralink" sense of futurism.

---

## 2. Colors & Surface Philosophy
The palette is rooted in a "Cinematic Dark" foundation, utilizing deep blacks and shifting grays to create a sense of infinite space.

### The "No-Line" Rule
Traditional 1px solid borders are strictly prohibited for sectioning. Structural boundaries must be defined exclusively through **Surface Transitions** or **Ghost Borders**. 
*   **Surface Transition:** Placing a `surface-container-low` component against a `surface` background.
*   **Ghost Border:** If a boundary is required for accessibility, use the `outline-variant` token at **15% opacity**. Never use 100% opaque lines.

### Surface Hierarchy & Nesting
Treat the UI as a series of stacked, semi-translucent plates.
- **Base Layer:** `surface` (#131314) for the main canvas.
- **Section Layer:** `surface-container-low` for large content groupings.
- **Interactive Layer:** `surface-container-highest` for active bento cards or floating controls.
- **The Glass Rule:** For modals and high-level overlays, use `surface-variant` with a **20px Backdrop Blur** and 60% opacity to allow the "neural network" patterns to bleed through.

### Accent States (The Pulse)
Accents are functional, not decorative. They represent the "health" of the data:
- **Stable (Primary):** `primary-container` (#4ADE80). Used for steady heartbeats and synced data.
- **Watchful (Secondary):** `secondary-container` (#E3AA00). Used for data drifting from baseline.
- **Alert (Tertiary):** `on-tertiary-container` (#96282D). Used for critical intercepts. Implement as a "Soft Pulse" animation (0.5s ease-in-out) rather than a static block of color.

---

## 3. Typography
We use **Inter** for its clinical precision and **Space Grotesk** for technical labeling to provide a subtle "instrumentation" feel.

- **Display (Lg/Md):** Used for singular, high-impact biometrics (e.g., "98 BPM"). Set with tight letter-spacing (-0.02em).
- **Headline (Sm/Md):** Used for section titles. These should be treated as editorial headers—often placed asymmetrically to the left of a bento cluster.
- **Title (Sm/Md):** Reserved for card headers.
- **Label (Md/Sm):** Set in **Space Grotesk**. Used for metadata, timestamps, and "Neuralink" style technical readouts. Always uppercase with +0.05em tracking.

---

## 4. Elevation & Depth
Depth in this system is achieved through **Tonal Layering**, mimicking the way light interacts with polished obsidian.

- **The Layering Principle:** To lift a card, move it up one tier in the `surface-container` scale. A `surface-container-highest` card sitting on a `surface-dim` background creates a natural, soft-edged lift.
- **Ambient Shadows:** Shadows must be invisible but felt. Use a blur of 40px-60px with a 4% opacity of the `on-surface` color. This simulates a "glow" from the glass rather than a shadow cast by a light source.
- **Signature Texture:** Integrate a "Digital Network" background pattern—subtle, glowing lines with 5% opacity—that sits between the `surface` and `surface-container` layers.

---

## 5. Components

### Bento Cards
The core unit of the UI.
- **Styling:** Use `xl` (0.75rem) corner radius.
- **Separation:** Strictly forbid divider lines. Use `surface-container-low` and `24px` padding to separate content blocks.
- **Accents:** Use a 2px top-border gradient (e.g., `primary` to transparent) only when a card requires high-priority focus.

### Buttons
- **Primary:** `surface-tint` background with `on-primary` text. No border.
- **Secondary:** Transparent background with a `Ghost Border` (outline-variant @ 20%).
- **State Change:** On hover, apply a `primary` glow (5px blur) to the text/icon rather than shifting the background color significantly.

### Input Fields
- **Styling:** Minimalist bottom-border only, or a subtle `surface-container-highest` fill.
- **Focus:** The bottom border transitions from `outline` to `primary` with a soft outer glow.
- **Error State:** Use `on-tertiary-container` text with a subtle `error` pulse on the input line.

### Biometric Chips
- **Selection:** Small, pill-shaped (`full` roundedness).
- **Active State:** Use a 10% opacity fill of the `primary` color with a `primary` 1px text.

---

## 6. Do's and Don'ts

### Do:
- **Use Negative Space:** Allow data to breathe. The "high-end" feel comes from the space between elements, not the elements themselves.
- **Animate Transitions:** Use staggered entrance animations (0.3s) for bento cards to simulate a system "booting up."
- **Focus on Legibility:** Even though it’s "Neuralink-style," ensure `body-md` text always hits a 4.5:1 contrast ratio against the surface.

### Don't:
- **No Heavy Borders:** Never use a 100% opaque border. It breaks the "cinematic glass" illusion.
- **No Pure White:** Use `on-surface` (#E5E2E3) for text. Pure #FFFFFF is too harsh and feels unrefined in a dark mode environment.
- **No Standard Grids:** Avoid perfectly symmetrical 3x3 grids. Offset one or two cards (e.g., one wide card, two tall ones) to create visual "rhythm."

### Clinical Professionalism
Every animation and glow must serve a purpose. If a pulse is present, it must represent real-time data. If a blur is used, it must represent a layer of depth. We are designing for health surveillance; the system must feel as reliable as the hardware it supports.