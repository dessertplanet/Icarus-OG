//A re-imagining of Zack Schollz's brilliant "Icarus" patch for the Monome Norns- this time for Organelle.

/*
--I warn you, fly a middle
-- course: go too low & water
-- will weigh you down;
-- go too high and the sun's
-- fire will burn you.
-- keep to the middle way.
-- speeding up time more easily
-- destroys the sun
*/

//Load patch from file to declare variables
"/tmp/patch/init.scd".load;

//Load patch from file to setup SynthDef and Synths
"/tmp/patch/sounds.scd".load;

//Load patch from file to create necessary functions etc
"/tmp/patch/lib.scd".load;

//Load patch from file to create graphics routines and functions
"/tmp/patch/visuals.scd".load;


//The main.scd file contains the core OSCdefs for patch functionality that respond to messages from mother.scd & Organelle hardware

//RoutePhysicalKeys needs tweaking so redefining from mother.scd here
OSCdef( \RoutePhysicalKeys,
	{

		arg msg, time, addr, recvPort;

		var feedbackKnob, delayKnob, filterKnob, delaytime, feedback, filter;

		feedbackKnob = ~coreParams.subBus(2);
		delayKnob = ~coreParams.subBus(1);
		filterKnob = ~coreParams.subBus(0);

		case
		{msg[1] == 0}
		{
			//key 0 is aux
			~self.sendMsg("/aux", msg[2]);
		}
		{(msg[1] == 1) && ~aux}
		{
			//first physical key on organelle (C1)

			s.bind {
				~synths.do({|synth| synth.set(\delaytimelag, 4)});
			};

			if (msg[2] > 0)
			{
				delaytime = 0.95;
				~tempDelay = delayKnob.getSynchronous;
				~bounceDelay = true;

			}
			{
				delaytime = ~tempDelay;
				~bounceDelay = false;
				s.bind {
					~synths.do({|synth| synth.set(\delaytimelag, 0.1)});
				}

			};


			delayKnob.setSynchronous(delaytime);

			if(~page == 1){
				~loadParamLine.(1,1, ~friendlyValues[\core].(delaytime, 1));
			};


		}
		{(msg[1] == 2) && ~aux}
		{
			//second physical key on organelle (C#1)
			~bounceFilter = true;

			s.bind {
				~synths.do({|synth| synth.set(\filterlag, 20)});
			};

			if (msg[2] > 0)
			{
				filter = 0.0;
				~tempFilter = filterKnob.getSynchronous;
				~horizon = 64;

			}
			{
				filter = ~tempFilter;
				~bounceFilter = false;
				~horizon = ~tempFilter.linlin(0,1, 64, 0).asInteger;
				s.bind {
					~synths.do({|synth| synth.set(\filterlag, 0.1)});
				}

			};

			filterKnob.setSynchronous(filter);

			if(~page == 1){
				~loadParamLine.(1,0, ~friendlyValues[\core].(filter, 0));
			};


		}
		{(msg[1] == 3) && ~aux}
		{
			//third physical key on organelle (D1)

			if (msg[2] > 0)
			{ ~bounceFeedback = true; ~tempFeedback = feedbackKnob.getSynchronous; feedback = 0.85}
			{ ~bounceFeedback = false; feedback = ~tempFeedback};
			feedbackKnob.setSynchronous(feedback);

			if(~page == 1){
				~loadParamLine.(1,2, ~friendlyValues[\core].(feedback, 2));
			}
		};

		if (((msg[1] > 0) && (~aux == false)) || (msg[2] == 0)){
			//notes from the physical organelle keyboard are transposed so that the low C on organelle is middle C
			~self.sendMsg("/note", msg[1] + 59, msg[2] / 3 );
		}
	},
	"/key",
	recvPort:4000
);

OSCdef( \note,
	{
		arg msg, time, addr, recvPort;
		var num = msg[1], vel = msg[2], synth;

		if (vel > 0) {
			//NOTE ON
			synth = ~synths[0 .. ~polyphony-1].wrapAt(~voiceCount);

			s.bind {
				synth.set(\envgate, 1, \note, num);
			};
			~voiceCount = ~voiceCount + 1;
		}{
			//NOTE OFF
			s.bind {
				~synths.do({
					|voice, i|
					voice.get(\note, {
						|value|
						if (value == num) { voice.set(\envgate, 0) }
					})
				})
			};

			if (~voiceCount > 0) {~voiceCount = ~voiceCount - 1;}
		};
	},
	"/note",
	recvPort:57120
);

