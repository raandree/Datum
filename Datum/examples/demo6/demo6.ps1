if($PSScriptRoot) {
    $here = $PSScriptRoot
} else {
    $here = 'C:\src\Datum\Datum\examples\demo6'
}
pushd $here

ipmo $here\..\..\Datum.psd1 -force

$yml = Get-Content -raw $PSScriptRoot\datum.yml | ConvertFrom-Yaml

$datum = New-DatumStructure $yml


$ConfigurationData = @{
    AllNodes = @($Datum.AllNodes.psobject.Properties | % { $Datum.AllNodes.($_.Name) })
    Datum = $Datum
}

$Node = $Configurationdata.Allnodes[0]

#"Node is $($Node|FL *|Out-String)" | Write-Warning

Lookup -Node $Node -PropertyPath 'Profiles' <#'AllValues'#> -Verbose -Debug | Write-Warning

$Env:PSModulePath += ';C:\src\Datum\Datum\examples\demo6\Configurations'


configuration RootConfiguration
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName PLATFORM
    node $AllNodes.NodeName {
        (Lookup $Node 'Profiles') | % {
            $(Write-Warning "Looking up $_")
            #Include $_
            $Includes = $(lookup $Node $_)
            $(Write-Warning "Including")
            $Includes | % { x ($_.keys[0]) } #auto lookup
        }
    }
}

RootConfiguration -ConfigurationData $ConfigurationData

(cat -raw .\MyConfiguration\SRV01.mof) -replace '\\n',"`r`n"

#popd

#>