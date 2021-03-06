<#SDS Modified Pester Test file header to handle modules.#>
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = ( (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.' ) -replace '.ps1', '.psd1'
$scriptBody = "using module $here\$sut"
$script = [ScriptBlock]::Create($scriptBody)
. $script

Describe "New-DynamicParameter" {
    It "Returns a System.Management.Automation.RuntimeDefinedParameter object" {
        (New-DynamicParameter -Name 'parama' -Type String ).GetType() | Should Be 'System.Management.Automation.RuntimeDefinedParameter'   }
    It "Returns a System.Management.Automation.RuntimeDefinedParameter object if passed a validation set" {
        (New-DynamicParameter -Name 'paramb' -Type String -ValidateSetOptions 'Bob','Mary','Sue').GetType() | Should Be 'System.Management.Automation.RuntimeDefinedParameter'    }
    It "Returns a System.Management.Automation.RuntimeDefinedParameter object by positional parameters" {
        (New-DynamicParameter paramc string ).GetType() | Should Be 'System.Management.Automation.RuntimeDefinedParameter'    }
}<#End Describe New-DynamicParameter#>


Describe "New-DynamicParameterDictionary" {
    It "Returns a System.Management.Automation.RuntimeDefinedParameterDictionary object when piped New-DynamicParameter results" {
        ( (New-DynamicParameter -Name 'parama' -Type String ), (New-DynamicParameter -Name 'paramb' -Type String -ValidateSet 'Bob','Mary','Sue') | New-DynamicParameterDictionary ).GetType() | Should Be 'System.Management.Automation.RuntimeDefinedParameterDictionary'   }
}<#End Describe New-DynamicParameterDictionary#>



    