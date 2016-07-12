//grabpupilsize_main.cpp (compile x64)
//-----------------------------------------------------------------------//
//																		 
// Program:
// This program was exclusively written for the purpose of real-time
// pupil analysis using a Basler usb 3.0 CCD camera and opencv in a 
// Windows 7 X64 environment. The executable generates both a numerical 
// as well as a video output.
//
// This executable is used to record pupil size and position measurements 
// and is optimized to function in the InVivo-Toolbox. 
// 
// The executable produces a MPEG compressed Audio Video Interleave (AVI) 
// video container. For more compression options google FOURCC.
//
//------------------------------------------------------------------------//
// 
// The program makes use of a configuration file and a settings file in	
// order to run properly. Make sure these are in the root of the 
// executable.
//		- config_grabpupilsize.cfg
//		- default.ini
//
//------------------------------------------------------------------------//
//
// Software written by Simon Lansbergen, 
// 
//	(c) June 2016. SL
//
//	BETA 30-5-2016:
//		- pre-threshold step
//		- crosshair functionality
//		- changed numerical output to area
//		- calibration
//
//
//------------------------------------------------------------------------//


// Include files to use the PYLON API.
#include <pylon/PylonIncludes.h>
#ifdef PYLON_WIN_BUILD
#    include <pylon/PylonGUI.h>
#endif
#include <pylon/usb/BaslerUsbInstantCamera.h>
// Include files to use openCV.
#include "opencv2/highgui/highgui.hpp"
#include "opencv2/imgproc/imgproc.hpp"
#include "opencv2/imgcodecs.hpp"
#include "opencv2/core/core.hpp"
// include file to read configuration file
#include <read_config_file.h>
// Additional include files.
#include <fstream>
#include <iostream>


using namespace Pylon; // Namespace for using pylon objects.
using namespace cv;    // Namespace for using openCV objects.
using namespace std;   // Namespace for using cout.