OSCdef( \knobs,
	{
		arg msg, time, addr, recvPort;
		var vol, raw = msg[1..4], outbound;

		4.do({
			|i|

			if ((raw[i] != ~knobs[i]) && (~knobs[i] != nil))
			{
				outbound = [ "/pageknobs", ~page, i, raw[i] ];

				~self.sendMsg(*outbound);
			}
		});

		~knobs = raw;
	},
	"/knobs",
	recvPort:4000
);

OSCdef( \routeKnobs,
	{
		arg msg, time, addr, recvPort;

		var page = msg[1], address, outbound;

		switch (page)
		{0}{address = "/core"}
		{1}{address = "/core"}
		{2}{address = "/adsr"}
		{3}{address = "/voice"};

		outbound = [ address ] ++ msg[1..3];

		~self.sendMsg(*outbound);

	},
	"/pageknobs",
	recvPort:57120
);


OSCdef( \core,
	{
		arg msg, time, addr, recvPort;
		var page, index, raw;

		page = msg[1];
		index = msg[2];
		raw = msg[3] / 1023;

		//send value to server via control bus
		~coreParams.subBus(index).setSynchronous(raw);

		//store value language side
		~values[\core][index] = ~friendlyValues[\core].(raw, index);

		switch(index)
		{0}{
			~horizon = ~values[\core][0].linlin(0,100, 64, 0).asInteger;
		}
		{1}{
			~rdelay= ~values[\core][1].linlin(0,100,270,90).asInteger ;
			~rpos = [ (~center[0] + (40 * ~rdelay.degrad.sin)).asInteger, (~center [1] + (40 * ~rdelay.degrad.cos)).asInteger ];
		}
		{2}{
			~rfeedback = ~values[\core][2].linlin(50, 150, 1, 15).asInteger;
		}
		{3}{
			~rdestruct = ~values[\core][3].linlin(0,100,0,~horizon).asInteger;
		};


		if(page > 0)
		{
			~loadParamLine.(1, index, ~values[\core][index]);
		}
	},
	"/core",
	recvPort:57120
);

OSCdef( \adsr,
	{
		arg msg, time, addr, recvPort;
		var index, raw;

		index = msg[2];
		raw = msg[3] / 1023;

		//send value to server via control bus
		~adsrParams.subBus(index).setSynchronous(raw);

		//store value language side
		~values[\adsr][index] = ~friendlyValues[\adsr].(raw, index);

		~loadParamLine.(2, index, ~values[\adsr][index]);

	},
	"/adsr",
	recvPort:57120
);

OSCdef( \voice,
	{
		arg msg, time, addr, recvPort;

		var index, raw;

		index = msg[2];
		raw = msg[3] / 1023;

		//send value to server via control bus
		~voiceParams.subBus(index).setSynchronous(raw);

		//store value language side
		~values[\voice][index] = ~friendlyValues[\voice].(raw, index);

		~loadParamLine.(3, index, ~values[\voice][index]);

		//need to do stuff here
		switch(index)
		{0}
		{
			~synths.do({
				|synth|
				synth.set(\transpose, ~values[\voice][0] * 12);
			})
		}
	},
	"/voice",
	recvPort:57120
);




OSCdef( \enc,
	{
		arg msg, time, addr, recvPort;

		if (msg[1] == 1)
		{
			//TURN TO RIGHT
			if (~page == 0) {
				~refresh.stop;
			};

			if (~page < 3) {
				~page = ~page + 1;
				~loadParamPage.(~page, ~values[~pageKeys[~page]]);
			}
		}{
			//TURN TO LEFT

			if (~page == 1) {
				~refresh.reset.play;
			};

			if (~page > 0) {
				~page = ~page - 1;

				if (~page>0) {
					~loadParamPage.(~page, ~values[~pageKeys[~page]]);
				}
			}
		};
	},
	"/encoder/turn",
	recvPort:4000
);

OSCdef( \encbut,
	{
		arg msg, time, addr, recvPort;
		//press encoder to pop patch menu
		m.sendMsg("/gohome");

	},
	"/encoder/button",
	recvPort:4000
);

OSCdef( \aux,
	{
		arg msg, time, addr, recvPort;
		var push = msg[1], ledVal;

		//write the organelle aux button state to a language side env variable and light up a pretty LED!

		if(push > 0)
		{
			//pushing aux turns LED yellow
			ledVal = 2;

			~aux = true;
		}{
			//releasing aux turns LED off
			ledVal = 0;

			~aux = false;
		};

		m.sendMsg("/led", ledVal);
	},
	"/aux",
	recvPort:57120
);