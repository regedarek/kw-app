# Checklist & Dokumentacja

## Staging i Production Deployment

**Stack:** Kamal + Docker + Rails + Static (nginx)

---

## 1. Cele dokumentu

Celem tego dokumentu jest dostarczenie **kompletnej, krok‑po‑kroku dokumentacji wdrożeniowej i operacyjnej**, która:

* umożliwia postawienie środowiska **staging na Raspberry Pi** oraz **production na VPS/bare‑metal**
* minimalizuje różnice pomiędzy środowiskami (staging ≈ production)
* pełni rolę checklisty operacyjnej
* ułatwia utrzymanie, backup oraz disaster recovery

Dokument jest przeznaczony do trzymania w repozytorium (np. `/docs/ops.md`).

---

## 2. Architektura referencyjna

### 2.1 Założenia

* Single host (brak klastra)
* Kontenery Docker zarządzane przez Kamal
* Routing HTTP/HTTPS przez kamal‑proxy
* Zero‑downtime deploy

### 2.2 Diagram logiczny

* 1 × host (Raspberry Pi – staging / VPS – production)
* Docker Engine
* kamal‑proxy (80/443)
* Kontenery:

  * Rails app (Puma)
  * Static site (nginx)
  * PostgreSQL (accessory)

---

## 3. Implementation Stages

### Stage 0 – Przygotowanie infrastruktury

**Cel:** stabilny, powtarzalny host pod Docker.

Checklist:

* [ ] Ubuntu Server 24.04 LTS (ARM64 dla Pi, AMD64 dla VPS)
* [ ] SSD jako primary storage
* [ ] Swap ≥ 4 GB
* [ ] `vm.swappiness=10`
* [ ] Aktualizacja systemu (`apt update && apt upgrade`)
* [ ] Użytkownik deploy (SSH key, sudo)
* [ ] Firewall (UFW): 22, 80, 443
* [ ] Synchronizacja czasu (systemd-timesyncd)

Decyzje:

* brak GUI
* brak snap Dockera

---

### Stage 1 – Docker

**Cel:** zapewnić runtime i restart kontenerów.

Checklist:

* [ ] Instalacja docker‑ce
* [ ] Instalacja docker‑compose‑plugin
* [ ] `docker info` działa poprawnie
* [ ] Docker uruchamia się po reboocie

Test:

```bash
docker run --rm hello-world
```

Opcje:

* ❌ Docker Swarm
* ❌ Kubernetes

---

### Stage 2 – Repozytorium aplikacji

**Cel:** identyczny artefakt na staging i production.

Checklist:

* [ ] Jeden Dockerfile (multi‑arch)
* [ ] `FROM ruby:<version>-slim`
* [ ] HEALTHCHECK endpoint (`/up`)
* [ ] Assets build w Dockerfile
* [ ] ENV rozdzielone (staging / production)
* [ ] Sekrety poza repo (ENV / Kamal secrets)

Opcje buildów:

* lokalny build + push
* CI (GitHub Actions – rekomendowane)

---

### Stage 3 – Kamal (staging)

**Cel:** pierwsze wdrożenie kontrolne.

Checklist:

* [ ] `kamal init`
* [ ] `config/deploy.staging.yml`
* [ ] Unikalny `service` name
* [ ] `proxy.host` (LAN lub staging domain)
* [ ] SSL wyłączone lub lokalne
* [ ] `kamal setup`
* [ ] `kamal deploy`

Walidacja:

* aplikacja odpowiada
* restart kontenera działa

---

### Stage 4 – Baza danych

**Cel:** trwałość danych i backup.

Checklist:

* [ ] PostgreSQL jako accessory
* [ ] Oddzielna baza dla staging
* [ ] Volume dla danych
* [ ] Dane nie trzymane w kontenerze

Opcje:

* lokalna DB (container) – staging
* managed DB – production (opcjonalnie)

---

### Stage 5 – Static Site

**Cel:** minimalny, stabilny hosting statyczny.

Checklist:

* [ ] nginx:alpine
* [ ] Tylko pliki statyczne
* [ ] Osobny service w Kamal
* [ ] Routing po domenie

Brak:

* Node.js
* runtime logic

---

### Stage 6 – Production cut‑over

**Cel:** przejście na produkcję bez zmiany architektury.

Checklist:

