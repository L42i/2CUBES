// Run this to monitor

v = {

	// set index of bus to monitor

	|srcIdx = 0|

	var win = Window("Bus Monitor for Object:"+srcIdx.asString,Rect(100,100,600,400)).front;

	var s1  = Slider(win,Rect(20,40,30,360));
	var s2  = Slider(win,Rect(60,40,30,360));
	var s3  = Slider(win,Rect(100,40,30,360));

	var t1 = StaticText(win, Rect(20, 10, 30, 30)).align_(\center).string_("X");
	var t2 = StaticText(win, Rect(60, 10, 30, 30)).align_(\center).string_("Y");
	var t3 = StaticText(win, Rect(100, 10, 30, 30)).align_(\center).string_("Z");

	var s4  = Slider(win,Rect(180,20,360,30));
	var s5  = Slider(win,Rect(180,60,360,30));
	var s6  = Slider(win,Rect(180,100,360,30));

	var t4 = StaticText(win, Rect(150, 20, 30, 30)).align_(\center).string_("A");
	var t5 = StaticText(win, Rect(150, 60, 30, 30)).align_(\center).string_("E");
	var t6 = StaticText(win, Rect(150, 100, 30, 30)).align_(\center).string_("D");



	var s7  = Slider(win,Rect(180,200,360,30));
	var s8  = Slider(win,Rect(180,240,360,30));
	var s9  = Slider(win,Rect(180,280,360,30));

	var t7 = StaticText(win, Rect(150, 200, 30, 30)).align_(\center).string_("P");
	var t8 = StaticText(win, Rect(150, 240, 30, 30)).align_(\center).string_("R");
	var t9 = StaticText(win, Rect(150, 280, 30, 30)).align_(\center).string_("Y");

	var updateIndicator = fork{loop{

		~quest_xyz_BUS[srcIdx].getn(3,{
			arg value;
			{
				s1.valueAction = value[0]+0.5;
				s2.valueAction = value[1]+0.5;
				s3.valueAction = value[2]+0.5;
			}.defer();
		});

		~quest_aed_BUS[srcIdx].getn(3,{
			arg value;
			{
				s4.valueAction = value[0];
				s5.valueAction = value[1];
				s6.valueAction = value[2];
			}.defer();
		});
		~quest_pry_BUS[srcIdx].getn(3,{
			arg value;
			{
				s7.valueAction = value[0]*0.5;
				s8.valueAction = value[1]*0.5;
				s9.valueAction = value[2]*0.5;
			}.defer();
		});

		0.05.wait;
	}};


};



v.value(0)