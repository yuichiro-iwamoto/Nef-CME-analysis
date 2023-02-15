/*Macro for segmenting cells and sorting into file structure suitable for CMEanalysis.
This analysis assumes your movies are 3 channel movies*/

var dataDirectory = "";
var movieDirectory = "";
var frameRate = "";
var movieNum = 0;
//Variables for indicating portion of stack to keep. Disregard if not trimming movie
var stackStart = 1;
var stackEnd = 151;

//make folder structure, gathering information
showMessage("Create folder for experimental condition. Select that folder");
dataDirectory = getDirectory("Choose a Directory");
Dialog.create("Experimental Date");
Dialog.addString("Insert date of experiment", "yyyymmdd");
Dialog.show();
date = Dialog.getString();
Dialog.create("Movie Frame Rate");
Dialog.addString("Insert imaging rate. For example, 2 if you imaged a frame per 2 seconds", "");
Dialog.show();
frameRate = Dialog.getString();
dataDirectory = dataDirectory + date;
File.makeDirectory(dataDirectory);
Dialog.create("Movie number");
Dialog.addNumber("How many movies are you going to analyze?", "");
Dialog.show();
movieNum = Dialog.getNumber();
Dialog.create("Channel Specification");
Dialog.addString("What is the coat protein channel", "C2");
coatChannel = Dialog.getString();
Dialog.addString("What is the second protein channel", "C1");
subChannel = Dialog.getString();
//For third channel. Comment out if not needed
Dialog.addString("What is the third protein channel", "C3");
subChannel2 = Dialog.getString();
Dialog.show();
print(coatChannel);
print(subChannel);
print(subChannel2);
//print(date);
//print(frameRate);

//loop for number or movies
for (ii = 0; ii < movieNum; ii++) {
	//print(movieNum);
	//print(ii);
	
	//opening the movie
	showMessage("Select movie to open");
	run("Open...", "open");
	movieName = getTitle();
	
	//Clear ROI Manager
	if (roiManager("count") != 0) {
		roiManager("deselect");
		roiManager("delete");
	}
	
	//Defining regions to segment in the movie
	//showMessage("Please select regions of the movie you would like to crop and save them to the ROI manager");
	setTool("rectangle");
	waitForUser("Select cells in the movie you would like to analyze. Save them to the ROI manager. Click OK when finished defining ROI's");
	
	nRoi = roiManager("count");
	for (i = 0; i < nRoi; i++) {
		selectImage(movieName);
		roiManager("select", i);
		run("Duplicate...", "duplicate");
		subMovieName = getTitle();
		run("Split Channels");
		cellDirectory = dataDirectory + File.separator + "cell" + (ii+1) + "-" + (i+1) + "_" + frameRate + "s";
		//print(cellDirectory);
		File.makeDirectory(cellDirectory);
		coatDirectory = cellDirectory + File.separator + "Ch" + "1";
		File.makeDirectory(coatDirectory);
		subDirectory = cellDirectory + File.separator + "Ch" + "2";
		File.makeDirectory(subDirectory);
		subDirectory2 = cellDirectory + File.separator + "Ch" + "3";
		File.makeDirectory(subDirectory2);
		selectImage(coatChannel + "-" + subMovieName);
		//for trimming. comment out line below if not using
		run("Slice Keeper", "first=" + stackStart + " last=" + stackEnd + " increment=1");
		saveAs("tiff", coatDirectory + "/" + getTitle());
		selectImage(subChannel + "-" + subMovieName);
		//for trimming. comment out line below if not using
		run("Slice Keeper", "first=" + stackStart + " last=" + stackEnd + " increment=1");
		saveAs("tiff", subDirectory + "/" + getTitle());
		selectImage(subChannel2 + "-" + subMovieName);
		//for trimming. comment out line below if not using
		run("Slice Keeper", "first=" + stackStart + " last=" + stackEnd + " increment=1");
		saveAs("tiff", subDirectory2 + "/" + getTitle());
		roiManager("deselect");
		selectImage(movieName);
		close("\\Others");
	}
	close();
	print(movieName);

}
