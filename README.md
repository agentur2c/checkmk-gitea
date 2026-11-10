# Checkmk Local Check für gitea / gitea-runner Update-Status

Dieses Bash-Skript integriert eine automatische Prüfung auf verfügbare gitea- / gitea-runner Updates in **Checkmk**. Es fragt die Version das Binary ab, vergleit mit der aktuellsten Download-Version und bereitet sie im passenden Format für einen Checkmk **Local Check** auf.

Dank einer integrierten, intelligenten Cache-Logik läuft Abfrage standardmäßig nur einmal pro Stunde. Liegt jedoch ein Fehler oder ein ausstehendes Update vor, schaltet das Skript sofort in den Minutentakt, damit Checkmk nach dem Einspielen des Updates **innerhalb von 60 Sekunden automatisch wieder auf Grün wechselt**.

## Getestet mit folgenden Versionen
* Checkmk Community (formerly Raw) >= 2.5.0
* Gitea >= 28.3.0
* Gitea-Runner >= 5.0.0

## Features
* **Automatische Erkennung:** Prüft zuverlässig, ob ein neues Gitea-Update bereitsteht.
* **Sofortige Fehlererkennung:** Strukturelle Probleme hebeln den Cache aus und werden **immer sofort** (innerhalb von 60 Sekunden) als `UNKNOWN` gemeldet.
* **Intelligentes Caching:** Schont die CPU, indem das Programm bei einem `OK`-Status nur alle 60 Minuten (`3600` Sekunden) abgefragt wird.
* **Dynamische Reaktionszeit:** Bei `WARN` (Updates verfügbar) oder `CRITICAL` (CLI-Fehler) wird der Cache ignoriert. Nach einem erfolgreichen Update wird der Status im nächsten Checkmk-Durchlauf sofort wieder grün.

---

# Installation / Update

## Automatisch

### Installationsskript quick-install.sh für gitea

**Über wget:**
```bash
wget -O - "https://raw.githubusercontent.com/agentur2c/checkmk-gitea/refs/heads/main/quick-install.sh" | sh
```

**Alternativ über curl:**
```bash
curl -s "https://raw.githubusercontent.com/agentur2c/checkmk-gitea/refs/heads/main/quick-install.sh" | sh
```

### Installationsskript quick-install-runner.sh für gitea-runner

**Über wget:**
```bash
wget -O - "https://raw.githubusercontent.com/agentur2c/checkmk-gitea/refs/heads/main/quick-install-runner.sh" | sh
```

**Alternativ über curl:**
```bash
curl -s "https://raw.githubusercontent.com/agentur2c/checkmk-gitea/refs/heads/main/quick-install-runner.sh" | sh
```

**Danach mit Schritt 4 der manuellen Installation fortfahren.**


## Manuell

### 1. Skript im Standard-Local-Verzeichnis ablegen
Da das Skript sein Caching selbst steuert, wird es im normalen `local`-Ordner für minütliche Ausführung abgelegt:

```bash
mkdir -p /usr/lib/check_mk_agent/local
```

### 2. Skript herunterladen
Lade das Skript direkt in das Verzeichnis herunter.

**Über wget:**
```bash
wget -O /usr/lib/check_mk_agent/local/gitea_version "https://raw.githubusercontent.com/agentur2c/checkmk-gitea/refs/heads/main/gitea_version/"
wget -O /usr/lib/check_mk_agent/local/gitea-runner_version "https://raw.githubusercontent.com/agentur2c/checkmk-gitea/refs/heads/main/gitea-runner_version/"
```

**Alternativ über curl:**
```bash
curl -o /usr/lib/check_mk_agent/local/gitea_version "https://raw.githubusercontent.com/agentur2c/checkmk-gitea/refs/heads/main/gitea_version"
curl -o /usr/lib/check_mk_agent/local/gitea-runner_version "https://raw.githubusercontent.com/agentur2c/checkmk-gitea/refs/heads/main/gitea-runner_version"
```

### 3. Ausführungsrechte vergeben
Damit der Checkmk-Agent das Skript ausführen kann, müssen die Rechte angepasst werden:

```bash
chmod +x /usr/lib/check_mk_agent/local/gitea_version
chmod +x /usr/lib/check_mk_agent/local/gitea-runner_version
```

### 4. In Checkmk einbinden
1. Wechsle in die **Checkmk Web-Oberfläche**.
2. Rufe die **Setup / Service Discovery** (Service-Erkennung) des betroffenen Hosts auf.
3. Checkmk erkennt den neuen Service `"Gitea Version"` automatisch.
4. Übernehme den Service mit **Accept all** und aktiviere die Änderungen (**Changes aktivieren**).

---

## Funktionsweise & Cache-Logik
Das Skript wird vom Checkmk-Agenten jede Minute aufgerufen, arbeitet aber extrem ressourcenschonend über eine eigene Cache-Datei unter `/var/tmp/cmk_gitea_update.cache`:

1. **Struktureller Check:** Zuerst wird geprüft, ob das Gitea-Verzeichnis existiert. Wenn nicht, bricht das Skript sofort mit `UNKNOWN` ab (kein Cache-Verzug!).
2. **Im Gut-Fall (OK):** Ist das System aktuell, liest das Skript 60 Minuten lang einfach nur blitzschnell die Cache-Datei aus. Die Gitea-CLI wird nicht belastet.
3. **Im Fehler- oder Update-Fall:** Meldet Gitea ein Update oder stürzt ab, wird dieser Status an Checkmk übergeben. Bei allen folgenden minütlichen Abfragen erzwingt das Skript eine Echtzeit-Prüfung, bis das System wieder `OK` ist.

## Lizenz usw.
Provided as is - use it on your own risk :-)
