
#  ____            ___  _    _         
# |___ \__      __/ _ \| | _| | ___ __ 
#   __) \ \ /\ / / | | | |/ / |/ / '__|
#  / __/ \ V  V /| |_| |   <|   <| |   
# |_____| \_/\_/  \___/|_|\_\_|\_\_|      
# https://qrz.com/db/2w0kkr

# Collect UK Repeater Lists, Combine and Output CSV  for  IC-9700                                    

Write-Host "--- Generate Repeater List - IC-9700 ---"  -ForegroundColor Cyan

# Functions

Function Convert-StreamToString {

    Param (
    
        $Stream
    
    )

    # Convert Content Stream to String
    $String =  ""
    foreach ($Char in $Stream) {  
        $Letter  = [char]$Char
        $String  =  $String  +  $Letter
    }

    Return $String

} 


# Define Base Variables

$TimeStamp  =  Get-Date -Format yyyy-MM-dd
$OutPut_File = "./UK_RepList_"+$TimeStamp+".csv"

$Base_Url = "http://downloads.d-staruk.co.uk/files/"

$File_List = @(
                "UK_DStar_VHF_Rpt_All.csv",
                "UK_DStar_UHF_Rpt_All.csv",
                "UK_FM_VHF_Rpt_All.csv",
                "UK_FM_UHF_Rpt_All.csv"
                )

# Empty Repeater List
$Repeaters   = @()


ForEach ($File in  $File_List)  {

    # Collect File from the Website
    $Url  = $Base_Url +  $File

    Write-Host "[FETCH] $Url"   -ForegroundColor  Gray

    Try  {

        $Content = (Invoke-WebRequest -Uri $Url -UseBasicParsing).Content
        $CSV = Convert-StreamToString -Stream $Content | ConvertFrom-CSV
        $Repeaters =  $Repeaters  +  $CSV

        Write-Host "[ADDED]" $CSV.Count "repeaters"  -ForegroundColor Yellow

    }
    Catch {

        Write-Host "[FAIL] Failed to fetch $Url"  -ForegroundColor Red

    }


}

Write-Host "[OUTPUT] Wrote" $Repeaters.Count "repeaters into" $OutPut_File  -ForegroundColor Green
$Repeaters | Export-Csv -Path $OutPut_File -NoTypeInformation

# Remove quote marks for 9700 import
(Get-Content $OutPut_File) | % {$_ -replace '"', ''} | Out-File -FilePath $OutPut_File -Force -Encoding ascii

