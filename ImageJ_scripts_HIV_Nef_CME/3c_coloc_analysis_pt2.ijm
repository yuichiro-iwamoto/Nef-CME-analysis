//This script is meant to be run after 3c_coloc_analysis.
refChannel = "C2-";
Channel2 = "C1-";
Channel3 = "C3-";

//Select a directory that 
masterDirectoryName = getDirectory("Choose a Directory");
masterFolderList = getFileList(masterDirectoryName);

for (i = 0; i < masterFolderList.length; i++) {
	is_cell = masterFolderList[i].contains("cell_");
	temp_cell = newArray(1);
	if (is_cell) {
		temp_cell = masterFolderList[i];
		
		if (i == 0) {
			cellDirectoryList = temp_cell;
		} else {
			cellDirectoryList = Array.concat(cellDirectoryList, temp_cell);
		}
	}	
}

run("Clear Results");
	
for (ii = 0; ii < cellDirectoryList.length; ii++) {
	
	directoryName = masterDirectoryName + cellDirectoryList[ii];
	colocDirectory = directoryName + "coloc_analysis";
	File.makeDirectory(colocDirectory);
	
	filelist = getFileList(directoryName);
	
	//Search for thresholded and average intensity projection images
	AVG_image = "";
	cell_mask = "";
	
	for (i = 0; i < filelist.length; i++) {
		is_AVG = filelist[i].contains("AVG");
		is_mask = filelist[i].contains("mask");
		if (is_AVG) {
			AVG_image = filelist[i];
		}
		if (is_mask) {
			cell_mask = filelist[i];
		}
		
	}
	
	cellID = substring(cell_mask, 5);
	
	//Calculate Manders Overlap for channels
	open(directoryName + cell_mask);
	run("Split Channels");
	imageCalculator("Multiply create", refChannel + cell_mask, Channel2 + cell_mask);
	selectWindow("Result of " + refChannel + cell_mask);
	refC2 = "refC2_" + cell_mask;
	rename(refC2);
	imageCalculator("Multiply create", refChannel + cell_mask, Channel3 + cell_mask);
	selectWindow("Result of " + refChannel + cell_mask);
	refC3 = "refC3_" + cell_mask;
	rename(refC3);
	imageCalculator("Multiply create", Channel2 + cell_mask, Channel3 + cell_mask);
	selectWindow("Result of " + Channel2 + cell_mask);
	C2C3 = "C2C3_" + cell_mask;
	rename(C2C3);
	
	//Calculate Manders Overlap for rotated ref channel and other channels
	selectWindow(refChannel + cell_mask);
	run("Duplicate...", " ");
	run("Rotate 90 Degrees Right");
	scrRefChannel = "90_C1-";
	rename(scrRefChannel + cell_mask);
	imageCalculator("Multiply create", scrRefChannel + cell_mask, refChannel + cell_mask);
	selectWindow("Result of " + scrRefChannel + cell_mask);
	scrRefRef = "scrRefRef_" + cell_mask;
	rename(scrRefRef);
	imageCalculator("Multiply create", scrRefChannel + cell_mask, Channel2 + cell_mask);
	selectWindow("Result of " + scrRefChannel + cell_mask);
	scrRefC2 = "scrRefC2_" + cell_mask;
	rename(scrRefC2);
	imageCalculator("Multiply create", scrRefChannel + cell_mask, Channel3 + cell_mask);
	selectWindow("Result of " + scrRefChannel + cell_mask);
	scrRefC3 = "scrRefC3_" + cell_mask;
	rename(scrRefC3);
	selectWindow(Channel2 + cell_mask);
	run("Duplicate...", " ");
	run("Rotate 90 Degrees Right");
	scrChannel2 = "90_C2-";
	rename(scrChannel2 + cell_mask);
	imageCalculator("Multiply create", scrChannel2 + cell_mask, Channel3 + cell_mask);
	selectWindow("Result of " + scrChannel2 + cell_mask);
	scrChannel2C3 = "scrC2C3_" + cell_mask;
	rename(scrChannel2C3);
	
	
	//Calculate areas of overlap
	selectWindow(refC2);
	run("Create Selection");
	//run("Make Inverse");
	getStatistics(area, mean);
	if (mean > 0) {
		refC2_overlap = area;
	} else {
		refC2_overlap = 0;
	}

	
	selectWindow(refC3);
	run("Create Selection");
	//run("Make Inverse");
	getStatistics(area, mean);
	if (mean > 0) {
		refC3_overlap = area;
	} else {
		refC3_overlap = 0;
	}
	
	selectWindow(C2C3);
	run("Create Selection");
	//run("Make Inverse");
	getStatistics(area, mean);
	if (mean > 0) {
		C2C3_overlap = area;
	} else {
		C2C3_overlap = 0;
	}

	selectWindow(refChannel + cell_mask);
	run("Create Selection");
	//run("Make Inverse");
	getStatistics(area, mean);
	if (mean > 0) {
		refArea = area;
	} else {
		refArea = 0;
	}

	
	selectWindow(Channel2 + cell_mask);
	run("Create Selection");
	//run("Make Inverse");
	getStatistics(area, mean);
	if (mean > 0) {
		C2Area = area;
	} else {
		C2Area = 0;
	}
	
	selectWindow(Channel3 + cell_mask);
	run("Create Selection");
	//run("Make Inverse");
	getStatistics(area, mean);
	if (mean > 0) {
		C3Area = area;
	} else {
		C3Area = 0;
	}

	selectWindow(scrRefRef);
	run("Create Selection");
	//run("Make Inverse");
	getStatistics(area, mean);
	if (mean > 0) {
		scrRefRef_overlap = area;
	} else {
		scrRefRef_overlap = 0;
	}
	
	selectWindow(scrRefC2);
	run("Create Selection");
	//run("Make Inverse");
	getStatistics(area, mean);
	if (mean > 0) {
		scrRefC2_overlap = area;
	} else {
		scrRefC2_overlap = 0;
	}
	
	selectWindow(scrRefC3);
	run("Create Selection");
	//run("Make Inverse");
	getStatistics(area, mean);
	if (mean > 0) {
		scrRefC3_overlap = area;
	} else {
		scrRefC3_overlap = 0;
	}

	selectWindow(scrChannel2C3);
	run("Create Selection");
	//run("Make Inverse");
	getStatistics(area, mean);
	if (mean > 0) {
		scrChannel2C3_overlap = area;
	} else {
		scrChannel2C3_overlap = 0;
	}
	
	//Calculate AVG intensity projection intensity for each channel
	open(directoryName + AVG_image);
	run("Split Channels");
	
	selectWindow(refChannel + cell_mask);
	run("Create Selection");
	run("Make Inverse");
	selectWindow(refChannel + AVG_image);
	run("Restore Selection");
	getStatistics(area, mean);
	refMean = mean;
	
	selectWindow(Channel2 + cell_mask);
	run("Create Selection");
	run("Make Inverse");
	selectWindow(Channel2 + AVG_image);
	run("Restore Selection");
	getStatistics(area, mean);
	C2Mean = mean;
	
	selectWindow(Channel3 + cell_mask);
	run("Create Selection");
	run("Make Inverse");
	selectWindow(Channel3 + AVG_image);
	run("Restore Selection");
	getStatistics(area, mean);
	C3Mean = mean;
	
	//output CSV file with coloc related parameters
	updateResults();
	setResult("Cell ID", ii, cellID);
	setResult("Ref Intensity", ii, refMean);
	setResult("C2 Intensity", ii, C2Mean);
	setResult("C3 Intensity", ii, C3Mean);
	setResult("Ref C2 coloc", ii, refC2_overlap/refArea);
	setResult("Ref C3 coloc", ii, refC3_overlap/refArea);
	setResult("C2 C3 coloc", ii, C2C3_overlap/C2Area);
	setResult("ScrRef Ref coloc", ii, scrRefRef_overlap/refArea);
	setResult("ScrRef C2 coloc", ii, scrRefC2_overlap/refArea);
	setResult("ScrRef C3 coloc", ii, scrRefC3_overlap/refArea);
	setResult("ScrC2 C3 coloc", ii, scrChannel2C3_overlap/C2Area);
	updateResults();
	
	saveAs("Results", colocDirectory + "/" + cellID + ".csv");
	
	//save relevant images
	selectWindow(refC2);
	saveAs("Tiff", colocDirectory + File.separator + refC2);
	selectWindow(refC3);
	saveAs("Tiff", colocDirectory + File.separator + refC3);
	selectWindow(C2C3);
	saveAs("Tiff", colocDirectory + File.separator + C2C3);
	selectWindow(scrRefRef);
	saveAs("Tiff", colocDirectory + File.separator + scrRefRef);
	selectWindow(scrRefC2);
	saveAs("Tiff", colocDirectory + File.separator + scrRefC2);
	selectWindow(scrRefC3);
	saveAs("Tiff", colocDirectory + File.separator + scrRefC3);
	selectWindow(scrChannel2C3);
	saveAs("Tiff", colocDirectory + File.separator + scrChannel2C3);
	
	close("*");
	
}

saveAs("Results", masterDirectoryName + "/" + "ResultsSummary.csv");
close("Results");