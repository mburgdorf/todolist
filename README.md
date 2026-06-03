# Todo List – Server Setup

> **Projekt:** Todo List für die Berufsschule  
> **Entwickler:** Maik Burgdorf

---

## Inhaltsverzeichnis

1. [Statische IP festlegen](#1-statische-ip-festlegen)
2. [Benutzer anlegen](#2-benutzer-anlegen)
3. [SSH-Dienst installieren & konfigurieren](#3-ssh-dienst-installieren--konfigurieren)
4. [SSH-Zugriff einschränken](#4-ssh-zugriff-einschränken)
5. [Docker installieren & konfigurieren](#5-docker-installieren--konfigurieren)
6. [Todo-Listen-Anwendung deployen](#6-todo-listen-anwendung-deployen)
7. [Zugriff auf die API](#7-zugriff-auf-die-api)
8. [Nützliche Docker-Befehle](#8-nützliche-docker-befehle)

---

## 1. Statische IP festlegen

**Ziel:** IP-Adresse von `192.168.24.137` auf `192.168.24.105` ändern.

1. Verbindungsnamen ermitteln:

   ```bash
   nmcli connection show
   ```

2. Statische IP konfigurieren (Verbindungsname und IP ggf. anpassen):

   ```bash
   
   sudo nmcli connection modify netplan-eth0 \
   ipv4.addresses 192.168.24.105/24 \
   ipv4.gateway 192.168.24.254 \
   ipv4.dns "192.168.24.254" \
   ipv4.method manual

   ```

3. Änderung aktivieren:
   
   ```bash
   sudo nmcli connection down netplan-eth0
   ```


   ```bash
   sudo nmcli connection up netplan-eth0
   ```

> **Hinweis:** Für diesen Schritt werden `sudo`-Rechte benötigt.

---

## 2. Benutzer anlegen

### 2.1 Benutzer `willi`

```bash
sudo adduser willi
```

- Passwort vergeben (in unserem Fall: `1234`)
- Dem Dialog folgen und am Ende mit **Y** bestätigen

### 2.2 Benutzer `fernzugriff`

```bash
sudo adduser fernzugriff
```

- Passwort vergeben (in unserem Fall: `12345`)
- Dem Dialog folgen und am Ende mit **Y** bestätigen

### 2.3 Sudo-Rechte für `fernzugriff` vergeben

```bash
sudo usermod -aG sudo fernzugriff
```

Prüfung:

```bash
groups fernzugriff
```

> Erwartete Ausgabe: Die Gruppe `sudo` ist aufgelistet.

---

## 3. SSH-Dienst installieren & konfigurieren

### 3.1 Paket installieren

```bash
sudo apt update
sudo apt install openssh-server -y
```

### 3.2 Dienst starten und dauerhaft aktivieren

```bash
sudo systemctl enable ssh
sudo systemctl start ssh
```

### 3.3 Status prüfen

```bash
sudo systemctl status ssh
```

> Erwartete Ausgabe enthält `enabled` und `active (running)`.

---

## 4. SSH-Zugriff einschränken

Nur der Benutzer `fernzugriff` soll sich per SSH verbinden dürfen.

1. SSH-Konfiguration öffnen:

   ```bash
   sudo nano /etc/ssh/sshd_config
   ```

2. Am Ende der Datei folgende Zeile hinzufügen:

   ```
   AllowUsers fernzugriff
   ```

3. SSH-Dienst neu starten, damit die Änderung greift:

   ```bash
   sudo systemctl restart ssh
   ```

---

## Zusammenfassung

| Benutzer | Passwort | Sudo | SSH-Zugang |
|----------|----------|------|------------|
| `willi` | `1234` | ❌ | ❌ |
| `fernzugriff` | `12345` | ✅ | ✅ |

Der Server ist nun unter der statischen IP `192.168.24.105` erreichbar. Ausschließlich der Benutzer `fernzugriff` kann sich per SSH verbinden und verfügt über administrative Rechte.

---

## 5. Docker installieren & konfigurieren

### 5.1 System aktualisieren

Vor der Docker-Installation sollten alle Pakete auf den neuesten Stand gebracht werden:

```bash
sudo apt-get update && sudo apt-get upgrade -y
```

### 5.2 Docker installieren

```bash
sudo apt install docker.io -y
```

### 5.3 Docker-Dienst starten und aktivieren

```bash
sudo systemctl enable docker.service
sudo systemctl start docker.service
```

### 5.4 Installation testen

**Test: Hello-World-Container**

```bash
sudo docker run hello-world
```

> **Erwartete Ausgabe:** `Hello from Docker!`

---

## 6. Todo-Listen-Anwendung deployen

### 6.1 Projektdateien auf den Raspberry Pi übertragen

Von deinem **lokalen Windows-PC** aus:

```powershell
scp Dockerfile server.py specification.yaml fernzugriff@192.168.24.105:~/todolist/
```

> Die Dateien werden in das Verzeichnis `~/todolist/` auf dem Raspberry Pi kopiert.

### 6.2 Docker-Image bauen

Per SSH auf dem Raspberry Pi einloggen:

```powershell
ssh fernzugriff@192.168.24.105
```

In das Projektverzeichnis wechseln und das Docker-Image erstellen:

```bash
cd ~/todolist
docker image build -t todolist-webapp .
```

### 6.3 Container starten

```bash
docker run -d -p 5000:5000 --name todolist todolist-webapp
```

**Parameter-Erklärung:**
- `-d`: Container läuft im Hintergrund (detached mode)
- `-p 5000:5000`: Port-Weiterleitung (Host:Container)
- `--name todolist`: Vergabe eines Container-Namens
- `todolist-webapp`: Name des Images

---

## 7. Zugriff auf die API

Die Todo-Listen-API ist nun von jedem Gerät im Netzwerk erreichbar:

**Basis-URL:**
```
http://192.168.24.105:5000/
```

**Beispiel-Anfrage:**

**Alle Einträge einer Liste abrufen:**
   ```
   GET http://192.168.24.105:5000/todo-list/1318d3d1-d979-47e1-a225-dab1751dbe75
   ```

---

## 8. Nützliche Docker-Befehle

| Befehl | Beschreibung |
|--------|--------------|
| `docker ps` | Zeigt laufende Container |
| `docker ps -a` | Zeigt alle Container (auch gestoppte) |
| `docker stop todolist` | Stoppt den Container |
| `docker start todolist` | Startet den Container |
| `docker restart todolist` | Startet den Container neu |
| `docker logs todolist` | Zeigt Container-Logs |
| `docker rm todolist` | Löscht den Container (muss gestoppt sein) |
| `docker images` | Zeigt alle Images |
| `docker rmi todolist-webapp` | Löscht das Image |

---