# StudyLoop Privacy Policy (隐私政策)

**Last Updated / 最近更新日期**: September 2, 2026
**Effective Date / 生效日期**: September 2, 2026
**Status**: READY FOR DEPLOYMENT / PUBLIC HOSTING

---

## 1. Overview (概述)

StudyLoop is an Android study-start companion designed to help university students overcome starting friction. We are committed to protecting user privacy through a **local-first architecture and strict data minimization**.

StudyLoop 是一款面向大学生的 Android 学习启动辅助应用。我们通过“本地优先”与“数据最小化”架构保护用户的隐私。

* **No Account Required (无需注册)**: You do not need to register, provide an email, or sign in to use StudyLoop.
* **On-Device Storage (本地存储)**: Your daily tasks, starting barriers, focus timers, reflections, and insights are stored locally on your device in SQLite.

---

## 2. Information We Handle (数据收集与处理范围)

### 2.1 Local Study Records (本地学习数据)
The following data is created and stored strictly on your local device:
* Task titles, selected task categories (e.g. Exam Revision, Programming, Paper Writing);
* Identified study barriers (e.g. Unsure where to start, Overload, Phone distraction, Tiredness, Perfectionism);
* Planned focus duration and actual foreground focus duration;
* Post-session reflection ratings (difficulty, focus level, mood change, next micro-action);
* Local historical statistics and pattern calculations.

**Data Transfer**: This data **NEVER** leaves your device unless you explicitly initiate a conversation with the AI Companion or back up your device.

### 2.2 Subscription & Purchase Information (RevenueCat)
StudyLoop uses RevenueCat to facilitate In-App Purchases for StudyLoop Pro entitlements on Google Play:
* **What is processed**: Anonymous app user ID, purchase token, transaction receipt, active entitlement status (Free vs. Pro).
* **Boundary**: RevenueCat receives only transaction metadata necessary to unlock Pro features. Your task names, study history, and reflections are **NEVER** shared with RevenueCat.

### 2.3 AI Corgi Learning Companion (柯基 AI 学习伴侣)
When you actively use the Corgi Companion chat, messages are processed through an AI service to deliver supportive dialogue and micro-action suggestions:
* **What is sent**:
  * The message text you type into the chat;
  * Your current selected barrier and active task name (to contextualize advice);
  * A locally aggregated summary of the past 7 days (e.g. "4 sessions completed, average 18 minutes, primary category: Programming").
* **What is NOT sent**:
  * Your full SQLite database;
  * Historical log of all individual past sessions;
  * Hardware serial numbers or personal identifiers.
* **Consent & Transparency**: You are shown an in-app disclosure upon first opening the AI Companion. You can choose whether to communicate with the AI Companion.
* **Offline Resilience**: If your device is offline or the AI service is unreachable, StudyLoop seamlessly falls back to local deterministic rule-based suggestions.

---

## 3. Medical and Health Disclaimer (非医疗声明)

StudyLoop and the Corgi AI Companion are designed solely for educational motivation and task reduction.
* StudyLoop does **NOT** provide medical, clinical psychological, or psychiatric diagnosis or treatment.
* StudyLoop does **NOT** claim to cure ADHD, clinical depression, anxiety, or chronic medical fatigue.
* If you experience severe physical discomfort, mental health crises, or self-harm thoughts, please seek assistance from licensed medical professionals or emergency services immediately.

---

## 4. Third-Party Services (第三方服务)

| Service | Purpose | Privacy Policy |
| :--- | :--- | :--- |
| **Google Play Services** | App distribution, in-app billing | [Google Privacy Policy](https://policies.google.com/privacy) |
| **RevenueCat** | Subscription status verification | [RevenueCat Privacy Policy](https://www.revenuecat.com/privacy) |
| **AI Gateway Service** | Natural language processing for companion suggestions | Governed by enterprise zero-retention API agreements |

---

## 5. Data Retention & Deletion (数据保留与删除)

* You have total ownership and control over your data.
* You can delete individual session records directly from the **Record Detail (记录详情)** screen.
* You can erase all data at any time by uninstalling the application or clearing App Storage in Android Settings.

---

## 6. Contact Us (用户支持与联系方式)

If you have questions, privacy inquiries, or feedback regarding this policy, please reach out via:
* **Project Repository**: File an issue in the official StudyLoop issue tracker.
* **Support Email**: `support@studyloop.app` (SUPPORT CONTACT REQUIRED BEFORE RELEASE)
