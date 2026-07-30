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
