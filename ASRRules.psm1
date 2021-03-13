
Function Set-ASRRuleConfig {
<#
.SYNOPSIS
    Change the local configuration of ASR Rules

.DESCRIPTION
    Change the local configuration of the Windows Defender Attack Surface Reduction (ASR) Rules

.PARAMETER Mode
    Indicate what action should be performed. Warn, Block (Enabled), Audit, Disable or NotConfigured

.PARAMETER InputObject
    Represents the rule(s) generated by Get-ASRRuleData to be modified

.EXAMPLE
    Get-ASRRuleConfig | Where-Object { $_.Action -eq 'NotConfigured' } |
    Get-ASRRuleData | Set-ASRRuleConfig -WhatIf -Mode AuditMode

    Simulate what rules that are currenly not configured would be set to Audit.

.EXAMPLE
    Get-ASRRuleData | Set-ASRRuleConfig -WhatIf -Mode AuditMode

    Change all local rules and set their config to AuditMode

#>

[CmdletBinding(SupportsShouldProcess)]
Param(
    [Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName)]
    $InputObject,

    [Parameter(Mandatory)]
    [ValidateSet('Disabled','Enabled','AuditMode','NotConfigured','Warn')]
    [string]$Mode
)
Begin {}
Process {
    $InputObject |
    ForEach-Object {
        $i = $_

        if (($i.psobject.TypeNames| Select-Object -First 1) -eq 'Windows.DefenderConfig.ASR.Rule.Information') {

            if (Get-ASRRuleData -Id $i.Guid) {
                $HT = @{
                    AttackSurfaceReductionRules_Ids = $i.Guid
                    AttackSurfaceReductionRules_Actions = $Mode
                }
                if ($pscmdlet.ShouldProcess("$($Mode)","Change rule: $($i.RuleName) to: ")) {
                    try {
                        ConfigDefender\Add-MpPreference @HT -ErrorAction Stop
                        Write-Verbose -Message "Successfully to set rule $($i.RuleName) to $($Mode)"
                    } catch {
                        Write-Warning -Message "Failed to set rule $($i.RuleName) to $($Mode) because $($_.Exception.Message)"
                    }
                }
            }

        } else {
            Write-Warning -Message 'Input is not a Windows.DefenderConfig.ASR.Rule.Information'
        }
    }
}
End {}
}

Function Get-ASRRuleConfig {
<#
.SYNOPSIS
    Get the local configuration of ASR Rules

.DESCRIPTION
    Get the local configuration of the Windows Defender Attack Surface Reduction (ASR) Rules

.PARAMETER InputObject
    Represents the rule(s) generated by Get-ASRRuleData to be modified

.EXAMPLE
    Get-ASRRuleConfig

    Get the effective configuration of all ASR rules (includes local, GPO based,...)

.EXAMPLE
    Get-ASRRuleData -Category 'Executables and Scripts' | Get-ASRRuleConfig

    Get the effective configuration of ASR Rules from the Executables and Scripts category
#>

[CmdletBinding(DefaultParameterSetName='All')]
Param(
    [Parameter(ParameterSetName = 'ByRuleId',ValueFromPipeline,ValueFromPipelineByPropertyName)]
    $InputObject
)
Begin {
    $RawConfig = ConfigDefender\Get-MpPreference

    Enum ASRAction {
        Warn =  [Byte]6
        Audit = [Byte]2
        Block = [Byte]1 # Enabled
        Disabled = [Byte]0
        NotConfigured = [Byte]5

    }
    $Rules  = $RawConfig.AttackSurfaceReductionRules_Ids
    $Actions = $RawConfig.AttackSurfaceReductionRules_Actions

    $i=0
    $RawData = $Rules |
    ForEach-Object {
        [PSCustomObject]@{
            Guid = $_
            Name = "$((Get-ASRRuleData -Id $_).RuleName)"
            Action = [ASRAction]$Actions[$i]
        }
        $i++
    }
    $RawData += Get-ASRRuleData | Where-Object { $_.Guid -notin $Rules } |
    ForEach-Object {
        [PSCustomObject]@{
            Guid = $_.Guid
            Name = $_.RuleName
            Action = [ASRAction]5
        }
    }
}
Process {
    Switch ($PSCmdlet.ParameterSetName) {
        'ByRuleId' {
            $PSBoundParameters['InputObject'] |
            ForEach-Object {
                $i = $_.Guid
                Write-Verbose "Dealing with Rule Id $($i)"
                $RawData | Where-Object { $_.Guid -eq $i }
            }
            break
        }
        'All' {
            $RawData
            break
        }
        default {}
    }
}
End{}
}


