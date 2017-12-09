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
                
                if($query -match '"(.*?[^\\])') #this regex is not good, needs improvment
                {
                    write-host 'valid input'
                    $pollname = $query.split('"')[1]
                    $pollanswers = @()
                    $answerlist = @()
                    for($j = 3; $query[$j] -ne $NULL; $j+=2)
                    {
                        $pollanswers += $query.split('"')[$j]
                    }
                    for($j = 0; $pollanswers[$j] -ne $NULL; $j++)
                    {
                        $answerlist += ([string]($j+1) + ". " + $pollanswers[$j] + "`r`n")
                    }
                    Invoke-RestMethod -Method Post -Uri ($API_URL + "sendMessage?chat_id=" + $updates.result.message[$i].chat.id + "&text=A new poll has been started!  The question is...`r`n`r`n$pollname`r`n`r`n$answerlist")
                }
                else 
                {
                    Invoke-RestMethod -Method Post -Uri ($API_URL + "sendMessage?chat_id=" + $updates.result.message[$i].chat.id + '&text=Invalid poll syntax. The format is /newpoll "Poll Name" "Option1" "Option2"...')
                }
            } 
            "/vote *" # /vote <num of option>.  only can vote on the current poll as only one poll is allowed at a time
            {   
                $query = $updates.result.message[$i].text.substring(6)
                if($query -match '^[1-9]$')
                {

                }
                else
                {
                    Invoke-RestMethod -Method Post -Uri ($API_URL + "sendMessage?chat_id=" + $updates.result.message[$i].chat.id + "&text=Invalid vote.  The vote command only accepts integers between 1 and 9.")
                }
            }
            "/results" # get results of current poll
            {

            }
        }


        $lastupdateid = $updates.result.update_id[$i] + 1
        

    }

}

