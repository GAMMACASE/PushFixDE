# PushFix Definitive Edition
This plugin was built around the [research](https://forums.alliedmods.net/showthread.php?p=2766789) done by [@XutaxKamay](https://github.com/XutaxKamay) (part 1), so huge thanks to him for his work.

Main idea of this plugin is to fix [client prediction errors](https://www.youtube.com/watch?v=0qBcYXMV9p4&ab_channel=Blacky) in a way that doesn't affect game movement and lets engine to calculate it the way it was intended, instead of redoing game movement code that mimics trigger_push for example as it was done in this [pushfix](https://forums.alliedmods.net/showthread.php?p=2323671) (This one doesn't match the original trigger_push game movement logic output you'd get if played without the fix and thus produces 10-20 units on avarage of difference on to what you should've got). This plugin also properly fixes ``m_vecBaseVelocity`` and removes ``DataTable warning: player: Out-of-range value (XXXX.000000) in SendPropFloat 'm_vecBaseVelocity', clamping.`` messages from console.

This plugin only introduces a QoL changes by fixing client prediction errors and doesn't affects/alters movement code whatsoever. It also does obsoletes any other trigger_push fix plugins that are outthere like [pushfix](https://forums.alliedmods.net/showthread.php?p=2323671) one. So, please, remove any other pushfix related plugins that you might have before installing this one to get the prefered game movement logic output.

## Requirements
* SourceMod 1.10 or higher.
* Current support: CSGO Only.

## Side note:
This plugin enforces ``sv_sendtables`` to ``1``, so any alterations to that convar might cause clients being unable to connect or any other side effects.
