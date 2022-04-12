#Requires -RunAsAdministrator

<#
 .Synopsis
  Initialize TTD PowerShell module

 .Description
  Download and install TTD
#>
function Initialize-TTD
{
    $TtdTempDir = $env:TEMP + "\TTD"

    if( !(Test-Path ($env:LocalAppData + "\Microsoft\WindowsApps\WinDbgX.exe") ) )
    {
        #
        # Find and install the latest WindbgX using https://store.rg-adguard.net/ (ProdId=9pgjgd53tn86)
        #
        $request = Invoke-WebRequest -UseBasicParsing -Method Post -Body "type=ProductId&url=9pgjgd53tn86&ring=RP&lang=en-US" https://store.rg-adguard.net/api/GetFiles
        if ($request.StatusCode -ne 200)
        {
            Write-Error "HTTP request failed"
            return $false
        }

        $links = @()
        $request.Links | Sort-Object -Descending -Property OuterHTML | ForEach-Object {
            if ( $_.OuterHTML.Contains(".appx") )
            {
                $links += $_.href
            }
        }

        if ( $links.Count -eq 0 )
        {
            Write-Error "No valid links found"
            return $false
        }

        $outfile = $env:TEMP+"\windbgx.appx"
        Invoke-WebRequest -UseBasicParsing -OutFile $outfile $links[0]
        Add-AppxPackage $outfile
    }

    if( !(Test-Path($TtdTempDir)) )
    {
        #
        # Copy only TTD folder
        #
        Set-Location 'C:\Program Files\WindowsApps\Microsoft.WinDbg_*\amd64\'
        Copy-Item -Recurse .\ttd\ $TtdTempDir\..\
    }

    $true
}
Export-ModuleMember -Function Initialize-TTD


<#
 .Synopsis
  Invoke TTD

 .Description
  Invoke TTD

 .Parameter Target
  The target to run

 .Parameter TargetArgs
  The parameters to run the target with (only for mode `launch` and `spawn-attach`)

 .Parameter Mode
  Indicates how to use TTD against the target: 3 modes are available, `launch`, `attach`, and `spawn-attach`.
  If the mode is set to `attach`, the `Target` parameter is expected to be the PID of the process to attach.

 .Example
   # Spawn and trace notepad
   Invoke-TTD -Target notepad.exe

 .Example
   # Spawn, wait 30 seconds and trace msword.exe with a specific document
   Invoke-TTD -Mode spawn-attach -Target msword.exe -TargetArgs @("\path\to\myfile.docx") -Delay 30
#>
function Invoke-TTD
{
    Param (
        [string] $Target,
        [int] $Delay = 30,
        [string] $OutputFolder = $env:TEMP,
        [string[]] $TargetArgs = @(),
        [string] [ValidateSet("Attach", "Launch", "Spawn-Attach")] $Mode = "launch"
    )

    $TtdPidFile = $env:TEMP + "\TTD-Run.pid"
    $TtdTempDir = $env:TEMP + "\TTD"

    $Args = @("-children", "-out", $OutputFolder)

    if ($Mode -eq "spawn-attach")
    {
        $Proc = Start-Process -PassThru -ArgumentList $TargetArgs $Target
        Start-Sleep $Delay
        $Args += @("-attach", $Proc.Id)
    }
    elseif ($Mode -eq "attach")
    {
        $Args += @("-attach", $Target)
    }
    else
    {
        $Args += @("-launch", $Target)
    }

    $TtdProc = Start-Process -PassThru -WorkingDirectory $TtdTempDir -ArgumentList $Args .\TTD.exe
    if($Mode -eq "launch")
    {
        $ProcPid = (Get-WmiObject Win32_Process | Where-Object {$_.ParentProcessId -eq $TtdProc.Id -and $_.ProcessName -ne "conhost.exe"}).ProcessId
        Set-Content -Path $TtdPidFile -Value "${ProcPid}"
    }
    elseif($Mode -eq "attach")
    {
        $ProcPid = $Target
    }
    else
    {
        $ProcPid = $Proc.Id
    }

    $ProcPid
}
Export-ModuleMember -Function Invoke-TTD


function Stop-TTD
{
    $TtdPidFile = $env:TEMP + "\TTD-Run.pid"

    if( Test-Path($TtdPidFile) )
    {
        $TtdPid = Get-Content $TtdPidFile
        $Args = @("-stop", $TtdPid)
        Start-Process -WorkingDirectory $TtdTempDir -Wait  -ArgumentList $Args .\TTD.exe
        Remove-Item $TtdPidFile
    }
}
Export-ModuleMember -Function Stop-TTD