
@(
 @{ Id = '56a863a9-875e-4185-98a7-b882c64b5ce5' ; Name = 'Block abuse of exploited vulnerable signed drivers' },
 @{ Id = '7674ba52-37eb-4a4f-a9a1-f0f9a1619a2c' ; Name = 'Block Adobe Reader from creating child processes' },
 @{ Id = 'd4f940ab-401b-4efc-aadc-ad5f3c50688a' ; Name = 'Block all Office applications from creating child processes' },
 @{ Id = '9e6c4e1f-7d60-472f-ba1a-a39ef669e4b2' ; Name = 'Block credential stealing from the Windows local security authority subsystem (lsass.exe)' },
 @{ Id = 'be9ba2d9-53ea-4cdc-84e5-9b1eeee46550' ; Name = 'Block executable content from email client and webmail' },
 @{ Id = '01443614-cd74-433a-b99e-2ecdc07bfc25' ; Name = 'Block executable files from running unless they meet a prevalence, age, or trusted list criterion' },
 @{ Id = '5beb7efe-fd9a-4556-801d-275e5ffc04cc' ; Name = 'Block execution of potentially obfuscated scripts' },
 @{ Id = 'd3e037e1-3eb8-44c8-a917-57927947596d' ; Name = 'Block JavaScript or VBScript from launching downloaded executable content' },
 @{ Id = '3b576869-a4ec-4529-8536-b80a7769e899' ; Name = 'Block Office applications from creating executable content' },
 @{ Id = '75668c1f-73b5-4cf0-bb93-3ecf5cb7cc84' ; Name = 'Block Office applications from injecting code into other processes' },
 @{ Id = '26190899-1602-49e8-8b27-eb1d0a1ce869' ; Name = 'Block Office communication application from creating child processes' },
 @{ Id = 'e6db77e5-3df2-4cf1-b95a-636979351e5b' ; Name = 'Block persistence through WMI event subscription' },
 @{ Id = 'd1e49aac-8f56-4280-b9ba-993a6d77406c' ; Name = 'Block process creations originating from PSExec and WMI commands' },
 @{ Id = '33ddedf1-c6e0-47cb-833e-de6133960387' ; Name = 'Block rebooting machine in Safe Mode' },
 @{ Id = 'b2b3f03d-6a65-4f7b-a9c7-1c7ef74a9ba4' ; Name = 'Block untrusted and unsigned processes that run from USB' },
 @{ Id = 'c0033c00-d16d-4114-a5a0-dc9b3a7d2ceb' ; Name = 'Block use of copied or impersonated system tools' },
 @{ Id = 'a8f5898e-1dc8-49a9-9878-85004b8a61e6' ; Name = 'Block Webshell creation for Servers' },
 @{ Id = '92e97fa1-2edf-4476-bdd6-9dd0b4dddc7b' ; Name = 'Block Win32 API calls from Office macros' },
 @{ Id = 'c1db55ab-c21a-4637-bb3f-a12568109d35' ; Name = 'Use advanced protection against ransomware' }
) |
Foreach-Object {
 $n = $_['Name']
 $i = $_['Id']
 Describe 'Testing ASR Rules by Names'  {
     It "Rulen Name $($n) should be exact" {
     (Get-ASRRuleData -Name $n).RuleName -eq $n | Should be $true
    }
 }
 Describe 'Testing ASR Rules by Id'  {
     It "Rule id $($i) should be exact" {
     (Get-ASRRuleData -Name $n).GUID -eq $i | Should be $true
    }
 }

}