// grabavi.cpp
//
//------------------------------------------------------------------------
//
// Software written by Simon Lansbergen, initially forked from
// Basler SDK C++, Utility_GrabAvi.cpp.
//
//   Editor(s) :
//	     SL : Simon Lansbergen
//		 
//
// Program:
// Produces an Audio Video Interleave (AVI) using Basler USB 3.0 camera 
// device. 
//
// This program was exclusively written for the purpose of video 
// acquisition in the Levelt-lab/Jander acquistition setup in a Windows 7 
// X64 environment.
// 
// Can has as input arguments both recording time and recording savepath 
// and name. The order for the input arguments is first time, in seconds. 
// Separated by a space, the savepath directory is given with double \\
// between folders (e.g. c:\\software\\test).
//
//
// --> try to process data in c++ on the spot instead of Matlab,
//     using opencv libraries.
//
// --> needs cmd input avi name and recording duration
// --> maybe (create from matlab) input config file for program
// 
//	(c) 03 March 2016. SL
//
//------------------------------------------------------------------------

// Include files to use the PYLON API.
#include <pylon/PylonIncludes.h>
#include <pylon/AviCompressionOptions.h>
#include <pylon/PylonGUI.h>
#include <pylon/usb/BaslerUsbInstantCamera.h>
typedef Pylon::CBaslerUsbInstantCamera Camera_t;

// Namespace for using pylon objects.
using namespace Pylon;
using namespace GenApi;
using namespace Basler_UsbCameraParams;

// Namespace for using cout.
using namespace std;


// Defining global static variables :
// - Frame rate: used for playing the video (play back frame rate).
static const int cFramesPerSecond = 20;
// - The maximum number of images to be grabbed.  
static const uint32_t c_countOfImagesToGrab = 100;


// When this amount of image data has been written the grabbing is stopped.
static const size_t c_maxImageDataBytesThreshold = 500 * 1024 * 1024;





/*
// argc gives the number of inputs from the cmd to main. without
// any input the default is 1, which is the name of the program
// executed.
//
// argv[] is an array containing the input from the cmd, argc can
// be used for the index.
*/

