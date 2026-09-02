# Spec: Authentic Corgi Companion & Interactive Chat Dialog

## Context & Goals

The user requested two key enhancements to StudyLoop:
1. **唤起聊天框 (Evoking Chat Dialog & Soft Keyboard Fix)**:
   - Provide an interactive, cozy chat dialog with the study companion dog to talk through study paralysis, emotional friction, and get micro-step suggestions.
   - Resolve soft keyboard (Android IME) popup issues on Android/Vivo devices across all input fields.
2. **柯基真实形象 (Authentic Welsh Corgi Visuals)**:
   - Upgrade the abstract blue companion icon to an authentic, adorable Welsh Corgi dog vector art with characteristic golden-orange fur, white blaze, large rounded perky ears with pink inner pads, shiny black nose, and 6 expressive emotional states (waiting, prompting, focusing, completed, interrupted, resting).

## Architecture & Design

### 1. Vector Asset Specifications (assets/dog_svg/)
- Width / Height: 100x100 (viewBox: 0 0 100 100)
- Color Palette:
  - Coat Primary (Golden Honey/Orange): #E58E3A, #D47728
  - Coat Secondary (Cream White): #FFFFFF, #FFFDF8
  - Ear Inner Pads: #F9B7C6
  - Eyes & Nose: #2A1F18, Catchlights #FFFFFF
  - Tongue / Mouth: #F87171
  - Cheeks: #FCA5A5 (gentle blush)
- 6 States:
  - waiting.svg: Front-facing happy Corgi with alert perky ears, bright smile, gentle tail wag.
  - prompting.svg: Adorable head-tilted Corgi with curious expression and tilted ears.
  - focusing.svg: Serene Corgi sitting/lying calmly in companion sphinx pose.
  - completed.svg: Joyous celebratory Corgi with happy curved eyes, open mouth and pink tongue.
  - interrupted.svg: Warm empathetic Corgi offering comfort and reassurance.
  - resting.svg: Curled-up sleeping Corgi with closed peaceful eyes and paws tucked in.

### 2. Corgi Chat Engine (lib/domain/corgi_chat_engine.dart)
- Offline, deterministic rule-based dialogue matching.
- Pre-loaded emotional support prompts:
  - 摸摸柯基小狗 -> Warm tail wag and cuddly reassurance.
  - 帮我把任务拆更小 -> Analyzes current task draft or barrier and suggests an effortless micro-step.
  - 学得好累，想要放弃 -> Gentle permission to rest or do a 5-minute tiny interval.
  - 总是忍不住想玩手机 -> Non-shaming reframing: put the phone 1 meter away, open 1 page.
  - 觉得好难，不知道怎么开始 -> Encourages the 'open file / write 1 line' principle.
- Free-form text matching:
  - Keyword extraction (e.g., 累, 手机, 难, 害怕, 不想学, 数学, 代码, 论文, 放弃) -> contextual, warm response with actionable advice.

### 3. Corgi Chat Modal (lib/presentation/widgets/corgi_chat_dialog.dart)
- Triggered by tapping the companion card anywhere or via header chat icon.
- Features:
  - Top header with Corgi avatar & live state.
  - Scrollable message history with animated bubbles.
  - Quick action chips horizontally scrollable.
  - Text input with auto-focus, send button, and keyboard handling.
  - Action card to insert micro-action directly into task draft if applicable.

### 4. Input Keyboard Reliability
- Clean up TextField implementations in TaskScreen and ReflectionScreen.
- Remove manual SystemChannels.textInput invocations that cause IME race conditions on Android.
- Ensure standard FocusNode with focusNode.requestFocus() on tap.
