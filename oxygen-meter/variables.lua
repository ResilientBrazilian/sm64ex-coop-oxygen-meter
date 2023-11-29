local audio_stream_load, get_texture_info = audio_stream_load, get_texture_info

m                                         = gMarioStates[0]

lastHP, metalHP                           = 0, 0

incFull, beep                             = audio_stream_load('galaxy_IncreaseFull.mp3'), audio_stream_load('beep.mp3')
ringHalf                                  = get_texture_info('Ring_Half')
maxAir, air, clock, wait                  = 1440, 1440, 0, 32

totIncAir, totIncHP                       = 0, 0

scale                                     = 0.1

showTimer                                 = false
