//A routine that provides the core SynthDef, then sets up the 5 synths necessary for max 5 voice polyphony

~init = Routine({

	var values;

	//Icarus
	SynthDef(\icarussynth,{
		arg amp=0.5, hz=220, pan=0, envgate=0,
		pulse=0,saw=0,bend=0,subpitch=1,
		attack=0.5,decay=1,release=1,sustain=0.9,
		resonance=0,portamento=0,tremelo=0,destruction=0,
		lpf = 18000, pwmcenter=0.5,pwmwidth=0.05,pwmfreq=3,detuning=0.1,
		feedback=0.5,delaytime=0.25, delaytimelag=0.1, sublevel=0.1, note = nil, destructionlvl = 0,
		transpose = 0, filterlag = 0.1, inputmix = 0.0;

		// vars
		var ender,snd,local,in,ampcheck,hz_dream,hz_sub,subdiv;


		if ( note != nil ) { hz = (note + transpose).midicps};

		lpf = ~coreParams.subBus(0).kr(1).linexp(0.0, 1.0, 20000, 1000).lag(filterlag);
		delaytime= ~coreParams.subBus(1).kr(1).linlin(0,1,0.5,0.05).lag(delaytimelag);
		destruction= ~coreParams.subBus(1).kr(1).linlin(0.5,1,30,0, \min);
		feedback = ~coreParams.subBus(2).kr(1).linlin(0,1,0.5,1.5).lag(2);
		destructionlvl = ~coreParams.subBus(3).kr(1);

		attack = ~adsrParams.subBus(0).kr(1).linlin(0.0,1.0,0.0,10.0);
		decay = ~adsrParams.subBus(1).kr(1).linlin(0.0,1.0,0.0,3.0);
		sustain = ~adsrParams.subBus(2).kr(1);
		release = ~adsrParams.subBus(3).kr(1).linlin(0.0,1.0,0.0,10.0);

		portamento = ~voiceParams.subBus(1).kr(1).linlin(0,1,0,3);
		sublevel = ~voiceParams.subBus(2).kr(1);
		inputmix = ~voiceParams.subBus(3).kr(1).linlin(0,1,-1,1);


		// envelope stuff
		ender = EnvGen.ar(
			Env.new(
				curve: 'cubed',
				levels: [0,1,sustain,0],
				times: [attack+0.015,decay,release],
				releaseNode: 2,
			),
			gate: envgate,
		);

		// dreamcrusher++
		hz_dream=(Lag.kr(hz+(SinOsc.kr(LFNoise0.kr(1))*(((hz).cpsmidi+1).midicps-(hz))*detuning),portamento).cpsmidi + bend).midicps;
		in = VarSaw.ar(hz_dream,
			width:
			LFTri.kr(pwmfreq+rrand(0.1,0.3),mul:pwmwidth/2,add:pwmcenter),
			mul:0.5
		);
		// add suboscillator
		subdiv=2**subpitch;
		hz_sub=(Lag.kr(hz/subdiv+(SinOsc.kr(LFNoise0.kr(1))*(((hz/subdiv).cpsmidi+1).midicps-(hz/subdiv))*detuning),portamento).cpsmidi + bend).midicps;
		in = in + Pulse.ar(hz_sub,
			width:
			LFTri.kr(pwmfreq+rrand(0.1,0.3),mul:pwmwidth/2,add:pwmcenter),
			mul:0.5*sublevel
		);
		in = Splay.ar(in);

		in = in * ender;

		in[0] = XFade2.ar(in[0], In.ar(~ioBus.subBus(2)), inputmix);
		in[1] = XFade2.ar(in[1], In.ar(~ioBus.subBus(3)), inputmix);

		// random panning
		in = Balance2.ar(in[0] ,in[1],SinOsc.kr(
			LinLin.kr(LFNoise0.kr(0.1),-1,1,0.05,0.2)
		)*0.1);



		ampcheck = Amplitude.kr(Mix.ar(in));
		in = in * (ampcheck > 0.02); // noise gate
		local = LocalIn.ar(2);
		local = OnePole.ar(local, 0.4);
		local = OnePole.ar(local, -0.08);
		local = Rotate2.ar(local[0], local[1],0.2);
		local = DelayC.ar(local, 0.5,
			Lag.kr(delaytime,0.2)
		);
		local = LeakDC.ar(local);
		local = ((local + in) * 1.25).softclip;

		local = MoogFF.ar(local,Lag.kr(lpf,1),gain: 0);
		// add destruction thing
		local = ((local*((1-EnvGen.kr(
			Env(
				levels: [0, 1,0],
				times: [0.1,0.1],
				curve:\sine,
			),
			gate: Dust.kr(destruction * destructionlvl)
		))))+local)/2;

		LocalOut.ar(local*Lag.kr(feedback,1));

		snd= Balance2.ar(local[0]*0.2,local[1]*0.2,SinOsc.kr(
			LinLin.kr(LFNoise0.kr(0.1),-1,1,0.05,0.2)
		)*0.1);

		// manual pan
		snd = Mix.ar([
			Pan2.ar(snd[0],-1+(2*pan),amp),
			Pan2.ar(snd[1],1+(2*pan),amp),
		]);
		SendTrig.kr(Dust.kr(30.0),0,Amplitude.kr(snd[0]+snd[1],3,3));
		Out.ar(0,snd)
	}).add;

	//prepare for encoder turn input
	m.sendMsg("/enablepatchsub", 1);

	3.wait;

	//Init

	~maxVoices = 5;
	~polyphony = ~maxVoices;


	~synths = ~maxVoices.collect({
		Synth(\icarussynth);
	});


	~voiceCount = 0;


	~current_time = 0;
	~graphics.(\ShowInfoBar, false);
	~refresh = ~refresh.play;
}).play;