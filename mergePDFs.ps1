#Benötigt das Modul PSWritePDF
#Falls nicht mehr vorhanden, "Install-Module PSWritePDF -Force"
#Falls OutOfDate, "Update-Module PSWritePDF"
# author = lucasscodes

#teste ob Modul installiert ist
if ((Get-Command -Module PSWritePDF).Length -eq 0) {
  #Teste ob Rechte vorhanden sind das Modul nachzuladen, sonst brich ab mit Fehlermeldung.
  $user = [Security.Principal.WindowsIdentity]::GetCurrent();
  if((New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator) -eq 0) {
    write-host "Modul fehlt, starte dieses Skript mit Adminrechten erneut um PSWritePDF automatisch nachzuladen!";
    Start-Sleep -Seconds 7;
    exit;
  }
  #Falls Rechte vorhanden, installiere Modul automatisch
  Install-Module PSWritePDF -Force;
}

#Erkennt Hilfeanfragen
if($args[0] -eq "help") {
  write-host "mergePDFs.ps1 Parameters:";
  write-host "1: FolderPath,              example: `"C:\Users\`"";
  write-host "2: List of PDF-Names,       example: (`"a.pdf`",`"b.pdf`",`"c.pdf`")";
  write-host "3: Name of Target PDF-File, example: `"result.pdf`"";
  exit;
}
#Erkennt leere Parameterliste
elseif($args.Count -eq 0) {
  write-host "No Parameters passed... try Parameter `"help`"";
  exit;}

#externeVariablen
#$inputOrdner = "C:\Users\**CENSORED**\ICG\PDFs\Folien\";
#$inputDateiNamen = "01-icg-webgl.pdf", "02-icg-polygonal-modelling.pdf","03-icg-splines.pdf","04-icg-transformations.pdf","05-icg-cameras.pdf","06-icg-lighting1.pdf","06-icg-lighting2.pdf","07-icg-projection.pdf","08-icg-rasterization.pdf","09-icg-shading.pdf", "10-icg-textures1.pdf", "10-icg-textures2.pdf", "11-icg-vfx.pdf", "11-icg-vfx2.pdf";
#$inputZielName = "Concat.pdf";

#Werden nun aus den Args entnommen
if($args.count -eq 3) {
  $inputOrdner = $args[0];
  $inputDateiNamen = $args[1];
  $inputZielName = $args[2];
}

#interneVariablen
#Da im ersten Schritt nicht 0+1=1 geht, wird der extra behandelt und macht 1+1'=x. Erst danach x+1=x++
$erstername = $inputDateiNamen[0];
$len = ($inputDateiNamen.Length)-1;
$namen = $inputDateiNamen[1..$len];
$ordner = $inputOrdner;

#Sollten noch nicht vorhanden sein und nach diesem Skript auch wieder entfernt werden.
#HARDCODED, TOCHANGE!
$target1 = "0987654321yaxb0987654321.pdf";
$target2 = "0987654321ybxa0987654321.pdf";

#Um zu wissen welchen Speicher ich nutzen muss und ob ich im Außnahmefall mit dem ersten Element bin.
$counter = -1;

#Erzeugt die Pfade zu den Zwischenspeichern und der ersten PDF
$o1 = -join($ordner, $target1);
$o2 = -join($ordner, $target2);
$i1 = -join($ordner, $erstername);

#Versuch PDFs von vorherigen Durchgängen zu finden und wegzuräumen, da sie wiederverwendet werden
try {Remove-Item -Path $o1, Remove-Item -Path $o2}
catch {}

#für jeden Namen ab NameNo2
foreach ($name in $namen) {
  #Gib Info raus
  write-host ($counter+2)"/"$len"ter Merge wird durchgeführt...";
  #Berechne dynamisch den Pfad der neu anzufügenden PDF
  $i2 = -join($ordner, $name);
  #Falls erster Schritt, merge die ersten beiden PDFs
  if ($counter -eq -1) {
    Merge-PDF -InputFile $i1, $i2 -OutputFile $o1;}
  #Da ab hier sicher nicht erster Schritt wird acc+newPDF=acc'
  #Falls o1 gebraucht wird, speichere in o2
  elseif (($counter % 2) -eq 0) {
    Merge-PDF -InputFile $o1, $i2 -OutputFile $o2;}
  #Falls o2 gebraucht wird, speichere in o1
  elseif (($counter % 2) -eq 1) {
    Merge-PDF -InputFile $o2, $i2 -OutputFile $o1;}
  $counter++;
}

#Letzten Inkrement negieren, somit gelten Z.47/Z.50 Bedingungen vom letzten Element wieder
$counter--;

#Jenachdem welche Bedingung galt, nutze letzten verwendeten Speicher als Ergebniss und lösche den anderen.
if (($counter % 2) -eq 0) {
  Rename-Item -Path $o2 -NewName $inputZielName;
  Remove-Item -Path $o1;}
elseif (($counter % 2) -eq 1) {
  Rename-Item -Path $o1 -NewName $inputZielName;
  Remove-Item -Path $o2;}

write-host $inputZielName" wurde scheinbar erfolgreich erstellt!";
