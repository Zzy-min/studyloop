# Design Specification: StudyLoop UI Comprehensive Redesign & Design System

- **Author**: StudyLoop Engineering & Design
- **Date**: 2026-09-01
- **Status**: Draft / Pending Approval
- **Target OS**: Android (Material 3)
- **Reference Artwork**: 4 Mockup Screens (`media_1788250547119.png`)

---

## 1. Executive Summary & Vision

StudyLoop is an Android study starter companion for university students addressing the psychological inertia:
> *"I know I should study, but why can't I just start?"*

The visual and UX direction is:
**Clean Minimalist + Android Material 3 + Gentle Non-judgmental Companionship**.
- Color Tone: Natural Sage Green (`#5FAF68`), Soft Warm-White (`#F8F9F3`), Pure White surfaces (`#FFFFFF`).
- Emotional feeling: A quiet Welsh Corgi sitting beside you without pressure, judgment, or gamified stress.
- Principle: Strictly local deterministic rules, zero generative AI at runtime, zero punitive language on early session stops.

---

## 2. Design System Architecture (`lib/design_system/`)

### 2.1 Color Tokens (`colors.dart`)
- **Primary Green**:
  - `primary`: `#5FAF68` (Natural sage green)
  - `primaryDark`: `#46884E`
  - `primaryLight`: `#E8F4E9` (Soft green surface tint)
  - `primaryContainer`: `#EEF6EF`
- **Background & Surfaces**:
  - `background`: `#F8F9F3` (Soft warm off-white)
  - `surface`: `#FFFFFF` (Pure white for cards)
  - `surfaceSecondary`: `#F2F4EC` (Light neutral container)
- **Neutral Typography & Borders**:
  - `textPrimary`: `#1C251D` (Deep charcoal green, softer than pure black)
  - `textSecondary`: `#5F7061` (Calm slate green-gray)
  - `textTertiary`: `#8F9E91` (Muted placeholder/caption)
  - `border`: `#E1E7DE` (Subtle divider/border)
  - `borderSelected`: `#5FAF68` (Active state border)
- **Functional Semantics**:
  - `warning`: `#F59E0B`
  - `endEarlySalmon`: `#E57373` (Warm coral/salmon red for "结束并保存", friendly and gentle)
  - `chartBlue`: `#64B5F6`
  - `chartYellow`: `#FFD54F`
  - `chartPurple`: `#BA68C8`

### 2.2 Typography Scale (`typography.dart`)
- `display`: 28–32sp, Bold (Display titles)
- `pageTitle`: 22–24sp, Bold (`今天想解决什么问题？`, `专注中`, `我的学习洞察`)
- `sectionTitle`: 17–19sp, SemiBold (`今日建议的最小行动`, `个人规律`)
- `cardTitle`: 15–16sp, Medium/SemiBold
- `body`: 14–15sp, Regular, line-height 1.45
- `caption`: 12–13sp, Regular
- `timerDigits`: 52–60sp, Medium/SemiBold tabular figures

### 2.3 Spacing Scale (`spacing.dart`)
- `xxs`: 4dp, `xs`: 8dp, `sm`: 12dp, `md`: 16dp, `lg`: 20dp, `xl`: 24dp, `xxl`: 32dp, `xxxl`: 40dp, `huge`: 48dp

### 2.4 Radius & Shadows (`radius.dart` & `shadows.dart`)
- Radius: `sm` (8dp), `md` (12dp), `lg` (16dp), `xl` (20dp), `pill` (28dp), `full` (999dp).
- Shadows: Very soft, minimal elevation: `BoxShadow(color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 3))`.

---

## 3. Screen Breakdown & Mapping

1. **欢迎页 Welcome (`/welcome`)**:
   - Breathing space, infinity logo, `StudyLoop`, `从现在开始，
迈出你的一小步。`, Sitting Corgi with green bandana, `开始你的学习之旅` primary button, `🌐 Language / 语言` secondary button, privacy badge `🛡 所有数据保存在本地设备中 · 隐私安心`.
2. **首页 / 学习启动 Home (`/`)**:
   - Header: `早上好！👋` + settings icon.
   - 5 compact horizontal barrier cards: `无从下手`, `任务太多`, `手机干扰`, `精力不足`, `过度准备`.
   - `今日建议的最小行动` card: document icon, task title, action description, chevron `>`, chips (`预计专注 25 分钟`, `难度预估 中等`), and Primary CTA `▶ 开始专注`.
   - 底部柯基陪伴模块: `柯基伙伴在这里陪着你 🐾`, `准备好就开始吧，我会在这里等你回来～`, `● 等待中`, Resting Corgi on green cushion.
   - 4-item Bottom Navigation Bar (`首页`, `记录`, `洞察`, `我的`).
3. **专注页面 Focus Timer (`/focus`)**:
   - `✕`, `专注中` (`仅统计前台时间`), `🎵`.
   - Sage green circular progress ring with focusing corgi (headphones + laptop).
   - Digital countdown (`24:36`), `⏸ 暂停` / `▶ 继续`.
   - Task card with green indicator bar, target duration with `编辑` button.
   - Non-punitive reassurance: `提前结束也没关系 我们会如实记录你的实际投入时间。`
   - Coral/salmon red bottom button: `结束并保存`.
4. **学习洞察 Insights (`/insights`)**:
   - `我的学习洞察` / `基于你的真实记录生成`.
   - Range tabs: `周` | `月` | `3月` | `全部`.
   - Focus Time Metric Card with bar chart (`专注时长 28.4 小时`, `较上月 ↑ 18%`).
   - Pattern cards: `最适合你的专注时长` (clock icon), `最佳专注时段` (sunrise icon), `任务类型分布` (donut chart).
   - Empty state for < 3 records.
