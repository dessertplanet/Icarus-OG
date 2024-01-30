<H1>Icarus</H1>

This is a lovingly ported version of Zack Schollz's Monome Norns patch called Icarus (original found here: <https://github.com/schollz/icarus>) for the Organelle M/S.

PLEASE READ INSTALLATION INSTRUCTIONS BEFORE DOWNLOADING :)

Zack originally based this on the Korg Monotron delay which makes sense if you have played with one of those. I don’t have a Norns (yet) so this was built entirely from code inspection and YouTube videos.

It has been a passion project of mine for a few months now to figure out how to do this using Supercollider on the Organelle and it is finally ready to share.

FEATURES:
– 5 voice Polyphonic Super-saw Synth
– Pulse wave sub Oscillator
– Hard-wired, 100% wet, low fi delay insanity
– Stereo Output (and input)
– AUX key + physical keys 1-3 introduce temporary “shifts”
– MIDI input support (setup in OG settings and relaunch patch, don’t forget to save)
– Fun graphics!

INSTALLING AND RUNNING:
Supercollider is a bit weird on Organelle! So there is a dance you need to do to make this patch work.

First: Installation requires internet access so we can install a prerequisite (jackd) and installation can TAKE SEVERAL MINUTES so please be patient and let it do it’s thing while the deploy script is running.

Second: Supercollider on the Organelle M/S (and therefore this patch!) will only run after installation if it thinks there is some kind of screen/display attached. You can fake this by restarting your Organelle and then going to Wi-Fi Settings -> Start VNC. This process actually crashes mother and you end up back at the root of the main menu. But even without connecting a display or signing in via VNC (or even connecting a network), after you land at the root of the menu you should be able to launch the launch the Icarus patch from the Synthesizers menu without issue. If you see a black screen and do NOT see “heating up supercollider” then you may have the display issue. Try the steps above again.

Have fun! Beware this can get loud.
