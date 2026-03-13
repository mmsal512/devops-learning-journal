# 🐳 Docker Multi-Stage Builds | بناء Docker متعدد المراحل

> **Project Reference | مرجع المشروع:** [infra-full-stack](https://github.com/mmsal512/infra-full-stack)
> **Date | التاريخ:** 2026-03-12

---

## 📖 Overview | نظرة عامة

**EN:** This note documents the production-grade Dockerfile built for the Flask app in `infra-full-stack`. It uses multi-stage builds, non-root user, health checks, and Gunicorn WSGI.

**AR:** توثيق ملف Dockerfile بمستوى إنتاجي لتطبيق Flask. يستخدم بناء متعدد المراحل، مستخدم غير root، فحص صحة، وخادم Gunicorn WSGI.

---

## 🔷 Multi-Stage Build | البناء متعدد المراحل

### Stage 1: Builder | مرحلة البناء

```dockerfile
FROM python:3.12-slim AS builder
WORKDIR /build
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt
```

### Stage 2: Production | مرحلة الإنتاج

```dockerfile
FROM python:3.12-slim
COPY --from=builder /install /usr/local
COPY app.py .
```

> **💡 Why multi-stage? | لماذا متعدد المراحل؟**
> | Approach | Image Size |
> |:---------|:-----------|
> | Single stage | ~400MB+ (Python + pip cache + build tools) |
> | Multi-stage | ~150MB (Python + packages + app only) |
>
> Builder stage artifacts (pip, setuptools) are NOT needed at runtime — they're discarded.
> ملفات مرحلة البناء غير مطلوبة وقت التشغيل — يتم التخلص منها.

---

## 🔒 Security — Non-Root User | الأمان — مستخدم غير Root

```dockerfile
RUN groupadd -r appuser && \
    useradd -r -g appuser -d /app -s /sbin/nologin appuser

WORKDIR /app
COPY --from=builder /install /usr/local
COPY app.py .
RUN chown -R appuser:appuser /app
USER appuser
```

> **⚠️ Why non-root? | لماذا غير root؟**
> - If attacker exploits the app → only `appuser` permissions | صلاحيات محدودة فقط
> - Cannot modify system files or install packages | لا يمكنه تعديل ملفات النظام
> - `-s /sbin/nologin` prevents interactive shell | يمنع الوصول التفاعلي
> - **Kubernetes security best practice** | من أفضل ممارسات أمان Kubernetes

---

## 🏥 Health Check | فحص الصحة

```dockerfile
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/health')" || exit 1
```

| Parameter | Value | Meaning / المعنى |
|:----------|:------|:-----------------|
| `--interval` | 30s | Check every 30 seconds / فحص كل 30 ثانية |
| `--timeout` | 5s | Fail if no response in 5s / فشل إذا لم يستجب |
| `--start-period` | 10s | Grace period for startup / فترة سماح للبدء |
| `--retries` | 3 | Unhealthy after 3 failures / غير صحي بعد 3 فشلات |

> **💡** Uses Python built-in `urllib` — no need to install `curl` in slim image!

---

## 🚀 Gunicorn — Production WSGI Server | خادم WSGI للإنتاج

```dockerfile
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2", "--threads", "2", "--timeout", "120", "app:app"]
```

| Feature | Flask Dev Server | Gunicorn |
|:--------|:-----------------|:---------|
| Concurrency | Single-threaded | Multi-worker + multi-threaded |
| Performance | Development only | Production-ready |
| Stability | May crash under load | Graceful worker management |

> - `--workers 2` — 2 worker processes (rule of thumb: 2×CPU + 1)
> - `--threads 2` — 2 threads per worker (4 concurrent requests total)
> - `--timeout 120` — Kill worker if request takes >120s

---

## 📋 Environment Variables & Labels | متغيرات البيئة والعلامات

```dockerfile
LABEL maintainer="Mohammed Alefari <mmsal20902012@gmail.com>"
LABEL description="Infra Full Stack — DevOps Portfolio App"

ENV PORT=5000 \
    APP_VERSION=1.0.0 \
    ENVIRONMENT=production

EXPOSE 5000
```

> Defaults can be overridden via `-e` flag or K8s ConfigMaps/env vars.
> القيم الافتراضية يمكن تجاوزها عبر `-e` أو ConfigMaps.

---

## 🔑 Key Takeaways | الخلاصات الرئيسية

1. **Always use multi-stage builds** to minimize image size and attack surface | استخدم البناء متعدد المراحل دائمًا
2. **Never run containers as root** — Create a dedicated non-root user | لا تشغل الحاويات كـ root
3. **Use Gunicorn in production** — Flask dev server is NOT production-ready | استخدم Gunicorn في الإنتاج
4. **Add HEALTHCHECK** for container orchestration | أضف فحص الصحة
5. **Use `--no-cache-dir`** with pip to reduce image size | لتقليل حجم الصورة

---

> **🔗 Files:** `app/Dockerfile`, `app/requirements.txt`
