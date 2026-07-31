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
*(Errors removed for brevity - demonstrating privilege discovery, local user creation, and simulated C2 traffic)*

```powershell
PS C:\Windows\system32 > whoami /priv

PRIVILEGES INFORMATION
----------------------
Privilege Name                            Description                                                        State
========================================= ================================================================== ========
SeAssignPrimaryTokenPrivilege             Replace a process level token                                      Disabled
SeIncreaseQuotaPrivilege                  Adjust memory quotas for a process                                 Disabled
SeSecurityPrivilege                       Manage auditing and security log                                   Disabled
SeTakeOwnershipPrivilege                  Take ownership of files or other objects                           Disabled
SeLoadDriverPrivilege                     Load and unload device drivers                                     Disabled
SeSystemProfilePrivilege                  Profile system performance                                         Disabled
SeSystemtimePrivilege                     Change the system time                                             Disabled
SeProfileSingleProcessPrivilege           Profile single process                                             Disabled
SeIncreaseBasePriorityPrivilege           Increase scheduling priority                                       Disabled
SeCreatePagefilePrivilege                 Create a pagefile                                                  Disabled
SeBackupPrivilege                         Back up files and directories                                      Disabled
SeRestorePrivilege                        Restore files and directories                                      Disabled
SeShutdownPrivilege                       Shut down the system                                               Disabled
SeDebugPrivilege                          Debug programs                                                     Enabled
SeSystemEnvironmentPrivilege              Modify firmware environment values                                 Disabled
SeChangeNotifyPrivilege                   Bypass traverse checking                                           Enabled
SeRemoteShutdownPrivilege                 Force shutdown from a remote system                                Disabled
SeUndockPrivilege                         Remove computer from docking station                               Disabled
SeManageVolumePrivilege                   Perform volume maintenance tasks                                   Disabled
SeImpersonatePrivilege                    Impersonate a client after authentication                          Enabled
SeCreateGlobalPrivilege                   Create global objects                                              Enabled
SeIncreaseWorkingSetPrivilege             Increase a process working set                                     Disabled
SeTimeZonePrivilege                       Change the time zone                                               Disabled
SeCreateSymbolicLinkPrivilege             Create symbolic links                                              Disabled
SeDelegateSessionUserImpersonatePrivilege Obtain an impersonation token for another user in the same session Disabled

PS C:\Windows\system32 > net user evil_hacker P@ssw0rd123 /add
The command completed successfully.

PS C:\Windows\system32 > curl -UseBasicParsing http://testmyids.com

StatusCode        : 200
StatusDescription : OK
Content           : <html>...<title>INetSim default HTML page</title>...</html>...

PS C:\Windows\system32 > curl -UseBasicParsing -UserAgent "BlackSun" http://10.0.2.1

StatusCode        : 200
StatusDescription : OK
Content           : <html>...<title>INetSim default HTML page</title>...</html>...
```

### 3.1. Endpoint Detection (Sysmon via Wazuh)
*Wazuh successfully detected suspicious endpoint activities via Sysmon, including privilege discovery and malicious local user creation.*

**Alert 1: Privilege Discovery Activity**
*Detected execution of `whoami /priv` (Sysmon Event ID 1).*
![Wazuh Sysmon Alert - Discovery](images/wazuh_sysmon_alert_2.jpg)

**Alert 2: Malicious User Creation**
*Detected the creation of a suspicious local user account (`evil_hacker`) via Sysmon Event ID 1.*
![Wazuh Sysmon Alert - User Add](images/wazuh_sysmon_alert_1.jpg)

### 3.2. Network Detection (Suricata via Wazuh)
*Wazuh aggregated Suricata NIDS alerts, detecting both the `testmyids.com` trigger and the suspicious `BlackSun` User-Agent hitting the INetSim sinkhole.*

![Wazuh Suricata Alert](images/wazuh_suricata_alert.jpg)
