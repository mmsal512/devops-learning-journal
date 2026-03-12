# 📝 Daily Learning Log | سجل التعلم اليومي

> Daily documentation of my DevOps learning journey.
> One commit a day. One step closer to mastery.

> توثيق يومي لرحلتي في تعلم DevOps.
> التزام واحد يومياً. خطوة أقرب نحو الإتقان.

---

## 📅 2026-03-11 — Day 2 | اليوم الثاني

### 🎯 What I Did Today | ماذا أنجزت اليوم

- ✅ **Created `collect-server-info.sh` — Server Info Collector Script | إنشاء سكربت جمع معلومات السيرفر** — A comprehensive Bash script that collects 16 categories of server information and generates both text and JSON reports for infrastructure planning | سكربت Bash شامل يجمع 16 فئة من معلومات السيرفر وينتج تقارير نصية و JSON للتخطيط البنيوي
  - **16 Sections | 16 قسمًا:** System Info, Hardware & Resources, Network Config, SSH Config, Firewall (UFW/iptables), Docker Environment, Kubernetes (K3s), Security Tools, Installed DevOps Tools, Cloudflare Tunnel, Traefik Reverse Proxy, Domain & SSL, Cron Jobs, Docker Compose ENV (Sanitized), Resource Assessment, JSON Summary | معلومات النظام، الموارد، الشبكة، SSH، الجدار الناري، Docker، K3s، أدوات الأمان، أدوات DevOps، Cloudflare Tunnel، Traefik، النطاقات و SSL، المهام المجدولة، متغيرات البيئة (محمية)، تقييم الموارد، ملخص JSON
  - **Dual Output | مخرجات مزدوجة:** Human-readable text report + machine-parseable JSON report | تقرير نصي مقروء + تقرير JSON قابل للتحليل
  - **Security-First Approach | نهج الأمان أولاً:** Automatic masking of sensitive environment variables (passwords, tokens, API keys) | إخفاء تلقائي للمتغيرات الحساسة (كلمات المرور، التوكنات، مفاتيح API)
  - **Resource Assessment | تقييم الموارد:** Automatic evaluation of RAM, Disk, and CPU to determine if the server can handle additional workloads | تقييم تلقائي للرام، القرص، والمعالج لتحديد إمكانية تحمّل أعباء إضافية

### 🛠️ Tools & Technologies Used | الأدوات والتقنيات المستخدمة

| Tool / الأداة | Purpose / الغرض |
| :--- | :--- |
| Bash | Writing the server info collection script / كتابة سكربت جمع معلومات السيرفر |
| `set -euo pipefail` | Strict error handling / معالجة الأخطاء الصارمة |
| `tee` | Dual output to terminal and file simultaneously / إخراج مزدوج للطرفية والملف |
| `free`, `df`, `nproc` | Collecting hardware resource info / جمع معلومات الموارد |
| `ss`, `ip`, `curl` | Network configuration detection / اكتشاف إعدادات الشبكة |
| Docker CLI | Inspecting containers, images, volumes, networks / فحص الحاويات والصور والشبكات |
| `kubectl` / `k3s` | Kubernetes cluster inspection / فحص كلستر Kubernetes |
| `jq` | JSON processing for Traefik route extraction / معالجة JSON لاستخراج مسارات Traefik |
| `openssl` | SSL certificate expiry checking / فحص انتهاء شهادات SSL |
| `ufw` / `iptables` | Firewall rules inspection / فحص قواعد الجدار الناري |

### 📚 What I Learned | ماذا تعلمت

1. **Comprehensive Server Auditing | مراجعة السيرفر الشاملة** — How to systematically collect all critical info (system, hardware, network, security, containers, K8s) in a single automated script | كيفية جمع جميع المعلومات الحرجة بشكل منهجي في سكربت آلي واحد
2. **Sanitizing Secrets for Public Repos | تنظيف الأسرار للريبوهات العامة** — Using `grep -qiE` to detect sensitive env variable names and mask their values with `********` | استخدام `grep -qiE` لاكتشاف أسماء المتغيرات الحساسة وإخفاء قيمها
3. **Resource Capacity Planning | تخطيط سعة الموارد** — Automated assessment of available RAM, disk, and CPU load to make informed decisions about running additional workloads | تقييم آلي للرام والقرص وحمل المعالج لاتخاذ قرارات مبنية على بيانات
4. **Dual Report Formats | صيغ التقارير المزدوجة** — Generating both human-readable (colorized text) and machine-readable (JSON) reports from the same data collection | إنتاج تقارير مقروءة للبشر (نص ملون) وقابلة للتحليل (JSON) من نفس البيانات
5. **Safe Command Execution | تنفيذ الأوامر الآمن** — Using `safe_run()` wrapper and `2>/dev/null` to gracefully handle missing tools or permission errors | استخدام دالة `safe_run()` و `2>/dev/null` للتعامل بأمان مع الأدوات المفقودة أو أخطاء الصلاحيات

### 💡 Key Takeaways | الخلاصات الرئيسية

> **EN:** Before starting any infrastructure project, you must collect and understand the current state of your server. A well-structured info collector script saves hours of manual investigation and provides a clear picture for capacity planning. Always sanitize sensitive data before sharing or committing to public repos.

