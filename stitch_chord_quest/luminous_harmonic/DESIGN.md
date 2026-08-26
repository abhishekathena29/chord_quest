---
name: Luminous Harmonic
colors:
  surface: '#f7f9fb'
  surface-dim: '#d8dadc'
  surface-bright: '#f7f9fb'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f4f6'
  surface-container: '#eceef0'
  surface-container-high: '#e6e8ea'
  surface-container-highest: '#e0e3e5'
  on-surface: '#191c1e'
  on-surface-variant: '#3b494b'
  inverse-surface: '#2d3133'
  inverse-on-surface: '#eff1f3'
  outline: '#6a7a7b'
  outline-variant: '#b9cacb'
  surface-tint: '#006970'
  primary: '#006970'
  on-primary: '#ffffff'
  primary-container: '#00f0ff'
  on-primary-container: '#006970'
  inverse-primary: '#00dbe9'
  secondary: '#a900a9'
  on-secondary: '#ffffff'
  secondary-container: '#fe00fe'
  on-secondary-container: '#500050'
  tertiary: '#7212ff'
  on-tertiary: '#ffffff'
  tertiary-container: '#e1d2ff'
  on-tertiary-container: '#7213ff'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#7df4ff'
  primary-fixed-dim: '#00dbe9'
  on-primary-fixed: '#002022'
  on-primary-fixed-variant: '#004f54'
  secondary-fixed: '#ffd7f5'
  secondary-fixed-dim: '#ffabf3'
  on-secondary-fixed: '#380038'
  on-secondary-fixed-variant: '#810081'
  tertiary-fixed: '#e9ddff'
  tertiary-fixed-dim: '#d1bcff'
  on-tertiary-fixed: '#23005b'
  on-tertiary-fixed-variant: '#5700c9'
  background: '#f7f9fb'
  on-background: '#191c1e'
  surface-variant: '#e0e3e5'
typography:
  headline-xl:
    fontFamily: Plus Jakarta Sans
    fontSize: 48px
    fontWeight: '800'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Plus Jakarta Sans
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
  body-lg:
    fontFamily: Be Vietnam Pro
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Be Vietnam Pro
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-md:
    fontFamily: Be Vietnam Pro
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.02em
  label-sm:
    fontFamily: Be Vietnam Pro
    fontSize: 12px
    fontWeight: '700'
    lineHeight: 16px
    letterSpacing: 0.05em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 8px
  xs: 4px
  sm: 12px
  md: 24px
  lg: 40px
  xl: 64px
  gutter: 20px
  margin-mobile: 16px
  margin-desktop: 48px
---

## Brand & Style
This design system centers on a vibrant, light-mode Glassmorphism aesthetic tailored for an immersive music learning experience. The brand personality is energetic, futuristic, and encouraging, designed to reduce the friction of learning through visual delight. 

The UI utilizes a "Luminous Glass" style, characterized by translucent surfaces, high-saturation accents, and mesh-gradient backgrounds that evoke a sense of digital melody. Interactive elements are designed to feel like physical light-sources, using vibrant blurs and soft glows to guide the user's eye toward progress and play.

## Colors
The palette is built on high-energy contrasts. The **Primary Electric Cyan** represents action, rhythm, and progress. The **Secondary Magenta** is used for creative milestones, highlights, and secondary interactions. 

Backgrounds are not static; they should feature soft mesh gradients using the primary, secondary, and tertiary colors at 5-10% opacity, moving slowly to create a sense of "living" atmosphere. Surfaces use a "Milk Glass" approach—semi-transparent white that adopts the hue of the background blobs beneath them.

## Typography
Typography is modern, friendly, and highly legible. **Plus Jakarta Sans** is used for headings to provide a clean, geometric structure with a slight "tech" edge. **Be Vietnam Pro** handles the body text, chosen for its warmth and contemporary feel in instructional content. 

Text on glass surfaces should maintain high contrast—use dark greys for body text and deep saturated versions of the primary/secondary colors for emphasized labels.

## Layout & Spacing
The layout follows a fluid, organic rhythm. A 12-column grid is used for desktop, but elements are often decoupled from strict vertical lines to allow for floating glass "islands." 

Padding within glass containers should be generous (minimum 24px) to ensure the backdrop blur effect is visible and the content doesn't feel cramped against the translucent edges. Use the `md` (24px) unit as the standard gap between component groups.

## Elevation & Depth
Depth is achieved through the interaction of three layers:
1.  **The Atmosphere:** A base layer of `#F7F9FB` with animated mesh gradient "blobs" (Gaussian blur > 100px).
2.  **The Glass Layer:** Containers use a `backdrop-filter: blur(20px)` and a background of `rgba(255, 255, 255, 0.6)`. 
3.  **The Inner Glow:** A subtle 1px inner border (`rgba(255, 255, 255, 0.8)`) on the top and left sides of containers simulates a light source hitting the glass edge.

Shadows are avoided in favor of "Color Glows"—outer blurs that inherit the hue of the component (e.g., a Cyan button has a soft Cyan glow rather than a black shadow).

## Shapes
The design system uses "Round Eight" logic. Standard components utilize a 0.5rem (8px) base radius. Larger glass cards and containers scale up to `rounded-xl` (1.5rem / 24px) to emphasize the soft, approachable nature of the learning interface. 

Icons and decorative elements should use nested geometric shapes (hexagons and diamonds) with rounded corners to maintain the sophisticated, modern aesthetic.

## Components
-   **Glass Cards:** The primary container. Must have `backdrop-filter: blur(20px)`, a semi-transparent white fill, and a thin white stroke.
-   **Action Buttons:** Solid, high-saturation gradients (Primary to Secondary). These should have a "bloom" effect on hover (increasing the outer glow intensity).
-   **Progress Rings:** Use thick strokes with rounded caps. The unfilled portion should be a low-opacity version of the primary color.
-   **Input Fields:** Ghost-style inputs with a semi-transparent background. On focus, the border should glow with the Primary color.
-   **Practice Chips:** Small, pill-shaped glass elements with a vibrant icon. The icon should be housed in a small rounded hexagon.
-   **Music Staff/Visualizers:** Lines should be thin and crisp, using the Primary color with a slight neon outer glow to make them appear as if they are floating on top of the glass.