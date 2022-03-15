<#
.SYNOPSIS
IP Reputation Lookup Script
written by @DFinDFIR

This script leverages IPQualityScore.com's (FREE) API.  It is limited to 5000 lookups per month.  You can also use a paid version for different limitations (if any).

Shout out to Norbet P since I cannibalized a script he shared with me to build this.

INFO:
Setup an account here to get your API key. 
https://www.ipqualityscore.com/user/plans

Usage:
.\IpQualityLookup.ps1 -APIKey "{APIPKEY}" -InputFile {Path to Input File} -OutFile {Path to Output File}

Example (source/destination files within same folder as script):
.\IpQualityLookup.ps1 -APIKey "AVXXXXXXXXXXXXXXXXXXXXgc" -InputFile .\iplist.txt -OutFile ipResults.csv

DISCLAIMER - I have no financial interest in IPqualityscore.com nor do I receive any compensation from them monetary or other.

.PARAMETER APIKey
API Key obtained by setting up a (Free) account at https://www.ipqualityscore.com/user/plans

.PARAMETER InputFile
Plain text file with list of IP addresses to look up (one IP address per line)

.PARAMETER OutFile
Name (or path) of output file.  Current directory will be used for output if not specified

#>

Param
(
  [Parameter(Mandatory=$true)]
  [string]$APIKey,
  
  [Parameter(Mandatory=$true)]
  [string]$InputFile,

  [Parameter(Mandatory=$true)]
  [string]$OutFile
)

# $apiKey=$args[0]
# $inputFile=$args[1]
# $csvPath=$args[2]

$apiKey=$APIKey
$inputFile=$InputFile
$csvPath=$OutFile

function Get-IPInfo {
  Param
  (
    [string]$uri,
	  [string]$IP
  ) 
  $request = Invoke-RestMethod -Method Get -Uri $uri
  [PSCustomObject]@{
    IP      = $IP     
	fraud_score = $request.fraud_score    
	country_code = $request.country_code   
	region = $request.region         
	city = $request.city           
	ISP = $request.ISP            
	ASN = $request.ASN            
	organization = $request.organization   
	is_crawler = $request.is_crawler     
	timezone = $request.timezone       
	mobile = $request.mobile         
	host = $request.host           
	proxy = $request.proxy          
	vpn = $request.vpn            
	tor = $request.tor            
	active_vpn = $request.active_vpn     
	active_tor = $request.active_tor     
	recent_abuse = $request.recent_abuse   
	bot_status = $request.bot_status       
	latitude = $request.latitude       
	longitude = $request.longitude
	message = $request.message    	
  }
}

$IPs = Get-Content $inputFile
$lines=$IPs.count
Write-Host "$lines IPs to process..." -ForegroundColor Green

"Output file set to $csvPath"|Write-Host -ForegroundColor Green
$i = 0
$prog = 0

$stringUri="https://ipqualityscore.com/api/json/ip/"
$stringUriEnd="?strictness=2&fast=1"

ForEach ($IP In $IPs) {
  $i++   
  $prog++  
  Write-Progress -Activity "Looking up IP Reputation info" -Status "Current IP : $IP ($prog of $lines)" -percentComplete ($prog / $lines*100)
    $errorcount=0
  Do{
    #do lookup 
    $geo = $null
    $error.Clear()
	$uri=$stringUri+$apiKey+"/"+$IP+$stringUriEnd
    $geo =Get-IPInfo $uri $IP -ErrorAction SilentlyContinue
   
    #check for errors and wait 70 secs to continue
    if ($error[0] -ne $null){
      Write-Host "Error occured! Waiting a min to try again" -ForegroundColor Red
      $errorcount++
      Start-Sleep 70
    }
  }while (($error -ne $null) -or ($errorcount -eq 3) ) #while there are errors or it has tried 3 times and  failed
  
  if ($errorcount -eq 3 ){"Tooo many errors... Aborting!"|Write-Host -ForegroundColor Yellow -BackgroundColor Red; Exit} #too many errors and quit
  $geo| Export-Csv $csvPath -NoTypeInformation -Append
  #$prog
  If ($prog -eq 1){$geo|ft -AutoSize}else {$geo|ft -AutoSize -HideTableHeaders}
  $geo = $null
}

#Done message
"DONE!`nCheck $csvPath for results"|Write-Host -ForegroundColor Green
