# Figma Export Drop Zone

Source of truth: **WEMA Bank Mobile Assets and Design**, starting at `node-id=48-284`.
Drop exported design material here so the implementation can match Figma exactly.

## What to put where

### 1. `screens/` — one PNG per frame (the most important thing)
Export **every** screen frame in the approved flow, at **2x PNG**.
Name each file after the screen so mapping is unambiguous, e.g.:

```
01_splash.png
02_onboarding_1_my_courses.png
02_onboarding_2_track_performance.png
02_onboarding_3_contact_admin.png
02_onboarding_4_subscription_code.png
02_onboarding_5_biometrics.png
03_login.png
04_otp.png
05_home.png
06_courses_hub.png
07_my_courses_all_open.png
07_my_courses_completed.png
07_my_courses_in_progress.png
08_course_content.png
09_catalogue.png
09_catalogue_filter.png
09_catalogue_marketing_selected.png
10_subscribe_success.png
11_request_approval_popup.png
11_request_submitted_success.png
12_side_menu.png
13_my_learning.png
14_leaderboard.png
15_subscription_code.png
15_subscription_code_success.png
16_communications_list.png
16_communication_detail.png
17_competencies.png
18_certificates.png
19_profile.png
20_help_support.png
20_help_support_success.png
21_about.png
```
(Skip any that don't exist in the file; add any I missed. Exact names aren't critical — just keep them readable.)

**How to export in Figma:** select a frame → right sidebar → **Export** section (bottom) → set **2x** and **PNG** → **Export**. You can multi-select frames and export them all at once.

### 2. `assets/` — icons & illustrations as SVG (preferred) or PNG
The onboarding illustrations, the four home module-card icons, side-menu icons, badge/leaderboard art, lesson-status indicators, empty-state art, and the splash logo/texture.
Export **SVG** where the source is vector (crisp, drops straight into the app's `assets/svg/`); PNG for anything raster. Name them descriptively (`illustration_onboarding_my_courses.svg`, `icon_module_courses.svg`, `badge_latest.svg`, etc.).

### 3. `TOKENS.md` — fill in the values (see the template file next to this README)
Colors, typography, radii, spacing. Easiest source is Figma's **local styles / variables** panel, or **Dev Mode** (select an element → the Inspect panel shows exact hex, font, size, weight, radius, padding). If typing it all is a pain, just drop **screenshots of the Color Styles and Text Styles panels** into this folder instead and I'll read the values off them.

---

When you've dropped the files, tell me and I'll ingest everything, reconcile the tokens against the current app values (`#48B401` green / `#FB562A` orange), and produce the full screen-by-screen implementation plan before touching code.