int main(int argc, char* argv[])
{
	//------------------------//
	//						  //
	//------------------------//
	
	// The exit code of the sample application.
	int exitCode = 0;
		
	system("CLS");
	
	//------------------------//
	// Configuration variable //
	//------------------------//

	const char* open_config = "config_grabpupilsize.cfg";

	//-------------------//
	// Defualt variables //
	//-------------------//

	// default hard coded settings if Config.cfg file is not present or in-complete/commented
	bool show_screen_info = 1;
	bool save_video = 0;
	bool save_radius = 0;
	bool save_original = 0;
	
	// BETA 3-6-2016
	double threshold_ = 20;
	int thress = 20; // <- delete one and rename both to threshold
	
	int thres_mode = 0;
	ThresholdTypes thres_type = THRESH_BINARY;
	const char* thres_name = "THRESH_BINARY";
	int cFramesPerSecond = 20;
	const char* save_path = "c:/output.avi";
	const char* save_path_num = "c:/output.txt";
	const char* save_path_ori = "c:/original.avi";
	string sav_pat = "c:/output.avi";
	string sav_pat_num = "c:/output.txt";;
	string sav_pat_ori = "c:/original.avi";
	Size ROI_dimensions = Size(150, 150);
	bool ROI_start_auto = 1;
	Size ROI_start;
	int ROI_start_x;
	int ROI_start_y;
	int width_SE = 3;
	int heigth_SE = 3;
	Size SE_morph = Size(width_SE, heigth_SE);
	int heigth_blur = 3;
	int width_blur = 3;
	Size blur_dimensions = Size(width_SE, heigth_SE);
	int itterations_close = 3;
	double pupil_aspect_ratio = 1.5;
	int pupil_min = 15;
	int pupil_max = 55;
	bool original_image = 1;
	bool blurred_image = 0;
	bool thresholded_image = 0;
	bool closed_image = 0;
	bool end_result_image = 1;
	bool show_ost = 0;
	double size_text = 0.5;
	uint32_t time, frames;
	
	// BETA 31-5-2016, 3-6-2016
	int pre_threshold = 100;
	bool pre_threshold_image = 0;

	// BETA 31-5-2016
	bool crosshair = 0;
	double pi = 3.14159;

	// BETA 1-6-2016
	bool calibrate = 0;
	int cali_x_a = 280;
	int cali_x_b = 350;
	int cali_y_a = 100;
	int cali_y_b = 200;
	

	//---------------------//
	// Remaining variables //
	//---------------------//

	// video writer output
	VideoWriter roi_end_result, original;

	// images for processing
	// Mat eye;
	Mat thres;
	Mat roi_eye_rgb;
	Mat close;
	Mat blur;
	Mat roi_eye;
	// Mat frame;
	Mat pre_thres;
	Mat frame;
	Mat eye;
	
	// BETA 31-5-2016
	Mat aim;

	// BETA 1-6-2015 - callibration
	Mat cali;

	// variables for numerical output
	ofstream output_end_result;
	ostringstream strs, ost1, ost2, ost3;
	string radius, size_roi, frame_rate, output_file;


	//-------------------------//
	// read configuration file //
	//-------------------------//

	// get config.cfg from cmd-line if entered correctly
	if (argc == 5)
	{
		if (isalpha(*argv[1]) || isdigit(*argv[2]) || isdigit(*argv[3]) || isdigit(*argv[4])) {
			puts("Wrong input argument for [time] or [save num] or [save vid] or [config.cfg] ?");
		}

		else if (isdigit(*argv[1]) && isalpha(*argv[2]) && isalpha(*argv[3]) && isalpha(*argv[4])) {
			// get entered config.cfg file and path
			open_config = argv[4];	

			cout << endl << endl << "*** Reading configuration file : " << open_config << " ***";

		}
		else {
			puts("Not a number: Wrong input argument for [time] or [save num] or [save vid] or [config.cfg] ?");
			return 1;
		}
	
	}
	else {
		cout << endl << endl << "*** Reading system configuration file : " << open_config << " ***";
	}

	// read config file
	ifstream ifile(open_config);
	if (ifile) { // The file exists, and is open for input

		ConfigFile cfg(open_config);

		// check for existance and replace defualt value
		if (cfg.keyExists("show_screen_info") == true) { // get screen info on/off
			show_screen_info = cfg.getValueOfKey<bool>("show_screen_info");
		}
		if (cfg.keyExists("save_video") == true) { // get video save_file info
			save_video = cfg.getValueOfKey<bool>("save_video");
		}
		if (cfg.keyExists("save_radius") == true) { // get numerical save_file info
			save_radius = cfg.getValueOfKey<bool>("save_radius");
		}
		if (cfg.keyExists("save_original") == true) { // get save original stream info
			save_original = cfg.getValueOfKey<bool>("save_original");
		}
		
		// BETA 6-3-2016, Remove when done
		
		/*
		if (cfg.keyExists("threshold") == true) { // get threshold value
			threshold_ = cfg.getValueOfKey<double>("threshold");
		}
		*/

		if (cfg.keyExists("frames_per_sec") == true) { // get frames per second
			cFramesPerSecond = cfg.getValueOfKey<int>("frames_per_sec");
		}
		if (cfg.keyExists("save_path_vid") == true) { // get video output file name & path
			sav_pat = cfg.getValueOfKey<string>("save_path_vid");
			save_path = sav_pat.c_str();
		}
		if (cfg.keyExists("save_path_num") == true) { // get numerical output file name & path
			sav_pat_num = cfg.getValueOfKey<string>("save_path_num");
			save_path_num = sav_pat_num.c_str();
		}
		if (cfg.keyExists("save_path_ori") == true) { // get original stream file name & path
			sav_pat_ori = cfg.getValueOfKey<string>("save_path_ori");
			save_path_ori = sav_pat_ori.c_str();
		}
		if (cfg.keyExists("height_roi") == true && cfg.keyExists("width_roi") == true) { // get heigth & width ROI
			int ROI_heigth = cfg.getValueOfKey<int>("height_roi");
			int ROI_width = cfg.getValueOfKey<int>("width_roi");
			ROI_dimensions = Size(ROI_width, ROI_heigth);
		}
		if (cfg.keyExists("ROI_start_x") == true && cfg.keyExists("ROI_start_y") == true) { // get x and y starting point for ROI
			ROI_start_y = cfg.getValueOfKey<int>("ROI_start_y");
			ROI_start_x = cfg.getValueOfKey<int>("ROI_start_x");
			ROI_start = Size(ROI_start_x, ROI_start_y);
			ROI_start_auto = 0;
		}
		if (cfg.keyExists("width_SE") == true && cfg.keyExists("heigth_SE") == true) { // get dimensions SE
			width_SE = cfg.getValueOfKey<int>("width_SE");
			heigth_SE = cfg.getValueOfKey<int>("heigth_SE");
			SE_morph = Size(width_SE, heigth_SE);
		}
		if (cfg.keyExists("heigth_blur") == true && cfg.keyExists("width_blur") == true) { // get dimensions Gaussian blur
			heigth_blur = cfg.getValueOfKey<int>("heigth_blur");
			width_blur = cfg.getValueOfKey<int>("width_blur");
			blur_dimensions = Size(width_blur, heigth_blur);
		}
		if (cfg.keyExists("thres_mode") == true) { // get threshold method
			thres_mode = cfg.getValueOfKey<int>("thres_mode");
			switch (thres_mode) {
			case 0:
				thres_type = THRESH_BINARY;
				thres_name = "THRESH_BINARY";
				break;
			case 1:
				thres_type = THRESH_BINARY_INV;
				thres_name = "THRESH_BINARY_INV";
				break;
			case 2:
				thres_type = THRESH_TRUNC;
				thres_name = "THRESH_TRUNC";
				break;
			case 3:
				thres_type = THRESH_TOZERO;
				thres_name = "THRESH_TOZERO";
				break;
			case 4:
				thres_type = THRESH_TOZERO_INV;
				thres_name = "THRESH_TOZERO_INV";
				break;
			default:
				thres_type = THRESH_BINARY;
				thres_name = "THRESH_BINARY";
			}
		}
		if (cfg.keyExists("itterations_close") == true) { // get number of itterations for closing operation
			itterations_close = cfg.getValueOfKey<int>("itterations_close");
		}
		if (cfg.keyExists("pupil_aspect_ratio") == true) { // get aspect ratio threshold accepted ellipse
			pupil_aspect_ratio = cfg.getValueOfKey<double>("pupil_aspect_ratio");
		}
		if (cfg.keyExists("pupil_min") == true) {  // get minimal accepted pupil radius
			pupil_min = cfg.getValueOfKey<int>("pupil_min");
		}
		if (cfg.keyExists("pupil_max") == true) {  // get maximal accepted pupil radius
			pupil_max = cfg.getValueOfKey<int>("pupil_max");
		}
		if (cfg.keyExists("original_image") == true) { // info: stream original stream to display
			original_image = cfg.getValueOfKey<bool>("original_image");
		}
		if (cfg.keyExists("blurred_image") == true) { // info: stream blurred stream to display
			blurred_image = cfg.getValueOfKey<bool>("blurred_image");
		}
		if (cfg.keyExists("thresholded_image") == true) { // info: thresholded_image blurred stream to display
			thresholded_image = cfg.getValueOfKey<bool>("thresholded_image");
		}
		if (cfg.keyExists("closed_image") == true) { // info: closed_image blurred stream to display
			closed_image = cfg.getValueOfKey<bool>("closed_image");
		}
		if (cfg.keyExists("end_result_image") == true) { // info: end_result_image blurred stream to display
			end_result_image = cfg.getValueOfKey<bool>("end_result_image");
		}
		if(cfg.keyExists("show_ost") == true) {	// put text on screen info
			show_ost = cfg.getValueOfKey<bool>("show_ost");
		}
		if (cfg.keyExists("size_text") == true) { // get text size for on screen text
			size_text = cfg.getValueOfKey<double>("size_text");
		}
		

		if (cfg.keyExists("threshold") == true) { // get threshold value
			thress = cfg.getValueOfKey<int>("threshold");
		}


		// BETA 31-5-2016, 3-6-2016
		if (cfg.keyExists("pre_threshold") == true) { // get pre threshold value
			pre_threshold = cfg.getValueOfKey<int>("pre_threshold");
		}
		if (cfg.keyExists("pre_threshold_image") == true) { // info: pre_threshold_image stream to display
			pre_threshold_image = cfg.getValueOfKey<bool>("pre_threshold_image");
		}

		// Beta 31-5-2016
		if (cfg.keyExists("crosshair") == true) { // 
			crosshair = cfg.getValueOfKey<bool>("crosshair");
		}

		// Beta 1-6-2016
		if (cfg.keyExists("calibrate") == true) { // 
			calibrate = cfg.getValueOfKey<bool>("calibrate");
		}
		
		if (cfg.keyExists("cali_x_a") == true && cfg.keyExists("cali_x_b") == true &&
			cfg.keyExists("cali_y_a") == true && cfg.keyExists("cali_y_b") == true) { // 
			cali_x_a = cfg.getValueOfKey<int>("cali_x_a");
			cali_x_b = cfg.getValueOfKey<int>("cali_x_b");
			cali_y_a = cfg.getValueOfKey<int>("cali_y_a");
			cali_y_b = cfg.getValueOfKey<int>("cali_y_b");
		}
		

		cout << endl << endl << " *** Configuration file loaded ***" << endl;

	}
	else {
		cout << endl << endl << " *** No configuration file found ***" << endl;
		cout << " *** Default, internal parameters loaded ***" << endl;
	}
	
		
	//------------------------//
	// Handle input arguments //
	//------------------------//
		
	cout << endl << endl << "Program has " << (argc - 1) << " extra input arguments:" << endl;
	for (int i = 1; i < argc; ++i) cout << argv[i] << endl;


	// input: none
	if (argc <= 1)	// actual count (starts at 1)
	{
		// disable saving both numerical as well as video output.
		save_video = false;
		//save_video = false;
		save_radius = false;
		// amount of frames to grab
		frames = 60 * cFramesPerSecond;	
		cout << endl << endl << " *** Calibration mode *** " << endl << endl;
		cout << " - No recording of video or numerical output" << endl;
		cout << " - 30 seconds of video stream" << endl << endl;
		cout << " - Hit [ESC] in video window to quit the program" << endl;
	}
	// input: [time]
	else if (argc == 2)
	{
		if (isalpha(*argv[1])) {	// index starts at 0
			puts("Not a number: Wrong input argument for [time] ?");
		}
		else if (isdigit(*argv[1])) {
			// atoi = Ascii To Int -> stops converting at the first non int
			time = atoi(argv[1]);				
			// amount of frames to grab
			frames = time * cFramesPerSecond;	
			cout << endl << "Recording time (sec(s))                      : " << time << endl;
			cout << "Total frames recorded                        : " << frames << endl;
			cout << "No additional savepath and name entered for numeric output" << endl;
			cout << "No additional savepath and name entered for video output." << endl;

		}
		else {
			puts("Not a number: Wrong input argument for [time] ?");
			return 1;
		}
	}
	// input: [time] [save num]
	else if (argc == 3)
	{
		if (isalpha(*argv[1]) || isdigit(*argv[2])) {	// index starts at 0
			puts("Not a number: Wrong input argument for [time] or [save num] ?");
		}
		else if (isdigit(*argv[1]) && isalpha(*argv[2])) {
			// atoi = Ascii To Int -> stops converting at the first non int
			time = atoi(argv[1]);
			// amount of frames to grab
			frames = time * cFramesPerSecond;
			// get entered save path and name for numerical output
			save_path_num = argv[2];
			
			cout << endl << "Recording time (sec(s))                      : " << time << endl;
			cout << "Total frames recorded                        : " << frames << endl;
			cout << "Entered additional savepath and name for video output : " << save_path_num << endl;
			cout << "No additional savepath and name entered for video output." << endl;

		}

		else {
			puts("Not a number: Wrong input argument for [time] or [save num] ?");
			return 1;
		}
	}
	// input: [time] [save num] [save vid]
	else if (argc == 4)
	{
		
		// atoi = Ascii To Int -> stops converting at the first non int
		time = atoi(argv[1]);
		// amount of frames to grab
		frames = time * cFramesPerSecond;
		// get entered save path and name for numerical output
		save_path_num = argv[2];
		// get entered save path and name for video output
		save_path = argv[3];

		cout << endl << "Recording time (sec(s))                      : " << time << endl;
		cout << "Total frames recorded                        : " << frames << endl;
		cout << "Entered additional savepath and name for video output : " << save_path_num << endl;
		cout << "Entered additional savepath and name for numerical output : " << save_path << endl;
		
		/*
		
		if (isalpha(*argv[1]) || isdigit(*argv[2]) || isdigit(*argv[3])) {
			puts("Wrong input argument for [time] or [save num] or [save vid] ?");
		}

		else if (isdigit(*argv[1]) && isalpha(*argv[2]) && isalpha(*argv[3])) {
			// atoi = Ascii To Int -> stops converting at the first non int
			time = atoi(argv[1]);
			// amount of frames to grab
			frames = time * cFramesPerSecond;
			// get entered save path and name for numerical output
			save_path_num = argv[2];
			// get entered save path and name for video output
			save_path = argv[3];

			cout << endl << "Recording time (sec(s))                      : " << time << endl;
			cout << "Total frames recorded                        : " << frames << endl;
			cout << "Entered additional savepath and name for video output : " << save_path_num << endl;
			cout << "Entered additional savepath and name for numerical output : " << save_path << endl;

		}

		else {
			puts("Not a number: Wrong input argument for [time] or [save num] or [save vid] ?");
			return 1;
		}
		*/

	}
	// input: [time] [save num] [save vid] [config.cfg]
	else if (argc == 5){

		if (isalpha(*argv[1]) || isdigit(*argv[2]) || isdigit(*argv[3]) || isdigit(*argv[4])) {
			puts("Wrong input argument for [time] or [save num] or [save vid] or [config.cfg] ?");
		}

		else if (isdigit(*argv[1]) && isalpha(*argv[2]) && isalpha(*argv[3]) && isalpha(*argv[4])) {
			// atoi = Ascii To Int -> stops converting at the first non int
			time = atoi(argv[1]);
			// amount of frames to grab
			frames = time * cFramesPerSecond;
			// get entered save path and name for numerical output
			save_path_num = argv[2];
			// get entered save path and name for video output
			save_path = argv[3];
			
			cout << endl << "Recording time (sec(s))                      : " << time << endl;
			cout << "Total frames recorded                        : " << frames << endl;
			cout << "Entered additional savepath and name for video output : " << save_path_num << endl;
			cout << "Entered additional savepath and name for numerical output : " << save_path << endl;

		}

		else {
			puts("Not a number: Wrong input argument for [time] or [save num] or [save vid] ?");
			return 1;
		}

	}
	// return 1 (exit)
	else
	{
		cout << endl << " *** To many input arguments *** " << endl;
		return 1;
	}


	

	//-----------------------//
	// Show loaded variables //
	//-----------------------//

	if (show_screen_info == true) {

		cout << endl << endl;
		cout << "*------------------------------------------------------*" << endl;
		cout << "*****               Program Parameters             *****" << endl;
		cout << "*------------------------------------------------------*" << endl;
		cout << "*" << endl;
		
		// BETA 31-5-2016
		cout << "* Show Crosshair to aim camera        : " << crosshair << endl;

		cout << "* Save video output                   : " << save_video << endl;
		cout << "* Save original stream                : " << save_original << endl;
		cout << "* Save radius numerical output        : " << save_radius << endl;
		cout << "* Save path video output              : " << save_path << endl;
		cout << "* Save path original stream           : " << save_path_ori << endl;
		cout << "* Save path numerical output          : " << save_path_num << endl;
		cout << endl;
		cout << "* Frames per second                   : " << cFramesPerSecond << endl;
		cout << "* Heigth and width ROI                : " << ROI_dimensions << endl;
		if (ROI_start_auto == false) {
			cout << "* Anchor coordinate [X,Y] ROI \n  manually set                        : " << ROI_start << endl;
		}
		else { cout << "* Anchor coordinate [X,Y] ROI set automatically" << endl; }
		cout << endl;
		cout << "* Value of threshold                  : " << thress << endl;
		cout << "* Threshold mode                      : (" << thres_mode << ") " << thres_name << endl;
		cout << "* pre-threshold value                 : " << pre_threshold << endl;
		cout << "* Size Gaussian blur filter           : " << blur_dimensions << endl;
		cout << "* Size structuring element \n  for morphological closing           : " << SE_morph << endl;
		cout << "* Total itterations closing operation : " << itterations_close << endl;
		cout << "* Threshold aspect ratio ellipse      : " << pupil_aspect_ratio << endl;
		cout << "* Minimum radius accepted ellipse     : " << pupil_min << endl;
		cout << "* Maximum radius accepted ellipse     : " << pupil_max << endl;
		cout << endl;
		cout << "* Show original stream on display     : " << original_image << endl;
		cout << "* Show blurred stream on display      : " << blurred_image << endl;
		cout << "* Show pre-threshold stream on display: " << pre_threshold_image << endl;
		cout << "* Show thresholded stream on display  : " << thresholded_image << endl;
		cout << "* Show morph closed stream on display : " << closed_image << endl;
		cout << "* Show end result stream on display   : " << end_result_image << endl;
		cout << endl;
		cout << "* Show text on end result stream      : " << show_ost << endl;
		cout << "* Size text on screen                 : " << size_text << endl;
		cout << "*" << endl;
		cout << "*------------------------------------------------------*" << endl;
		cout << "*******     Program by S.E Lansbergen, 2016     ******** " << endl;
		cout << "*------------------------------------------------------*" << endl;
		
	}
		


	// set variables for on screen text output
	if (show_ost == true) {
		// text with save path & name
		ost3 << save_path;
		output_file = ost3.str();
	}
	
	// BETA 31-5-2016
	if (crosshair == true) {
	// text for ROI size
	ost1 << "ROI size: " << ROI_dimensions.width << "x" << ROI_dimensions.height;
	size_roi = ost1.str();
	}

	//--------------------------------//
	// Video acquisition and analysis //
	//--------------------------------//
	
	// Before using any pylon methods, the pylon runtime must be initialized. 
	PylonInitialize();
		
	try
	{
		// Create an instant camera object with the camera device found first.
		//CInstantCamera camera(CTlFactory::GetInstance().CreateFirstDevice());

		CBaslerUsbInstantCamera camera(CTlFactory::GetInstance().CreateFirstDevice());

		// Print the model name of the camera.
		cout << endl << endl << "Connected Basler USB 3.0 device, type : " << camera.GetDeviceInfo().GetModelName() << endl;
				
		// open camera object to parse frame# etc.
		camera.Open();

		// Enable the acquisition frame rate parameter and set the frame rate.
		camera.AcquisitionFrameRateEnable.SetValue(true);
		camera.AcquisitionFrameRate.SetValue(cFramesPerSecond);

		// Get native width and height from connected camera
		GenApi::CIntegerPtr width(camera.GetNodeMap().GetNode("Width"));
		GenApi::CIntegerPtr height(camera.GetNodeMap().GetNode("Height"));

		// The parameter MaxNumBuffer can be used to control the count of buffers
		// allocated for grabbing. The default value of this parameter is 10.
		camera.MaxNumBuffer = 5;

		// Start the grabbing of c_countOfImagesToGrab images.
		// The camera device is parameterized with a default configuration which
		// sets up free-running continuous acquisition.
		camera.StartGrabbing(frames);

		// convers pylon video stream into CPylonImage object
		// which will be used to construct Mat objects
		CPylonImage image;
		CImageFormatConverter fc;
		// define pixel output format (to match algorithm optimalization).
		fc.OutputPixelFormat = PixelType_Mono8;

		// This smart pointer will receive the grab result data. (Pylon).
		CGrabResultPtr ptrGrabResult;

		// create Mat image template
		Mat cv_img(width->GetValue(), height->GetValue(), CV_8UC3); 
		
		// set contours variable
		vector<vector<Point> > contours;

		// automatically calculate start point of ROI
		if (ROI_start_auto == true) {
			Size size(width->GetValue(), height->GetValue());
			ROI_start_x = (size.width / 2) - (ROI_dimensions.width / 2);
			ROI_start_y = (size.height / 2) - (ROI_dimensions.height / 2);
		}
		
		// set ROI
		Rect roi(ROI_start_x, ROI_start_y, ROI_dimensions.width, ROI_dimensions.height);

		// set Structuring Element
		Mat SE = getStructuringElement(MORPH_ELLIPSE, SE_morph, Point(-1, -1));

				
		//--------------------------------//
		// Open avi and txt output stream //
		//--------------------------------//
		
		// open video writer object: End Result
		if (save_video == true) {
		
			roi_end_result.open(save_path, CV_FOURCC('M', 'P', 'E', 'G'), cFramesPerSecond, ROI_dimensions, true);
								
			//if the VideoWriter file is not initialized successfully, exit the program.
			if (!roi_end_result.isOpened())
			{
				cout << "ERROR: Failed to write the video" << endl;
				return -1;
			}
		}

		// open video writer object: Original
		if (save_original == true) {
			cout << Size(width->GetValue(), height->GetValue()) << endl;
			original.open(save_path_ori, CV_FOURCC('M', 'P', 'E', 'G'), cFramesPerSecond, Size(width->GetValue(), height->GetValue()), true);

			//if the VideoWriter file is not initialized successfully, exit the program.
			if (!original.isOpened())
			{
				cout << "ERROR: Failed to write the video" << endl;
				return -1;
			}
		}

		// open outstream to write end result (radius)
		if (save_radius == true) {
			output_end_result.open(save_path_num);
		}
		

		// BETA 31-5-2016
		Size size_cam(width->GetValue(), height->GetValue());
		
		// BETA 1-6-2016
		Point calibrate_stripe1a(cali_x_a, cali_y_a);
		Point calibrate_stripe1b(cali_x_a, cali_y_b);
		Point calibrate_stripe2a(cali_x_b, cali_y_a);
		Point calibrate_stripe2b(cali_x_b, cali_y_b);


		//---------------------//
		// Main Algorithm Loop //
		//---------------------//

		// initiate main loop with algorithm
		while (camera.IsGrabbing())
		{
			// Wait for an image and then retrieve it. A timeout of 5000 ms is used.
			camera.RetrieveResult(5000, ptrGrabResult, TimeoutHandling_ThrowException);

			// Image grabbed successfully?
			if (ptrGrabResult->GrabSucceeded())
			{

				// Step 1
				//
				// convert to Mat - openCV format for analysis
				fc.Convert(image, ptrGrabResult);
				cv_img = Mat(ptrGrabResult->GetHeight(), ptrGrabResult->GetWidth(), CV_8U, (uint8_t*)image.GetBuffer());

				// Step 1b
				//
				// BETA 31-5-2016
				if (crosshair == true) {
					cvtColor(cv_img, aim, CV_GRAY2RGB);
					line(aim, Point((size_cam.width / 2 - 25), size_cam.height / 2), Point((size_cam.width / 2 + 25), size_cam.height / 2), Scalar(0, 255, 0), 2, 8);
					line(aim, Point(size_cam.width / 2, (size_cam.height / 2 - 25)), Point(size_cam.width / 2, (size_cam.height / 2 + 25)), Scalar(0, 255, 0), 2, 8);
					rectangle(aim, roi, Scalar(0, 255, 0), 2, 8);
					putText(aim, size_roi, cvPoint(30, 20),
						FONT_HERSHEY_COMPLEX_SMALL, (0.8), cvScalar(0, 255, 0), 1, CV_AA);
					imshow("Crosshair", aim);
				}

				// Step 1c
				//
				// BETA 1-6-2016  -> extra calibration step
				if (calibrate == true) {
					cvtColor(cv_img, cali, CV_GRAY2RGB);
					line(cali, calibrate_stripe1a, calibrate_stripe1b, Scalar(255, 0, 0), 4, 8);
					line(cali, calibrate_stripe2a, calibrate_stripe2b, Scalar(255, 0, 0), 4, 8);
					putText(cali, "Calibrate", cvPoint(30, 20),
						FONT_HERSHEY_COMPLEX_SMALL, (0.8), cvScalar(255, 0, 0), 1, CV_AA);
					imshow("calibrate", cali);
				}

				// Step 2
				//
				// take ROI from eye original
				eye = cv_img;
				roi_eye = eye(roi);
				// make RGB copy of ROI for end result
				cvtColor(roi_eye, roi_eye_rgb, CV_GRAY2RGB);
				if (original_image == true) { imshow("original", eye); }

				// Step 3
				//
				// apply Gaussian blur to ROI
				GaussianBlur(roi_eye, blur, blur_dimensions, 0, 0, BORDER_DEFAULT);
				if (blurred_image == true) { imshow("Gaussian blur", blur); }

				// Step 4 - BETA 30-5-2016
				//
				// Convert to binary image by pre-thresholding it
				threshold(blur, pre_thres, pre_threshold, 255, THRESH_TOZERO_INV);
				if (pre_threshold_image == true) { imshow("Pre-thresholded", pre_thres); 
				createTrackbar("Pre Threshold:", "Pre-thresholded", &pre_threshold, 255);
				}
				
				// Step 5
				//
				// Convert to binary image by thresholding it
				//threshold(pre_thres, thres, threshold_, 255, thres_type);
				threshold(pre_thres, thres, thress, 255, thres_type);
				if (thresholded_image == true) { imshow("Thresholded", thres); 
				createTrackbar(" Threshold:", "Thresholded", &thress , 255);
				}

				// Step 6
				//
				// Morphological closing (erosion and dilation)
				morphologyEx(thres, close, MORPH_CLOSE, SE, Point(-1, -1), itterations_close);
				if (closed_image == true) { imshow("Morphological closing", close); 
				createTrackbar(" Itterations:", "Morphological closing", &itterations_close, 10);
				}
				
				// Step 7
				//
				// find contour algorithm
				findContours(close, contours, RETR_LIST, CHAIN_APPROX_NONE);
				
				// Step 8
				// 
				// Fit ellipse and draw on image
				double test_width(0), test_height(0);
				int flag(0), radius_output;

				// Loop to draw circle on video image
				for (int i = 0; i < contours.size(); i++)
				{

					size_t count = contours[i].size();
					if (count < 6)
						continue;
					Mat pointsf;
					Mat(contours[i]).convertTo(pointsf, CV_32F);
					RotatedRect box = fitEllipse(pointsf);
					if (MAX(box.size.width, box.size.height) > MIN(box.size.width, box.size.height) * pupil_aspect_ratio)
						continue;

					// sets min and max width and heigth of the box in which the ellipse is fitted
					// only these are used in the video and numerical output
					if (MAX(box.size.width, box.size.height) > pupil_min && MAX(box.size.width, box.size.height) < pupil_max) {

						flag++;  // counts 1 at first itteration

						// adds found all width and height in all itterations
						test_width = test_width + box.size.width;
						test_height = test_height + box.size.height;
							
						//drawContours(roi_eye_rgb, contours, (int)i, Scalar::all(255), 1, 8);
						ellipse(roi_eye_rgb, box, Scalar(0, 0, 255), 1, LINE_AA);
						ellipse(roi_eye_rgb, box.center, box.size*0.5f, box.angle, 0, 360, Scalar(0, 255, 255), 1, LINE_AA);

					}
				}


				// devides width and heigth with total number of found ellipses to get average value
				//
				if (test_width != NAN && test_height != NAN
					&& test_width != 0 && test_height != 0) {
					test_width = test_width / flag;
					test_height = test_height / flag;

					// add radius to streamstring for output to video frame
					//
					strs << "Radius : " << sqrt(test_width*test_width + test_height*test_height) << " pix";		
					radius = strs.str();
					
					// method: Square root of width and height rectangle
					//radius_output = sqrt(test_width*test_width + test_height*test_height);
					
					// BETA 31-5-2016
					// Method: area of ellipse -> pi*a*b (a and b are /2 length of rectangle axis)
					radius_output = (test_width / 2) * (test_height / 2) * pi;

				}
				else
				{
					// add radius to streamstring for output to video frame
					//
					strs << "Radius : " << 0 << " pix";
					radius = strs.str();
					radius_output = 0;
				}

				
				// put streamstring to video frame
				if (show_ost == true) {
					putText(roi_eye_rgb, output_file, cvPoint(30, 20),
					FONT_HERSHEY_COMPLEX_SMALL, (size_text), cvScalar(0, 0, 255), 1, CV_AA);
				}


				//------------------------------//
				// Store radius & video streams //
				//------------------------------//

				// store radius in output file
				if (save_radius == true) {
					output_end_result << radius_output << endl;
				}
				
				// write the end result into file
				if (save_video == true) {
					roi_end_result.write(roi_eye_rgb);
				}
				// write the original stream into file
				if (save_original == true) {
					// conversion of Mat file is necassery prior to saving with mpeg compression
					cvtColor(eye, eye, CV_GRAY2RGB);
					original.write(eye);
				}
				
				
				//--------------------//
				// show video streams //
				//--------------------//
				
				// BETA 3-6-2016

				if (end_result_image == true) { imshow("Result (ROI)", roi_eye_rgb); 
				createTrackbar("size min:", "Result (ROI)", &pupil_min, 75);
				createTrackbar("size max:", "Result (ROI)", &pupil_max, 150);
				}

				
				// close grabbing when escape-key "Esc" is used
				if (waitKey(30) == 27) {
					camera.StopGrabbing();
				}

			}

			else
			{
				cout << "Error: " << ptrGrabResult->GetErrorCode() << " " << ptrGrabResult->GetErrorDescription() << endl;
			}
		} // end algorithm main loop
		
	// close numerical output stream
	if (save_radius == true) { output_end_result.close(); }

	}
	
	catch (const GenericException &e)
	{
		// Error handling.
		cerr << "An exception occurred." << endl
			<< e.GetDescription() << endl;
		exitCode = 1;
	}
		
	// Releases all pylon resources. 
	PylonTerminate();

	// end on terminal screen
	if (save_radius == true || save_video == true) {
		cout << endl << endl << " *** Done recording ***" << endl << endl; }
	else { 
		cout << endl << endl << " *** Done ***" << endl << endl; }
	
	return exitCode;
}