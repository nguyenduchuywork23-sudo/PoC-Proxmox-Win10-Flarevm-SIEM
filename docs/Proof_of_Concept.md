# Proof of Concept: Validation & Execution

This document provides real-world validation logs from the Proxmox environment, proving that the Air-Gapped routing, Telemetry pipeline, and Detection Rules are functioning securely.

## 1. Network Isolation & Telemetry Pipeline Validation
**Goal:** Prove that the Windows 10 victim machine (`10.0.0.2`) can successfully bypass the `iptables DROP` kill-switch **exclusively** for SIEM telemetry (Port 1514), while remaining completely air-gapped from the internet.

**Execution on Windows 10 (FLARE-VM):**
```powershell
PS C:\Windows\system32 > Get-NetTCPConnection -RemoteAddress 192.168.1.244

LocalAddress        LocalPort RemoteAddress       RemotePort State       AppliedSetting
------------        --------- -------------       ---------- -----       --------------
10.0.0.2            54374     192.168.1.244       1514       Established Internet
```

## 2. Endpoint Telemetry Generation (Sysmon EID 5)
**Goal:** Prove that Sysmon is actively monitoring the endpoint, capturing deep process lifecycle events (creation/termination), and formatting them for the Wazuh Agent.

**Execution on Windows 10 (FLARE-VM):**
```powershell
PS C:\Windows\system32 > Get-WinEvent -LogName "Microsoft-Windows-Sysmon/Operational" -MaxEvents 1 | Select-Object TimeCreated, Message | Format-List

TimeCreated : 7/30/2026 2:38:38 PM
Message     : Process terminated:
              RuleName: -
              UtcTime: 2026-07-30 21:38:38.846
              ProcessGuid: {3e8a7aa9-c3e5-6a6b-4e13-000000001400}
              ProcessId: 6500
              Image: C:\Windows\servicing\TrustedInstaller.exe
              User: NT AUTHORITY\SYSTEM
```

## 3. SIEM Detection & Alerting (Wazuh & Suricata)
**Goal:** Prove that the SIEM (Wazuh) successfully aggregates and correlates logs from both the endpoint (Sysmon) and the network gateway (Suricata), triggering alerts for malicious activities.

**Execution on Windows 10 (FLARE-VM):**
*(Errors removed for brevity - demonstrating local user creation and simulated C2 traffic)*

```powershell
PS C:\Windows\system32 > net user evil_hacker P@ssw0rd123 /add
The command completed successfully.

PS C:\Windows\system32 > curl -UseBasicParsing http://testmyids.com

StatusCode        : 200
StatusDescription : OK
Content           : <html>...<title>INetSim default HTML page</title>...</html>

PS C:\Windows\system32 > curl -UseBasicParsing -UserAgent "BlackSun" http://10.0.2.1

StatusCode        : 200
StatusDescription : OK
Content           : <html>...<title>INetSim default HTML page</title>...</html>
```

### 3.1. Endpoint Detection (Sysmon via Wazuh)
*Wazuh successfully detected the creation of a suspicious local user account (`evil_hacker`) via Sysmon Event ID 1.*

![Wazuh Sysmon Alert](images/wazuh_sysmon_alert.png)

### 3.2. Network Detection (Suricata via Wazuh)
*Wazuh aggregated Suricata NIDS alerts, detecting both the `testmyids.com` trigger and the suspicious `BlackSun` User-Agent hitting the INetSim sinkhole.*

![Wazuh Suricata Alert](images/wazuh_suricata_alert.png)
