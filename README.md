<strong><p align="center">🚀 ASRRules</p></strong>
=======

## About

The ASRRules module is designed to help handle the Windows Defender Attack Surface Reduction (ASR) Rules

## Usage

### Install the module

```powershell
# Check the mmodule on powershellgallery.com
Find-Module -Name ASRRules -Repository PSGallery

# Save the module locally in Downloads folder
Save-Module -Name ASRRules -Repository PSGallery -Path ~/Downloads

# Import the module
Import-Module ~/Downloads/ASRRules/2.0.0/ASRRules.psd1 -Force -Verbose
```

### Functions

#### Check the commands available

```powershell
Get-Command -Module ASRRules

CommandType     Name                                               ModuleName
-----------     ----                                               ----------
Function        Get-ASRRuleConfig                                  ASRRules
Function        Get-ASRRuleData                                    ASRRules
Function        Set-ASRRuleConfig                                  ASRRules
```

### Help

#### Syntax of Get-ASRRuleData

```powershell
# View the syntax of Get-ASRRuleData

Get-Command Get-ASRRuleData -Syntax

Get-ASRRuleData [<CommonParameters>]

Get-ASRRuleData -Name <string[]> [<CommonParameters>]

Get-ASRRuleData -Id <string[]> [<CommonParameters>]

Get-ASRRuleData -Category <string[]> [<CommonParameters>]
```

#### Syntax of Get-ASRRuleConfig

```powershell
# View the syntax of Get-ASRRuleConfig

Get-Command Get-ASRRuleConfig -Syntax

Get-ASRRuleConfig [<CommonParameters>]

Get-ASRRuleConfig [-InputObject <Object>] [<CommonParameters>]
```

#### Syntax of Set-ASRRuleConfig

```powershell
# View the syntax of Set-ASRRuleConfig

Get-Command Set-ASRRuleConfig -Syntax

Set-ASRRuleConfig [[-InputObject] <Object>] [-Mode] <string> [-WhatIf] [-Confirm] [<CommonParameters>]
```

### Examples

#### Examples of Get-ASRRuleData

```powershell
# View examples provided in the help of Get-ASRRuleData

Get-Help Get-ASRRuleData  -Examples

NAME
    Get-ASRRuleData

SYNOPSIS
    Get information about ASR Rules

    -------------------------- EXAMPLE 1 --------------------------

    C:\PS>Get-ASRRuleData


    Get info about all ASR rules




    -------------------------- EXAMPLE 2 --------------------------

    C:\PS>Get-ASRRuleData -Category 'Executables and Scripts'


    Get info about rules from the 'Executables and Scripts' category




    -------------------------- EXAMPLE 3 --------------------------

    C:\PS>Get-ASRRuleData -Name 'Block Win32 API calls from Office macros' | Format-List *


    Get info about this specific rule and lists all the info




    -------------------------- EXAMPLE 4 --------------------------

    C:\PS>Get-ASRRuleData -Id 92e97fa1-2edf-4476-bdd6-9dd0b4dddc7b | Format-List *


    Get info about this specific rule and lists all the info
```

##### Example 1

<img src=media/Get-ASRRuleData.PNG >

##### Example 3

<img src=media/Get-ASRRuleData-2.PNG >


#### Examples of Get-ASRRuleConfig

```powershell
# View examples provided in the help for Get-ASRRuleConfig

Get-Help Get-ASRRuleConfig  -Examples

NAME
    Get-ASRRuleConfig

SYNOPSIS
    Get the local configuration of ASR Rules

    -------------------------- EXAMPLE 1 --------------------------

    C:\PS>Get-ASRRuleConfig


    Get the effective configuration of all ASR rules (includes local, GPO based,...)




    -------------------------- EXAMPLE 2 --------------------------

    C:\PS>Get-ASRRuleData -Category 'Executables and Scripts' | Get-ASRRuleConfig


    Get the effective configuration of ASR Rules from the Executables and Scripts category
```

##### Example 2

<img src=media/Get-ASRConfig-2.PNG >

#### Examples of Set-ASRRuleConfig

```powershell
# View examples provided in the help for Set-ASRRuleConfig

Get-Help Set-ASRRuleConfig  -Examples

NAME
    Set-ASRRuleConfig

SYNOPSIS
    Change the local configuration of ASR Rules

    -------------------------- EXAMPLE 1 --------------------------

    C:\PS>Get-ASRRuleConfig | Where-Object { $_.Action -eq 'NotConfigured' } |


    Get-ASRRuleData | Set-ASRRuleConfig -WhatIf -Mode AuditMode

    Simulate what rules that are currenly not configured would be set to Audit.




    -------------------------- EXAMPLE 2 --------------------------

    C:\PS>Get-ASRRuleData | Set-ASRRuleConfig -Mode AuditMode -Verbose


    Change all local rules and set their config to AuditMode
```

##### Example 1

<img src=media/Set-ASRConfig.PNG >

## Issues

None yet, but if you find one please let me know by opening an issue in this repository

## Blog posts about this module

https://p0w3rsh3ll.wordpress.com/2021/03/25/windows-defender-attack-surface-reduction-asr-rules-module/

https://p0w3rsh3ll.wordpress.com/2021/12/11/update-of-windows-defender-attack-surface-reduction-asr-rules-module/

## Useful links

https://docs.microsoft.com/en-us/windows/security/threat-protection/microsoft-defender-atp/attack-surface-reduction

https://medium.com/palantir/microsoft-defender-attack-surface-reduction-recommendations-a5c7d41c3cf8

https://techcommunity.microsoft.com/t5/microsoft-defender-for-endpoint/demystifying-attack-surface-reduction-rules-part-1/ba-p/1306420

https://techcommunity.microsoft.com/t5/microsoft-defender-for-endpoint/demystifying-attack-surface-reduction-rules-part-2/ba-p/1326565

https://techcommunity.microsoft.com/t5/microsoft-defender-for-endpoint/demystifying-attack-surface-reduction-rules-part-3/ba-p/1360968

https://techcommunity.microsoft.com/t5/microsoft-defender-for-endpoint/demystifying-attack-surface-reduction-rules-part-4/ba-p/1384425
