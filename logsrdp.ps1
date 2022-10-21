## Script de logging des logins en RDP

﻿function getrdpuser{ ## fonction pour récup l'utilisateur connecté en rdp
$quout = quser ## commande permettant de voir les sessions ouvertes
$found = $false ## permet de passer sur tous les users connectés dans la boucle while
$point = ">" ## l'utilisateur connecté a ce symbole devant son ID
$sid = (($quout | Where-Object { $_ -match $point }) -split ' +')[2] ## récupérer un session ID permet de savoir que la session est active et existe bien
while ($found -eq $false) ## tant qu'on a pas trouvé l'utilisateur connecté
{
    $username = (($quout | Where-Object { $_ -match $point }) -split ' +')[0] ## on récupère son nom dans la chaîne renvoyée par quser
    $sid = (($quout | Where-Object { $_ -match $point }) -split ' +')[2] ## on récupère l'ID de session
    $found = $true ## vu qu'on est tombés sur l'utilisateur on sort de la boucle
}
return $username.Substring(1,$username.Length-1) ## on enlève le symbole devant le nom d'utilisateur et on le renvoie
}

$time = Get-Date -f "HH:mm:ss"
$date = Get-Date -f "dd/MM/yyyy"
$logfile = "c:\log-connexion\$date.csv" ## emplacement du log
$compname = $env:COMPUTERNAME
$user = getrdpuser ## appel de la fonction de récup du nom utilisateur
$os = (Get-WmiObject Win32_OperatingSystem).Caption
$ip = (Get-NetIPConfiguration | Where-Object { $_.IPv4DefaultGateway -ne $null -and $_.NetAdapter.Status  -ne "Disconnected" }).IPV4address.IPAddress ## on récupère l'adresse IPV4 de la carte réseau qui est active ET connectée
$infologin = "$date,$time,$user,$compname,$ip,$os" ## on concatène les variables dans une ligne ...
add-content $logfile $infologin ## ... et on l'envoie dans le fichier CSV
