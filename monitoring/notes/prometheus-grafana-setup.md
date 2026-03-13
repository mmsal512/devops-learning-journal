# 📊 Prometheus & Grafana Monitoring Stack | حزمة المراقبة Prometheus و Grafana

> **Project Reference | مرجع المشروع:** [infra-full-stack](https://github.com/mmsal512/infra-full-stack)
> **Date | التاريخ:** 2026-03-12

---

## 📖 Overview | نظرة عامة

**EN:** This note documents the complete monitoring stack I deployed in Kubernetes for the `infra-full-stack` project. It includes Prometheus for metrics collection with auto-discovery and alert rules, and Grafana with pre-provisioned datasources and dashboards — all configured as code through ConfigMaps.

**AR:** تُوثّق هذه الملاحظة حزمة المراقبة الكاملة التي نشرتها في Kubernetes لمشروع `infra-full-stack`. تشمل Prometheus لجمع المقاييس مع الاكتشاف التلقائي وقواعد التنبيه، و Grafana مع مصادر بيانات ولوحات معلومات مُعدة مسبقًا — كلها مُعدّة كرمز عبر ConfigMaps.

---

## 🔶 Prometheus — Metrics Collection | جمع المقاييس

### Architecture | الهيكلية

```
Flask App (Pod #1)                Flask App (Pod #2)
    :5000/metrics                     :5000/metrics
         │                                 │
         └──────────┬──────────────────────┘
                    │
              ┌─────▼──────┐
              │ Prometheus  │ ← kubernetes_sd_configs (auto-discovery)
              │   v2.51     │
              │   :30090    │ ← alert-rules.yml
              └─────┬───────┘
                    │
              ┌─────▼──────┐
              │  Grafana    │ ← datasources.yaml (auto-provisioned)
              │   v10.4     │ ← flask-app.json (dashboard)
              │   :30030    │
              └─────────────┘
```

### RBAC — Giving Prometheus Permission | إعطاء Prometheus الصلاحيات

```yaml
# ServiceAccount — Identity for Prometheus pod
apiVersion: v1
kind: ServiceAccount
metadata:
  name: prometheus
  namespace: infra-full-stack

# ClusterRole — What Prometheus can do
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: prometheus-infra
rules:
  - apiGroups: [""]
    resources: [nodes, nodes/proxy, services, endpoints, pods]
    verbs: [get, list, watch]           # Read-only access
  - nonResourceURLs: [/metrics]
    verbs: [get]

# ClusterRoleBinding — Connect ServiceAccount to Role
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: prometheus-infra
roleRef:
  kind: ClusterRole
  name: prometheus-infra
subjects:
  - kind: ServiceAccount
    name: prometheus
    namespace: infra-full-stack
```

> **💡 Least Privilege Principle | مبدأ الصلاحيات الأقل:**
> Prometheus only gets `get`, `list`, `watch` — never `create`, `update`, or `delete`. This is the minimum needed for service discovery.
>
> Prometheus يحصل فقط على `get`, `list`, `watch` — أبدًا `create` أو `update` أو `delete`. هذا هو الحد الأدنى المطلوب لاكتشاف الخدمات.

### Scrape Configuration | إعداد جمع المقاييس

```yaml
scrape_configs:
  # Self-monitoring
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  # Auto-discover Flask pods via annotations
  - job_name: 'flask-app'
    kubernetes_sd_configs:
      - role: pod
        namespaces:
          names: ['infra-full-stack']
    relabel_configs:
      # Only scrape pods with annotation: prometheus.io/scrape = "true"
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
        action: keep
        regex: true
      # Use the pod's prometheus.io/path annotation for metrics path
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]
        action: replace
        target_label: __metrics_path__
        regex: (.+)
      # Build the scrape target from pod IP + port annotation
      - source_labels: [__meta_kubernetes_pod_ip, __meta_kubernetes_pod_annotation_prometheus_io_port]
        action: replace
        target_label: __address__
        regex: (.+);(.+)
        replacement: $1:$2
```

> **💡 How auto-discovery works | كيف يعمل الاكتشاف التلقائي:**
> 1. Prometheus asks Kubernetes API: "What pods exist in `infra-full-stack` namespace?" | يسأل Kubernetes API عن الـ pods الموجودة
> 2. Filters only pods with `prometheus.io/scrape: "true"` annotation | يُفلتر فقط الـ pods بتعليق `scrape: true`
> 3. Builds the target URL from pod IP + annotation port + annotation path | يبني عنوان الهدف من IP + المنفذ + المسار
> 4. Result: `http://<pod-ip>:5000/metrics` | النتيجة: عنوان المقاييس

### Alert Rules | قواعد التنبيه

```yaml
groups:
  - name: flask-app-alerts
    rules:
      # App is down for more than 1 minute
      - alert: AppDown
        expr: up{job="flask-app"} == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Flask App is DOWN"

      # Too many requests
      - alert: HighRequestCount
        expr: app_requests_total > 10000
        for: 5m
        labels:
          severity: warning

      # Pod restarting frequently
      - alert: PodRestart
        expr: increase(kube_pod_container_status_restarts_total{namespace="infra-full-stack"}[1h]) > 3
        for: 1m
        labels:
          severity: warning
```

### Custom Flask Metrics | مقاييس Flask المخصصة

The Flask app exposes Prometheus-compatible metrics at `/metrics`:

```
# HELP app_requests_total Total number of requests
# TYPE app_requests_total counter
app_requests_total 1542

# HELP app_up Application up status
# TYPE app_up gauge
app_up 1

# HELP app_uptime_seconds Application uptime in seconds
# TYPE app_uptime_seconds gauge
app_uptime_seconds 86400

# HELP app_info Application information
# TYPE app_info gauge
app_info{version="1.1.0",hostname="flask-app-7d4b8c6f9-x2k4m"} 1
```

---

## 🟠 Grafana — Dashboards & Visualization | لوحات المعلومات والتمثيل البصري

### Auto-Provisioned Datasource | مصدر بيانات مُعد مسبقًا

```yaml
# ConfigMap: grafana-datasources
datasources.yaml: |
  apiVersion: 1
  datasources:
    - name: Prometheus
      type: prometheus
      access: proxy
      url: http://prometheus-service:9090    # K8s internal DNS
      isDefault: true
      editable: true
```

> **💡** Using K8s internal DNS (`prometheus-service:9090`) instead of IP address. Kubernetes automatically resolves service names within the cluster.
>
> استخدام DNS الداخلي لـ K8s بدلاً من عنوان IP. يحل Kubernetes أسماء الخدمات تلقائيًا داخل الكلستر.

### Pre-Built Dashboard (6 Panels) | لوحة معلومات جاهزة (6 أقسام)

| Panel | Type | PromQL Expression | Purpose |
|:------|:-----|:------------------|:--------|
| App Status | stat | `up{job="flask-app"}` | UP/DOWN indicator |
| Total Requests | stat | `sum(app_requests_total)` | Request counter |
| Running Pods | stat | `count(up{job="flask-app"} == 1)` | Active pod count |
| App Uptime | stat | `max(app_uptime_seconds)` | Uptime in seconds |
| Up/Down Over Time | timeseries | `up{job="flask-app"}` | Availability history |
| Requests Rate | timeseries | `rate(app_requests_total[1m])` | Requests per second |

### Secure Access — K8s Secrets | الوصول الآمن

```yaml
env:
  - name: GF_SECURITY_ADMIN_USER
    value: "admin"
  - name: GF_SECURITY_ADMIN_PASSWORD
    valueFrom:
      secretKeyRef:
        name: grafana-secrets
        key: admin-password          # From K8s Secret, not hardcoded!
  - name: GF_USERS_ALLOW_SIGN_UP
    value: "false"                   # Disable public registration
```

---

## 📊 Access Points | نقاط الوصول

| Service | Port | Endpoint |
|:--------|:----:|:---------|
| Flask App | `30080` | `http://<server-ip>:30080` |
| Prometheus | `30090` | `http://<server-ip>:30090` |
| Grafana | `30030` | `http://<server-ip>:30030` |

---

## 🔑 Key Takeaways | الخلاصات الرئيسية

1. **Use kubernetes_sd for auto-discovery** — Don't hardcode pod IPs, let Prometheus find them | استخدم الاكتشاف التلقائي بدلاً من عناوين IP الثابتة
2. **Annotations > Static Config** — Pod annotations make scrape configuration declarative | التعليقات على الـ pods أفضل من الإعداد الثابت
3. **Dashboard as Code** — Store Grafana dashboards in ConfigMaps for version control | خزّن لوحات Grafana في ConfigMaps للتحكم بالإصدارات
4. **RBAC is mandatory** — Prometheus needs explicit permission to discover pods | RBAC إلزامي لاكتشاف الـ pods
5. **Alert rules catch problems early** — Define alerts for down apps, high load, and frequent restarts | قواعد التنبيه تكشف المشاكل مبكرًا
6. **Never hardcode Grafana passwords** — Use K8s Secrets via `secretKeyRef` | لا تكتب كلمات مرور Grafana مباشرة

---

> **🔗 Files Reference | مرجع الملفات:**
> - `kubernetes/monitoring/prometheus/` (deployment, configmap, clusterrole)
> - `kubernetes/monitoring/grafana/` (deployment, configmap)
