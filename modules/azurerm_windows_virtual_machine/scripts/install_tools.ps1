# 1. Install kubectl on Windows Virtual Machine
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri 'https://dl.k8s.io/release/v1.30.0/bin/windows/amd64/kubectl.exe' -OutFile 'C:\Windows\System32\kubectl.exe'

# 2. Install Azure CLI on Windows Virtual Machine
$azCliMsi = "$env:TEMP\azure-cli.msi"
Invoke-WebRequest -Uri 'https://aka.ms/installazurecliwindows' -OutFile $azCliMsi
Start-Process msiexec.exe -ArgumentList "/i `"$azCliMsi`" /quiet /qn /norestart" -Wait
Remove-Item $azCliMsi -Force
