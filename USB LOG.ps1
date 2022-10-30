#Source: https://www.reddit.com/r/PowerShell/comments/9zebvv/comment/eaic9mc/?utm_source=share&utm_medium=web2x&context=3
#Seems plausible that you could run a script on (the occurrence of) one of these events to collect more detailed information.
#Seems outdated in 2022, can be 4-6 yrs. old.
#THIS IS NOT MY OWN WORK!
$EventLog = New-Object System.Diagnostics.Eventing.Reader.EventLogConfiguration 'Microsoft-Windows-DriverFrameworks-UserMode/Operational'

if($EventLog.IsEnabled -eq $True)
{
    [System.Collections.ArrayList]$EventList = @()
        $filter = @{
            Logname  = 'Microsoft-Windows-DriverFrameworks-UserMode/Operational'
            Level    = 0, 1, 2, 3, 4, 5
            ID	     = 2003, 2004, 2005, 2100, 2101, 2102, 2103, 2104, 2105, 2106, 2107, 2108, 2109
        }
    $events = Get-WinEvent $filter
    foreach($event in $events)
    {

        $XML = [xml]$event.ToXml()
        [void]$EventList.Add([PSCustomObject]@{ 
            LifetimeId   = $XML.Event.UserData.UMDFHostDeviceRequest.LifetimeId
            InstanceId   = $XML.Event.UserData.UMDFHostDeviceRequest.InstanceId
            EventID      = $XML.Event.System.EventID
            Computer     = $XML.Event.System.Computer
            TimeCreated  = [datetime]$XML.Event.System.TimeCreated.SystemTime
        })
    }

} else 
{
    $EventLog.IsEnabled = $True
    $EventLog.SaveChanges()

}

$EventList
