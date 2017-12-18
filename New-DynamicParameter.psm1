
FUNCTION New-DynamicParameterDictionary {
<#
.SYNOPSIS
Collects dynamic parameters into a dictionary for use
in a DynamicParam block.
Functions using dynamic parameters MUST be defined with CmdletBinding blocks.
.EXAMPLE
#A function with two dynamic parameters, one of which can be affected on the fly by a non-mandatory normal parameter.
FUNCTION test {
    [CmdletBinding()]
    PARAM($myFilter)
    DynamicParam {
        $set = Get-ChildItem -Filter $myFilter | Select-Object -ExpandProperty Name | Sort-Object -Unique
        (New-DynamicParameter -Name 'parama' -Type String -ValidateSet $set ), (New-DynamicParameter -Name 'paramb' -Type String -ValidateSet 'Bob','Mary','Sue') | New-DynamicParameterDictionary 
    }
    BEGIN{}
    PROCESS {
    $PSBoundParameters['parama']
    $PSBoundParameters['paramb']
    }
    END{}
}
Get-Help test

#>

    [CmdletBinding()]
	[OutputType('System.Management.Automation.RuntimeDefinedParameterDictionary')]
    PARAM(
        [Parameter(Mandatory = $true, ValueFromPipeline                 = $true)][System.Management.Automation.RuntimeDefinedParameter]$InputRuntimeDefinedParameter
    )
    BEGIN{Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
    $RDPDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary }
    PROCESS{ $RDPDictionary.Add($InputRuntimeDefinedParameter.Name, $InputRuntimeDefinedParameter) }
    END{return $RDPDictionary}
}


function New-DynamicParameter
{
<#
.SYNOPSIS
Adam Bertram's function for creating dynamic parameters during function design.
.LINK
https://raw.githubusercontent.com/adbertram/Random-PowerShell-Work/master/PowerShell%20Internals/New-DynamicParam.ps1
.LINK
https://www.adamtheautomator.com/psbloggingweek-dynamic-parameters-and-parameter-validation/
#>

	[CmdletBinding()]
	[OutputType('System.Management.Automation.RuntimeDefinedParameter')]
	param (
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$Name,
		
		[Parameter()]
		[ValidateNotNullOrEmpty()]
		[type]$Type = [string],
		
		[ValidateNotNullOrEmpty()]
		[Parameter()]
		[array]$ValidateSetOptions,
		
		[Parameter()]
		[ValidateNotNullOrEmpty()]
		[switch]$ValidateNotNullOrEmpty,
		
		[Parameter()]
		[ValidateNotNullOrEmpty()]
		[ValidateCount(2, 2)]
		[int[]]$ValidateRange,
		
		[Parameter()]
		[switch]$Mandatory = $false,
		
		[Parameter()]
		[string]$ParameterSetName = '__AllParameterSets',
		
		[Parameter()]
		[switch]$ValueFromPipeline = $false,
		
		[Parameter()]
		[switch]$ValueFromPipelineByPropertyName = $false
	)
	
	$AttribColl = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
	$ParamAttrib = New-Object System.Management.Automation.ParameterAttribute
	$ParamAttrib.Mandatory = $Mandatory.IsPresent
	$ParamAttrib.ParameterSetName = $ParameterSetName
	$ParamAttrib.ValueFromPipeline = $ValueFromPipeline.IsPresent
	$ParamAttrib.ValueFromPipelineByPropertyName = $ValueFromPipelineByPropertyName.IsPresent
	$AttribColl.Add($ParamAttrib)
	if ($PSBoundParameters.ContainsKey('ValidateSetOptions'))
	{
		$AttribColl.Add((New-Object System.Management.Automation.ValidateSetAttribute($ValidateSetOptions)))
	}
	if ($PSBoundParameters.ContainsKey('ValidateRange'))
	{
		$AttribColl.Add((New-Object System.Management.Automation.ValidateRangeAttribute($ValidateRange)))
	}
	if ($ValidateNotNullOrEmpty.IsPresent)
	{
		$AttribColl.Add((New-Object System.Management.Automation.ValidateNotNullOrEmptyAttribute))
	}
	
	$RuntimeParam = New-Object System.Management.Automation.RuntimeDefinedParameter($Name, $Type, $AttribColl)
    $RuntimeParam | Out-String | Write-Verbose
	$RuntimeParam
	
}<#End Function New-DynamicParameter#>