int main(int argc, char* argv[]) {


	// The exit code of the sample application.
	int exitCode = 0;

	// *** changed -> added
	//

	// state input argument variables

	uint32_t time, frames;
	const char* save_path = "d:\\software\\temp\\test.avi";

	// set input arguments
	cout << endl << "Hi" << endl;

	cout << "Program has " << (argc - 1) << " extra input arguments:" << endl;
	for (int i = 1; i < argc; ++i) cout << argv[i] << endl;

	if (argc <= 1)	// actual count (starts at 1)
	{
		cout << endl << " *** To few input arguments *** " << endl;
		return 0;
	}

	else if (argc == 2)
	{
		if (isalpha(*argv[1])) {	// index starts at 0
			puts("Not a number: Wrong input argument?");
		}
		else if (isdigit(*argv[1])) {
			time = atoi(argv[1]);				// atoi = Ascii To Int -> stops converting at the first non int
			frames = time * cFramesPerSecond;	// amount of frames to grab
			save_path = "d:\\software\\temp\\test.avi";
			//cout << save_path << endl;
			cout << endl << "Recording time (sec(s))   : " << time << endl;
			cout << "Total frames recorded     : " << frames << endl;
			cout << "No savepath and name entered, default savepath and name : d:\\software\\test.avi" << endl;

		}
		else {
			puts("Not a number: Wrong input argument?");
		}
	}
	else if (argc == 3)
	{


		if (isalpha(*argv[1]) || isdigit(*argv[2])) {
			puts("Wrong input argument?");
		}

		else if (isdigit(*argv[1]) || isalpha(*argv[2])) {
			time = atoi(argv[1]);				// atoi = Ascii To Int -> stops converting at the first non int
			frames = time * cFramesPerSecond;	// amount of frames to grab
			save_path = argv[2];

			cout << endl << "Recording time (sec(s))   : " << time << endl;
			cout << "Total frames recorded     : " << frames << endl;
			cout << "Savepath and name entered : " << save_path << endl;

		}
	
			else {
			puts("Not a number: Wrong input argument?");
			}

	}
		
	else
	{cout << endl << " *** To many input arguments *** " << endl;
	return 0;}
	
	

	// Before using any pylon methods, the pylon runtime must be initialized. 
	PylonInitialize();
	
	try
	{
		// Create an AVI writer object.
		CAviWriter aviWriter;

		// The AVI writer supports the output formats PixelType_Mono8,
		// PixelType_BGR8packed, and PixelType_BGRA8packed.
		EPixelType aviPixelType = PixelType_Mono8;
		
		

		// *** changed
		//
		// Create an dedicated USB instant camera object with the camera device found first.
		Camera_t camera(CTlFactory::GetInstance().CreateFirstDevice());

		// Print the model name of the camera.
		cout << "Using device " << camera.GetDeviceInfo().GetModelName() << endl;

		// Open the camera.
		camera.Open();


		// *** changed -> added
		//
		// Enable the acquisition frame rate parameter and set the frame rate. (Enabling
		// the acquisition frame rate parameter allows the camera to control the frame
		// rate internally.)
		camera.AcquisitionFrameRateEnable.SetValue(true);
		camera.AcquisitionFrameRate.SetValue(20.0);
		
		
		// Get the required camera settings.
		CIntegerPtr width(camera.GetNodeMap().GetNode("Width"));
		CIntegerPtr height(camera.GetNodeMap().GetNode("Height"));
		CEnumerationPtr pixelFormat(camera.GetNodeMap().GetNode("PixelFormat"));
		if (pixelFormat.IsValid())
		{
			// If the camera produces Mono8 images use Mono8 for the AVI file.
			if (pixelFormat->ToString() == "Mono8")
			{
				aviPixelType = PixelType_Mono8;
			}
		}
		
		// *** changed -> added
		//
		// Optionally set up compression options.
		SAviCompressionOptions* pCompressionOptions = NULL;
		// Uncomment the two code lines below to enable AVI compression.
		// A dialog will be shown for selecting the codec.
		SAviCompressionOptions compressionOptions("MSVC", false);
		// SAviCompressionOptions compressionOptions("MSVC", true);   // works, high compression
		// SAviCompressionOptions compressionOptions("MRLE", false);   // works, medium, nut noisy compression
		// SAviCompressionOptions compressionOptions("MRLE", false);   // expansion so it seems?
		
		pCompressionOptions = &compressionOptions;

		// *** changed -> added
		//
		// compression option (quality percentage 100% -> 10000)
		compressionOptions.compressionOptions.dwQuality = 7500;

		// Open the AVI writer.
		
		aviWriter.Open(
			save_path,
			cFramesPerSecond,
			aviPixelType,
			(uint32_t)width->GetValue(),
			(uint32_t)height->GetValue(),
			ImageOrientation_BottomUp, // Some compression codecs will not work with top down oriented images.
			pCompressionOptions);
		/*
		aviWriter.Open(
			"_TestAvi.avi",
			cFramesPerSecond,
			aviPixelType,
			(uint32_t)width->GetValue(),
			(uint32_t)height->GetValue(),
			ImageOrientation_BottomUp, // Some compression codecs will not work with top down oriented images.
			pCompressionOptions);
		*/

		
		// Start the grabbing of c_countOfImagesToGrab images.
		// The camera device is parameterized with a default configuration which
		// sets up free running continuous acquisition.
		//camera.StartGrabbing(c_countOfImagesToGrab, GrabStrategy_LatestImages);
		
		camera.StartGrabbing(frames, GrabStrategy_LatestImages);


		cout << "Please wait. Images are grabbed." << endl;

		// This smart pointer will receive the grab result data.
		CGrabResultPtr ptrGrabResult;

		// Camera.StopGrabbing() is called automatically by the RetrieveResult() method
		// when c_countOfImagesToGrab images have been retrieved.
		while (camera.IsGrabbing())
		{
			// Wait for an image and then retrieve it. A timeout of 5000 ms is used.
			camera.RetrieveResult(5000, ptrGrabResult, TimeoutHandling_ThrowException);

			// Display the image. Remove the following line of code to maximize frame rate.
			// Pylon::DisplayImage(1, ptrGrabResult);

			// If required, the grabbed image is converted to the correct format and is then added to the AVI file.
			// The orientation of the image taken by the camera is top down.
			// The bottom up orientation is specified to apply when opening the Avi Writer. That is why the image is
			// always converted before it is added to the AVI file.
			// To maximize frame rate try to avoid image conversion (see the CanAddWithoutConversion() method).
			aviWriter.Add( ptrGrabResult);

			// If images are skipped, writing AVI frames takes too much processing time.
			//std::cout << "Images Skipped = " << ptrGrabResult->GetNumberOfSkippedImages() << boolalpha
			// 	<< "; Image has been converted = " << !aviWriter.CanAddWithoutConversion(ptrGrabResult)
			// 	<< std::endl;
			
			int counter = 0;
			
			if (counter == (frames / 2)) { 
				cout << "Acquiring Data ... 50%" << endl;
			}

			counter++;

			/*
			
						
			// Check whether the image data size limit has been reached to avoid the AVI File to get too large.
			// The size returned by GetImageDataBytesWritten() does not include the sizes of the AVI file header and AVI file index.
			// See the documentation for GetImageDataBytesWritten() for more information.
			if (c_maxImageDataBytesThreshold < aviWriter.GetImageDataBytesWritten())
			{
				std::cout << "The image data size limit has been reached." << endl;
				break;
			}





		*/
		}
	

		// End note and info on acquired data
		cout << endl << "Done Acquiring & Saving Data ..." << endl;
		cout << "Acquired : " << frames / cFramesPerSecond << " seconds of data." << endl;
		cout << endl;
}
	
	
	
	
	
	
	catch (const GenericException &e)
	{
		// Error handling.
		cerr << "An exception occurred." << endl
			<< e.GetDescription() << endl;
		exitCode = 1;
	}

	

	// Comment the following two lines to disable waiting on exit.
	//cerr << endl << "Press Enter to exit." << endl;
	//while (cin.get() != '\n');

	// Releases all pylon resources. 
	PylonTerminate();
	
	return exitCode;
}
