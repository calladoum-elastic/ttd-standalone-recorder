#Requires -RunAsAdministrator

Set-ExecutionPolicy -Scope LocalMachine Bypass
Import-Module ($PSScriptRoot + "\TTD.psm1")


if( Initialize-TTD )
{
    #
    # Customize here to what you want to do.
    #

    # - You can `Invoke-TTD` to launch a process directly:
    # $p = Invoke-TTD -Mode launch -OutputFolder c:\temp\output -Target "c:\windows\system32\notepad.exe"

    # - Or attach an existing process
    # Invoke-WebRequest -UseBasicParsing "http://mydomain.com/Payroll.exe"
    # $x = Start-Process .\Payroll.exe
    # Sleep 3
    # $p = Invoke-TTD -Mode attach -Target $x.Id -OutputFolder c:\temp\output

    # - Or do both
    # $p = Invoke-TTD -Mode spawn-attach -Delay Delay -Target c:\windows\system32\winver.exe -OutputFolder c:\temp\output

}
