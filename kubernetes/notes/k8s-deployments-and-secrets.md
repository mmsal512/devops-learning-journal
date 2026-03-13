# ☸️ Kubernetes Deployments, Services & Secrets | نشر Kubernetes والخدمات والأسرار

> **Project Reference | مرجع المشروع:** [infra-full-stack](https://github.com/mmsal512/infra-full-stack)
> **Date | التاريخ:** 2026-03-12

---

## 📖 Overview | نظرة عامة

**EN:** This note covers the Kubernetes resources I used in the `infra-full-stack` project running on K3s. It includes Deployments with rolling updates and health probes, Services with NodePort, HorizontalPodAutoscaler (HPA), ConfigMaps, and Kubernetes Secrets for secure credential management.

**AR:** تُغطي هذه الملاحظة موارد Kubernetes التي استخدمتها في مشروع `infra-full-stack` على K3s. تشمل Deployments مع تحديثات تدريجية وفحوصات صحة، Services مع NodePort، التوسع التلقائي (HPA)، ConfigMaps، و Kubernetes Secrets لإدارة بيانات الاعتماد بشكل آمن.

---

## 1️⃣ Namespace — Isolation | مساحة الأسماء — العزل

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: infra-full-stack
  labels:
    app: infra-full-stack
    project: portfolio
```

> **💡 Why namespaces? | لماذا مساحات الأسماء؟**
> Namespaces isolate your project resources from other workloads on the same cluster. This is critical when running K3s on a shared server with Docker containers.
>
> مساحات الأسماء تعزل موارد مشروعك عن الأعباء الأخرى على نفس الكلستر. هذا حيوي عند تشغيل K3s على سيرفر مشترك مع حاويات Docker.

---

## 2️⃣ Deployment — Rolling Updates & Health Probes | النشر — تحديثات تدريجية وفحوصات صحة

### Rolling Update Strategy | استراتيجية التحديث التدريجي

```yaml
spec:
  replicas: 2
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1          # Create 1 extra pod during update
      maxUnavailable: 0    # Never have fewer than 2 running pods
```

> **EN:** `maxSurge: 1` + `maxUnavailable: 0` = **Zero-downtime deployment**. During an update, Kubernetes creates a new pod first, waits for it to be ready, then terminates an old one.
>
> **AR:** `maxSurge: 1` + `maxUnavailable: 0` = **نشر بدون توقف**. أثناء التحديث، ينشئ Kubernetes pod جديد أولاً، ينتظر حتى يكون جاهزاً، ثم يُنهي واحداً قديماً.

### Liveness Probe — Is the app alive? | فحص الحياة

```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 5000
  initialDelaySeconds: 15    # Wait 15s before first check
  periodSeconds: 20           # Check every 20s
  timeoutSeconds: 5           # Timeout after 5s
  failureThreshold: 3         # Restart after 3 consecutive failures
```

> **EN:** If the app fails 3 health checks in a row (60 seconds total), Kubernetes automatically restarts the pod. This creates **self-healing** infrastructure.
>
> **AR:** إذا فشل التطبيق في 3 فحوصات صحية متتالية (60 ثانية إجمالاً)، يُعيد Kubernetes تشغيل الـ pod تلقائياً. هذا ينشئ بنية تحتية **ذاتية الإصلاح**.

### Readiness Probe — Is the app ready for traffic? | فحص الجاهزية

```yaml
readinessProbe:
  httpGet:
    path: /ready
    port: 5000
  initialDelaySeconds: 5     # Check quickly after start
  periodSeconds: 10           # Check frequently
  timeoutSeconds: 3
```

> **💡 Liveness vs Readiness | الحياة مقابل الجاهزية:**
> | Probe | Question | Action on Failure |
> |:------|:---------|:------------------|
> | Liveness | Is it alive? هل هو حي؟ | **Restart** the pod |
> | Readiness | Can it serve traffic? هل يخدم الطلبات؟ | **Remove** from Service (no traffic) |

### Resource Limits | حدود الموارد

```yaml
resources:
  requests:
    cpu: "50m"        # Guaranteed minimum: 5% of 1 CPU
    memory: "64Mi"    # Guaranteed minimum: 64MB
  limits:
    cpu: "200m"       # Maximum: 20% of 1 CPU
    memory: "128Mi"   # Maximum: 128MB — OOMKilled if exceeded
```

> **⚠️ Warning | تحذير:** Without resource limits, a single pod can consume all server resources and crash everything else. Always set limits!
>
> بدون حدود الموارد، يمكن لـ pod واحد أن يستهلك كل موارد السيرفر ويُعطل كل شيء آخر. دائمًا حدد الحدود!

### Prometheus Annotations | تعليقات Prometheus

```yaml
template:
  metadata:
    annotations:
      prometheus.io/scrape: "true"
      prometheus.io/path: "/metrics"
      prometheus.io/port: "5000"
```

> **EN:** These annotations tell Prometheus to automatically discover and scrape metrics from this pod. No manual configuration needed!
>
> **AR:** هذه التعليقات تُخبر Prometheus باكتشاف المقاييس من هذا الـ pod وجمعها تلقائياً. لا حاجة لإعداد يدوي!

---

## 3️⃣ Service — NodePort | الخدمة

```yaml
apiVersion: v1
kind: Service
metadata:
  name: flask-app-service
  namespace: infra-full-stack
spec:
  type: NodePort
  selector:
    app: flask-app           # Routes traffic to pods with this label
  ports:
    - port: 80               # Service port (internal)
      targetPort: 5000       # Container port (Flask app)
      nodePort: 30080        # External port (accessible from outside)
```

> **💡 Service Types | أنواع الخدمات:**
> | Type | Access | Use Case |
> |:-----|:-------|:---------|
> | `ClusterIP` | Internal only | Service-to-service communication |
> | `NodePort` | External via port 30000-32767 | Direct access (what we use) |
> | `LoadBalancer` | Cloud provider LB | Production cloud environments |

---

## 4️⃣ HorizontalPodAutoscaler (HPA) | التوسع التلقائي الأفقي

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: flask-app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: flask-app
  minReplicas: 2       # Never less than 2 pods (high availability)
  maxReplicas: 4       # Never more than 4 pods (resource protection)
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70    # Scale up when CPU > 70%
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: 80    # Scale up when memory > 80%
```

> **EN:** HPA automatically adjusts the number of pods based on CPU and memory usage. If average CPU across all pods exceeds 70%, it creates new pods (up to 4). When load decreases, it scales back down to 2.
>
> **AR:** HPA يُعدّل عدد الـ pods تلقائياً بناءً على استخدام CPU والذاكرة. إذا تجاوز معدل CPU عبر كل الـ pods 70%، ينشئ pods جديدة (حتى 4). عندما ينخفض الحمل، يُقلص إلى 2.

---

## 5️⃣ ConfigMap — App Configuration | خريطة التكوين

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
  namespace: infra-full-stack
data:
  APP_VERSION: "1.0.0"
  PORT: "5000"
  ENVIRONMENT: "production"
```

Used in the Deployment via `envFrom`:
```yaml
envFrom:
  - configMapRef:
      name: app-config
```

> **💡 ConfigMap vs Secret | خريطة التكوين مقابل السر:**
> - **ConfigMap** → Non-sensitive configuration (version, port, environment) | إعدادات غير حساسة
> - **Secret** → Sensitive data (passwords, tokens, keys) | بيانات حساسة

---

## 6️⃣ Kubernetes Secrets — Secure Credentials | أسرار Kubernetes — بيانات اعتماد آمنة

### Creating Secrets via kubectl (from CD pipeline) | إنشاء الأسرار عبر kubectl

```bash
kubectl create secret generic grafana-secrets \
  --namespace=infra-full-stack \
  --from-literal=admin-password="$GRAFANA_ADMIN_PASSWORD" \
  --dry-run=client -o yaml | kubectl apply -f -
```

### Using Secrets in Deployment | استخدام الأسرار في النشر

```yaml
env:
  - name: GF_SECURITY_ADMIN_PASSWORD
    valueFrom:
      secretKeyRef:
        name: grafana-secrets      # Name of the K8s Secret
        key: admin-password        # Key within the Secret
```

### Complete Secrets Flow | مسار الأسرار الكامل

```
GitHub Secret (GRAFANA_ADMIN_PASSWORD)
    │
    ▼ env block in workflow
GitHub Actions Runner
    │
    ▼ envs parameter in ssh-action
Remote Server (via SSH)
    │
    ▼ kubectl create secret
Kubernetes Secret (grafana-secrets)
    │
    ▼ secretKeyRef in deployment.yaml
Grafana Pod (GF_SECURITY_ADMIN_PASSWORD env var)
```

> **⚠️ Never do this | لا تفعل هذا أبداً:**
> ```yaml
> # ❌ BAD — Password in plain text in the YAML file
> env:
>   - name: GF_SECURITY_ADMIN_PASSWORD
>     value: "admin123"    # Exposed in public repo!
> ```
>
> **✅ Always use secretKeyRef | دائماً استخدم secretKeyRef:**
> ```yaml
> # ✅ GOOD — Password from K8s Secret
> env:
>   - name: GF_SECURITY_ADMIN_PASSWORD
>     valueFrom:
>       secretKeyRef:
>         name: grafana-secrets
>         key: admin-password
> ```

---

## 📊 All Resources Summary | ملخص جميع الموارد

| Resource | Name | Namespace | Purpose |
|:---------|:-----|:----------|:--------|
| Namespace | `infra-full-stack` | — | Project isolation |
| Deployment | `flask-app` | `infra-full-stack` | 2 replicas, rolling update, probes |
| Service | `flask-app-service` | `infra-full-stack` | NodePort :30080 |
| HPA | `flask-app-hpa` | `infra-full-stack` | Auto-scale 2→4 pods |
| ConfigMap | `app-config` | `infra-full-stack` | App settings |
| Secret | `grafana-secrets` | `infra-full-stack` | Grafana admin password |

---

## 🔑 Key Takeaways | الخلاصات الرئيسية

1. **Always use rolling updates** with `maxUnavailable: 0` for zero-downtime | استخدم التحديثات التدريجية دائمًا
2. **Set both liveness and readiness probes** — They serve different purposes | حدد كلا فحصي الحياة والجاهزية
3. **Always set resource limits** to protect the cluster | حدد حدود الموارد لحماية الكلستر
4. **Use Secrets for passwords, ConfigMaps for config** — Never mix them | استخدم Secrets لكلمات المرور و ConfigMaps للإعدادات
5. **HPA needs resource requests** to calculate utilization percentages | HPA يحتاج requests لحساب نسب الاستخدام

---

> **🔗 Files Reference | مرجع الملفات:**
> - `kubernetes/namespace.yaml`
> - `kubernetes/app/deployment.yaml`, `service.yaml`, `configmap.yaml`, `hpa.yaml`
