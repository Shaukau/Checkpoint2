
# Q.5.7Import module Function pr utiliser le fonction log
Import-Module "C:\Scripts\Functions.psm1"

Function Random-Password
{
    param ([Int]$Length = 8)
    
    $Punc = 46..46
    $Digits = 48..57
    $Letters = 65..90 + 97..122

    $Password = Get-Random -Count $Length -Input ($Punc + $Digits + $Letters) |`
        ForEach -begin { $aa = $null } -process {$aa += [char]$_} -end {$aa}
    Return $Password.ToString()
}

Function ManageAccentsAndCapitalLetters
{
    param ([String]$String)
    
    $StringWithoutAccent = $String -replace '[éèêë]', 'e' -replace '[àâä]', 'a' -replace '[îï]', 'i' -replace '[ôö]', 'o' -replace '[ùûü]', 'u'
    $StringWithoutAccentAndCapitalLetters = $StringWithoutAccent.ToLower()
    $StringWithoutAccentAndCapitalLetters
}

$Path = "C:\Scripts"
$CsvFile = "$Path\Users.csv"
$LogFile = "$Path\Log.log"

# Q.5.3 Correction du skip pr prendre en compte le premier utilisateur
# Q.5.5 import uniquement des champs utilisé dans le script
$Users = Import-Csv -Path $CsvFile -Delimiter ";" `
    -Header "prenom","nom","societe","fonction","service","description" `
    -Encoding UTF8  | Select-Object -Skip 1




foreach ($User in $Users)
{
    $Prenom = ManageAccentsAndCapitalLetters -String $User.prenom
    $Nom = ManageAccentsAndCapitalLetters -String $User.Nom
    $Name = "$Prenom.$Nom"
    If (-not(Get-LocalUser -Name "$Prenom.$Nom" -ErrorAction SilentlyContinue))
    {
        $Pass = Random-Password
        $Password = (ConvertTo-secureString $Pass -AsPlainText -Force)
        $Description = "$($User.Description) - $($User.Fonction)"
        # Q.5.4 Utilisation du champ description lor de la creation du compte
        # Q.5.11 Desactivation de l'expiration du MDP
        $UserInfo = @{
            Name                 = "$Prenom.$Nom"
            FullName             = "$Prenom.$Nom"
            Password             = $Password
	    Description		 = $Description
            AccountNeverExpires  = $True
            PasswordNeverExpires = $True
        }

        New-LocalUser @UserInfo
        #Q.5.10
        Add-LocalGroupMember -Group "Utilisateurs" -Member "$Prenom.$Nom"
        # Q.5.6 Affichage du MDP
        Write-Host "L'utilisateur $Prenom.$Nom a été crée avec le mot de passe $Pass" -ForegroundColor Green
	# Q.5.8 Journalisation de la creation du compte utilisateur
	Log "Le compte $Prenom.$Nom a été créé"
    }
    # Q.5.9 affichage uniquement si le compte exixte deja
	Write-Host "Le compte $Prenom.$Nom existe déjà" -ForegroundColor Red
}
