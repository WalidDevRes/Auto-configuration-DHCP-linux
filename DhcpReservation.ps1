function MiseEnPlaceDHCP {
    $ip = Read-Host "Veuillez donner l'adresse IP du serveur DHCP"
    $carte = Read-Host "Veuillez donner le nom de votre carte réseau connectée à votre serveur DHCP (Exemple : enp0s3)"
    $IpReseau = Read-Host "Veuillez donner l'adresse réseau (Exemple : xx.xx.xx.0)"    
    $ipRangeIn = Read-Host "Veuillez donner la première adresse IP de la plage (Exemple : xx.xx.xx.xx)"
    $ipRangeOut = Read-Host "Veuillez donner la deuxième adresse IP de la plage (Exemple : xx.xx.xx.xx)"
    $MasqueIp = Read-Host "Veuillez donner votre masque IP (Exemple : 255.255.255.0)"
    $Masqueslash = Read-Host "Veuillez donner votre masque IP (Exemple : 24)"
    $router = Read-Host "Veuillez donner la route par défaut (Exemple : 192.168.1.254)"
    $Dns = Read-Host "Donnez le DNS (Exemple : 200.200.80.0)"
    $DomainName = Read-Host 'Donnez un nom de domaine (Exemple : "walid")'
    $DefaultBail = Read-Host "Donnez le temps de bail par défaut"
    $Bail = Read-Host "Donnez le temps de bail"

    $commandeV2 = "sudo rm -r /etc/default/isc-dhcp-server"
    $commandeV3 = "sudo touch /etc/default/isc-dhcp-server"
    $commandeV4 = "sudo ip link set $carte up"
    $commandeV5 = "sudo rm -r /etc/dhcp/dhcpd.conf"
    $commandeV6 = "sudo touch /etc/dhcp/dhcpd.conf"
    $commandeV7 = "sudo ip addr add $ip/$Masqueslash dev $carte"
    $commandeV8 = "sudo rm /etc/resolv.conf"
    $commandeV9 = "sudo touch /etc/resolv.conf"
    $commandeV11 = "sudo systemctl restart isc-dhcp-server.service"

    $FichierV1 = "/etc/default/isc-dhcp-server"
    $FichierV2 = "/etc/dhcp/dhcpd.conf"
    $FichierV3 = "/etc/resolv.conf"

     $contenuV1 = @"
 INTERFACESv4="$carte"
"@

    $contenuV2 = @"
subnet $IpReseau netmask $MasqueIp {
    range $ipRangeIn $ipRangeOut;
    option subnet-mask $MasqueIp;
    option routers $router;
    option domain-name-servers $Dns;
    option domain-name $DomainName;
    default-lease-time $DefaultBail;
    max-lease-time $Bail;
}
"@

    $contenuV3 = @"
nameserver $ip 
options edns0 trust-ad
search .
"@

    Invoke-Expression -Command $commandeV2
    Invoke-Expression -Command $commandeV3
    Add-Content -Path $FichierV1 -Value $contenuV1
    Invoke-Expression -Command $commandeV5
    Invoke-Expression -Command $commandeV6
    Add-Content -Path $FichierV2 -Value $contenuV2
    Invoke-Expression -Command $commandeV4
    Invoke-Expression -Command $commandeV7
    Invoke-Expression -Command $commandeV8
    Add-Content -Path $FichierV3 -Value $contenuV3
    Invoke-Expression -Command $commandeV9
    Invoke-Expression -Command $commandeV11

    Write-Output "Le serveur DHCP a été configuré avec succès."

    ChoixFin
}

function Reservation {
foreach ($i in 1..10) {

$mac= Read-Host('Veuillez donner votre addrese MAC')
$macTableau = New-Object System.Collections.Generic.List[string]
$macTableau.Add($mac)

while ([string]::IsNullOrEmpty($mac)) {
    Write-Output "Veuillez rentrer l'addrese MAC"
    $mac= Read-Host "Veuillez donner votre addrese MAC"
}
while ($mac.Length -ne 12 -and $mac -match '::') {
    Write-Output "Veuillez entrer une adresse MAC valide (12 caractères avec les deux points qui séparent) :"
    $mac = Read-Host "Adresse MAC"
}

$ip= Read-Host('Veuillez donner votre addrese Ip')
$ipTableau = New-Object System.Collections.Generic.List[string]
$ipTableau.Add($ip)

while (-not ($ip -match '^(\d{1,3}\.){3}\d{1,3}$')) {
    Write-Output "Veuillez entrer une adresse IP valide (avec un point qui séparent) :"
    $ip = Read-Host "Adresse IP"
}

$filepath = "/etc/dhcp/dhcpd.conf"

 $newContent = @"
  host client$i {
     hardware ethernet $mac;
     fixed-address $ip; 
} 
"@

 Add-Content -Path $filepath -Value $newContent

 $commande = "systemctl restart isc-dhcp-server"

 Invoke-Expression -Command $commande
 $mac= Read-Host("Voullez vous relancer la reservation d'ip dhcp ? (oui / non)")
 if($mac -eq "oui"){
     
 }
 elseif($mac -eq "non"){
  exit
 }
}
}

function Choix {
    $mac= Read-Host("Voullez vous lancer l'instalation du serveur DHCP (oui / non)")
    if($mac -eq "oui"){
        MiseEnPlaceDHCP
    }
    elseif ($mac -eq "non") {
    $mac= Read-Host("Voullez vous lancer la reservation d'ip dhcp ? (oui / non)")
    
    if($mac -eq "oui"){
        Reservation
    }
    elseif($mac -eq "non"){
     exit
    }
    }
}

function ChoixFin {
    $mac= Read-Host("Voullez vous lancer la reservation d'ip dhcp ? (oui / non)")
    if($mac -eq "oui"){
        Reservation
    }
    elseif($mac -eq "non"){
     exit
    }
}
Choix