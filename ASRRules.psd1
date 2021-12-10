@{

# Script module or binary module file associated with this manifest.
RootModule = 'ASRRules.psm1'

# Version number of this module.
ModuleVersion = '1.0.1'

# ID used to uniquely identify this module
GUID = '7cd70489-80bc-4cd9-931c-18fba4dfe0ac'

# Author of this module
Author = 'Emin Atac'

# Copyright statement for this module
Copyright = 'MIT License'

# Description of the functionality provided by this module
Description = 'ASRRules is a module that will help view and modify Attack Surface Reduction Rules provided by Windows Defender'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '5.1'

RequiredModules = 'ConfigDefender'
CompatiblePSEditions = @('Desktop', 'Core')

# Minimum version of Microsoft .NET Framework required by this module
# DotNetFrameworkVersion = '4.0'

# Minimum version of the common language runtime (CLR) required by this module
# CLRVersion = '4.0'

# Functions to export from this module
FunctionsToExport = @('Get-ASRRuleData','Set-ASRRuleConfig','Get-ASRRuleConfig')
# FunctionsToExport = '*'

PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = @('security','defense','PSEdition_Core','PSEdition_Desktop')

        # A URL to the license for this module.
        LicenseUri = 'https://opensource.org/licenses/BSD-3-Clause'

        # A URL to the main website for this project.
         ProjectUri = 'https://github.com/p0w3rsh3ll/ASRRules'

         ExternalModuleDependencies = @('ConfigDefender')

    } # End of PSData hashtable

} # End of PrivateData hashtable

}
