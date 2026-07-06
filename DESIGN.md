---
name: Orange AI
colors:
  surface: '#fff8f6'
  surface-dim: '#ead6cd'
  surface-bright: '#fff8f6'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#fff1eb'
  surface-container: '#feeae0'
  surface-container-high: '#f9e4db'
  surface-container-highest: '#f3ded5'
  on-surface: '#241914'
  on-surface-variant: '#564338'
  inverse-surface: '#3a2e28'
  inverse-on-surface: '#ffede5'
  outline: '#8a7266'
  outline-variant: '#ddc1b3'
  surface-tint: '#9a4600'
  primary: '#9a4600'
  on-primary: '#ffffff'
  primary-container: '#ff8a3d'
  on-primary-container: '#682d00'
  inverse-primary: '#ffb68d'
  secondary: '#895026'
  on-secondary: '#ffffff'
  secondary-container: '#ffb380'
  on-secondary-container: '#794319'
  tertiary: '#006783'
  on-tertiary: '#ffffff'
  tertiary-container: '#00b7e7'
  on-tertiary-container: '#004457'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#ffdbc9'
  primary-fixed-dim: '#ffb68d'
  on-primary-fixed: '#321200'
  on-primary-fixed-variant: '#763300'
  secondary-fixed: '#ffdcc7'
  secondary-fixed-dim: '#ffb786'
  on-secondary-fixed: '#311300'
  on-secondary-fixed-variant: '#6d3910'
  tertiary-fixed: '#bce9ff'
  tertiary-fixed-dim: '#63d3ff'
  on-tertiary-fixed: '#001f29'
  on-tertiary-fixed-variant: '#004d63'
  background: '#fff8f6'
  on-background: '#241914'
  surface-variant: '#f3ded5'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 64px
    fontWeight: '700'
    lineHeight: 72px
    letterSpacing: -0.02em
  display-md:
    fontFamily: Inter
    fontSize: 48px
    fontWeight: '700'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-lg:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.05em
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 8px
  container-max: 1440px
  gutter: 24px
  margin-desktop: 64px
  margin-tablet: 32px
  margin-mobile: 16px
---

## Brand & Style

This design system embodies a "Liquid Glass" aesthetic, merging the clarity of high-end minimalism with the organic warmth of soft ambient lighting. The brand personality is sophisticated yet approachable, targeting professionals who value both high-performance AI tools and a calming, premium user experience.

The visual language utilizes heavy glassmorphism, featuring multi-layered translucent surfaces that catch "light" from the primary brand color. The emotional response is one of clarity, fluidity, and effortless intelligence. By prioritizing white space and subtle depth over heavy ornamentation, the interface feels weightless and expansive, ideal for a desktop-first productivity environment.

## Colors

The palette is centered around a vibrant, energetic primary orange that acts as a light source within the interface. 

- **Primary (#FF8A3D):** Used for key actions, focus states, and the "glow" reflected in glass surfaces.
- **Secondary (#FFB380):** A softer tint for hover states and secondary accents.
- **Background (#FFF5EC):** A warm, creamy neutral that prevents the "clinical" feel of pure white, providing a soft canvas for glass effects.
- **Surface (#FFFFFF):** Used at varying opacities (from 40% to 80%) to create the frosted glass effect.
- **Text (#2B2B2B):** A deep charcoal that ensures high legibility while remaining softer than pure black.

## Typography

The design system utilizes **Inter** exclusively to maintain a clean, systematic, and highly readable environment. The typographic hierarchy relies on significant scale differences and weight variations to guide the eye through dense AI-driven data.

Headlines use tighter letter spacing and heavier weights to feel "anchored" against the ethereal glass backgrounds. Body text is set with generous line heights to ensure long-form AI responses are easily digestible. Labels utilize subtle tracking (letter spacing) and uppercase styling to provide structural markers without adding visual bulk.

## Layout & Spacing

The layout follows a fluid-grid philosophy within a max-width container, optimized for desktop viewing. A strict 8px base unit governs all dimensions, ensuring mathematical harmony across the UI.

- **Desktop (1024px+):** 12-column grid with wide 64px outer margins to emphasize the minimalist, "breathing" nature of the design.
- **Tablet (768px - 1023px):** 8-column grid with 32px margins. Glass panels may transition from side-by-side to stacked.
- **Mobile (<767px):** 4-column grid with 16px margins. Glass opacities should be increased slightly (less transparent) to maintain legibility on smaller screens.

Spacing between major glass sections should be generous (48px - 64px) to allow the background light gradients to show through, creating the "liquid" feel.

## Elevation & Depth

Depth is achieved through a combination of backdrop blurs and "inner-glow" borders rather than traditional dark shadows.

1.  **Backdrop Blur:** All glass surfaces must apply a `backdrop-filter: blur(20px)`.
2.  **Surface Opacity:** Default glass surfaces are `rgba(255, 255, 255, 0.6)`. High-elevation surfaces (like modals) use `rgba(255, 255, 255, 0.8)`.
3.  **The Glass Stroke:** Every glass element requires a 1px solid white border with 30% opacity. This acts as a "specular highlight" on the edge of the glass.
4.  **Ambient Glow:** Instead of a drop shadow, use a large, very soft shadow tinted with the primary color: `0px 20px 40px rgba(255, 138, 61, 0.1)`.

## Shapes

The design system employs a highly organic shape language with a base roundedness of 24px for all primary containers.

- **Small elements (Buttons, Inputs):** 24px radius (`rounded-xl` logic).
- **Medium elements (Cards, Popovers):** 32px radius.
- **Large elements (Main Content Areas):** 48px radius.

This extreme roundness complements the "liquid" theme, making the interface feel soft to the touch and removing any harsh "industrial" corners.

## Components

### Buttons
Primary buttons are solid #FF8A3D with white text and a subtle 20px "orange glow" shadow. Secondary buttons use the glass style (frosted white background) with #FF8A3D text.

### Cards & Glass Panels
The signature component of this design system. These must feature the 20px backdrop blur, a 1px white specular border, and the 24px corner radius. Content inside should have at least 32px of padding to maintain the minimalist feel.

### Input Fields
Inputs are semi-transparent white (40% opacity) with a 1px white border. On focus, the border color shifts to the primary #FF8A3D and the background opacity increases slightly to 60%.

### Chips
Small, pill-shaped glass elements (rounded-full) used for tags or categories. They use a lighter blur (10px) to remain distinct from the main panels they sit upon.

### AI Chat Bubbles
User messages are represented by standard glass panels. AI-generated responses should feature a subtle gradient background (White to 10% Primary Color) to denote "intelligence" and active processing.