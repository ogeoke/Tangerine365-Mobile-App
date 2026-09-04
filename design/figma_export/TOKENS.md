# Tangerine365 Mobile App — Design Tokens

> Extracted directly from the approved Figma mobile screens, page `48:284`, on 21 August 2026. The Figma file does not contain published local color styles, text styles, or variable collections, so the values below come from the actual screen layers. Use the specific frame values where a component has an explicitly documented variant.

Figma source: https://www.figma.com/design/QlMwzWxIKHtghE6vP3BZPZ/WEMA-Bank-Mobile-Assets-and-Design?node-id=48-284

## Brand colors

| Token | Hex | Notes / where used |
|---|---|---|
| Tangerine green (primary) | `#397B27` | Primary buttons, Courses module card, completed lesson indicator, form actions, selected borders. Replace the existing app value `#48B401`. |
| Tangerine orange (accent) | `#E83312` | Back arrows, accent links, selected actions. Replace the existing app value `#FB562A`. |
| Light green | `#EBF6E7` | Light-green analytics cards, chips, and supporting surfaces. Success icon background uses the lighter variant `#E8F7E3`. |
| Light orange | `#FBE4D6` | Warm light-orange surfaces; also the Banking Tools module-card background. |
| Text primary | `#141A21` | Main screen headings, body text, and status text. Analytics/authentication headings also use the near-black variant `#0E1217`. |
| Text secondary / muted | `#6B7385` | Supporting text, subtitles, and metadata. Analytics/authentication supporting text also uses `#747D8B`. |
| Surface / card background | `#FFFFFF` | Course cards, analytics cards, dialogs, and standard form fields. |
| Screen background | `#F7FAF7` | Home, Courses Hub, My Courses, and Course Content. Several feature screens use the close variant `#F8FAF8`; authentication base background is `#F6F4E9`. |
| Border / divider | `#E3E8E3` | Header dividers. Authentication input borders use `#D5DAD5`; support form inputs use `#D4DBD4`. |
| Success | `#397B27` | Success check marks, success action buttons, and confirmation accents. |
| Error / not-started (red) | `#E53935` | Red lesson-status circles for Not Started. |
| Warning / in-progress (yellow) | `#F2A511` | Yellow lesson-status circles for In Progress. |
| Completed (green) | `#397B27` | Green lesson-status circles for Completed. Analytics charts use a distinct completed-series green, `#4FA633`. |

### Additional approved semantic colors

| Token | Hex | Usage |
|---|---|---|
| Dark supporting green | `#406E2B` | Secondary green links, selected indicator dots, and some menu/header accents. |
| Waiting / analytics alert | `#EC380E` | Waiting segment in the My Learning activity chart. |
| Analytics completed | `#4FA633` | Completed course segment and legend marker. |
| Analytics in progress | `#EDB01F` | In-progress course segment and legend marker. |
| Analytics not started | `#59B2D1` | Not-started course segment and legend marker. |
| Disabled/read-only input | `#F0F2F0` | Read-only user field on Help & Support. |
| Placeholder text | `#99A3A1` | Help & Support form placeholders. |
| Authentication veil | `#FFFDF6` at `18%` opacity | Transparent overlay above the blurred login/OTP background. |
| Modal scrim | `#050A08` at `48%` opacity | Subscription-success overlay backdrop. |

## Home module-card background colors (solid, per Figma)

| Module | Background | Border | Icon-square background | Primary text |
|---|---|---|---|---|
| Courses | `#397B27` | `#397B27` | `#679756` | `#FFFFFF` |
| Knowledge Repository | `#E2ECD9` | `#CADBBE` | `#CDDEC1` | `#4C6248` |
| Banking Tools | `#FBE4D6` | `#F0CCB5` | `#F1CEB6` | `#785942` |
| Information Management | `#DDEFE6` | `#C2DCD0` | `#C5DDD1` | `#47695D` |

Home module-card dimensions: `156 × 164 px`; icon squares: `46 × 46 px`, with `15 px` corner radius.

## Typography

Font family: **Manrope**.

The approved design does **not** use the application's existing Inter, Jost, or Mulish fonts. Bundle and configure Manrope before implementing the new screens.

Font weights:

- Manrope Regular: `400`.
- Manrope SemiBold: `600`.
- Manrope Bold: `700`.

| Style | Font | Size | Weight | Line height | Used for |
|---|---|---|---|---|---|
| Display / H1 | `Manrope` | `23 px` | `600` | `31 px` where explicitly set; otherwise Figma `AUTO` | Screen titles and the Login heading. |
| H2 | `Manrope` | `15–17 px` | `600`; analytics section titles may use `700` | Figma `AUTO` | Section headings; Courses Hub headings use `15 px`, Home uses `17 px`, and support section heading uses `16 px`. |
| Body | `Manrope` | `11–12 px` | `400` | `16–19 px` when explicitly set; otherwise Figma `AUTO` | Supporting copy, subtitles, and descriptive text. Login subtitle uses `11 / 16 px`; success description uses `12 / 19 px`. |
| Caption / small | `Manrope` | `8–10 px` | `400`; emphasized labels may use `600` | `12–14 px` where explicitly set; otherwise Figma `AUTO` | Labels, metadata, course details, and helper text. |
| Button | `Manrope` | `12 px` | `600` | `17 px` on authentication buttons; `AUTO` elsewhere | Primary and secondary button labels. Subscription Code Submit uses the approved larger `15 px` variant. |

