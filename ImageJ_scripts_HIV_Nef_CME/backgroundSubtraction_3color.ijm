//Script for background subtraction
name = getTitle();

//Clear ROI Manager
if (roiManager("count") != 0) {
	roiManager("deselect");
	roiManager("delete");
}
//Designate region for backgorund subtraction
selectWindow(name);
setTool("rectangle");
waitForUser("Select background region to subtract. Save to ROI manager");

//Split image for 2color
/*
selectWindow(name);
run("Split Channels");
c1name = "C1-" + name;
c2name = "C2-" + name;
channelNames = newArray(c1name, c2name);

for (i = 0; i < 2; i++) {
	selectWindow(channelNames[i]);
	roiManager("Select", 0);
	getStatistics(area,mean);
	selectWindow(channelNames[i]);
	run("Select All");
	run("Subtract...", "value=" + mean + " stack");
	
}

run("Merge Channels...", "c2=[" + channelNames[0] + "] c6=[" + channelNames[1] + "] create ignore");
*/

//Split image for 3color


selectWindow(name);
run("Split Channels");
c1name = "C1-" + name;
c2name = "C2-" + name;
c3name = "C3-" + name;
channelNames = newArray(c1name, c2name, c3name);

for (i = 0; i < 3; i++) {
	selectWindow(channelNames[i]);
	roiManager("Select", 0);
	getStatistics(area,mean);
	selectWindow(channelNames[i]);
	run("Select All");
	run("Subtract...", "value=" + mean + " stack");
	
}

run("Merge Channels...", "c2=[" + channelNames[0] + "] c5=[" + channelNames[1] + "] c6=[" + channelNames[2] + "] create ignore");


rename("BS-" + name);