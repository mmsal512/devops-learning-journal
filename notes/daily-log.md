# 📝 Daily Learning Log | سجل التعلم اليومي

> Daily documentation of my DevOps learning journey.
> One commit a day. One step closer to mastery.

> توثيق يومي لرحلتي في تعلم DevOps.
> التزام واحد يومياً. خطوة أقرب نحو الإتقان.

---

## 📅 2026-03-25 — Day 12 | اليوم الثاني عشر

### 🎯 What I Did Today | ماذا أنجزت اليوم

- ✅ **Optimized Cloudflare Caching & Fixed GitHub API Sync in Laravel Portfolio | تحسين تخزين Cloudflare المؤقت وإصلاح مزامنة GitHub API في معرض الأعمال Laravel** — Repaired tracking mechanisms by configuring Cloudflare Cache Rules and built an automated background process to synchronize GitHub project metrics without manual intervention | إصلاح آليات التتبع من خلال تكوين قواعد التخزين المؤقت في Cloudflare وبناء عملية تلقائية في الخلفية لمزامنة مقاييس مشاريع GitHub دون تدخل يدوي.
  - **Dynamic Route Caching Bypass | تجاوز التخزين المؤقت للمسارات الديناميكية:** Wrote Cloudflare custom rules to bypass HTML caching for specific sensitive and tracked routes (like admin panels and file downloads), ensuring the origin server correctly tracks visitor analytics and increments database counters | كتابة قواعد مخصصة في Cloudflare لتجاوز التخزين المؤقت لمسارات محددة لضمان تتبع الزوار بشكل صحيح وزيادة عدادات قاعدة البيانات.
  - **Automated GitHub Metrics Sync | مزامنة تلقائية لمقاييس GitHub:** Developed an Artisan command (`github:refresh`) utilizing Laravel's HTTP client to fetch repositories' stars and forks safely | تطوير أمر Artisan لجلب بيانات النجوم والتفرعات من مستودعات GitHub بشكل آمن.
  - **Dockerized Laravel Scheduler | جدولة مهام Laravel داخل Docker:** Integrated `php artisan schedule:work` into `supervisord.conf` to run scheduled jobs resiliently inside the production container, enabling the hourly GitHub metrics sync | دمج أمر الجدولة في Supervisor لتشغيل المهام المجدولة داخل حاوية الإنتاج، مما يتيح التحديث التلقائي كل ساعة.

### 🛠️ Tools & Technologies Used | الأدوات والتقنيات المستخدمة

| Tool / الأداة | Purpose / الغرض |
| :--- | :--- |
| Cloudflare | Edge Caching & Page Rules / التخزين المؤقت والقواعد على الحافة |
| Laravel Scheduler | Task Scheduling & Automation / جدولة المهام والأتمتة |
| Docker & Supervisor | Process Management inside containers / إدارة العمليات داخل الحاويات |

### 📚 What I Learned | ماذا تعلمت

