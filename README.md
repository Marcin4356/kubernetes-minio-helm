# 📄 Zadanie rekrutacyjne – Junior DevOps Engineer

## 🔷 Opis zadania

Celem projektu jest lokalne uruchomienie klastra Kubernetes w trybie multi-node oraz wdrożenie w nim trzech komponentów przy pomocy Helm:

- **nginx-ingress** – Ingress Controller
- **MinIO** – obiektowy storage z wgranymi obrazkami
- **nginx-frontend** – serwis zwracający statyczny HTML z obrazkami z MinIO
- **Horizontal Pod Autoscaler (HPA)** dla frontendu

---

## 🖥️ Wymagania środowiskowe

Przed rozpoczęciem upewnij się, że masz zainstalowane:

- Docker
- Rancher Desktop (Container Runtime: dockerd)
- k3d
- kubectl
- Helm
- MinIO Client (`mc`)

---

## 🚀 Uruchomienie krok po kroku

### 1️⃣ Utwórz klaster Kubernetes (HA)

Utwórz lokalny klaster k3s z 3 serwerami i 2 agentami:

```bash
k3d cluster create task-ha \
  --servers 3 \
  --agents 2 \
  --k3s-server-arg "--write-kubeconfig-mode=644" \
  --wait
```

Sprawdź stan węzłów:

```bash
kubectl get nodes
```

---

### 2️⃣ Zainstaluj nginx-ingress

Dodaj repozytorium Helm i zainstaluj nginx-ingress:

```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

helm install nginx-ingress ingress-nginx/ingress-nginx \
  -n ingress-nginx --create-namespace \
  -f helm-values/nginx-ingress/values.yaml
```

---

### 3️⃣ Zainstaluj MinIO

Dodaj repozytorium Helm i zainstaluj MinIO:

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

helm install minio bitnami/minio \
  -n minio --create-namespace \
  -f helm-values/minio/values.yaml
```

Skonfiguruj MinIO Client (`mc`):

```bash
mc alias set localminio http://<IP_MINIO>:9000 minio minio123
```

Utwórz bucket `demo` i załaduj obrazy:

```bash
mc mb localminio/demo
mc cp localminio/images/*.jpg localminio/demo/
```

---

### 4️⃣ Wdróż nginx-frontend

Wdróż frontend z własnego Helm chartu:

```bash
helm install nginx-frontend ./helm-values/nginx-frontend -n default
```

---

### 5️⃣ Skonfiguruj Ingress

Zaaplikuj manifest Ingress:

```bash
kubectl apply -f k8s-manifests/ingress.yaml
```

Dodaj wpis do pliku `/etc/hosts`:

```
127.0.0.1 demo.local
```

Przejdź w przeglądarce do: http://demo.local

---

### 6️⃣ Skonfiguruj HPA

Upewnij się, że metrics-server działa:

```bash
kubectl get deployment metrics-server -n kube-system
```

Wdróż HPA:

```bash
kubectl apply -f k8s-manifests/hpa-nginx-frontend.yaml
```

Sprawdź działanie HPA:

```bash
kubectl get hpa
```

---

## 📂 Struktura repozytorium

```
helm-values/
├── minio/
│   ├── policy.json
│   └── values.yaml
├── nginx-frontend/
│   ├── Chart.yaml
│   ├── index.html
│   ├── templates/
│   │   ├── configmap.yaml
│   │   ├── deployment.yaml
│   │   ├── ingress.yaml
│   │   ├── nginx-configmap.yaml
│   │   └── service.yaml
│   └── values.yaml
└── nginx-ingress/
    └── values.yaml

k8s-manifests/
├── hpa-nginx-frontend.yaml
└── ingress.yaml

values-minio.yaml
README.md
NOTES.md
```

---

## 🔗 Źródła

- Rancher Desktop
- k3d
- nginx-ingress Helm Chart
- MinIO Helm Chart
- nginx Helm Chart (statyczny)

---

📌 **Autor:** Marcin4356  
📌 **Repozytorium:** https://github.com/Marcin4356/unofficial
