//////FUNCTIONS/////////////

//load or reload a whole param page (Updates screen)
~loadParamPage = {
	arg page, values;

	~graphics.(\Clear);
	~graphics.(\ShowInfoBar, true);
	4.do { |i|
		m.sendMsg("/oled/line/" ++ (i+1), ~pageStrings[page][i] ++ values[i] ++ " " ++ ~pageUnits[page][i]);
	}
};

//load or reload a specific line on a param page (Updates screen)
~loadParamLine = {
	arg page, index, value;

	if(page > 0)
	{
		m.sendMsg("/oled/line/" ++ (index+1), ~pageStrings[page][index] ++ value ++ " " ++ ~pageUnits[page][index]);
	}
};

//Cleanup functions for reuse!
~valueCleanup = ();

~valueCleanup[\percentage] = { |input| (input * 100).asInteger };

~valueCleanup[\seconds] = { |input, max = 10.0| input.linlin(0.0, 1.0,0.0, max).asStringPrec(3) };


//page-specific cleanup functions (raw in, friendly out)

~friendlyValues = ();

~friendlyValues[\core] = {
	|raw, index|

	switch (index)
	{0}{~valueCleanup[\percentage].(raw)}
	{1}{~valueCleanup[\percentage].(raw)}
	{2}{raw.linlin(0.0,1.0,50.0,150.0).asInteger;}
	{3}{~valueCleanup[\percentage].(raw)}

};


~friendlyValues[\adsr] = {
	|raw, index|

	switch (index)
	{0}{~valueCleanup[\seconds].(raw);}
	{1}{~valueCleanup[\seconds].(raw, 3.0);}
	{2}{~valueCleanup[\percentage].(raw);}
	{3}{~valueCleanup[\seconds].(raw);};
};

~friendlyValues[\voice] = {
	|raw, index|


	switch (index)
	{0}{raw.linlin(0.0,1.0,-2,2).asInteger;}
	{1}{~valueCleanup[\seconds].(raw)}
	{2}{~valueCleanup[\percentage].(raw)}
	{3}{~valueCleanup[\percentage].(raw)};

};