function Get-HuduCompanyJumplink {
  [CmdletBinding()]
  param(
    [parameter(ValueFromPipeline,Mandatory)]
    [object]$Company,

    [parameter(Mandatory)]
    [ArgumentCompletions('ninja','cw_manage','auvik','syncro')]
    [string]$Integrator
  )

  process {
    $_companyId = $Company | Find-ObjectIdByReference -Type Company
    $_company = Get-HuduCompanies -Id $_companyId
    if ($_integration = $_company.integrations | ? { $_.integrator_name -eq $Integrator }) {
        $_id = $_integration.sync_id ? "integration_id=$($_integration.sync_id)" : "integration_identifier=$($_integration.identifier)"
        return "{0}/api/v1/companies/jump?integration_slug={1}&{2}" -f (Get-HuduBaseURL), $Integrator, $_id
    }
  }
}