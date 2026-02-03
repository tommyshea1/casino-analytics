# Casino Operations Dashboard — Design Spec

## Design Principles
- **Executive-ready:** Clean, minimal, no clutter. Think shareholder deck.
- **Scannable:** KPIs first, then trends, then detail.
- **Consistent:** One color story, one font family, aligned spacing.

---

## Color Palette

| Role | Hex | Use |
|------|-----|-----|
| **Primary** | `#1e3a5f` | Header, titles, primary bars |
| **Accent** | `#17a2b8` | Lines, secondary emphasis |
| **Positive** | `#28a745` | Gains, up arrows |
| **Neutral** | `#6c757d` | Labels, axis text |
| **Background** | `#f8f9fa` | Dashboard canvas |
| **Card** | `#ffffff` | KPI cards, chart areas |
| **Border** | `#dee2e6` | Subtle dividers |

---

## Typography
- **Title:** Bold, 18–20pt, Primary color
- **Subtitle:** Regular, 12pt, Neutral
- **KPI number:** Bold, 36–48pt, Primary
- **KPI label:** Regular, 11pt, Neutral
- **Axis labels:** Regular, 10pt, Neutral
- **Chart titles:** Bold, 12pt, Primary, left-aligned

---

## Layout Grid

- **Padding:** 16px between all elements
- **KPI row:** 4 equal-width cards, full width
- **Charts:** Use tiled layout; no overlapping
- **Aspect:** Prefer wider charts for trends (e.g. 2:1 width:height for line/area)

---

## Component Specs

### 1. Header Strip
- Full-width band, Primary color
- Left: "Casino Operations Dashboard" (white, bold 18pt)
- Right (optional): "Q3 Performance" or date range (white, 12pt)
- Height: ~56px

### 2. KPI Cards (Row 1)
- 4 cards, equal width
- White background, 1px Border, 8px padding, 12px corner radius
- **Layout per card:**
  - Line 1: Label (e.g. "Total Gaming Revenue") — 11pt Neutral
  - Line 2: Big number — 36–40pt Bold Primary
  - Line 3 (optional): Comparison — 10pt (e.g. "↑ 8.5% vs prior period")
- Align numbers left; keep cards same height

### 3. Chart Area Rules
- **All charts:** White background, 1px Border, 8px corner radius
- **Gridlines:** Light gray only; no heavy lines
- **Zero line:** Show on bar/line charts; subtle gray
- **Legends:** Bottom or right; 10pt text
- **No chart junk:** Remove redundant labels; one clear title per chart

### 4. Chart-Specific Notes
- **Line/Area:** Single series = Accent color; use area fill at 20–30% opacity
- **Bars:** Single color = Primary; use Accent for highlights (e.g. weekend)
- **Pie/Donut:** Use 4–5 shades of Primary → Accent; avoid red/green for non-up/down meaning
- **Tables:** Header row Primary background, white text; rows alternating light gray/white

---

## Recommended Order of Build
1. Set workbook theme and default fonts
2. Build and format KPI cards
3. Build Monthly Trend (line/area)
4. Build Revenue by Manufacturer (horizontal bar)
5. Build Hourly Activity (area)
6. Build Day of Week (bar)
7. Build Player Tier (bar or donut)
8. Build Table Games (bar or table)
9. Build Promo by Tier (stacked bar)
10. Assemble dashboard with 16px padding and header
11. Pass: remove gridlines, align titles, check spacing

---

## Accessibility
- Contrast: All text meets WCAG AA on its background
- Don’t rely on color alone: use labels + color for key metrics
- Title every chart so screen readers and exports make sense