### Exact frequently used text styles

| Usage | Family | Size | Weight | Line height | Color |
|---|---|---|---|---|---|
| Standard module screen title | `Manrope` | `23 px` | `600` | `AUTO` | `#141A21` |
| Login heading | `Manrope` | `23 px` | `600` | `31 px` | `#0E1217` |
| OTP heading | `Manrope` | `21 px` | `600` | `29 px` | `#0E1217` |
| Courses Hub section heading | `Manrope` | `15 px` | `600` | `AUTO` | `#141A21` |
| Home service heading | `Manrope` | `17 px` | `600` | `AUTO` | `#141A21` |
| Analytics section heading | `Manrope` | `16 px` | `700` | `AUTO` | `#0E1217` |
| Analytics card heading | `Manrope` | `14 px` | `700` | `AUTO` | `#0E1217` |
| Standard screen subtitle | `Manrope` | `12 px` | `400` | `AUTO` | `#6B7385` |
| Login subtitle | `Manrope` | `11 px` | `400` | `16 px` | `#747D8B` |
| Course-card title | `Manrope` | `10 px` | `600` | `AUTO` | `#141A21` |
| Course-card metadata | `Manrope` | `8–9 px` | `400` | `AUTO` | `#6B7385` |
| Form field label | `Manrope` | `11 px` | `600` | `AUTO` | `#30383B` |
| Form field value / placeholder | `Manrope` | `10 px` | `400` | `AUTO` | `#404F45` / `#99A3A1` |
| Primary authentication button | `Manrope` | `12 px` | `600` | `17 px` | `#FFFFFF` |
| OTP digit | `Manrope` | `20 px` | `600` | `AUTO` | `#0E1217` |

## Shape & spacing

| Token | Value |
|---|---|
| Design viewport | `360 × 800 px` |
| Card corner radius | `14 px` for course/catalogue cards; `16 px` for Home module cards and analytics cards. |
| Button corner radius | `25 px` for `50 px` authentication buttons; `23 px` for `46 px` support/secondary buttons; `14 px` for the `54 px` Subscription Code button. |
| Input corner radius | `12 px` for login inputs; `8 px` for Help & Support inputs; `11 px` for OTP boxes; `14 px` for the Subscription Code input. |
| Screen horizontal padding | `20 px` on application screens; `40 px` on Login and OTP screens. |
| Default gap between cards | `12 px` vertically in catalogue/Home grids; `18 px` horizontally in the two-column course catalogue; `8 px` horizontally between Home module cards and analytics summary cards. |
| Button height | `50 px` for login/OTP; `46 px` for Help & Support and secondary actions; `54 px` for Subscription Code Submit. |
| Input height | `50 px` for login; `42 px` for Help & Support; `54 px` for OTP boxes and Subscription Code; `82 px` for the support message textarea. |
| Header divider height | `1 px` |
| Standard content width | `320 px` within the `360 px` mobile viewport. |
| Authentication content width | `280 px` within the `360 px` mobile viewport. |
| Course catalogue card | `150 × 188 px`, radius `14 px`. |
| Course recommendation card | Approximately `150 × 130 px`, radius `14 px`. |
| Home module card | `156 × 164 px`, radius `16 px`. |
| OTP digit box | `40 × 54 px`, radius `11 px`, with `8 px` gaps. |
| Side-menu drawer width | `304 px` within the `360 px` viewport. |
| Success modal card | `312 × 285 px`, radius `20 px`. |

## Shadows, overlays, and imagery

| Element | Exact Figma treatment |
|---|---|
| Standard catalogue course-card shadow | `0 4px 10px rgba(0, 0, 0, 0.12)` |
| Courses Hub recommendation-card shadow | `0 4px 8px rgba(0, 0, 0, 0.10)` |
| Analytics-card shadow | `0 3px 10px rgba(10, 26, 10, 0.08)` |
| Primary authentication-button shadow | `0 5px 12px rgba(23, 65, 18, 0.22)` |
| Side-menu drawer shadow | `8px 0 18px rgba(5, 13, 5, 0.22)` |
| Subscription-success modal shadow | `0 10px 24px rgba(0, 0, 0, 0.18)` |
| Login / OTP image layer | Figma layer name: `Authentication Background`; full-screen `360 × 800 px` image fill. Export/reuse the actual image from Figma rather than substituting a different image. |
| Login / OTP image blur | Figma `LAYER_BLUR`, radius `11 px`. |
| Login / OTP image veil | Figma layer name: `Authentication Soft Veil`; `#FFFDF6` at `18%` opacity. |
| Subscription success scrim | `#050A08` at `48%` opacity. |

## Implementation notes

1. Treat the approved Figma screens as the source of truth; do not continue using legacy application colors `#48B401` and `#FB562A`.
2. Use `Manrope` instead of Inter, Jost, or Mulish.
3. Preserve the documented component-specific variants; one global radius or height cannot reproduce every approved screen.
4. The Home card colors above are taken from the approved `01 • Home` frame. The underlying duplicated Home content inside `07 • Menu Open` still contains older colors and must not override the actual Home frame.
5. Use red `#E53935`, yellow `#F2A511`, and green `#397B27` for lesson status. Do not substitute the separate analytics-chart series colors.
6. OTP helper text must read exactly: `OTP expires in 10 minutes`. Do not show a countdown timer.
7. Maintain the `360 × 800 px` reference viewport and implement real vertical scrolling rather than increasing screen height.
