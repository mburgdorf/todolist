# Todo List – Server Setup

> **Projekt:** Todo List für die Berufsschule  
> **Entwickler:** Maik Burgdorf

---

## Inhaltsverzeichnis

1. [Statische IP festlegen](#1-statische-ip-festlegen)
2. [Benutzer anlegen](#2-benutzer-anlegen)
3. [SSH-Dienst installieren & konfigurieren](#3-ssh-dienst-installieren--konfigurieren)
4. [SSH-Zugriff einschränken](#4-ssh-zugriff-einschränken)
5. [Zusammenfassung](#zusammenfassung)

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
     ipv4.method manual
   ```

3. Änderung aktivieren:

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
