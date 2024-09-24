// Run this to monitor

(

// set index of bus to monitor
var srcIdx = 0;

var win = Window("Bus Monitor for Object:"+srcIdx.asString,Rect(100,100,600,400)).front;

var s1  = Slider(win,Rect(20,10,30,360));
var s2  = Slider(win,Rect(60,10,30,360));
var s3  = Slider(win,Rect(100,10,30,360));

var t1 = StaticText(win, Rect(20, 10, 30, 30)).align_(\center).string_("X");
var t2 = StaticText(win, Rect(60, 10, 30, 30)).align_(\center).string_("Y");
var t3 = StaticText(win, Rect(100, 10, 30, 30)).align_(\center).string_("Z");

var s4  = Slider(win,Rect(180,20,360,30));
var s5  = Slider(win,Rect(180,60,360,30));
var s6  = Slider(win,Rect(180,100,360,30));

var t4 = StaticText(win, Rect(180, 20, 30, 30)).align_(\center).string_("A");
var t5 = StaticText(win, Rect(180, 60, 30, 30)).align_(\center).string_("E");
var t6 = StaticText(win, Rect(180, 100, 30, 30)).align_(\center).string_("D");


var updateIndicator = fork{loop{
	~xyz_BUS[srcIdx].getn(3,{
		arg value;
		{
			s1.valueAction = value[0];
			s2.valueAction = value[1];
			s3.valueAction = value[2];
		}.defer();
	});
	0.05.wait;
}};

var updateIndicator2 = fork{loop{
	~aed_BUS[srcIdx].getn(3,{
		arg value;
		{
			s4.valueAction = value[0];
			s5.valueAction = value[1];
			s6.valueAction = value[2];
		}.defer();
	});
	0.05.wait;
}};

)
