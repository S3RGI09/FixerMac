![Version](https://img.shields.io/badge/version-stable3.3-green) 
![by](https://img.shields.io/badge/by-S3RGI09-blue) 
![License](https://img.shields.io/badge/license-MIT-red)
# ![FixerMac](https://github.com/user-attachments/assets/400a29cd-722a-477c-b937-4070a62e4e45)

**FixerMac** is a bash script designed to diagnose and fix common macOS issues, including file system, kernel, permissions, pending updates, and network errors. It also generates a report (`report.md`) when it finds errors that it cannot fix automatically.

## Requirements

- macOS.
- Superuser permissions (sudo).

 ## Usage

1. **Clone the repository or download the script.**

2. **Run the script with superuser permissions:**
```
chmod +x fixermac.sh
sudo ./fixermac.sh
```

3. **The script will perform the following checks:**
- File system check (diskutil and fsck).
- Unofficial kernel extensions.
- Non-working kernel extensions
- Available disk space.
- Errors in system logs.
- Pending system updates.
- Network status and connectivity.
- Non-working drivers
- Correct date and time

4. **Options:**
- The script will ask you if you want to fix the errors found. Answer `y` to proceed with the fixes or `n` to finish.
- After the fixes, you will be given the option to reboot the system. Required to apply the fixes.

 ## Error Reporting

If the script finds errors that it cannot automatically correct, a file called `report.md` will be generated detailing the errors found and recommended actions.

>[!warning]
>The script itself is safe and designed for ethical purposes, it is necessary to request superuser permissions, since without them the script cannot correct errors, however, you can check the code yourself and verify that it does not contain potentially destructive behaviors, and on the contrary, it uses controlled and clear actions with user interaction.
>**Risk potential:** 3/10 (Low)
>- Use of elevated permissions (necessary)
>- Possible indirect damage (unlikely)
>- Errors by the user

>[!note]
>Common problems
>**If you cannot access HTTPS websites**, it may be because the TLS certificate is expired or not recognized.  To fix this, follow these steps:
>1. **Check the certificate authority**:
>- Check if the problem is that the untrusted certificate authority (CA) is **Let's Encrypt**.
>2. **Download the latest certificate**:
>- Go to [this link](https://letsencrypt.org/certs/isrgrootx1.txt) and copy the entire contents of the certificate.
>3. **Create a file with the certificate**:
>- Open **Terminal** and navigate to your preferred directory.
>- Run the command `nano cert.pem` to create a text file called `cert.pem`.
>- Paste the copied contents of the certificate and save the file by pressing `Ctrl + X`, then `Y` to confirm and `Enter`.
>4. **Install the certificate in Keychain Access**:
>- Open **Finder** and locate the `cert.pem` file.
>- Double-click the file to open it in **Keychain Access**.
>- Enter your password to authorize the installation.
>- Make sure you select the **"System"** keychain and check the **"Trust"** option to allow the system to trust this certificate.
>5. **Verify the installation**:
>- Check that the certificate has been installed correctly and that the browser or system recognizes the certificate as valid.
>6. **(Optional) Delete expired certificates**:
>- If you prefer, you can remove expired certificates from **Keychain Access** to keep the system clean.

## Contributions

If you would like to contribute to this project, please create a fork of the repository and submit a pull request with your improvements or fixes.

 ## Links
- [Darwin Repository, MacOS Kernel](https://github.com/apple/darwin-xnu)
- [Apple Support for Kernel Panic Bugs](https://support.apple.com/en-lamr/guide/mac-help/mchlp2890/mac)
- [Apple Support for Mac](https://support.apple.com/en-us/mac)
- [Using Apple Diagnostics](https://support.apple.com/en-us/102550)

## License

This project is licensed under the MIT License. For more details, see the `LICENSE` file.
