# 🏗️ Terraform — Hetzner Cloud Infrastructure | البنية التحتية كرمز عبر Terraform

> **Project Reference | مرجع المشروع:** [infra-full-stack](https://github.com/mmsal512/infra-full-stack)
> **Date | التاريخ:** 2026-03-12

---

## 📖 Overview | نظرة عامة

**EN:** This note documents the Terraform configuration for provisioning a production server on Hetzner Cloud. It covers the provider setup, resource definitions (server, firewall, SSH key), variables with sensitivity marking, outputs, and the `terraform.tfvars.example` pattern for public repos.

**AR:** توثيق إعدادات Terraform لتوفير سيرفر إنتاجي على Hetzner Cloud. يشمل إعداد المزود، تعريف الموارد (سيرفر، جدار ناري، مفتاح SSH)، المتغيرات مع علامة الحساسية، المخرجات، ونمط `terraform.tfvars.example` للريبوهات العامة.

---

## 🔷 Provider Configuration | إعداد المزود

```hcl
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.45"
    }
  }
}

provider "hcloud" {
  token = var.hcloud_token    # From variables, never hardcoded
}
```

> **💡 Version Constraints | قيود الإصدارات:**
> - `">= 1.5.0"` — Terraform must be at least v1.5.0
> - `"~> 1.45"` — Provider can be 1.45.x but not 1.46+ (pessimistic constraint)
> - This ensures reproducible infrastructure | يضمن بنية تحتية قابلة لإعادة الإنتاج

---

## 📋 Variables — Sensitive Data Handling | المتغيرات — معالجة البيانات الحساسة

```hcl
variable "hcloud_token" {
  description = "Hetzner Cloud API Token"
  type        = string
  sensitive   = true    # ⚠️ Won't appear in logs or plan output
}

variable "ssh_private_key_path" {
  description = "Path to SSH private key"
  type        = string
  default     = "~/.ssh/id_ed25519"
  sensitive   = true    # ⚠️ Marked sensitive
}

variable "server_name" {
  description = "Name of the server"
  type        = string
  default     = "infra-full-stack"   # Non-sensitive — has default
}

variable "server_type" {
  description = "Hetzner server type"
  type        = string
  default     = "cx22"    # 2 vCPU, 4GB RAM — ~€4.5/month
}

variable "ssh_port" {
  description = "Custom SSH port"
  type        = number
  default     = 2026
}
```

> **💡 `sensitive = true` | علامة الحساسية:**
> - Terraform hides this value in `plan` and `apply` output | يخفي القيمة في مخرجات plan و apply
> - Shows `(sensitive value)` instead of the actual value | يعرض `(sensitive value)` بدلاً من القيمة الفعلية
> - **Must use for:** tokens, passwords, private keys | يجب استخدامها لـ: التوكنات، كلمات المرور، المفاتيح الخاصة

---

## 🏗️ Resources | الموارد

### SSH Key | مفتاح SSH

```hcl
resource "hcloud_ssh_key" "default" {
  name       = "${var.server_name}-key"
  public_key = file(var.ssh_public_key_path)
}
```

### Firewall | الجدار الناري

```hcl
resource "hcloud_firewall" "default" {
  name = "${var.server_name}-fw"

  # Custom SSH port
  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = tostring(var.ssh_port)    # 2026
    source_ips = ["0.0.0.0/0", "::/0"]
  }

  # Kubernetes API (K3s)
  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "6443"
    source_ips = ["0.0.0.0/0", "::/0"]
  }

  # NodePort range for K8s services
  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "30000-32767"
    source_ips = ["0.0.0.0/0", "::/0"]
  }

  # Note: HTTP/HTTPS NOT opened — access via Cloudflare Tunnel
}
```

> **💡 Security design | التصميم الأمني:**
> - No HTTP (80) or HTTPS (443) — traffic goes through Cloudflare Tunnel | بدون HTTP/HTTPS — الحركة عبر Cloudflare Tunnel
> - Custom SSH port (2026 instead of 22) — reduces automated attacks | منفذ SSH مخصص يقلل الهجمات الآلية
> - NodePort range allows K8s services to be accessible | نطاق NodePort يسمح بالوصول لخدمات K8s

### Server | السيرفر

```hcl
resource "hcloud_server" "main" {
  name         = var.server_name
  server_type  = var.server_type
  location     = var.server_location
  image        = var.server_image
  ssh_keys     = [hcloud_ssh_key.default.id]
  firewall_ids = [hcloud_firewall.default.id]

  labels = {
    environment = "production"
    managed_by  = "terraform"
    project     = "infra-full-stack"
    owner       = "mohammed-alefari"
  }

  connection {
    type        = "ssh"
    user        = "root"
    private_key = file(var.ssh_private_key_path)
    host        = self.ipv4_address
  }

  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait",
      "echo '✅ Server is ready for Ansible provisioning!'"
    ]
  }
}
```

> **💡 Key concepts | مفاهيم أساسية:**
> - `labels` — Metadata for organizing resources | بيانات وصفية لتنظيم الموارد
> - `connection` — How Terraform connects to the server | كيف يتصل Terraform بالسيرفر
> - `provisioner "remote-exec"` — Runs commands after server creation | ينفذ أوامر بعد إنشاء السيرفر
> - `cloud-init status --wait` — Waits for initial setup to complete | ينتظر اكتمال الإعداد الأولي

---

## 📤 Outputs | المخرجات

```hcl
output "server_ip" {
  description = "Public IPv4 address"
  value       = hcloud_server.main.ipv4_address
}

output "ssh_command" {
  description = "SSH command to connect"
  value       = "ssh -p ${var.ssh_port} root@${hcloud_server.main.ipv4_address}"
}

output "ansible_inventory" {
  description = "Ansible inventory entry"
  value       = "${var.server_name} ansible_host=${hcloud_server.main.ipv4_address} ansible_user=root ansible_port=${var.ssh_port}"
}
```

> **💡** The `ansible_inventory` output generates a ready-to-paste line for your Ansible inventory file. This bridges Terraform and Ansible seamlessly.
>
> مخرج `ansible_inventory` يُنتج سطرًا جاهزًا للصق في ملف Ansible inventory. يربط Terraform و Ansible بسلاسة.

---

## 🔐 The `.tfvars.example` Pattern | نمط ملف tfvars.example

### `terraform.tfvars.example` (committed to Git)

```hcl
hcloud_token         = "YOUR_HETZNER_API_TOKEN"
server_name          = "infra-full-stack"
server_type          = "cx22"
ssh_public_key_path  = "~/.ssh/id_ed25519.pub"
ssh_private_key_path = "~/.ssh/id_ed25519"
ssh_port             = 2026
```

### `terraform.tfvars` (in .gitignore — NEVER committed)

```hcl
hcloud_token         = "actual-real-token-here"    # Real values
```

### `.gitignore` entries

```
terraform/.terraform/
terraform/*.tfstate
terraform/*.tfstate.backup
terraform/*.tfplan
terraform/terraform.tfvars       # ⚠️ Real values — never commit!
terraform/.terraform.lock.hcl
```

> **💡 Pattern | النمط:**
> 1. Commit `.example` file with placeholder values | ارفع ملف `.example` مع قيم وهمية
> 2. User copies: `cp terraform.tfvars.example terraform.tfvars` | المستخدم ينسخ الملف
> 3. User fills in real values | يملأ القيم الحقيقية
> 4. `.gitignore` prevents real values from being committed | `.gitignore` يمنع رفع القيم الحقيقية

---

## 📊 Terraform Workflow | سير عمل Terraform

```
terraform init      # Download provider plugins
    │
terraform plan      # Preview changes (dry-run)
    │
terraform apply     # Create/update resources
    │
terraform output    # View outputs (IPs, commands)
    │
terraform destroy   # Remove all resources (cleanup)
```

---

## 🔑 Key Takeaways | الخلاصات الرئيسية

1. **Mark secrets as `sensitive = true`** — Hides them from plan/apply output | علّم الأسرار بـ `sensitive = true`
2. **Use `.tfvars.example` + `.gitignore`** pattern for public repos | استخدم نمط `.tfvars.example` للريبوهات العامة
3. **Never commit `terraform.tfvars`** or `*.tfstate` files | لا ترفع أبدًا ملفات القيم الحقيقية أو الحالة
4. **Labels help organize** cloud resources | العلامات تساعد في تنظيم الموارد
5. **Outputs bridge tools** — Terraform output → Ansible inventory | المخرجات تربط الأدوات
6. **Version-lock providers** — Use `~>` for stability | ثبّت إصدارات المزودات

---

> **🔗 Files:** `terraform/provider.tf`, `main.tf`, `variables.tf`, `outputs.tf`, `terraform.tfvars.example`
