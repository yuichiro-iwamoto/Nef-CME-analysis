//Script for organizing movies into folder structure for analysis with cmeAnalysis
var dataDirectory = "";
var movieDirectory = "";
var frameRate = "";
var movieNum = 0;
var cellNum = 1;
//Variables for indicating portion of stack to keep. Disregard if not trimming movie
var stackStart = 6;
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
Dialog.addString("What is the coat protein channel", "C1");
Dialog.show();
coatChannel = Dialog.getString();
Dialog.create("Channel Specification");
Dialog.addString("What is the second protein channel", "C2");
Dialog.show();
subChannel = Dialog.getString();
Dialog.create("Channel Specification");
//For third channel. Comment out if not needed
Dialog.addString("What is the third protein channel", "C3");
Dialog.show();
subChannel2 = Dialog.getString();

for (ii = 0; ii < movieNum; ii++) {
	//print(movieNum);
	//print(ii);
	
	//opening the movie
	showMessage("Select movie to open");
	run("Open...", "open");
	movieName = getTitle();
	selectImage(movieName);
	run("Split Channels");
	cellDirectory = dataDirectory + File.separator + "Cell" + cellNum + "_" + frameRate + "s";
	//print(cellDirectory);
	File.makeDirectory(cellDirectory);
	coatDirectory = cellDirectory + File.separator + "Ch" + "1";
	File.makeDirectory(coatDirectory);
	subDirectory = cellDirectory + File.separator + "Ch" + "2";
	File.makeDirectory(subDirectory);
	subDirectory2 = cellDirectory + File.separator + "Ch" + "3";
	File.makeDirectory(subDirectory2)
	selectImage(coatChannel + "-" + movieName);
	//for trimming. comment out line below if not using
	run("Slice Keeper", "first=" + stackStart + " last=" + stackEnd + " increment=1");
	saveAs("tiff", coatDirectory + "/" + getTitle());
	selectImage(subChannel + "-" + movieName);
	//for trimming. comment out line below if not using
	run("Slice Keeper", "first=" + stackStart + " last=" + stackEnd + " increment=1");
	saveAs("tiff", subDirectory + "/" + getTitle());
	selectImage(subChannel2 + "-" + movieName);
	//for trimming. comment out line below if not using
	run("Slice Keeper", "first=" + stackStart + " last=" + stackEnd + " increment=1");
	saveAs("tiff", subDirectory2 + "/" + getTitle());
	close("*");
	cellNum++;
	}
	