1. **Edge Caching vs Origin Tracking | التخزين المؤقت مقابل تتبع الخادم الأولي** — Understanding how aggressive CDN caching can break server-side analytics, and how to surgically bypass cache for interactive or tracked routes using URI Path rules.
2. **Containerized Cron Jobs | المهام المجدولة داخل الحاويات** — How to properly run background scheduling processes (like Laravel's schedule:work) inside a Docker container without relying on the host machine's cron tab, directly managed by Supervisor.
3. **API Rate Limit Awareness | الوعي بحدود استخدام API** — Designing automated API calls (via HTTP facade) to respect external provider rate limits (GitHub API 5000/hr) by caching the process appropriately and running it at measured intervals.

### 💡 Key Takeaways | الخلاصات الرئيسية

> **EN:** A robust infrastructure shouldn't require manual maintenance. Automating data syncs via supervised container processes and setting precise CDN cache rules are hallmarks of a mature DevOps setup.
> **AR:** البنية التحتية القوية يجب ألا تتطلب صيانة يدوية. أتمتة مزامنة البيانات عبر عمليات الحاويات ووضع قواعد دقيقة لشبكة التوصيل (CDN) هي من علامات النضج في بيئات DevOps.

### 📊 Progress | التقدم

- 🔥 Current Streak / السلسلة الحالية: **12 days / 12 أيام**
- 📈 Total Commits Today / التزامات اليوم: **2**
- 🎯 Focus Area / مجال التركيز: CDN Optimization & Container Scheduled Tasks / تحسين شبكات التوصيل والمهام المجدولة للحاويات

---
## 📅 2026-03-18 — Day 5 | اليوم الخامس

### 🎯 What I Did Today | ماذا أنجزت اليوم

- ✅ **Developed Personal Portfolio Website `mmsal512.cloud` | تطوير موقع شخصي ومعرض أعمال `mmsal512.cloud`** — Built and launched a professional portfolio using PHP, Laravel, and PostgreSQL database to showcase my DevOps, cloud, and full-stack development skills | بناء وإطلاق موقع شخصي احترافي يعرض مهاراتي وخبراتي في مجال DevOps والتطوير السحابي باستخدام بيئة Laravel و PostgreSQL.
  - **Dynamic Content Management | إدارة محتوى ديناميكية:** Set up a secure database schema to manage projects, skills, and experiences.
  - **Custom Domain Integration | ربط النطاق المخصص:** Deployed and linked the application to `mmsal512.cloud` (formerly `tabdil.mmsal512.cloud`), implementing proper UI/UX principles.
  - **Private Repository | مستودع خاص:** The source code is maintained in a private repository `Mywebsite` to ensure security and manage proprietary implementations.

### 🛠️ Tools & Technologies Used | الأدوات والتقنيات المستخدمة

| Tool / الأداة | Purpose / الغرض |
| :--- | :--- |
| PHP & Laravel | Full-stack web framework / إطار عمل تطوير الويب |
| PostgreSQL (pgsql) | Relational database management / إدارة قواعد البيانات العلائقية |
| Git | Private repository management / إدارة المستودعات الخاصة |

### 📚 What I Learned | ماذا تعلمت

1. **Portfolio Architecture | معمارية معرض الأعمال** — Designing a portfolio that technically reflects the infrastructure knowledge I claim, demonstrating that the site is secure, fast, and maintainable.
2. **Database Migrations in PgSQL | ترحيل قواعد البيانات** — Creating efficient tables and relationships specific to PostgreSQL within the Laravel environment.
3. **Domain Management | إدارة النطاقات** — Managing custom domains and migrating from a subdomain (`tabdil.mmsal512.cloud`) to the main domain (`mmsal512.cloud`).

### 💡 Key Takeaways | الخلاصات الرئيسية

> **EN:** Building your own portfolio using the technologies you advocate for is the ultimate proof of skill. Treating a personal website as a real, production-ready DevOps project reinforces best practices.

> **AR:** بناء موقعك الشخصي باستخدام التقنيات التي تتقنها هو الدليل القاطع على مهاراتك. معاملة الموقع الشخصي كمشروع حقيقي يعزز أفضل الممارسات.

### 📊 Progress | التقدم

- 🔥 Current Streak / السلسلة الحالية: **5 days / 5 أيام**
- 📈 Total Commits Today / التزامات اليوم: **1**
- 🎯 Focus Area / مجال التركيز: Full-Stack Development & PostgreSQL / التطوير الشامل وقواعد البيانات

---

## 📅 2026-03-15 — Day 4 | اليوم الرابع

### 🎯 What I Did Today | ماذا أنجزت اليوم

- ✅ **Resolved Docker & Laravel Caching Issues for Local Development | حل مشكلة الكاش في الدوكر واللارافل لبيئة التطوير المحلية** — Understood the root causes of the "Live Reload" issue in Dockerized Laravel applications and implemented a permanent overriding solution without breaking production configurations | فهمت الأسباب الجذرية لمشكلة عدم تحديث الملفات مباشرة في تطبيقات Laravel داخل Docker، وطبقت حلاً جذرياً عبر تجاوز الإعدادات دون التأثير على إعدادات بيئة الإنتاج.
  - **OPcache Bypass | تجاوز OPcache:** Created `php-dev.ini` and mounted it as `zz-dev.ini` to guarantee it overrides production OPcache settings (`opcache.enable=0`), ensuring PHP reads the latest code changes directly from the volume mount | إنشاء ملف إعدادات جديد وتعطيل OPcache ليقوم التطبيق بقراءة التعديلات مباشرة.
  - **Smart Entrypoint Script | سكريبت إقلاع ذكي:** Modified `entrypoint.sh` to dynamically clear Laravel caches (`config:clear`, `route:clear`, `view:clear`) when `APP_ENV=local`, while retaining aggressive caching for production | تعديل سكريبت الإقلاع ليمسح الكاش تلقائياً في بيئة التطوير محلياً ويبقيه في بيئة الإنتاج.
  - **Docker Compose Override | ملف التجاوز:** Utilized `docker-compose.override.yml` to inject development variables (`APP_ENV=local`, `APP_DEBUG=true`) and mount development configuration files seamlessly.

### 🛠️ Tools & Technologies Used | الأدوات والتقنيات المستخدمة

| Tool / الأداة | Purpose / الغرض |
| :--- | :--- |
| Docker & Docker Compose | Containerization and overrides / الحاويات وتجاوز الإعدادات |
| Laravel Artisan | Managing application cache / إدارة الكاش في التطبيق |
| PHP OPcache | Bytecode caching mechanism / آلية التخزين المؤقت للكود المصدري |

### 📚 What I Learned | ماذا تعلمت

1. **The Role of OPcache | دور OPcache** — OPcache compiles and stores PHP scripts in RAM. In a development environment, this prevents live reloading. Disabling it locally is essential to see immediate code changes.
2. **Alphabetical Config Loading | التحميل الأبجدي للإعدادات** — PHP reads `.ini` files in `conf.d` alphabetically. Naming the override file `zz-dev.ini` forces it to load last, successfully overwriting any underlying OPcache configurations.
3. **Dynamic Entrypoints | نقاط الإقلاع الديناميكية** — Using environment variables (e.g., `APP_ENV`) inside `entrypoint.sh` allows a single Dockerfile and script to serve both production (caching) and local development (clearing).

### 💡 Key Takeaways | الخلاصات الرئيسية

> **EN:** To achieve true live reloading in a Dockerized PHP/Laravel environment, you must address both OPcache at the PHP level and Artisan caching at the framework level. Using `docker-compose.override.yml` is the cleanest way to adapt a production-ready container for local development.

> **AR:** للحصول على تحديث مباشر وحقيقي للملفات في بيئة دوكر ولارافل، يجب معالجة الكاش على مستوى لغة PHP (عبر OPcache) وعلى مستوى إطار العمل (عبر Artisan). استخدام ملف التجاوز `docker-compose.override.yml` هو الطريقة الأنظف والأكثر احترافية لتهيئة حاوية الإنتاج للعمل محلياً.

### 📊 Progress | التقدم

- 🔥 Current Streak / السلسلة الحالية: **4 days / 4 أيام**
- 📈 Total Commits Today / التزامات اليوم: **1**
- 🎯 Focus Area / مجال التركيز: Docker Optimization & Local Workflows / تحسين الوكر وسير العمل المحلي

---

## 📅 2026-03-12 — Day 3 | اليوم الثالث

### 🎯 What I Did Today | ماذا أنجزت اليوم

- ✅ **Security Audit for `infra-full-stack` — Found & Fixed 5 Issues | فحص أمني لمشروع البنية التحتية — اكتشاف وإصلاح 5 مشاكل** — Performed a comprehensive security scan of the entire repository before making it public. Removed all hardcoded sensitive data | إجراء فحص أمني شامل للريبو بالكامل قبل نشره عامًا. إزالة جميع البيانات الحساسة المكتوبة مباشرة
  - **Removed real Tailscale IP | إزالة عنوان Tailscale الحقيقي:** Replaced `100.123.45.67` with `YOUR_TAILSCALE_IP` placeholder across 5 files (ansible inventory, playbook, setup script, health-check script) | استبدال العنوان الحقيقي بـ placeholder في 5 ملفات
  - **Removed Grafana password | إزالة كلمة مرور Grafana:** Replaced hardcoded `admin123` from K8s deployment YAML and setup script | إزالة كلمة المرور المكشوفة من ملفات النشر والسكربتات
  - **Removed server hostname | إزالة اسم السيرفر:** Cleaned `srv-example-123` references from ansible inventory and scripts | تنظيف مراجع اسم السيرفر من ملفات Ansible والسكربتات
  - **Verified GitHub Actions Secrets | التحقق من أسرار GitHub Actions:** Confirmed all 6 secrets (DOCKER_USERNAME, DOCKER_TOKEN, SERVER_TAILSCALE_IP, SSH_PRIVATE_KEY, TELEGRAM_TOKEN, TELEGRAM_CHAT_ID) use `${{ secrets.* }}` properly | التأكد من أن جميع الأسرار الستة تستخدم مراجع آمنة

- ✅ **Migrated Grafana Password to Kubernetes Secrets | ترحيل كلمة مرور Grafana إلى K8s Secrets** — Replaced the hardcoded password in `grafana/deployment.yaml` with a `secretKeyRef` that reads from a Kubernetes Secret, which is automatically created by the CD pipeline from a GitHub Secret | استبدال كلمة المرور الثابتة بـ `secretKeyRef` يقرأ من K8s Secret يُنشأ تلقائيًا من GitHub Secret
  - **Flow | المسار:** `GitHub Secret (GRAFANA_ADMIN_PASSWORD)` → `SSH Action (envs)` → `kubectl create secret` → `K8s Secret (grafana-secrets)` → `Grafana Pod (secretKeyRef)`
  - **Updated `cd.yaml` | تحديث خط النشر:** Added `env` block and `envs` parameter to pass the secret via SSH, and a `kubectl create secret --dry-run=client -o yaml | kubectl apply` command for idempotent secret creation | إضافة تمرير المتغير عبر SSH وأمر إنشاء السر بطريقة متكررة

- ✅ **Updated `app.py` to Trigger CI/CD Pipeline | تحديث التطبيق لتشغيل خط CI/CD** — Bumped default version from `1.0.0` → `1.1.0` and added `last_updated` field to trigger the CI pipeline (watches `app/**` path) | رفع الإصدار وإضافة حقل التحديث لتفعيل خط الأنابيب

- ✅ **Created Professional Bilingual README.md for `infra-full-stack` | إنشاء README احترافي ثنائي اللغة** — Comprehensive documentation covering architecture, project structure, API endpoints, CI/CD flows, monitoring stack, security practices, and quick start guide | توثيق شامل يغطي الهيكلية، بنية المشروع، نقاط API، مسار CI/CD، حزمة المراقبة، ممارسات الأمان، ودليل البدء السريع
  - ASCII architecture diagram showing full deployment flow | رسم هيكلي يوضح مسار النشر الكامل
  - Tech stack badges (Python, Flask, Docker, K3s, Terraform, Ansible, GitHub Actions, Prometheus, Grafana) | شارات التقنيات المستخدمة

- ✅ **Updated GitHub Profile README (`mmsal512`) | تحديث بروفايل GitHub** — Added `infra-full-stack` as the top featured project, added Terraform + Prometheus + Grafana badges, and updated the learning roadmap progress | إضافة المشروع كأول مشروع مميز، وإضافة شارات التقنيات الجديدة، وتحديث نسب التقدم
  - CI/CD: 80% → **90%** | Kubernetes: 40% → **60%** | Terraform: 30% → **50%** | Prometheus & Grafana: 20% → **50%**

### 🛠️ Tools & Technologies Used | الأدوات والتقنيات المستخدمة

| Tool / الأداة | Purpose / الغرض |
| :--- | :--- |
| GitHub Actions | CI/CD pipeline — Test, Build, Push, Deploy, Notify / خط أنابيب التكامل والنشر المستمر |
| GitHub Secrets | Secure storage for credentials (7 secrets configured) / تخزين آمن لبيانات الاعتماد |
| Kubernetes Secrets | Secure password injection into Grafana pods / حقن كلمة المرور بشكل آمن في حاويات Grafana |
| `appleboy/ssh-action` | Remote deployment via SSH with environment variable forwarding / النشر عن بعد عبر SSH مع تمرير المتغيرات |
| `kubectl` | Creating secrets, applying manifests, rolling restarts / إنشاء الأسرار وتطبيق البيانات وإعادة التشغيل |
| Docker | Multi-stage build for Flask app (Python 3.12-slim) / بناء متعدد المراحل لتطبيق Flask |
| Prometheus | Metrics collection with auto-discovery and alert rules / جمع المقاييس مع الاكتشاف التلقائي وقواعد التنبيه |
| Grafana | Pre-provisioned dashboards with 6 monitoring panels / لوحات مراقبة مُعدة مسبقًا بـ 6 أقسام |
| `grep` / `ripgrep` | Scanning repository for sensitive data patterns / فحص الريبو للبحث عن أنماط البيانات الحساسة |
| Git | Version control, `.gitignore` security rules / التحكم بالإصدارات وقواعد تجاهل الملفات الحساسة |

### 📚 What I Learned | ماذا تعلمت

1. **Repository Security Scanning | فحص أمان الريبو** — How to systematically scan a repository for sensitive data (IPs, passwords, hostnames, API keys, tokens) using regex patterns before making it public | كيفية فحص الريبو بشكل منهجي للبحث عن البيانات الحساسة باستخدام أنماط regex قبل النشر العام
2. **Kubernetes Secrets with GitHub Actions | أسرار Kubernetes مع GitHub Actions** — How to securely pass secrets from GitHub → SSH → K8s using `appleboy/ssh-action`'s `envs` feature and `kubectl create secret --dry-run=client -o yaml | kubectl apply -f -` for idempotent creation | كيفية تمرير الأسرار بشكل آمن من GitHub إلى K8s عبر SSH مع إنشاء متكرر
3. **CI/CD Pipeline Design | تصميم خط CI/CD** — Full pipeline architecture: Test (pytest) → Build (Docker multi-stage) → Push (DockerHub with 3 tags) → Deploy (SSH + kubectl) → Health Check (retry loop) → Notify (Telegram) | هيكلية خط الأنابيب الكاملة من الاختبار حتى الإشعار
4. **Zero-Downtime Deployments | نشر بدون توقف** — Using Kubernetes `RollingUpdate` strategy with `maxSurge: 1` and `maxUnavailable: 0`, combined with liveness and readiness probes | استخدام استراتيجية التحديث التدريجي مع فحوصات الصحة والجاهزية
5. **Infrastructure Documentation Best Practices | أفضل ممارسات التوثيق** — Creating comprehensive bilingual README with architecture diagrams, project trees, API docs, and deployment guides that serve as both documentation and portfolio showcase | إنشاء توثيق شامل ثنائي اللغة يخدم كوثائق ومعرض أعمال

### 💡 Key Takeaways | الخلاصات الرئيسية

> **EN:** Security must be treated as a first-class concern in every DevOps workflow. Before making any repository public, perform a thorough scan for hardcoded IPs, passwords, hostnames, and API keys. Use Kubernetes Secrets and GitHub Actions Secrets to manage sensitive data — never hardcode credentials in YAML files. A well-designed CI/CD pipeline should handle the entire lifecycle: test → build → push → deploy → verify → notify. And always document your infrastructure professionally — your README is the first impression recruiters and collaborators see.

> **AR:** يجب معاملة الأمان كأولوية قصوى في كل سير عمل DevOps. قبل نشر أي ريبو عامًا، قم بفحص شامل للبحث عن عناوين IP وكلمات المرور وأسماء السيرفرات ومفاتيح API المكتوبة مباشرة. استخدم Kubernetes Secrets و GitHub Actions Secrets لإدارة البيانات الحساسة — لا تكتب بيانات الاعتماد مباشرة في ملفات YAML. خط CI/CD المصمم جيدًا يجب أن يتعامل مع دورة الحياة الكاملة: اختبار ← بناء ← رفع ← نشر ← تحقق ← إشعار. ودائمًا وثّق بنيتك التحتية باحترافية — ملف README هو الانطباع الأول الذي يراه المسؤولون عن التوظيف والمتعاونون.

### 📊 Progress | التقدم

- 🔥 Current Streak / السلسلة الحالية: **3 days / 3 أيام**
- 📈 Total Commits Today / التزامات اليوم: **3** (infra-full-stack, mmsal512 profile, devops-learning-journal)
- 🎯 Focus Area / مجال التركيز: CI/CD + Security + Kubernetes Secrets / التكامل المستمر + الأمان + أسرار Kubernetes

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