* [ ] `config/deploy.yml`
* [ ] Publiczny DNS
* [ ] SSL (Let's Encrypt)
* [ ] Monitoring aktywny
* [ ] Backup harmonogram
* [ ] Test deploy bez downtime

---

## 4. Maintenance & Operations

### 4.1 Utrzymanie serwera

Checklist:

* [ ] Aktualizacje bezpieczeństwa (miesięcznie)
* [ ] Sprawdzenie miejsca na dysku
* [ ] Reboot planowany (co 1–3 mies.)

Rekomendacje:

* alert na <20% wolnego miejsca
* brak automatycznych rebootów

---

### 4.2 Kontenery i aplikacje

Checklist:

* [ ] HEALTHCHECK aktywny
* [ ] Restart policy: `unless-stopped`
* [ ] Logi rotowane

Operacje:

* deploy tylko przez Kamal
* brak ręcznych restartów

---

## 5. Backup Database

### 5.1 Strategia

* Backup logiczny (`pg_dump`)
* 1 backup dziennie (minimum)
* Retencja 7–30 dni
* Backup off‑host

---

### 5.2 Implementacja (konkretna, rekomendowana)

Poniżej opisano **prostą, niezawodną i sprawdzoną implementację backupu PostgreSQL**, odpowiednią zarówno dla staging (Raspberry Pi), jak i production.

#### Założenia

* Backup wykonywany **poza kontenerem aplikacji**
* Użycie `pg_dump` (backup logiczny)
* Backup trafia **off-host** (zewnętrzny storage)
* Backup możliwy do odtworzenia na dowolnym hoście

---

#### Wariant A – Backup przez cron na hoście (rekomendowany)

**Dlaczego:**

* najmniej moving parts
* brak zależności od stanu kontenerów aplikacyjnych
* łatwy restore

##### Krok 1 – Skrypt backupu

`/opt/backups/pg_backup.sh`

```bash
#!/usr/bin/env bash
set -euo pipefail

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M")
BACKUP_DIR="/opt/backups/db"
FILENAME="pg_${TIMESTAMP}.sql.gz"

mkdir -p "$BACKUP_DIR"

pg_dump \
  -h 127.0.0.1 \
  -p 5432 \
  -U app \
  app_production \
  | gzip > "$BACKUP_DIR/$FILENAME"

# opcjonalnie: usuwanie backupów starszych niż 30 dni
find "$BACKUP_DIR" -type f -mtime +30 -delete
```

* uprawnienia:

```bash
chmod +x /opt/backups/pg_backup.sh
```

---

##### Krok 2 – Zmienne środowiskowe

Hasło DB trzymane **poza skryptem**:

```bash
export PGPASSWORD="<secret>"
```

Opcje:

* `.env` tylko dla roota
* systemd EnvironmentFile

---

##### Krok 3 – Cron

`/etc/cron.d/pg_backup`

```cron
0 2 * * * root /opt/backups/pg_backup.sh
```

* backup codziennie o 02:00
* poza godzinami szczytu

---

##### Krok 4 – Upload off-host (wymagane)

Opcje:

* S3 / S3-compatible (Backblaze B2, Wasabi)
* rsync na drugi serwer

Przykład (S3-compatible):

```bash
aws s3 sync /opt/backups/db s3://my-backup-bucket/db
```

---

#### Wariant B – Backup w dedykowanym kontenerze

**Kiedy:**

* brak dostępu do pg_dump na hoście
* polityka „wszystko w Dockerze"

Cechy:

* osobny kontener
* harmonogram przez cron w kontenerze
* większa złożoność

**Rekomendacja:** tylko jeśli Wariant A jest niemożliwy.

---

#### Restore – procedura testowa (OBOWIĄZKOWA)

Checklist restore:

1. Pobierz backup
2. Rozpakuj:

```bash
gunzip pg_YYYY-MM-DD.sql.gz
```

3. Restore:

```bash
psql -h 127.0.0.1 -U app app_production < pg_YYYY-MM-DD.sql
```

Testy:

* aplikacja startuje
* dane są spójne

---

#### Definition of Done – Backup DB

* [ ] Backup wykonuje się automatycznie
* [ ] Backup jest off-host
* [ ] Retencja działa
* [ ] Restore przetestowany ręcznie
* [ ] Procedura opisana w tym dokumencie

---

## 6. Disaster Recovery

Checklist:

* [ ] Repo + Dockerfile dostępne
* [ ] Backup DB poza hostem
* [ ] Instrukcja restore

Proces:

1. Nowy host
2. Docker
3. Kamal setup
4. Restore DB

RTO: < 1h

---

## 7. Opcje rozwoju (future‑proof)

* Managed DB
* CDN dla static
* Drugi VPS (cold‑standby)
* Monitoring APM

---

## 8. Świadomie NIE używamy

* Kubernetes
* Docker Swarm
* Helm
* Service Mesh

Uzasadnienie: over‑engineering dla single‑host.

---

## 9. Definition of Done (Production Ready)

* [ ] Deploy bez downtime
* [ ] Automatyczny restart po crashu
* [ ] Backup + restore przetestowany
* [ ] Monitoring i alerty
* [ ] Dokument aktualny

---

## 10. Notatki operacyjne

*Miejsce na decyzje architektoniczne, zmiany i wyjątki.*