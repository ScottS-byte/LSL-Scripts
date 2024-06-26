//Multi File Sound Player For Music Or Sounds Works Without Needing File Name changing If Named Right
//Script auto determin order of list of sound files in alphbetical order

float INTERVAL = 10.00;

integer LISTEN_CHAN = 2000;
integer SEND_CHAN = 2001;
float VOLUME = 1.0;

integer g_iSound;
integer tottrack;
integer g_iListenCtrl = -1;
integer g_iPlaying;
integer g_iLinked;
integer g_iStop;
integer g_iPod;
string g_sLink;

// DEBUG
integer g_iWasLinked;
integer g_iFinished;

Initialize()
{  
    // reset listeners
    if ( g_iListenCtrl != -1 )
    {
        llListenRemove(g_iListenCtrl);
    }
    g_iListenCtrl = llListen(LISTEN_CHAN,"","","");
    g_iPlaying = 0;
    g_iLinked = 0;
}



PlaySong()
{
    integer i;

    g_iPlaying = 1;    
    llSetSoundQueueing(TRUE);
    tottrack = llGetInventoryNumber(INVENTORY_SOUND);
    llPlaySound(llGetInventoryName(INVENTORY_SOUND, 0),VOLUME);
    llPreloadSound(llGetInventoryName(INVENTORY_SOUND, 1));
    llSetTimerEvent(5.0);  // wait 5 seconds before queueing the second file
    g_iSound = 1;
//    for ( i = 1; i < tottrack; i++ )
//    {
//        llPreloadSound(llGetInventoryName(INVENTORY_SOUND, i));
//    }
}


StopSong()
{
    
    g_iPlaying = 0;
    llStopSound();
    llSetTimerEvent(0.0);
    
}


integer CheckLink()
{
    string sLink;
    
    sLink = llGetLinkName(1);
    g_sLink = sLink;
    if ( llGetSubString(sLink,0,6) == "Jukebox" )
    {
        return TRUE;
    }
    return FALSE;
}


default
{
    state_entry()
    {
        Initialize();
    }
    
    on_rez(integer start_param)
    {
        Initialize();
        if ( start_param )
        {
            g_iPod = start_param - 1;
            if ( g_iPod )
            {
                llRequestPermissions(llGetOwner(),PERMISSION_ATTACH);
            } else {
                // Tell the controller what the CD key is so it can lin
            }
        }
    }
    
    changed(integer change)
    {
        if ( change == CHANGED_LINK )
        {
            if ( llGetLinkNumber() == 0 )
            {
                StopSong();
                llDie();
            } else {
                if ( g_iStop )
                {
                    llMessageLinked(1,llGetLinkNumber(),"UNLINK","");
                } else {
                    llMessageLinked(1,llGetLinkNumber(),"LINKID","");
                    g_iWasLinked = 1;
                }
            }
        }
    }
    
    attach(key id)
    {
        if ( id == NULL_KEY )
        {
            llDie();
        } else {
            PlaySong();
        }
    }
    
    run_time_permissions(integer perm)
    {
        if ( perm == PERMISSION_ATTACH )
        {
            llAttachToAvatar(ATTACH_LSHOULDER);
            llSetTexture("clear",ALL_SIDES);
        }
    }
    
    touch_start(integer total_number)
    {
        integer i;
        
        for ( i = 0; i < total_number; i++ )
        {
            if ( llDetectedKey(i) == llGetOwner() )
            {
                if ( g_iPlaying )
                {
                    g_iPlaying = 0;
                    llStopSound();
                    llSetTimerEvent(0.0);
                } else {
                    PlaySong();
                }
            }
        }
    }
    
    listen(integer channel, string name, key id, string message)
    {
        if ( message == "RESET" )
        {
            if ( llGetLinkNumber() == 0 )
            {
                llDie();
            } else {
                llMessageLinked(1,llGetLinkNumber(),"UNLINK","");
            }
        }
        
        if ( message == "STOP" )
        {
            if ( g_iPod )
            {
                StopSong();
                llDetachFromAvatar();
            }
        }
    }

    link_message(integer sender_num, integer num, string str, key id)
    {
        if ( str == "PLAY" )
        {
            if ( !g_iPlaying )
            {
                PlaySong();
            }
            return;
        }
        
        if ( str == "STOP" )
        {
            g_iStop = 1;
            StopSong();
            llMessageLinked(1,llGetLinkNumber(),"UNLINK","");
        }
        
        if ( str == "VOLUME" )
        {
            VOLUME = (float)num / 10.0;
            llAdjustSoundVolume(VOLUME);
        }
    }
    
    timer()
    {
        if ( g_iPlaying )
        {
            if ( g_iSound == 1 )
            {
                llSetTimerEvent(INTERVAL);
            }
            llPlaySound(llGetInventoryName(INVENTORY_SOUND, g_iSound),VOLUME);
            if ( g_iSound < (tottrack - 1) )
            {
                llPreloadSound(llGetInventoryName(INVENTORY_SOUND, g_iSound+1));
            }
            g_iSound++;
            if ( g_iSound >= tottrack )
            {
                llSetTimerEvent(INTERVAL + 5.0);
                g_iPlaying = 0;
            }
        } else {
            if ( llGetLinkNumber() != 0 )
            {
                llSetTimerEvent(0.0);
                if ( g_iPod )
                {
                    llDetachFromAvatar();
                } else {
                    llMessageLinked(1,0,"FINISH","");
                    g_iFinished = 1;
                }
            }
        }
    }
}
