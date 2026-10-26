package com.llarean.walking

import com.ryanheise.audioservice.AudioServiceActivity

// Shares the Flutter engine with the media service, so the walk keeps
// running when the screen is off or the app is in the background.
class MainActivity : AudioServiceActivity()
