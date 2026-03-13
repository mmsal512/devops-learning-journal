# 🔄 GitHub Actions CI/CD Pipeline | خط أنابيب CI/CD عبر GitHub Actions

> **Project Reference | مرجع المشروع:** [infra-full-stack](https://github.com/mmsal512/infra-full-stack)
> **Date | التاريخ:** 2026-03-12

---

## 📖 Overview | نظرة عامة

**EN:** This note documents the complete CI/CD pipeline I built for the `infra-full-stack` project using GitHub Actions. The pipeline consists of two separate workflows: **CI** (Test, Build & Push) and **CD** (Deploy to Kubernetes), connected via the `workflow_run` trigger. This architecture ensures the CD only runs after a successful CI.

**AR:** تُوثّق هذه الملاحظة خط أنابيب CI/CD الكامل الذي بنيته لمشروع `infra-full-stack` باستخدام GitHub Actions. يتكون الخط من مسارين منفصلين: **CI** (اختبار، بناء ورفع) و **CD** (نشر على Kubernetes)، متصلان عبر مُحفّز `workflow_run`. هذه الهيكلية تضمن تشغيل CD فقط بعد نجاح CI.

---

## 🔷 CI Workflow — Test, Build & Push | مسار CI — اختبار، بناء ورفع

### Trigger | المُحفّز

```yaml
on:
  push:
    branches: [main]
    paths:
      - 'app/**'                      # Only trigger when app files change
      - '.github/workflows/ci.yaml'   # Or when the workflow itself changes
  pull_request:
    branches: [main]
```

> **💡 Tip | نصيحة:** Using `paths` filter avoids unnecessary builds when only docs or infrastructure files change. This saves CI minutes and speeds up development.
>
> **💡** استخدام فلتر `paths` يتجنب البناء غير الضروري عند تغيير ملفات التوثيق فقط. هذا يوفر دقائق CI ويسرّع التطوير.

### Pipeline Steps | خطوات الخط

```
Push to main (app/**)
    │
    ├── 1️⃣ Checkout Code
    │
    ├── 2️⃣ Setup Python 3.12
    │
    ├── 3️⃣ Install Dependencies (pip install -r requirements.txt)
    │
    ├── 4️⃣ Run Tests (pytest — 7 test cases)
    │
    ├── 5️⃣ Setup Docker Buildx
    │
    ├── 6️⃣ Login to DockerHub (secrets.DOCKER_USERNAME + secrets.DOCKER_TOKEN)
    │
    ├── 7️⃣ Generate Metadata (short SHA + build date)
    │
    └── 8️⃣ Build & Push Docker Image (3 tags: latest, SHA, build number)
```

### Multi-Tag Strategy | استراتيجية العلامات المتعددة

```yaml
tags: |
  mohammed512/infra-full-stack:latest           # Always points to newest
  mohammed512/infra-full-stack:a1b2c3d           # Git short SHA for traceability
  mohammed512/infra-full-stack:build-42          # Build number for ordering
```

> **💡 Why 3 tags? | لماذا 3 علامات؟**
> - `latest` — Easy to use in development | سهلة الاستخدام في التطوير
> - `<short-sha>` — Trace exactly which commit built this image | تتبع أي commit بنى هذه الصورة
> - `build-<N>` — Know the build order chronologically | معرفة ترتيب البناء زمنياً

### Conditional Build | البناء الشرطي

```yaml
if: github.ref == 'refs/heads/main' && github.event_name == 'push'
```

> **EN:** The build step only runs on actual pushes to `main`, not on PRs. This prevents wasting resources building images for unmerged code.
>
> **AR:** خطوة البناء تعمل فقط عند الدفع الفعلي لـ `main`، وليس على PRs. هذا يمنع هدر الموارد ببناء صور لكود لم يُدمج.

---

## 🟢 CD Workflow — Deploy to Kubernetes | مسار CD — النشر على Kubernetes

### Trigger — workflow_run | المُحفّز

```yaml
on:
  workflow_run:
    workflows: ["CI — Test, Build & Push"]   # Wait for CI to finish
    types: [completed]                        # Trigger when CI completes
    branches: [main]                          # Only for main branch

jobs:
  deploy:
    if: ${{ github.event.workflow_run.conclusion == 'success' }}  # Only if CI succeeded
```

> **💡 Key Concept | مفهوم أساسي:**
> - `workflow_run` connects two separate workflows | يربط بين مسارين منفصلين
> - `conclusion == 'success'` ensures CD only runs after CI passes | يضمن تشغيل CD فقط بعد نجاح CI
> - Unlike `needs`, this works across workflow files | على عكس `needs`، يعمل عبر ملفات مسارات مختلفة

### SSH Deployment with appleboy/ssh-action | النشر عبر SSH

```yaml
- name: Deploy via SSH
  uses: appleboy/ssh-action@v1.0.3
  env:
    GRAFANA_ADMIN_PASSWORD: ${{ secrets.GRAFANA_ADMIN_PASSWORD }}
  with:
    host: ${{ secrets.SERVER_TAILSCALE_IP }}
    username: mohammed
    key: ${{ secrets.SSH_PRIVATE_KEY }}
    port: 2026
    envs: GRAFANA_ADMIN_PASSWORD    # Forward env vars to remote server
    script: |
      # Commands executed on the remote server
```

> **⚠️ Important | مهم:**
> - `env` block sets the variable in the GitHub Actions runner | يضبط المتغير في الـ runner
> - `envs` parameter forwards it to the remote SSH session | يمرره لجلسة SSH البعيدة
> - Both are needed for secrets to reach the server | كلاهما مطلوب لوصول الأسرار للسيرفر

### Deployment Script Flow | مسار سكربت النشر

```bash
# 1. Pull latest code
git pull origin main

# 2. Create/Update K8s secrets from GitHub Secrets
kubectl create secret generic grafana-secrets \
  --namespace=infra-full-stack \
  --from-literal=admin-password="$GRAFANA_ADMIN_PASSWORD" \
  --dry-run=client -o yaml | kubectl apply -f -

# 3. Apply all manifests
kubectl apply -f kubernetes/namespace.yaml
kubectl apply -f kubernetes/app/
kubectl apply -f kubernetes/monitoring/prometheus/
kubectl apply -f kubernetes/monitoring/grafana/

# 4. Rolling restart (picks up new image)
kubectl rollout restart deployment/flask-app -n infra-full-stack

# 5. Wait for rollout to complete
kubectl rollout status deployment/flask-app -n infra-full-stack --timeout=120s
```

> **💡 Idempotent Secret Creation | إنشاء سر متكرر:**
> The `--dry-run=client -o yaml | kubectl apply -f -` pattern creates the secret if it doesn't exist, or updates it if it does. This makes the deployment safe to run multiple times.
>
> نمط `--dry-run=client -o yaml | kubectl apply -f -` ينشئ السر إذا لم يكن موجودًا، أو يحدثه إذا كان موجودًا. هذا يجعل النشر آمنًا للتشغيل عدة مرات.

### Health Check with Retry Loop | فحص الصحة مع إعادة المحاولة

```bash
sleep 15
for i in $(seq 1 6); do
  if curl -sf http://localhost:30080/health > /dev/null 2>&1; then
    echo "✅ Health check passed!"
    exit 0
  fi
  echo "⏳ Attempt $i/6 — waiting 10s..."
  sleep 10
done
echo "❌ Health check failed"
exit 1
```

> **EN:** 6 attempts × 10 seconds = 60 seconds max wait. The `sleep 15` at the start gives pods time to start. If all attempts fail, `exit 1` marks the deployment as failed.
>
> **AR:** 6 محاولات × 10 ثوانٍ = 60 ثانية انتظار كحد أقصى. `sleep 15` في البداية يعطي الـ pods وقتًا للبدء. إذا فشلت كل المحاولات، `exit 1` يُعلّم النشر كفاشل.

### Telegram Notifications | إشعارات Telegram

```yaml
- name: Notify Telegram (Success)
  if: success()
  run: |
    curl -sf -X POST "https://api.telegram.org/bot${{ secrets.TELEGRAM_TOKEN }}/sendMessage" \
      -d chat_id="${{ secrets.TELEGRAM_CHAT_ID }}" \
      -d parse_mode="Markdown" \
      -d text="✅ *infra-full-stack Deployed!*
    📦 Image: \`mohammed512/infra-full-stack:latest\`
    🔢 Build: #${{ github.run_number }}"

- name: Notify Telegram (Failure)
  if: failure()
  run: |
    # Similar but with ❌ and link to workflow logs
```

> **💡** Using `|| true` at the end prevents notification failures from failing the entire workflow.
>
> استخدام `|| true` في النهاية يمنع فشل الإشعار من إفشال المسار بالكامل.

---

## 🔐 GitHub Secrets Management | إدارة أسرار GitHub

### Required Secrets | الأسرار المطلوبة

| Secret | Used In | Purpose |
|:-------|:--------|:--------|
| `DOCKER_USERNAME` | CI | DockerHub login |
| `DOCKER_TOKEN` | CI | DockerHub access token |
| `SERVER_TAILSCALE_IP` | CD | Server IP for SSH deployment |
| `SSH_PRIVATE_KEY` | CD | SSH authentication key |
| `GRAFANA_ADMIN_PASSWORD` | CD | Grafana admin password → K8s Secret |
| `TELEGRAM_TOKEN` | CD | Telegram Bot API token |
| `TELEGRAM_CHAT_ID` | CD | Telegram chat for notifications |

### How to Add | كيفية الإضافة

```
GitHub Repo → Settings → Secrets and variables → Actions → New repository secret
```

> **⚠️ Never | لا تفعل أبداً:**
> - Never hardcode secrets in workflow files | لا تكتب الأسرار في ملفات المسارات
> - Never echo secrets in logs | لا تطبع الأسرار في السجلات
> - Never use secrets in PR workflows from forks | لا تستخدم الأسرار في PRs من forks

---

## 📊 Complete Pipeline Architecture | هيكلية الخط الكاملة

```
┌───────────────── CI ─────────────────┐     ┌──────────────── CD ─────────────────────┐
│                                       │     │                                         │
│  Push (app/**) → Test → Build → Push  │────▶│  Deploy → Health Check → Telegram       │
│                                       │     │                                         │
│  ┌──────┐  ┌──────┐  ┌───────────┐   │     │  ┌──────┐  ┌──────┐  ┌──────────────┐  │
│  │pytest│→ │Docker│→ │ DockerHub │   │     │  │ SSH  │→ │Health│→ │  Telegram    │  │
│  │7tests│  │Build │  │ 3 tags    │   │     │  │Deploy│  │Check │  │  Notify      │  │
│  └──────┘  └──────┘  └───────────┘   │     │  └──────┘  └──────┘  └──────────────┘  │
└───────────────────────────────────────┘     └─────────────────────────────────────────┘
         workflow_run (success only)
```

---

## 🔑 Key Takeaways | الخلاصات الرئيسية

1. **Separate CI from CD** — Use `workflow_run` to decouple testing/building from deployment | افصل CI عن CD باستخدام `workflow_run`
2. **Path filters save resources** — Only build when relevant files change | فلاتر المسارات توفر الموارد
3. **Multi-tag images** — Use `latest` + `SHA` + `build-N` for flexibility and traceability | صور متعددة العلامات للمرونة والتتبع
4. **Health checks are essential** — Never mark a deployment as "done" without verification | فحوصات الصحة ضرورية
5. **Notify on both success and failure** — Stay informed about every deployment | أشعر بكل نشر سواء نجاح أو فشل
6. **Secrets flow** — `GitHub Secret` → `env` → `envs` → `SSH` → `kubectl` → `K8s Secret` → `Pod` | مسار تدفق الأسرار

---

> **🔗 Files Reference | مرجع الملفات:**
> - CI: `.github/workflows/ci.yaml`
> - CD: `.github/workflows/cd.yaml`
