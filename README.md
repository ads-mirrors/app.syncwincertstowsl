# 🛡️ Sync Windows Trusted Certificates into WSL

This toolkit allows you to **export Windows system certificates** (Root, Intermediate, AuthRoot) and **import them into a WSL (Ubuntu)** trust store for use with tools like `curl`, `git`, `apt`, etc. It also includes a cleanup script to remove the imported certificates.

---

## 📁 Included Files

| Filename                     | Purpose                                                                                                        |
| ---------------------------- | -------------------------------------------------------------------------------------------------------------- |
| `GetWindowsCerts.ps1`        | PowerShell script that exports all Root, Intermediate, and AuthRoot certificates from Windows into PEM format. |
| `import-split-windows-ca.sh` | WSL (Ubuntu) Bash script that splits, renames, and installs the exported certificates.                         |
| `cleanup-sync-ca.sh`         | WSL (Ubuntu) Bash script that removes the imported certificates and deletes the Windows export directory.      |

---

## 🧭 Instructions

### Step 1: Export Windows Certificates

Run the PowerShell script from an **elevated Administrator PowerShell** session on Windows:

```powershell
.\GetWindowsCerts.ps1
```

This will export all machine-level Root, AuthRoot, and Intermediate certificates to:

```
C:\ca-export\windows-root-certs\
```

Each file will contain a full certificate chain in PEM format.

---

### Step 2: Import into WSL (Ubuntu)

In WSL Ubuntu 20.x:

1. Make the import script executable:

```bash
chmod +x import-split-windows-ca.sh
```

2. Run the script:

```bash
sudo ./import-split-windows-ca.sh
```

This will:

* Split each `.pem` bundle into individual `.crt` files
* Install them into `/usr/local/share/ca-certificates/windows-roots/`
* Refresh the trust store using `update-ca-certificates`

After this step, system tools in Ubuntu will trust the imported Windows CAs.

---

### Step 3: (Optional) Clean Up Certificates

To remove the previously imported certs and delete the Windows export folder:

1. Make the cleanup script executable:

```bash
chmod +x cleanup-sync-ca.sh
```

2. Run it:

```bash
sudo ./cleanup-sync-ca.sh
```

This will:

* Remove all `.crt` files in `/usr/local/share/ca-certificates/windows-roots/`
* Refresh the trust store to purge them
* Delete the export folder: `C:\ca-export\windows-root-certs`

---

## 🔐 Security Notes

* Use these scripts only in trusted corporate or internal environments.
* This method expands your Linux CA trust footprint to match Windows—be cautious if using public networks or high-security workloads.
* Always review which certificates are exported by inspecting the files in `C:\ca-export\windows-root-certs`.

---

## ✅ Compatibility

* **Windows**: PowerShell 5.1+, Windows 10/11
* **Linux (WSL)**: Ubuntu 20.04 or later
* Tested in WSL 2 environments with `update-ca-certificates`