> **AR:** قبل بدء أي مشروع بنية تحتية، يجب جمع وفهم الحالة الحالية للسيرفر. سكربت جمع المعلومات المنظم يوفر ساعات من البحث اليدوي ويقدم صورة واضحة لتخطيط السعة. دائمًا نظّف البيانات الحساسة قبل المشاركة أو الرفع على ريبوهات عامة.

### 📊 Progress | التقدم

- 🔥 Current Streak / السلسلة الحالية: **2 days / يومان**
- 📈 Total Commits Today / التزامات اليوم: **1**
- 🎯 Focus Area / مجال التركيز: Linux Scripting & Infrastructure Auditing / سكربتات لينكس ومراجعة البنية التحتية

---

## 📅 2026-03-10 — Day 1 | اليوم الأول

### 🎯 What I Did Today | ماذا أنجزت اليوم

- ✅ **Created daily-commit-reminder automation script | إنشاء سكربت تذكير الالتزام اليومي** — A Bash script that monitors my Git activity and sends Telegram notifications as reminders to commit daily | سكربت Bash يراقب نشاطي في Git ويرسل إشعارات تلجرام كتذكيرات للالتزام اليومي
  - Features | المميزات: Streak tracking, urgency levels (morning/afternoon/evening), test mode, status dashboard | تتبع السلسلة، مستويات الإلحاح (صباح/ظهر/مساء)، وضع الاختبار، لوحة الحالة
  - Telegram Bot integration for real-time notifications in Arabic | دمج بوت تلجرام للإشعارات الفورية بالعربية
  - Cron job setup for 3x daily reminders (10 AM, 4 PM, 9 PM) | إعداد مهام Cron لـ 3 تذكيرات يومية (10 ص، 4 م، 9 م)

- ✅ **Set up devops-learning-journal repository | إعداد مستودع دفتر التعلم** — Created a structured learning journal with organized folders for each DevOps domain | إنشاء دفتر تعلم منظم بمجلدات مرتبة لكل مجال DevOps

- ✅ **Created GitHub profile README | إنشاء ملف README للبروفايل** — Professional profile with badges, tech stack, featured projects, GitHub analytics, and learning roadmap | بروفايل احترافي يحتوي على شارات، التقنيات، المشاريع المميزة، إحصائيات GitHub، وخارطة طريق التعلم

### 🛠️ Tools & Technologies Used | الأدوات والتقنيات المستخدمة

| Tool / الأداة | Purpose / الغرض |
| :--- | :--- |
| Bash | Scripting the daily reminder automation / كتابة سكربت أتمتة التذكير اليومي |
| Telegram Bot API | Sending notification reminders / إرسال إشعارات التذكير |
| Cron | Scheduling automated checks / جدولة الفحوصات التلقائية |
| Git | Version control & contribution tracking / التحكم بالإصدارات وتتبع المساهمات |
| Markdown | Documentation / التوثيق |

### 📚 What I Learned | ماذا تعلمت

1. **Telegram Bot API** — How to use `curl` with the Telegram Bot API to send formatted Markdown messages | كيفية استخدام `curl` مع Telegram Bot API لإرسال رسائل Markdown منسقة
2. **Git Log Filtering** — Using `git log --since` and `--format=%cd --date=short` to check commit dates | استخدام `git log --since` و `--format=%cd --date=short` للتحقق من تواريخ الالتزامات
3. **Bash Best Practices** — Using `set -euo pipefail`, proper error handling, and structured script arguments | استخدام `set -euo pipefail`، معالجة الأخطاء السليمة، والمعاملات المنظمة
4. **Streak Tracking** — Iterating through dates to calculate consecutive commit days | التكرار عبر التواريخ لحساب أيام الالتزام المتتالية

### 💡 Key Takeaways | الخلاصات الرئيسية

> **EN:** Automating reminders is a great way to build habits. The best way to maintain a green contribution graph is to integrate learning into your daily routine and document everything you do.

> **AR:** أتمتة التذكيرات طريقة ممتازة لبناء العادات. أفضل طريقة للحفاظ على رسم بياني أخضر للمساهمات هي دمج التعلم في روتينك اليومي وتوثيق كل ما تفعله.

### 📊 Progress | التقدم

- 🔥 Current Streak / السلسلة الحالية: **1 day / يوم واحد**
- 📈 Total Commits Today / التزامات اليوم: **1**
- 🎯 Focus Area / مجال التركيز: Automation & Scripting / الأتمتة والسكربتات

---

<!-- 
## 📅 YYYY-MM-DD — Day N | اليوم N

### 🎯 What I Did Today | ماذا أنجزت اليوم
- 

### 🛠️ Tools & Technologies Used | الأدوات والتقنيات المستخدمة
| Tool / الأداة | Purpose / الغرض |
| :--- | :--- |
|  |  |

### 📚 What I Learned | ماذا تعلمت
1. 

### 💡 Key Takeaways | الخلاصات الرئيسية
> **EN:** 
> **AR:** 

### 📊 Progress | التقدم
- 🔥 Current Streak / السلسلة الحالية: ** days / أيام**
- 📈 Total Commits Today / التزامات اليوم: ****
- 🎯 Focus Area / مجال التركيز: 
-->
