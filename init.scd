//Declare variables for use in Main!

~knobs = nil ! 4;
~aux = false;
~bounceFilter = false;
~bounceDelay = false;
~bounceFeedback = false;
~tempFeedback = nil;
~tempDelaytime = nil;
~tempFilter = nil;

//buses for server consumption
~coreParams = Bus.control(numChannels: 4);
~adsrParams = Bus.control(numChannels: 4);
~voiceParams = Bus.control(numChannels: 4);

//Default Values written to these buses
~coreParams.setSynchronous(
	/*filter*/ 0.0,
	/*delaytime*/ 0.25,
	/*feedback*/ 0.3,
	/*destructionlvl*/ 0.0);

~adsrParams.setSynchronous(
	/*attack*/ 1/12,
	/*decay*/ 1/3,
	/*sustain*/ 9/10,
	/*release*/ 2/3);

~voiceParams.setSynchronous(
	/*octave*/ 0.0,
	/*Portamento*/ 0.0,
	/*sub level*/ 0.0,
	/*input mix*/ -1.0
);

//initial page to appear at launch
~page = 0;

//strings for each param page
~coreParamStrings = [
	"Depth:      ",
	"Time:      ",
	"Sun:        ",
	"Black Hole: " ];

~adsrParamStrings = [
	"Attack:     ",
	"Decay:      ",
	"Sustain:    ",
	"Release:    " ];

~voiceParamStrings = [
	"Octave:     ",
	"Portamento: ",
	"Sub Osc:    ",
	"Input Mix:  " ];

//Units for each param page
~coreUnits = "%" ! 4;
~adsrUnits = [ "sec", "sec", "%", "sec"];
~voiceUnits = ["", "sec", "%", "%"];

//Language side value storage (always friendly values)

~values = ();

~values[\core] = [0, 25, 0.3.linlin(0.0, 1.0, 50, 150).asInteger, 0];

~values[\adsr] = [(1/12).asStringPrec(3), 0.33, 90, 0.7];

~values[\voice] = [0, 0, 0, 0];

//Useful lookups
~pageKeys = [nil, \core, \adsr, \voice];
~pageStrings = [nil, ~coreParamStrings, ~adsrParamStrings, ~voiceParamStrings];
~pageUnits = [nil,~coreUnits, ~adsrUnits, ~voiceUnits];


//graphics variables

~rdelay = 25.linlin(0,100,270,90);

~rpos = [ 63 + (40 * 225.degrad.sin), 31 + (40 * 225.degrad.cos) ];

~center = [63, 31];

~rfeedback = 0.3.linlin(0.0, 1.0, 4, 20).asInteger;

~rvolume = 0.asInteger;

~horizon = 30;

~rdestruct = 0.asInteger;