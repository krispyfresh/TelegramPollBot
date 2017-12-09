$Telegram_API_Key = "506079496:AAGY9qCHRq7iNA6uNncnSuMZalXGUuYqX_M"
$API_URL = ("https://api.telegram.org/bot" + $Telegram_API_Key + "/")
$lastupdateid = 0

while($true -eq $true)
{
    $updates = (Invoke-RestMethod -Uri ($API_URL + "getUpdates?offset=" + $lastupdateid + "&timeout=60"))

    for($i = 0; $i -lt $updates.result.count; $i++)
    {
        #write-host $updates.result.message[$i]
        switch -wildcard ($updates.result.message[$i].text) 
        {
            "/newpoll *" # /newpoll "Question" "Option1" "Option2" etc.  start a new poll.  one poll at a time allowed in order to avoid spam
            { 
                $query = $updates.result.message[$i].text.substring(9)
                write-host $query
            } 
            "/vote *" # /vote <num of option>.  only can vote on the current poll as only one poll is allowed at a time
            {
                $query = $updates.result.message[$i].text.substring(6)
                write-host $query
            }
       
            
        }


        $lastupdateid = $updates.result.update_id[$i] + 1
        

    }

}

