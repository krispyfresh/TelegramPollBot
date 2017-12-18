$Telegram_API_Key = "506079496:AAGY9qCHRq7iNA6uNncnSuMZalXGUuYqX_M"
$API_URL = ("https://api.telegram.org/bot" + $Telegram_API_Key + "/")
$lastupdateid = 0
$currentpoll = @()

function Format-PollOutput($poll)
{
    $outputstring = ($poll[0][0] + "`r`n")
    for($j = 1; $j -lt $poll.length; $j++)
    {
        $outputstring += ([string]$j + ". " + $poll[$j][0] + "`t`t`t" + $poll[$j][1] + "`r`n")

    }
    return $outputstring
}

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
                
                if($query -match '"(.*?[^\\])"') #this regex is not good, needs improvment
                {
                    $currentpoll = ,@($query.split('"')[1],1)
                    for($j = 3; $query.split('"')[$j] -ne $NULL; $j += 2)
                    {
                        $currentpoll += ,@($query.split('"')[$j],0)
                    }
                    $answerlist = @()
                    for($j = 1; $j -lt $currentpoll.length; $j++)
                    {
                        $answerlist += ([string]$j + ". " + $currentpoll[$j][0] + "`r`n")

                    }

                    Invoke-RestMethod -Method Post -Uri ($API_URL + "sendMessage?chat_id=" + $updates.result.message[$i].chat.id + "&text=A new poll has been started!  The question is...`r`n`r`n" + $currentpoll[0][0] + "`r`n`r`n$answerlist")
                                        

                }
                else 
                {
                    Invoke-RestMethod -Method Post -Uri ($API_URL + "sendMessage?chat_id=" + $updates.result.message[$i].chat.id + '&text=Invalid poll syntax. The format is /newpoll "Poll Name" "Option1" "Option2"...')
                }
            } 
            "/vote *" # /vote <num of option>.  only can vote on the current poll as only one poll is allowed at a time
            {   
                if($currentpoll.count -eq 0) #if there is no current poll, give error message
                {
                    Invoke-RestMethod -Method Post -Uri ($API_URL + "sendMessage?chat_id=" + $updates.result.message[$i].chat.id + '&text=There is no active poll to vote on.')
                }
                $query = $updates.result.message[$i].text.substring(6)
                if($query -match '^[1-9]$')
                {   
                    if([int]$query -lt $currentpoll.length)
                    {
                        $currentpoll[([int]$query)][1]++
                        Invoke-RestMethod -Method Post -Uri ($API_URL + "sendMessage?chat_id=" + $updates.result.message[$i].chat.id + "&text=Vote accepted.  Current results:`r`n" + (Format-PollOutput($currentpoll)))
                        
                    }
                    else
                    {
                        Invoke-RestMethod -Method Post -Uri ($API_URL + "sendMessage?chat_id=" + $updates.result.message[$i].chat.id + "&text=Invalid vote.  The vote command only accepts integers between 1 and " + $currentpoll.length)
                    }
                }
                else
                {
                    Invoke-RestMethod -Method Post -Uri ($API_URL + "sendMessage?chat_id=" + $updates.result.message[$i].chat.id + "&text=Invalid vote.  The vote command only accepts integers between 1 and " + $currentpoll.length)
                }
            }
            "/results" # get results of current poll
            {
                Invoke-RestMethod -Method Post -Uri ($API_URL + "sendMessage?chat_id=" + $updates.result.message[$i].chat.id + "&text=Current results:`r`n" + (Format-PollOutput($currentpoll)))
            }
        }
        $lastupdateid = $updates.result.update_id[$i] + 1
    }
}

