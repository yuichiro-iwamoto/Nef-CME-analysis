//Script for median filter background subtraction of stacks
mfSize = 6; //pixel size for MF
name = getTitle();
run("Split Channels");
c1name = "C1-" + name;
c2name = "C2-" + name;
c3name = "C3-" + name;
channelNames = newArray(c1name, c2name, c3name);

//print(channelNames[1]);

for (i = 0; i < 3; i++) {
	selectWindow(channelNames[i]);
	run("Duplicate...", "duplicate");
	run("Median...", "radius=" + mfSize + " stack");
	mfWindow = getTitle();
	imageCalculator("Subtract create stack", channelNames[i],mfWindow);
	close(mfWindow);
	close(channelNames[i]);
	channelNames[i] = getTitle();
}

run("Merge Channels...", "c2=[" + channelNames[0] + "] c5=[" + channelNames[1] + "] c6=[" + channelNames[2] + "] create ignore");

rename("MF-" + name);

Stack.setChannel(1);
run("Magenta");
Stack.setChannel(3);
run("Cyan");