Function Get-ASRRuleData {
<#
.SYNOPSIS
    Get information about ASR Rules

.DESCRIPTION
    Get information about Windows Defender Attack Surface Reduction (ASR) Rules

.PARAMETER Name
    Represents the rule name(s) to be used to retrieve data

.PARAMETER Id
    Represents the rule id(s) or Guid(s) to be used to retrieve data

.PARAMETER Category
    Represents the rule category(ies) to be used to retrieve data

.EXAMPLE
    Get-ASRRuleData

    Get info about all ASR rules

.EXAMPLE
    Get-ASRRuleData -Category 'Executables and Scripts'

    Get info about rules from the 'Executables and Scripts' category

.EXAMPLE
    Get-ASRRuleData -Name 'Block  Win32 API calls from Office macros' | Format-List *

    Get info about this specific rule and lists all the info

.EXAMPLE
    Get-ASRRuleData -Id 92E97FA1-2EDF-4476-BDD6-9DD0B4DDDC7B | Format-List *

    Get info about this specific rule and lists all the info

#>

[CmdletBinding(DefaultParameterSetName='All')]
Param()
DynamicParam {

    $Dictionary = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameterDictionary

    #region helper function
    Function New-ParameterAttributCollection {
    [CmdletBinding()]
    Param(
        [Switch]$Mandatory,
        [Switch]$ValueFromPipeline,
        [Switch]$ValueFromPipelineByPropertyName,
        [String]$ParameterSetName,

        [Parameter()]
        [ValidateSet(
        'Arguments','Count','Drive','EnumeratedArguments','Length','NotNull',
        'NotNullOrEmpty','Pattern','Range','Script','Set','UserDrive'
        )][string]$ValidateType,

        [Parameter()]
        $ValidationContent

    )
    Begin {}
    Process {
        $c = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $a = New-Object System.Management.Automation.ParameterAttribute
        if ($Mandatory) {
            $a.Mandatory = $true
        }
        if ($ValueFromPipeline) {
            $a.ValueFromPipeline = $true
        }
        if ($ValueFromPipelineByPropertyName) {
            $a.ValueFromPipelineByPropertyName=$true
        }
        if ($ParameterSetName) {
            $a.ParameterSetName = $ParameterSetName
        }
        $c.Add($a)

        if ($ValidateType -and $ValidationContent) {
            try {
                $c.Add((New-Object "System.Management.Automation.Validate$($ValidateType)Attribute"(
                    $ValidationContent
                )))
            } catch {
                Throw $_
            }
        }
        $c
    }
    End {}
    }
    #endregion

    #region DATA
    $All = @(
        @{
            Category = '3rd Party Apps'
            RuleName = 'Block Adobe Reader from creating child processes'
            GUID = '7674ba52-37eb-4a4f-a9a1-f0f9a1619a2c'
            'File & folder exclusions Supported' =	$true
            MinOSVersion = [version]'10.0.16299.0'
            'Minimum OS supported' = 'Windows 10, version 1709 (RS3, build 16299) or greater'
        },
        @{
            Category = 'Microsoft Office'
            RuleName = 'Block all Office applications from creating child processes'
	        GUID = 'D4F940AB-401B-4EFC-AADC-AD5F3C50688A'
            'File & folder exclusions Supported' =	$true
            MinOSVersion = [version]'10.0.16299.0'
            'Minimum OS supported' = 'Windows 10, version 1709 (RS3, build 16299) or greater'
        },
        @{
            Category = 'Windows Credential'
            RuleName = 'Block credential stealing from the Windows local security authority subsystem (lsass.exe)'
	        GUID = '9e6c4e1f-7d60-472f-ba1a-a39ef669e4b2'
            'File & folder exclusions Supported' =	$true
            MinOSVersion = [version]'10.0.16299.0'
            'Minimum OS supported' = 'Windows 10, version 1709 (RS3, build 16299) or greater'
        },
        @{
            Category = 'E-mail and Webmail'
            RuleName = 'Block executable content from email client and webmail'
	        GUID = 'BE9BA2D9-53EA-4CDC-84E5-9B1EEEE46550'
            'File & folder exclusions Supported' =	$true
            MinOSVersion = [version]'10.0.16299.0'
            'Minimum OS supported' = 'Windows 10, version 1709 (RS3, build 16299) or greater'
        },
        @{
            Category = 'Executables and Scripts'
            RuleName = 'Block executable files from running unless they meet a prevalence, age, or trusted list criterion'
	        GUID = '01443614-cd74-433a-b99e-2ecdc07bfc25'
            'File & folder exclusions Supported' =	$true
            MinOSVersion = [version]'10.0.16299.0'
            'Minimum OS supported' = 'Windows 10, version 1709 (RS3, build 16299) or greater'
        },
        @{
            Category = 'Executables and Scripts'
            RuleName = 'Block execution of potentially obfuscated scripts'
	        GUID = '5BEB7EFE-FD9A-4556-801D-275E5FFC04CC'
            'File & folder exclusions Supported' =	$true
            MinOSVersion = [version]'10.0.16299.0'
            'Minimum OS supported' = 'Windows 10, version 1709 (RS3, build 16299) or greater'
        },
        @{
            Category = 'Executables and Scripts'
            RuleName = 'Block JavaScript or VBScript from launching downloaded executable content'
	        GUID = 'D3E037E1-3EB8-44C8-A917-57927947596D'
            'File & folder exclusions Supported' =	$true
            MinOSVersion = [version]'10.0.16299.0'
            'Minimum OS supported' = 'Windows 10, version 1709 (RS3, build 16299) or greater'
        },
        @{
            Category = 'Microsoft Office'
            RuleName = 'Block Office applications from creating executable content'
	        GUID = '3B576869-A4EC-4529-8536-B80A7769E899'
            'File & folder exclusions Supported' =	$true
            MinOSVersion = [version]'10.0.16299.0'
            'Minimum OS supported' = 'Windows 10, version 1709 (RS3, build 16299) or greater'
        },
        @{
            Category = 'Microsoft Office'
            RuleName = 'Block Office applications from injecting code into other processes'
	        GUID = '75668C1F-73B5-4CF0-BB93-3ECF5CB7CC84'
            'File & folder exclusions Supported' =	$true
            MinOSVersion = [version]'10.0.16299.0'
            'Minimum OS supported' = 'Windows 10, version 1709 (RS3, build 16299) or greater'
        },
        @{
            Category = 'Microsoft Office'
            RuleName = 'Block Office communication application from creating child processes'
	        GUID = '26190899-1602-49e8-8b27-eb1d0a1ce869'
            'File & folder exclusions Supported' =	$true
            MinOSVersion = [version]'10.0.16299.0'
            'Minimum OS supported' = 'Windows 10, version 1709 (RS3, build 16299) or greater'
        },
        @{
            Category = 'Windows Management Interface (WMI)'
            RuleName = 'Block persistence through WMI event subscription'
	        GUID = 'e6db77e5-3df2-4cf1-b95a-636979351e5b'
            'File & folder exclusions Supported' = $false
            MinOSVersion = [version]'10.0.18362.0'
            'Minimum OS supported' = 'Windows 10, version 1903 (build 18362) or greater'
        }
        @{
            Category = 'Windows Management Interface (WMI)'
            RuleName = 'Block process creations originating from PSExec and WMI commands'
	        GUID = 'd1e49aac-8f56-4280-b9ba-993a6d77406c'
            'File & folder exclusions Supported' =	$true
            MinOSVersion = [version]'10.0.16299.0'
            'Minimum OS supported' = 'Windows 10, version 1709 (RS3, build 16299) or greater'
        },
        @{
            Category = 'Device Control'
            RuleName = 'Block untrusted and unsigned processes that run from USB'
	        GUID = 'b2b3f03d-6a65-4f7b-a9c7-1c7ef74a9ba4'
            'File & folder exclusions Supported' =	$true
            MinOSVersion = [version]'10.0.16299.0'
            'Minimum OS supported' = 'Windows 10, version 1709 (RS3, build 16299) or greater'
        },
        @{
            Category = 'Microsoft Office'
            RuleName = 'Block  Win32 API calls from Office macros'
	        GUID = '92E97FA1-2EDF-4476-BDD6-9DD0B4DDDC7B'
            'File & folder exclusions Supported' =	$true
            MinOSVersion = [version]'10.0.16299.0'
            'Minimum OS supported' = 'Windows 10, version 1709 (RS3, build 16299) or greater'
        },
        @{
            Category = 'Executables and Scripts'
            RuleName = 'Use advanced protection against ransomware'
	        GUID = 'c1db55ab-c21a-4637-bb3f-a12568109d35'
            'File & folder exclusions Supported' =	$true
            MinOSVersion = [version]'10.0.16299.0'
            'Minimum OS supported' = 'Windows 10, version 1709 (RS3, build 16299) or greater'
        }
    )
    #endregion

    #region param RuleName
    $Dictionary.Add(
        'Name',
        (New-Object System.Management.Automation.RuntimeDefinedParameter(
            'Name',
            [string[]],
            (New-ParameterAttributCollection -Mandatory -ValidateType Set -ValidationContent (
               $All | ForEach-Object { $_.RuleName }
            ) -ValueFromPipeline -ValueFromPipelineByPropertyName -ParameterSetName 'ByRuleName')
        ))
    )
    #endregion

    #region param RuleId
    $Dictionary.Add(
        'Id',
        (New-Object System.Management.Automation.RuntimeDefinedParameter(
            'Id',
            [string[]],
            (New-ParameterAttributCollection -Mandatory -ValidateType Set -ValidationContent (
               $All | ForEach-Object { $_.GUID }
            ) -ValueFromPipeline -ValueFromPipelineByPropertyName -ParameterSetName 'ByRuleId')
        ))
    )
    #endregion

    #region param RuleCategory
    $Dictionary.Add(
        'Category',
        (New-Object System.Management.Automation.RuntimeDefinedParameter(
            'Category',
            [string[]],
            (New-ParameterAttributCollection -Mandatory -ValidateType Set -ValidationContent (
               $All | ForEach-Object { $_.Category } | Sort-Object -Unique
            ) -ValueFromPipeline -ValueFromPipelineByPropertyName -ParameterSetName 'ByRuleCategory')
        ))
    )
    #endregion
    $Dictionary

}
Begin {}
Process {

    $(Switch ($PSCmdlet.ParameterSetName) {
        'ByRuleName' {
            $PSBoundParameters['Name'] | ForEach-Object {
                $n = $_
                [PSCustomObject]($All | Where-Object { $_.RuleName -eq $n })
            }
            break
        }
        'ByRuleId' {
            $PSBoundParameters['Id']| ForEach-Object {
                $i = $_
                [PSCustomObject]($All | Where-Object { $_.GUID -eq $i })
            }
            break
        }
        'ByRuleCategory' {
            $PSBoundParameters['Category'] | ForEach-Object {
                $c = $_
                [PSCustomObject]($All | Where-Object { $_.Category -eq $c })
            }
            break
        }
        'All' {
            $All | ForEach-Object {[PSCustomObject]$_}
            break
        }
        default {}
    }) | ForEach-Object {
        $null = $_.PSTypeNames.Insert(0,'Windows.DefenderConfig.ASR.Rule.Information')
        try {
            Update-TypeData -TypeName 'Windows.DefenderConfig.ASR.Rule.Information' -Force -DefaultDisplayPropertySet GUID,RuleName,MinOSVersion -ErrorAction Stop -WhatIf:$false
        } catch {
            Write-Warning -Message "Failed to update type data class because $($_.Exception.Message)"
        }
        $_
    }
}
End {}
}

Export-ModuleMember -Function 'Get-ASRRuleData','Set-ASRRuleConfig','Get-ASRRuleConfig'
