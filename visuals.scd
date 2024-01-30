/////////GRAPHICS STUFF////

~delay = 50;
~feedback = 100;
~vuValsTmp = 0.8;

~frameHLine = {
	|x1, x2, y, color = true|

	//only for horizontal lines! constant "y"

	(x2-x1).do({
		|i|
		~setPixel.(x1 + i, y, color, [0, ~horizon, 128, 64])
	})
};

~rnd = {
	|x|
	if (x == 0) {0}
	{
		if (x == nil) {x = 1};
		x = x * 100;
		x = rand(x) / 100;
	}
};


~customCos = {
	|x|
	x = x * 360;

	x.degrad.cos;
};

//temp horizon


~refresh = Routine({
	var rate = 0.2,
	rdelta, rpos, rfeedback,
	rvolume, rlow, rhigh;


	~graphics.(\ShowInfoBar, false);
	~graphics.(\Clear);

	~rvolume = 0.8.asInteger;




	loop {

		~pixels = Int8Array.newClear(1024);

		//rpos.postln;
		~rvolume = ~vuVals[2].linlin(0,1,4,30).asInteger;

		rlow = ~rvolume;
		rhigh = ~rfeedback + ~rvolume;
		rdelta = ~rfeedback;

		//////////
		//circle drawn into blob

		rlow.do({
			|i|
			~frameCircle.(~rpos[0], (~rpos[1] +10 + ~rdestruct), i , true, [0,(0 + (2* ~rdestruct)).clip(0,64),128, ~horizon.clip(0,64)])
		});


		rdelta.do({
			|i|
			~frameCircle.(~rpos[0], (~rpos[1] + 10 + ~rdestruct), (rlow + i), (i.odd || ~bounceFeedback) , [0,0,128, (~horizon + (2 * ~rdestruct)).clip(0,64)]);
			~frameCircle.(~rpos[0], (~rpos[1] + 10 + ~rdestruct), (rhigh + i), ((i%3 == 0) || ~bounceFeedback), [0,0,128, (~horizon + (2 * ~rdestruct)).clip(0,64)]);
		});


		//Draw water into blob///////
		thisThread.randSeed_(4);


		64.do({
			|y|
			var z;


			z = 64 / (y + 1);

			(z*5).asInteger.do({
				|i|
				var x, w;

				x = (~rnd.(160) + (~current_time * 160 / z))%150 - 16;

				w = ~customCos.(~rnd.() + ~current_time) * 12 / z;

				if(w > 0)
				{
					//if (((x-w) > 0) && ((x+w) < 128) && (y < (64 - ~horizon))){
					~frameHLine.(x-w, x+w, y+~horizon)
					//}
				}
			})
		});

		//////

		//send blob and flip screen
		~graphics.(\Frame, ~pixels);
		~graphics.(\Flip);
		~current_time = ~current_time + rate + (~bounceDelay.asInteger * 2);
		if (~current_time > 10) { ~current_time = 0 };
		rate.wait;
	}
});
