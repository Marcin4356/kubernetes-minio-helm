Problemy i rozwiązania  
MinIO w stanie offline  
Po zainstalowaniu MinIO sprawdziłem `/minio/health/ready` i dostałem `X-Minio-Server-Status: offline`. 
Próba `mc alias set` kończyła się błędem `Server not initialized yet`. 
Okazało się, że miałem `replicas: 2` i `persistence.enabled: false` w `values.yaml`. MinIO w trybie distributed wymaga storage. Włączyłem `persistence.enabled: true`, ustawiłem `size: 10Gi` i `storageClass: local-path`. Po `helm upgrade` MinIO weszło w stan online.

Brak repozytorium bitnami  
Przy próbie `helm upgrade` dostałem błąd `repo bitnami not found`. Dodałem repo i zrobiłem update:

helm repo add bitnami https://charts.bitnami.com/bitnami  
helm repo update

Potem upgrade działał normalnie.

Brak auth w values.yaml  
Po włączeniu persistence i upgrade dostałem błąd o braku `root-user` w secrecie. Dodałem w `values.yaml`:

auth:  
  rootUser: mojadmin  
  rootPassword: Haslo2025!

Zrobiłem ponownie `helm upgrade` i MinIO zaczęło działać z nowymi danymi.

port-forward i mc  
Przy próbie `mc alias set` dostawałem `connection refused`, bo przerywałem albo w ogóle nie włączałem `kubectl port-forward`. Odpaliłem `kubectl port-forward svc/minio-svc -n minio 9000:9000` w osobnym terminalu i wtedy `mc alias set` zadziałał.

Brak synchronizacji Helm release  
Po kilku `helm upgrade` zauważyłem, że niektóre zmiany z `values.yaml` nie były stosowane. Wyczyściłem lokalny cache i wymusiłem odświeżenie:

helm repo update  
helm dependency update  
helm upgrade …

Pomogło i zmiany zaczęły się propagować.

Problem z readiness probe MinIO  
MinIO długo utrzymywał się w stanie `not ready` mimo że pody były `Running`. Okazało się, że readiness probe miał zbyt krótki timeout dla distributed setup. Zwiększyłem `readinessProbe.initialDelaySeconds` i `timeoutSeconds` w `values.yaml` i MinIO zgłosiło `Ready`.

Problem z local-path PVC  
PVC dla MinIO czasami wchodziło w `Pending`, bo w klastrze brakowało miejsca w `/opt/local-path-provisioner`. Zwolniłem miejsce na nodach i zrestartowałem MinIO — problem zniknął.

Konflikt portów na localhost  
Podczas `port-forward` MinIO pojawiał się błąd `address already in use`, bo port 9000 był już zajęty. Znalazłem proces blokujący port przez `lsof -i :9000` i zabiłem go. Potem `port-forward` działał poprawnie.

Podsumowanie  
Wszystkie błędy udało mi się rozwiązać. MinIO działa w trybie distributed, storage jest włączony, repozytorium bitnami dodane, auth ustawione, port-forward działa.
