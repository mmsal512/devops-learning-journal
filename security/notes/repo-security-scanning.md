# 🔒 Repository Security Scanning | فحص أمان الريبو قبل النشر العام

> **Project Reference | مرجع المشروع:** [infra-full-stack](https://github.com/mmsal512/infra-full-stack)
> **Date | التاريخ:** 2026-03-12

---

## 📖 Overview | نظرة عامة

**EN:** This note documents the security scanning process I performed on the `infra-full-stack` repository before making it public. I found and fixed 5 security issues: hardcoded IPs, passwords, and server hostnames. This guide covers what to look for, how to scan, and how to fix common issues.

**AR:** توثيق عملية الفحص الأمني لريبو `infra-full-stack` قبل نشره عامًا. اكتشفت وأصلحت 5 مشاكل أمنية: عناوين IP ثابتة، كلمات مرور، وأسماء سيرفرات. يغطي هذا الدليل ماذا تبحث عنه، كيف تفحص، وكيف تصلح المشاكل الشائعة.

---

## 🔍 What to Look For | ماذا تبحث عنه

### Sensitive Data Checklist | قائمة التحقق من البيانات الحساسة

| Category | Examples | Risk Level |
|:---------|:---------|:-----------|
| **IP Addresses** | `100.126.131.64`, `192.168.1.x` (private/Tailscale) | 🔴 High |
| **Passwords** | `admin123`, `password`, `mySecretPass` | 🔴 Critical |
| **API Tokens** | `ghp_xxx`, `sk-xxx`, `AKIA...` | 🔴 Critical |
| **Server Hostnames** | `srv1262599`, `my-server.example.com` | 🟡 Medium |
| **SSH Keys** | `id_rsa`, `id_ed25519` (private keys) | 🔴 Critical |
| **Database URLs** | `postgresql://user:pass@host/db` | 🔴 Critical |
| **Environment Files** | `.env`, `terraform.tfvars` | 🔴 Critical |

---

## 🛠️ How to Scan | كيف تفحص

### 1. Search for IP Addresses | البحث عن عناوين IP

```bash
# Find all IP addresses in the project (excluding .git)
grep -rn --include='*.{yaml,yml,sh,ini,tf,py,md}' \
  -E '\b[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\b' .

# Common safe IPs to ignore:
# 0.0.0.0 — bind all interfaces (normal in Docker/Flask)
# ::/0    — IPv6 wildcard (normal in firewall rules)
```

### 2. Search for Passwords | البحث عن كلمات المرور

```bash
grep -rni --include='*.{yaml,yml,sh,ini,tf,py}' \
  -E '(password|passwd|pwd)\s*[:=]' .
```

### 3. Search for Tokens & Keys | البحث عن التوكنات والمفاتيح

```bash
grep -rni --include='*.{yaml,yml,sh,ini,tf,py}' \
  -E '(api[_-]?key|api[_-]?token|secret[_-]?key|private[_-]?key)\s*[:=]' .
```

### 4. Search for Server Names | البحث عن أسماء السيرفرات

```bash
grep -rni --include='*.{yaml,yml,sh,ini}' \
  -E '(srv[0-9]+|hostinger|hetzner)' .
```

### 5. Check for Sensitive Files | التحقق من الملفات الحساسة

```bash
# Look for files that should never be committed
find . -name '*.env' -o -name 'terraform.tfvars' -o -name '*.pem' \
  -o -name 'id_rsa' -o -name 'id_ed25519' -o -name '*.key'
```

---

## 🔧 How to Fix | كيف تصلح

### Fix 1: Replace Hardcoded IPs with Placeholders | استبدال عناوين IP بـ Placeholders

```diff
# Before (INSECURE) ❌
-TAILSCALE_IP="100.126.131.64"
-echo "App: http://100.126.131.64:30080"

# After (SAFE) ✅
+TAILSCALE_IP="${TAILSCALE_IP:-YOUR_TAILSCALE_IP}"
+echo "App: http://YOUR_TAILSCALE_IP:30080"
```

### Fix 2: Use K8s Secrets Instead of Hardcoded Passwords | استخدام K8s Secrets

```diff
# Before (INSECURE) ❌
-  - name: GF_SECURITY_ADMIN_PASSWORD
-    value: "admin123"

# After (SAFE) ✅
+  - name: GF_SECURITY_ADMIN_PASSWORD
+    valueFrom:
+      secretKeyRef:
+        name: grafana-secrets
+        key: admin-password
```

### Fix 3: Comment Out Real Server Info | تعليق معلومات السيرفر الحقيقية

```diff
# Before (INSECURE) ❌
-srv1262599 ansible_host=100.126.131.64 ansible_user=mohammed

# After (SAFE) ✅
+# your-server ansible_host=YOUR_TAILSCALE_IP ansible_user=mohammed
```

### Fix 4: Use GitHub Actions Secrets | استخدام أسرار GitHub Actions

```yaml
# ✅ SAFE — Credentials from GitHub Secrets
- uses: docker/login-action@v3
  with:
    username: ${{ secrets.DOCKER_USERNAME }}
    password: ${{ secrets.DOCKER_TOKEN }}
```

---

## 🛡️ Prevention — .gitignore | الوقاية

```gitignore
# Terraform state & real values
terraform/.terraform/
terraform/*.tfstate
terraform/*.tfstate.backup
terraform/terraform.tfvars        # ⚠️ Real values

# Environment files
.env
*.env.local

# SSH Keys (if accidentally placed in project)
*.pem
id_rsa
id_ed25519
```

> **💡 Rule of thumb | قاعدة أساسية:**
> If a file contains ANY real credential, it MUST be in `.gitignore`.
> إذا احتوى ملف على أي بيانات اعتماد حقيقية، يجب أن يكون في `.gitignore`.

---

## 📊 Real Issues Found in infra-full-stack | المشاكل الحقيقية المكتشفة

| # | File | Issue | Fix |
|:-:|:-----|:------|:----|
| 1 | `grafana/deployment.yaml` | Password `admin123` hardcoded | → `secretKeyRef` from K8s Secret |
| 2 | `ansible/inventory/hosts.ini` | Real Tailscale IP + hostname | → Commented out with placeholder |
| 3 | `ansible/playbook.yml` | Real Tailscale IP (4 occurrences) | → `YOUR_TAILSCALE_IP` |
| 4 | `scripts/setup-on-existing-server.sh` | Real IP + password + hostname | → Placeholders |
| 5 | `scripts/health-check.sh` | Real Tailscale IP | → Environment variable |

---

## ✅ Post-Scan Verification | التحقق بعد الفحص

After fixing, always run these checks again to confirm:

```bash
# Verify no real IPs remain
grep -rn '100.126.131.64' . --include='*.{yaml,yml,sh,ini,tf}'
# Expected: No results found ✅

# Verify no passwords remain
grep -rn 'admin123' . --include='*.{yaml,yml,sh,ini}'
# Expected: No results found ✅

# Verify no server names remain
grep -rn 'srv1262599' . --include='*.{yaml,yml,sh,ini}'
# Expected: No results found ✅
```

---

## 🔑 Key Takeaways | الخلاصات الرئيسية

1. **Scan before every public push** — Make it a habit | افحص قبل كل push عام
2. **Use placeholders** like `YOUR_TAILSCALE_IP`, `CHANGE_ME` | استخدم placeholders
3. **Use Secrets management** — K8s Secrets, GitHub Secrets, never hardcode | استخدم إدارة الأسرار
4. **`.gitignore` is your first line of defense** | `.gitignore` هو خط دفاعك الأول
5. **Check for patterns, not specific values** — Use regex to catch ALL sensitive data | ابحث عن الأنماط وليس القيم المحددة
6. **Verify fixes** — Always re-scan after cleaning | تحقق من الإصلاحات دائمًا

---

> **🔗 Files:** `.gitignore`, all project files scanned
