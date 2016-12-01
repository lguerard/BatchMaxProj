macro "BatchMaxProj"
{
	/* Batch maximum intensity projection of all the files in a folder.
	 *  The images need to be stacks.
	 *  They will be saved in a new folder called "MaxProj"
	 *  inside the source folder.
	 *  
	 *  Instructions:
	 *  Run the macro and select the folder where the images are.
	 *  You will then need to decide which parameters you want for the scale bar.
	 *  Once you've selected them, you will then be asked to enter them again for the batch processing.
	 *  
	 *  Publications are important for us. Publications are signs that our work generates results.
	 *  This enables us to apply for more funds to keep the centre running.
	 *  Therefore you MUST acknowledge the CCI facility when you use this macro for a publication,
	 *  a conference contribution, a grant application etc.
	 *  
	 *  Macro created by Laurent Guerard, Centre for Cellular Imaging
	 *  160621 Version 1.0
	 */


	//Select the folder where the images are
	dir = getDirectory("Choose Z-stack image folder");
	//Get all the file in the folder
	list = getFileList(dir);
	//Create the output folder
	dir2 = dir+"MaxProj"+File.separator;
	File.makeDirectory(dir2);

	//Different information for the scale bar
	colorChoice = newArray("White","Black","Grey","Blue","Red","Yellow");
	posChoice = newArray("Top Left","Top Middle","Top Right","Lower Left","Lower Middle","Lower Right");
	labels = newArray("Bold Text", "Hide Text", "Serif Font", "Overlay","Label all slices");
	defaults = newArray("False","False","False","False","False");
	
	//Open a picture for testing the parameters of the scale bar
	open(list[0]);
	waitForUser("You will now be prompted with different settings for the scale bar\nOnce you've selected the correct ones, remember them, they will be asked afterwards");
	run("Scale Bar...");
	close(list[0]);

	//Dialog for the scale bar
	//Create and show the dialog
	Dialog.create("Parameters for Scale Bar");
	Dialog.addNumber("Width in µm",10);
	Dialog.addNumber("Height in pixels",4);
	Dialog.addNumber("Font size",14);
	Dialog.addChoice("Color",colorChoice);
	Dialog.addChoice("Location",posChoice);
	Dialog.addCheckboxGroup(3,2,labels,defaults);
	Dialog.show();

	//Get all the parameters
	ScaleWidth = Dialog.getNumber();
	ScaleHeight = Dialog.getNumber();
	ScaleFont = Dialog.getNumber();
	ScaleColor = Dialog.getChoice();
	ScaleLocation = Dialog.getChoice();
	ScaleBold = Dialog.getCheckbox();
	ScaleHide = Dialog.getCheckbox();
	ScaleSerif = Dialog.getCheckbox();
	ScaleOverlay = Dialog.getCheckbox();
	ScaleStacks = Dialog.getCheckbox();

	parameters = "width=&ScaleWidth height=&ScaleHeight font=&ScaleFont color=&ScaleColor location=[&ScaleLocation]";

	if (ScaleBold)
		parameters = parameters +" bold";
	if (ScaleHide)
		parameters = parameters+" hide";
	if (ScaleSerif)
		parameters = parameters+" serif";
	if (ScaleOverlay)
		parameters = parameters+" overlay";
	if (ScaleStacks)
		parameters = parameters+ "label";
	
	setBatchMode(true);

	//Batch processing
	for(a=0;a<list.length;a++)
	{
		showProgress(a+1, list.length);
		//Check if the file is not a folder
		if(!File.isDirectory(dir+list[a]))
		{
		//Open it	
			open(list[a]);
			//waitForUser(list[a]);
			name = getTitle();
			dotIndex = lastIndexOf(name,".");
			shortTitle = substring(name, 0, dotIndex);
			//Check if the file is a stack
			if(nSlices() > 1)
			{
				run("Scale Bar...", parameters);
				//If the scale bar is an overlay, we need to flatten it to save it in the file
				if (ScaleOverlay)
				{
					if(a==0)
						run("Flatten");
				}
				
				//Then we project
				run("Z Project...", "projection=[Max Intensity]");
				path = dir2+shortTitle;
				save(path+"MaxProj.tif");
				run("Close All");
			}
		}
	}

	//End message
	showMessage("Finished !");
}