# IPQualityLookup.ps1
##Powershell script used for IP reputation and Geo location lookups

This script leverages IPQualityScore.com's (FREE) API.  It is limited to 5000 lookups per month.  You can also use a paid version for different limitations (if any).

Shout out to Norbet P since I cannibalized a script he shared with me to build this.

INFO:
Setup an account here to get your API key. 
https://www.ipqualityscore.com/user/plans

Usage
*.\IpQualityLookup.ps1 -APIKey "{APIPKEY}" -InputFile {Path to Input File} -OutFile {Path to Output File}*

Example (source/destination files within same folder as script)
*.\IpQualityLookup.ps1 -APIKey "AVXXXXXXXXXXXXXXXXXXXXgc" -InputFile .\iplist.txt -OutFile ipResults.csv*

**DISCLAIMER** - I have no financial interest in IPqualityscore.com nor do I receive any compensation from them monetary or other.
