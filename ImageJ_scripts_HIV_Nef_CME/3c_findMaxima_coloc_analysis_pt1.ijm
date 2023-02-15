//Plug-in for generating average projections of from a three color movie
//and measuring their mander's colocalization coefficient.

mfSize = 6;
phansalkarSize = 15;
subtractValue = 10;

imageName = getTitle();
directory = getDirectory("image");
analysisdirectory = directory + imageName + "_analysis";
File.makeDirectory(analysisdirectory);
//print(analysisdirectory);

//clearing ROI manager
if (roiManager("count") != 0) {
	roiManager("deselect");
	roiManager("delete");
}

//background subtraction
//Designate region for backgorund subtraction
selectWindow(imageName);
setTool("rectangle");
waitForUser("Select background region to subtract. Save to ROI manager");
selectWindow(imageName);
run("Split Channels");
c1name = "C1-" + imageName;
c2name = "C2-" + imageName;
c3name = "C3-" + imageName;
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


imageName = "BS-" + imageName;
rename(imageName);

//clearing ROI manager
if (roiManager("count") != 0) {
	roiManager("deselect");
	roiManager("delete");
}

//selecting cells to analyze
setTool("rectangle");

waitForUser("Draw a SQUARE ROI around the cells you want to analyze. Save the ROI's to the ROI manager");

roiNum = roiManager("count");
roiManager("save", analysisdirectory + "/" + "cropped_area" + ".zip");

for (i = 0; i < roiNum; i++) {
	cellDirectory = analysisdirectory + "/" + "cell_" + (i);
	File.makeDirectory(cellDirectory);
	selectWindow(imageName);
	roiManager("select", i);
	run("Duplicate...", "duplicate");
	cellName = "cell_" + i + "_" + imageName;
	rename(cellName);
	selectWindow(cellName);
	run("Duplicate...", "duplicate");
	Stack.setChannel(1);
	run("Green");
	Stack.setChannel(2);
	run("Magenta");
	Stack.setChannel(3);
	run("Cyan");
	saveAs("tiff", cellDirectory + "/" + cellName);
	selectWindow(cellName);
	
	//Median Filter
	run("Split Channels");
	c1name = "C1-" + cellName;
	c2name = "C2-" + cellName;
	c3name = "C3-" + cellName;
	channelNames = newArray(c1name, c2name, c3name);
	
	for (ii = 0; ii < 3; ii++) {
		//print(channelNames[ii]);
		selectWindow(channelNames[ii]);
		run("Duplicate...", "duplicate");
		run("Median...", "radius=" + mfSize + " stack");
		mfWindow = getTitle();
		imageCalculator("Subtract create stack", channelNames[ii],mfWindow);
		close(mfWindow);
		close(channelNames[ii]);
		channelNames[ii] = getTitle();
	}
	
	run("Merge Channels...", "c2=[" + channelNames[0] + "] c5=[" + channelNames[1] + "] c6=[" + channelNames[2] + "] create ignore");
	
	MF_cellName = "MF-" + cellName;
	rename(MF_cellName);

	//Generate mask for each channel
	run("Split Channels");
	c1name = "C1-" + MF_cellName;
	c2name = "C2-" + MF_cellName;
	c3name = "C3-" + MF_cellName;
	channelNames = newArray(c1name, c2name, c3name);
	c1mask = "";
	c2mask = "";
	c3mask = "";
	maskNames = newArray(c1mask, c2mask, c3mask);
	c1AVG = "";
	c2AVG = "";
	c3AVG = "";
	AVGNames = newArray(c1AVG, c2AVG, c3AVG);

	//Code related to thresholding
	for (ii = 0; ii < 3; ii++) {
		selectWindow(channelNames[ii]);
		run("Smooth", "stack");
		run("Z Project...", "projection=[Average Intensity]");
		run("Duplicate...", "duplicate");
		run("8-bit");
		run("Subtract...", "value=" + subtractValue);
		run("Find Maxima...", "prominence=10 output=[Maxima Within Tolerance]");
		maskNames[ii] = getTitle();
		AVGNames[ii] = "AVG_" + channelNames[ii];
	}

	run("Merge Channels...", "c2=[" + maskNames[0] + "] c5=[" + maskNames[1] + "] c6=[" + maskNames[2] + "] create ignore");	
	mask_cellName = "mask_" + cellName;
	rename(mask_cellName);
	Stack.setChannel(1);
	run("Green");
	Stack.setChannel(2);
	run("Magenta");
	Stack.setChannel(3);
	run("Cyan");
	saveAs("tiff", cellDirectory + "/" + mask_cellName);

	run("Merge Channels...", "c2=[" + AVGNames[0] + "] c5=[" + AVGNames[1] + "] c6=[" + AVGNames[2] + "] create ignore");	
	AVG_cellName = "AVG_" + cellName;
	rename(AVG_cellName);
	Stack.setChannel(1);
	run("Green");
	Stack.setChannel(2);
	run("Magenta");
	Stack.setChannel(3);
	run("Cyan");
	saveAs("tiff", cellDirectory + "/" + AVG_cellName);

	selectWindow(imageName);
	close("\\Others");
}
