# f2048 Visual Spec (Award-Level)

This document turns the concept plan into concrete visual decisions and UI tokens.

## Visual Direction

Theme name: Luminous Tactile
Mood: premium, calm, object-like depth, soft glow, refined typography.
Primary feel: a crafted glass board floating over a warm atmospheric gradient.

## Typography

- Display (titles, big numbers): Fraunces Semibold
- UI (labels, buttons, meta): Manrope Medium
- Numerals in tiles: Fraunces Semibold, tabular numbers on

Type sizes (iOS points / Flutter logical pixels):
- Display XL: 34, line 40, tracking -0.2
- Display L: 28, line 34, tracking -0.2
- Title: 22, line 28, tracking -0.1
- Body: 16, line 22, tracking 0
- Caption: 12, line 16, tracking 0.2

Fallbacks: "Fraunces" -> "Times New Roman"; "Manrope" -> "Arial".

## Color System

Neutrals:
- Ink 900: #121112
- Ink 800: #1E1C1E
- Ink 600: #3A353A
- Cloud 200: #E8E2DD
- Cloud 100: #F3EFEA
- Cloud 050: #FAF7F2

Accents:
- Ember: #F07D4E
- Gold: #F5C36A
- Sea: #69C6C2
- Rose: #E88BA1

Background gradient (base layer):
- Top: #F7EFE3
- Mid: #EEDCC6
- Bottom: #E8C9A7

Interaction highlight:
- Glow: #FFD9A3 at 40% opacity

Text colors:
- Primary text: Ink 900
- Secondary text: Ink 600
- On-tile text: Ink 900 for light tiles, Cloud 050 for dark tiles

## Layout + Spacing

Spacing scale: 4, 8, 12, 16, 24, 32, 40.
Safe margins: 24 (iOS), 20 (Android) minimum.
Board size: 86% of screen width on phones, 70% on tablets.
Corner radii:
- Tile: 16
- Board container: 24
- Buttons: 20

## Board Container

Visual:
- Background: Cloud 050 at 70% opacity
- Border: 1px Cloud 200 at 60% opacity
- Shadow: 0 16 40 rgba(18,17,18,0.18)
- Inner highlight: top inset 1px rgba(255,255,255,0.5)
- Frosted blur on board background (if feasible)

## Tiles

Tile size: square, 6% gap relative to board width (auto-scaled).
Base style:
- Radius 16
- Shadow: 0 10 20 rgba(18,17,18,0.16)
- Highlight: inset 0 1 0 rgba(255,255,255,0.35)
- Edge sheen: 1px top-left light, 1px bottom-right dark

Value color mapping (low to high):
- 2: #F8EFE2
- 4: #F2E1C8
- 8: #F6C997
- 16: #F4A36B
- 32: #EF7C4E
- 64: #E65E5A
- 128: #D94E7B
- 256: #B8498A
- 512: #8E4C9F
- 1024: #6D4CA6
- 2048+: #4C4AA9

Tile text:
- 2-64: Ink 900
- 128+: Cloud 050
Numbers: 24-48 based on tile size, weight 600.

## Buttons

Primary button:
- Background: Ember -> Gold vertical gradient
- Text: Ink 900
- Shadow: 0 6 14 rgba(18,17,18,0.18)
- Pressed: scale 0.98 + lower shadow

Secondary button:
- Background: Cloud 050
- Border: 1px Cloud 200
- Text: Ink 800

## Icons

Style: rounded, 1.75px stroke, soft corners, no sharp edges.
Default color: Ink 600.
Active: Ember.

## Motion

Curves:
- Enter: easeOutCubic
- Merge: elasticOut (light)
- Press: easeInOut

Timings:
- Screen load: 420ms (staggered 40ms)
- Tile spawn: 180ms scale + fade
- Tile move: 120ms translate
- Merge pulse: 180ms scale to 1.08 then settle
- Button press: 90ms

## Background & Atmosphere

Layer 1: gradient (see Color System).
Layer 2: soft blurred shapes (circles/ovals) at 8% opacity.
Layer 3: subtle noise texture at 4% opacity.

## Haptics & Sound

Haptics:
- Tile move: light impact
- Merge: medium impact
- 2048: success notification

Sound:
- Move: soft tick (low volume)
- Merge: warm chime
- Win: short rising chord

All sounds must be toggleable in Settings.

## Accessibility

- Minimum text contrast 4.5:1 for labels.
- Provide high-contrast mode: swap tile text to Ink 900 and add border.
- Support reduce motion: disable parallax and elastic merge.

## Screen Treatments

Onboarding:
- Full-screen gradient hero
- Animated hand swipe over board (Lottie or vector)
- Minimal text: "Combine. Rise. Breathe."

Main Menu:
- Board preview as hero element
- CTA "Play" uses primary button style

Stats + Achievements:
- Cards: Cloud 050 background, 16 radius, subtle shadow
- Data chips: pill shapes, Gold tint

Settings:
- Section headers in Fraunces
- Toggles in Ember active state
