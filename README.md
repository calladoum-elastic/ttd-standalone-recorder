# TTD Standalone Recorder

Execute safely anything in seconds and collect the execution trace(s).


## Pre-requisite

Just Hyper-V

```powershell
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
```

And Windows Sandbox enabled

```powershell
Enable-WindowsOptionalFeature -FeatureName "Containers-DisposableClientVM" -All -Online
```


(Opt.) If you want to use Windows Sandbox from a guest Hyper-V VM, enabling nested virtualization is also required

```powershell
Set-VMProcessor -VMName MyVmName -ExposeVirtualizationExtensions $true
```


## Get

```
git clone https://github.com/calladoum-elastic/ttd-standalone-recorder
cd ttd-standalone-recorder
```

You may want to edit it `ttd.wsb` XML file to replace the path of the repository

```xml
        <MappedFolder>
            <HostFolder>C:\git\ttd-standalone-recorder\Scripts</HostFolder>  <!-- HERE -->
        [...]
```


## Prepare

Edit `Scripts/Run.ps1` (inside the `If ( Initialize-TTD )` statement) to add the actions you want monitored.
Once the environment is ready, you can use `Invoke-TTD` on the process to execute, and specify the output folder.


## Run

Double click on `ttd.wsb`, collect the result in the output folder.


