function Get-HuduFolderRecursion {
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipeline)]
        [object]$Parent,

        [object[]]$RecursionPool
    )
    process {
        Write-Debug "Processing recursion for $($Parent.name) [$($Parent.id)])"
        $children = $RecursionPool | Where-Object { $_.parent_folder_id -eq $Parent.id }
        Write-Debug "Found $($children.count) children for $($Parent.name) [$($Parent.id)]"
        foreach ($child in $children){
            $moreChildren = $RecursionPool | Where-Object { $_.parent_folder_id -eq $child.id }
            if ($moreChildren){
                $child | Add-Member -MemberType NoteProperty -Name children -Value @((Get-HuduFolderRecursion -Parent $child -RecursionPool $RecursionPool))
            }
        }
        return $children
    }
}