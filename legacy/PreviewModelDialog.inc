#if defined previewmodel_dialog_included
	#endinput
#endif
#define previewmodel_dialog_included

/**************************************/
// PreviewModelDialog.inc - v4.7.2 - Last Updated: 14 Oct, 2019 - By Gammix
/***************************************/

#include <memory.inc> // by BigETI

// definitions
#if !defined MAX_DIALOG_PREVIEW_TEXTSIZE
	#define MAX_DIALOG_PREVIEW_TEXTSIZE 128
#endif

#if !defined DEFAULT_DIALOG_INCREMENT_SIZE
	#define DEFAULT_DIALOG_INCREMENT_SIZE 100
#endif

#define DIALOG_STYLE_PREVIEW_MODEL 6 // new dialog id definition
#define DIALOG_STYLE_PREVMODEL DIALOG_STYLE_PREVIEW_MODEL

#define MAX_DIALOG_PREVIEW_ROWS 2
#define MAX_DIALOG_PREVIEW_COLUMNS 6

#define DIALOG_PREVIEW_HORIZONTAL_GAP 56.5
#define DIALOG_PREVIEW_VERTICAL_GAP 63.5

#define DIALOG_PREVIEW_SELECT_COLOR 0xFF0000FF
#define DIALOG_PREVIEW_UNSELECT_COLOR 0x464646FF

#define SCROLL_BAR_UP_TEXTDRAW Prev@FrameTD[4]
#define SCROLL_BAR_DOWN_TEXTDRAW Prev@FrameTD[5]

#define LEFT_BUTTON_TEXTDRAW Prev@LeftButtonTD[0]
#define RIGHT_BUTTON_TEXTDRAW Prev@RightButtonTD[0]
#define CENTER_BUTTON_TEXTDRAW Prev@CenterButtonTD[0]

#define LISTITEM_TEXTDRAW<%0> Prev@ModelTD[%0][0]

// variables
static 
	Text:Prev@FrameTD[6],
	Text:Prev@LeftButtonTD[2],
	Text:Prev@RightButtonTD[2],
	Text:Prev@CenterButtonTD[2],
	Text:Prev@ModelTD[MAX_DIALOG_PREVIEW_ROWS * MAX_DIALOG_PREVIEW_COLUMNS][2],
	PlayerText:Prev@HeaderPTD[MAX_PLAYERS],
	PlayerText:Prev@LeftButtonPTD[MAX_PLAYERS],
	PlayerText:Prev@RightButtonPTD[MAX_PLAYERS],
	PlayerText:Prev@CenterButtonPTD[MAX_PLAYERS],
	PlayerText:Prev@PageNumberPTD[MAX_PLAYERS],
	PlayerText:Prev@ScrollBarPTD[MAX_PLAYERS],
	PlayerText:Prev@ModelTextPTD[MAX_PLAYERS][MAX_DIALOG_PREVIEW_ROWS * MAX_DIALOG_PREVIEW_COLUMNS],
	bool:Prev@CancelSelection[MAX_PLAYERS],
	Prev@PlayerDialogID[MAX_PLAYERS],
	Prev@PlayerDialogListitem[MAX_PLAYERS],
	Prev@PlayerDialogNumListitems[MAX_PLAYERS],
	Prev@PlayerDialogPage[MAX_PLAYERS],
	Prev@PlayerDialogTickCount[MAX_PLAYERS],
	Pointer:Prev@PlayerListitemPointer[MAX_PLAYERS];

// internal functions
static Prev_GetNumPages(playerid) {
	new size = Prev@PlayerDialogNumListitems[playerid];
	new page_size = (MAX_DIALOG_PREVIEW_ROWS * MAX_DIALOG_PREVIEW_COLUMNS);
    return ((size / page_size) + ((size % page_size) ? 1 : 0));
}

static Prev_CancelSelectTextDraw(playerid) {
    Prev@CancelSelection[playerid] = true;
	return CancelSelectTextDraw(playerid);
}

static Prev_CreateTextDraws() {
	/*
	* FRAME
	*/
    Prev@FrameTD[0] = TextDrawCreate(144.0000, 183.0000, "CONTENT_BOX");
	TextDrawFont(Prev@FrameTD[0], 2);
	TextDrawLetterSize(Prev@FrameTD[0], 0.0000, 19.5000);
	TextDrawColor(Prev@FrameTD[0], -1);
	TextDrawSetShadow(Prev@FrameTD[0], 0);
	TextDrawSetOutline(Prev@FrameTD[0], 0);
	TextDrawBackgroundColor(Prev@FrameTD[0], 255);
	TextDrawSetProportional(Prev@FrameTD[0], 1);
	TextDrawUseBox(Prev@FrameTD[0], 1);
	TextDrawBoxColor(Prev@FrameTD[0], 175);
	TextDrawTextSize(Prev@FrameTD[0], 501.0000, 0.0000);

	Prev@FrameTD[1] = TextDrawCreate(146.5000, 195.5000, "LD_SPAC:WHITE");
	TextDrawFont(Prev@FrameTD[1], 4);
	TextDrawLetterSize(Prev@FrameTD[1], 0.0000, 18.2000);
	TextDrawColor(Prev@FrameTD[1], -1);
	TextDrawSetShadow(Prev@FrameTD[1], 0);
	TextDrawSetOutline(Prev@FrameTD[1], 0);
	TextDrawBackgroundColor(Prev@FrameTD[1], 255);
	TextDrawSetProportional(Prev@FrameTD[1], 1);
	TextDrawUseBox(Prev@FrameTD[1], 1);
	TextDrawBoxColor(Prev@FrameTD[1], 150);
	TextDrawTextSize(Prev@FrameTD[1], 351.5000, 130.0000);

	Prev@FrameTD[2] = TextDrawCreate(147.0000, 196.0000, "LD_SPAC:BLACK");
	TextDrawFont(Prev@FrameTD[2], 4);
	TextDrawLetterSize(Prev@FrameTD[2], 0.0000, 18.2000);
	TextDrawColor(Prev@FrameTD[2], -1);
	TextDrawSetShadow(Prev@FrameTD[2], 0);
	TextDrawSetOutline(Prev@FrameTD[2], 0);
	TextDrawBackgroundColor(Prev@FrameTD[2], 255);
	TextDrawSetProportional(Prev@FrameTD[2], 1);
	TextDrawUseBox(Prev@FrameTD[2], 1);
	TextDrawBoxColor(Prev@FrameTD[2], 150);
	TextDrawTextSize(Prev@FrameTD[2], 340.5000, 129.0000);

	Prev@FrameTD[3] = TextDrawCreate(488.0000, 196.0000, "LD_SPAC:BLACK");
	TextDrawFont(Prev@FrameTD[3], 4);
	TextDrawLetterSize(Prev@FrameTD[3], 0.0000, 18.2000);
	TextDrawColor(Prev@FrameTD[3], -1);
	TextDrawSetShadow(Prev@FrameTD[3], 0);
	TextDrawSetOutline(Prev@FrameTD[3], 0);
	TextDrawBackgroundColor(Prev@FrameTD[3], 255);
	TextDrawSetProportional(Prev@FrameTD[3], 1);
	TextDrawUseBox(Prev@FrameTD[3], 1);
	TextDrawBoxColor(Prev@FrameTD[3], 150);
	TextDrawTextSize(Prev@FrameTD[3], 9.5000, 129.0000);

	// button for scrolling up
	Prev@FrameTD[4] = TextDrawCreate(412.500000, 336.0000, "<");
	TextDrawFont(Prev@FrameTD[4], 1);
	TextDrawLetterSize(Prev@FrameTD[4], 0.4, 1.5);
	TextDrawTextSize(Prev@FrameTD[4], 431.500000, 17.000000);
	TextDrawSetOutline(Prev@FrameTD[4], 1);
	TextDrawSetShadow(Prev@FrameTD[4], 0);
	TextDrawAlignment(Prev@FrameTD[4], 1);
	TextDrawColor(Prev@FrameTD[4], -1);
	TextDrawBackgroundColor(Prev@FrameTD[4], 255);
	TextDrawBoxColor(Prev@FrameTD[4], 255);
	TextDrawUseBox(Prev@FrameTD[4], 1);
	TextDrawSetProportional(Prev@FrameTD[4], 1);
	TextDrawSetSelectable(Prev@FrameTD[4], 1);

	// button for scrolling down
	Prev@FrameTD[5] = TextDrawCreate(480.500000, 336.0000, ">");
	TextDrawFont(Prev@FrameTD[5], 1);
	TextDrawLetterSize(Prev@FrameTD[5], 0.4, 1.5);
	TextDrawTextSize(Prev@FrameTD[5], 496.000000, 17.000000);
	TextDrawSetOutline(Prev@FrameTD[5], 1);
	TextDrawSetShadow(Prev@FrameTD[5], 0);
	TextDrawAlignment(Prev@FrameTD[5], 1);
	TextDrawColor(Prev@FrameTD[5], -1);
	TextDrawBackgroundColor(Prev@FrameTD[5], 255);
	TextDrawBoxColor(Prev@FrameTD[5], 255);
	TextDrawUseBox(Prev@FrameTD[5], 1);
	TextDrawSetProportional(Prev@FrameTD[5], 1);
	TextDrawSetSelectable(Prev@FrameTD[5], 1);

	/*
	* LEFT BUTTON (button1)
	*/
	// left button for response type "1"
	Prev@LeftButtonTD[0] = TextDrawCreate(260.0000, 332.5000, "LD_SPAC:WHITE");
	TextDrawFont(Prev@LeftButtonTD[0], 4);
	TextDrawLetterSize(Prev@LeftButtonTD[0], 0.5000, 1.0000);
	TextDrawColor(Prev@LeftButtonTD[0], -1);
	TextDrawSetShadow(Prev@LeftButtonTD[0], 0);
	TextDrawSetOutline(Prev@LeftButtonTD[0], 0);
	TextDrawBackgroundColor(Prev@LeftButtonTD[0], 255);
	TextDrawSetProportional(Prev@LeftButtonTD[0], 1);
	TextDrawTextSize(Prev@LeftButtonTD[0], 55.50000, 18.5000);
	TextDrawSetSelectable(Prev@LeftButtonTD[0], 1);
	//

	Prev@LeftButtonTD[1] = TextDrawCreate(260.5000, 333.5000, "LD_SPAC:BLACK");
	TextDrawFont(Prev@LeftButtonTD[1], 4);
	TextDrawLetterSize(Prev@LeftButtonTD[1], 0.5000, 1.0000);
	TextDrawColor(Prev@LeftButtonTD[1], -1);
	TextDrawSetShadow(Prev@LeftButtonTD[1], 0);
	TextDrawSetOutline(Prev@LeftButtonTD[1], 0);
	TextDrawBackgroundColor(Prev@LeftButtonTD[1], 255);
	TextDrawSetProportional(Prev@LeftButtonTD[1], 1);
	TextDrawTextSize(Prev@LeftButtonTD[1], 54.0000, 17.0000);

	/*
	* RIGHT BUTTON (button2)
	*/
	// right button for response type "0"
	Prev@RightButtonTD[0] = TextDrawCreate(324.0000, 332.5000, "LD_SPAC:WHITE");
	TextDrawFont(Prev@RightButtonTD[0], 4);
	TextDrawLetterSize(Prev@RightButtonTD[0], 0.5000, 1.0000);
	TextDrawColor(Prev@RightButtonTD[0], -1);
	TextDrawSetShadow(Prev@RightButtonTD[0], 0);
	TextDrawSetOutline(Prev@RightButtonTD[0], 0);
	TextDrawBackgroundColor(Prev@RightButtonTD[0], 255);
	TextDrawSetProportional(Prev@RightButtonTD[0], 1);
	TextDrawTextSize(Prev@RightButtonTD[0], 55.5000, 18.5000);
	TextDrawSetSelectable(Prev@RightButtonTD[0], 1);
	//

	Prev@RightButtonTD[1] = TextDrawCreate(324.5000, 333.5000, "LD_SPAC:BLACK");
	TextDrawFont(Prev@RightButtonTD[1], 4);
	TextDrawLetterSize(Prev@RightButtonTD[1], 0.5000, 1.0000);
	TextDrawColor(Prev@RightButtonTD[1], -1);
	TextDrawSetShadow(Prev@RightButtonTD[1], 0);
	TextDrawSetOutline(Prev@RightButtonTD[1], 0);
	TextDrawBackgroundColor(Prev@RightButtonTD[1], 255);
	TextDrawSetProportional(Prev@RightButtonTD[1], 1);
	TextDrawTextSize(Prev@RightButtonTD[1], 54.0000, 17.0000);

	/*
	* CENTER BUTTON (button3)
	*/
	// right button for response type "0"
	Prev@CenterButtonTD[0] = TextDrawCreate(290.5000, 332.5000, "LD_SPAC:WHITE");
	TextDrawFont(Prev@CenterButtonTD[0], 4);
	TextDrawLetterSize(Prev@CenterButtonTD[0], 0.5000, 1.0000);
	TextDrawColor(Prev@CenterButtonTD[0], -1);
	TextDrawSetShadow(Prev@CenterButtonTD[0], 0);
	TextDrawSetOutline(Prev@CenterButtonTD[0], 0);
	TextDrawBackgroundColor(Prev@CenterButtonTD[0], 255);
	TextDrawSetProportional(Prev@CenterButtonTD[0], 1);
	TextDrawTextSize(Prev@CenterButtonTD[0], 55.5000, 18.5000);
	TextDrawSetSelectable(Prev@CenterButtonTD[0], 1);
	//

	Prev@CenterButtonTD[1] = TextDrawCreate(291.0000, 333.5000, "LD_SPAC:BLACK");
	TextDrawFont(Prev@CenterButtonTD[1], 4);
	TextDrawLetterSize(Prev@CenterButtonTD[1], 0.5000, 1.0000);
	TextDrawColor(Prev@CenterButtonTD[1], -1);
	TextDrawSetShadow(Prev@CenterButtonTD[1], 0);
	TextDrawSetOutline(Prev@CenterButtonTD[1], 0);
	TextDrawBackgroundColor(Prev@CenterButtonTD[1], 255);
	TextDrawSetProportional(Prev@CenterButtonTD[1], 1);
	TextDrawTextSize(Prev@CenterButtonTD[1], 54.0000, 17.0000);

	/*
	* PREVIEW MODEL LISTITEMS
	*/
	new textdrawid;

	for (new a = 0; a < MAX_DIALOG_PREVIEW_ROWS; a++) {
		for (new b = 0; b < MAX_DIALOG_PREVIEW_COLUMNS; b++) {
		    textdrawid = ((a * MAX_DIALOG_PREVIEW_COLUMNS) + b);

		    // listitem border button to select item
			Prev@ModelTD[textdrawid][0] = TextDrawCreate((148.0000 + (b * DIALOG_PREVIEW_HORIZONTAL_GAP)), (197.0000 + (a * DIALOG_PREVIEW_VERTICAL_GAP)), "LD_SPAC:WHITE");
			TextDrawFont(Prev@ModelTD[textdrawid][0], 4);
			TextDrawLetterSize(Prev@ModelTD[textdrawid][0], 0.5000, 1.0000);
			TextDrawColor(Prev@ModelTD[textdrawid][0], -16776961);
			TextDrawSetShadow(Prev@ModelTD[textdrawid][0], 0);
			TextDrawSetOutline(Prev@ModelTD[textdrawid][0], 0);
			TextDrawBackgroundColor(Prev@ModelTD[textdrawid][0], 255);
			TextDrawSetProportional(Prev@ModelTD[textdrawid][0], 1);
			TextDrawTextSize(Prev@ModelTD[textdrawid][0], 55.5000, 62.5000);
			TextDrawSetSelectable(Prev@ModelTD[textdrawid][0], 1);
			//

			Prev@ModelTD[textdrawid][1] = TextDrawCreate((149.0000 + (b * DIALOG_PREVIEW_HORIZONTAL_GAP)), (198.0000 + (a * DIALOG_PREVIEW_VERTICAL_GAP)), "MODEL");
			TextDrawFont(Prev@ModelTD[textdrawid][1], 5);
			TextDrawLetterSize(Prev@ModelTD[textdrawid][1], 0.5000, 1.0000);
			TextDrawTextSize(Prev@ModelTD[textdrawid][1], 53.5000, 60.5000);
			TextDrawSetOutline(Prev@ModelTD[textdrawid][1], 0);
			TextDrawSetShadow(Prev@ModelTD[textdrawid][1], 0);
			TextDrawAlignment(Prev@ModelTD[textdrawid][1], 1);
			TextDrawColor(Prev@ModelTD[textdrawid][1], -1);
			TextDrawBackgroundColor(Prev@ModelTD[textdrawid][1], 0x464646FF);
			TextDrawBoxColor(Prev@ModelTD[textdrawid][1], 255);
			TextDrawUseBox(Prev@ModelTD[textdrawid][1], 0);
			TextDrawSetProportional(Prev@ModelTD[textdrawid][1], 1);
			TextDrawSetPreviewRot(Prev@ModelTD[textdrawid][1], -10.000000, 0.000000, -20.000000, 1.000000);
		}
	}
}

static Prev_DestroyTextDraws() {
    /*
	* FRAME
	*/
	for (new i = 0; i < sizeof Prev@FrameTD; i++) {
   	 	TextDrawDestroy(Prev@FrameTD[i]);
	}

	/*
	* LEFT BUTTON (button1)
	*/
	TextDrawDestroy(Prev@LeftButtonTD[0]);
	TextDrawDestroy(Prev@LeftButtonTD[1]);

	/*
	* RIGHT BUTTON (button2)
	*/
	TextDrawDestroy(Prev@RightButtonTD[0]);
	TextDrawDestroy(Prev@RightButtonTD[1]);

	/*
	* CENTER BUTTON (button1)
	*/
	TextDrawDestroy(Prev@CenterButtonTD[0]);
	TextDrawDestroy(Prev@CenterButtonTD[1]);

	/*
	* PREVIEW MODEL LISTITEMS
	*/
	for (new i = 0; i < (MAX_DIALOG_PREVIEW_ROWS * MAX_DIALOG_PREVIEW_COLUMNS); i++) {
	    TextDrawDestroy(Prev@ModelTD[i][0]);
	    TextDrawDestroy(Prev@ModelTD[i][1]);
	}
}

static Prev_CreatePlayerTextDraws(playerid, header[], button1[], button2[], button3[], totalItems) {
    /*
	* HEADER
	*/
    Prev@HeaderPTD[playerid] = CreatePlayerTextDraw(playerid, 144.0000, 183.0000, header);
	PlayerTextDrawFont(playerid, Prev@HeaderPTD[playerid], 1);
	PlayerTextDrawLetterSize(playerid, Prev@HeaderPTD[playerid], 0.238, 1.2);
	PlayerTextDrawColor(playerid, Prev@HeaderPTD[playerid], -1);
	PlayerTextDrawSetShadow(playerid, Prev@HeaderPTD[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Prev@HeaderPTD[playerid], 0);
	PlayerTextDrawBackgroundColor(playerid, Prev@HeaderPTD[playerid], 255);
	PlayerTextDrawSetProportional(playerid, Prev@HeaderPTD[playerid], 1);
	PlayerTextDrawUseBox(playerid, Prev@HeaderPTD[playerid], 1);
	PlayerTextDrawBoxColor(playerid, Prev@HeaderPTD[playerid], 255);
	PlayerTextDrawTextSize(playerid, Prev@HeaderPTD[playerid], 501.0000, 0.0000);

	/*
	* LEFT BUTTON (button1)
	*/
	if (button1[0] != EOS) {
		Prev@LeftButtonPTD[playerid] = CreatePlayerTextDraw(playerid, 287.5000, 337.0000, button1);
		PlayerTextDrawFont(playerid, Prev@LeftButtonPTD[playerid], 1);
		PlayerTextDrawLetterSize(playerid, Prev@LeftButtonPTD[playerid], 0.245, 1.1);
		PlayerTextDrawAlignment(playerid, Prev@LeftButtonPTD[playerid], 2);
		PlayerTextDrawColor(playerid, Prev@LeftButtonPTD[playerid], -1);
		PlayerTextDrawSetShadow(playerid, Prev@LeftButtonPTD[playerid], 0);
		PlayerTextDrawSetOutline(playerid, Prev@LeftButtonPTD[playerid], 0);
		PlayerTextDrawBackgroundColor(playerid, Prev@LeftButtonPTD[playerid], 255);
		PlayerTextDrawSetProportional(playerid, Prev@LeftButtonPTD[playerid], 1);
		PlayerTextDrawTextSize(playerid, Prev@LeftButtonPTD[playerid], 0.0000, 480.0000);
	} else {
        Prev@LeftButtonPTD[playerid] = PlayerText:INVALID_TEXT_DRAW;
	}

	/*
	* RIGHT BUTTON (button2)
	*/
	if (button2[0] != EOS) {
		Prev@RightButtonPTD[playerid] = CreatePlayerTextDraw(playerid, 352.5000, 337.0000, button2);
		PlayerTextDrawFont(playerid, Prev@RightButtonPTD[playerid], 1);
		PlayerTextDrawLetterSize(playerid, Prev@RightButtonPTD[playerid], 0.245, 1.1);
		PlayerTextDrawAlignment(playerid, Prev@RightButtonPTD[playerid], 2);
		PlayerTextDrawColor(playerid, Prev@RightButtonPTD[playerid], -1);
		PlayerTextDrawSetShadow(playerid, Prev@RightButtonPTD[playerid], 0);
		PlayerTextDrawSetOutline(playerid, Prev@RightButtonPTD[playerid], 0);
		PlayerTextDrawBackgroundColor(playerid, Prev@RightButtonPTD[playerid], 255);
		PlayerTextDrawSetProportional(playerid, Prev@RightButtonPTD[playerid], 1);
		PlayerTextDrawTextSize(playerid, Prev@RightButtonPTD[playerid], 0.0000, 480.0000);
    } else {
        Prev@RightButtonPTD[playerid] = PlayerText:INVALID_TEXT_DRAW;
	}

	/*
	* CENTER BUTTON (button3)
	*/
	if (button3[0] != EOS) {
		Prev@CenterButtonPTD[playerid] = CreatePlayerTextDraw(playerid, 318.0000, 337.0000, button3);
		PlayerTextDrawFont(playerid, Prev@CenterButtonPTD[playerid], 1);
		PlayerTextDrawLetterSize(playerid, Prev@CenterButtonPTD[playerid], 0.245, 1.1);
		PlayerTextDrawAlignment(playerid, Prev@CenterButtonPTD[playerid], 2);
		PlayerTextDrawColor(playerid, Prev@CenterButtonPTD[playerid], -1);
		PlayerTextDrawSetShadow(playerid, Prev@CenterButtonPTD[playerid], 0);
		PlayerTextDrawSetOutline(playerid, Prev@CenterButtonPTD[playerid], 0);
		PlayerTextDrawBackgroundColor(playerid, Prev@CenterButtonPTD[playerid], 255);
		PlayerTextDrawSetProportional(playerid, Prev@CenterButtonPTD[playerid], 1);
		PlayerTextDrawTextSize(playerid, Prev@CenterButtonPTD[playerid], 0.0000, 480.0000);
    } else {
        Prev@CenterButtonPTD[playerid] = PlayerText:INVALID_TEXT_DRAW;
	}

	/*
	* PAGE NUMBER
	*/
	if (totalItems > (MAX_DIALOG_PREVIEW_ROWS * MAX_DIALOG_PREVIEW_COLUMNS)) { // if there are more than "12" listitems, create page textdraw
	    Prev@PageNumberPTD[playerid] = CreatePlayerTextDraw(playerid, 501.5000, 183.0000, "Page: 1");
		PlayerTextDrawFont(playerid, Prev@PageNumberPTD[playerid], 1);
		PlayerTextDrawLetterSize(playerid, Prev@PageNumberPTD[playerid], 0.245, 1.1);
		PlayerTextDrawAlignment(playerid, Prev@PageNumberPTD[playerid], 3);
		PlayerTextDrawColor(playerid, Prev@PageNumberPTD[playerid], -1);
		PlayerTextDrawSetShadow(playerid, Prev@PageNumberPTD[playerid], 0);
		PlayerTextDrawSetOutline(playerid, Prev@PageNumberPTD[playerid], 0);
		PlayerTextDrawBackgroundColor(playerid, Prev@PageNumberPTD[playerid], 255);
		PlayerTextDrawSetProportional(playerid, Prev@PageNumberPTD[playerid], 1);
		PlayerTextDrawTextSize(playerid, Prev@PageNumberPTD[playerid], 501.0000, 0.0000);
	} else {
        Prev@PageNumberPTD[playerid] = PlayerText:INVALID_TEXT_DRAW;
	}

	/*
	* PREVIEW MODEL LISTITEMS
	*/
	new textdrawid;

	for (new a = 0; a < MAX_DIALOG_PREVIEW_ROWS; a++) {
		for (new b = 0; b < MAX_DIALOG_PREVIEW_COLUMNS; b++) {
		    textdrawid = ((a * MAX_DIALOG_PREVIEW_COLUMNS) + b);

			if (textdrawid >= totalItems) {
			    Prev@ModelTextPTD[playerid][textdrawid] = PlayerText:INVALID_TEXT_DRAW;
				continue;
			}

			Prev@ModelTextPTD[playerid][textdrawid] = CreatePlayerTextDraw(playerid, (149.0000 + (b * DIALOG_PREVIEW_HORIZONTAL_GAP)), (198.5000 + (a * DIALOG_PREVIEW_VERTICAL_GAP)), "_");
			PlayerTextDrawFont(playerid, Prev@ModelTextPTD[playerid][textdrawid], 1);
			PlayerTextDrawLetterSize(playerid, Prev@ModelTextPTD[playerid][textdrawid], 0.2, 1.25);
			PlayerTextDrawColor(playerid, Prev@ModelTextPTD[playerid][textdrawid], -1);
			PlayerTextDrawSetShadow(playerid, Prev@ModelTextPTD[playerid][textdrawid], 0);
			PlayerTextDrawSetOutline(playerid, Prev@ModelTextPTD[playerid][textdrawid], 1);
			PlayerTextDrawBackgroundColor(playerid, Prev@ModelTextPTD[playerid][textdrawid], 100);
			PlayerTextDrawSetProportional(playerid, Prev@ModelTextPTD[playerid][textdrawid], 1);
			PlayerTextDrawUseBox(playerid, Prev@ModelTextPTD[playerid][textdrawid], 1);
			PlayerTextDrawBoxColor(playerid, Prev@ModelTextPTD[playerid][textdrawid], 0);
			PlayerTextDrawTextSize(playerid, Prev@ModelTextPTD[playerid][textdrawid], (203.0000 + (b * DIALOG_PREVIEW_HORIZONTAL_GAP)), 0.0000);
		}
	}

	/*
	* SCROLLBAR
	*/
	Prev@ScrollBarPTD[playerid] = PlayerText:INVALID_TEXT_DRAW; // we will create this later if needed in dialog
}

static Prev_DestroyPlayerTextDraws(playerid) {
    /*
	* HEADER
	*/
    PlayerTextDrawDestroy(playerid, Prev@HeaderPTD[playerid]);

	/*
	* LEFT BUTTON (button1)
	*/
    PlayerTextDrawDestroy(playerid, Prev@LeftButtonPTD[playerid]);

	/*
	* RIGHT BUTTON (button2)
	*/
    PlayerTextDrawDestroy(playerid, Prev@RightButtonPTD[playerid]);

	/*
	* CENTER BUTTON (button3)
	*/
    PlayerTextDrawDestroy(playerid, Prev@CenterButtonPTD[playerid]);

	/*
	* PAGE NUMBER
	*/
    PlayerTextDrawDestroy(playerid, Prev@PageNumberPTD[playerid]);

	/*
	* SCROLLBAR
	*/
	
    PlayerTextDrawDestroy(playerid, Prev@ScrollBarPTD[playerid]);

	/*
	* PREVIEW MODEL LISTITEMS
	*/
	for (new i = 0; i < (MAX_DIALOG_PREVIEW_ROWS * MAX_DIALOG_PREVIEW_COLUMNS); i++) {
		PlayerTextDrawDestroy(playerid, Prev@ModelTextPTD[playerid][i]);
	}
}

static Prev_UpdateScrollBar(playerid, page, totalPages) {
    PlayerTextDrawDestroy(playerid, Prev@ScrollBarPTD[playerid]);
	
	const Float:MAX_HEIGHT = 108.0000;
	new Float:height = (MAX_HEIGHT / totalPages);
    new Float:y = 206.5000;
	y += (height * page);

    Prev@ScrollBarPTD[playerid] = CreatePlayerTextDraw(playerid, 488.0000, y, "LD_SPAC:WHITE");
	PlayerTextDrawFont(playerid, Prev@ScrollBarPTD[playerid], 4);
	PlayerTextDrawLetterSize(playerid, Prev@ScrollBarPTD[playerid], 0.0000, 18.2000);
	PlayerTextDrawColor(playerid, Prev@ScrollBarPTD[playerid], -16776961);
	PlayerTextDrawSetShadow(playerid, Prev@ScrollBarPTD[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Prev@ScrollBarPTD[playerid], 0);
	PlayerTextDrawBackgroundColor(playerid, Prev@ScrollBarPTD[playerid], 255);
	PlayerTextDrawSetProportional(playerid, Prev@ScrollBarPTD[playerid], 1);
	PlayerTextDrawUseBox(playerid, Prev@ScrollBarPTD[playerid], 1);
	PlayerTextDrawBoxColor(playerid, Prev@ScrollBarPTD[playerid], 150);
	PlayerTextDrawTextSize(playerid, Prev@ScrollBarPTD[playerid], 7.5000, height);

	PlayerTextDrawSetSelectable(playerid, Prev@ScrollBarPTD[playerid], 1);

	PlayerTextDrawShow(playerid, Prev@ScrollBarPTD[playerid]);
	TextDrawShowForPlayer(playerid, SCROLL_BAR_UP_TEXTDRAW);
	TextDrawShowForPlayer(playerid, SCROLL_BAR_DOWN_TEXTDRAW);
}

static Prev_UpdateListitems(playerid, page, selected, totalItems) {
    new textdrawid;
    new listitemid;
	new Pointer:listitemPointer;
	new Pointer:listitemTextPointer;
	new modelid, text[MAX_DIALOG_PREVIEW_TEXTSIZE], Float:rx, Float:ry, Float:rz, Float:zoom, color1, color2;

	PlayerTextDrawHide(playerid, Prev@ModelTextPTD[playerid][Prev@PlayerDialogListitem[playerid]]);

	for (new a = 0; a < MAX_DIALOG_PREVIEW_ROWS; a++) {
		for (new b = 0; b < MAX_DIALOG_PREVIEW_COLUMNS; b++) {
		    textdrawid = ((a * MAX_DIALOG_PREVIEW_COLUMNS) + b);
            listitemid = ((page * (MAX_DIALOG_PREVIEW_ROWS * MAX_DIALOG_PREVIEW_COLUMNS)) + textdrawid);

			if (listitemid >= totalItems) {
			    TextDrawHideForPlayer(playerid, Prev@ModelTD[textdrawid][0]);
			    TextDrawHideForPlayer(playerid, Prev@ModelTD[textdrawid][1]);
				continue;
			}

			listitemPointer = Pointer:MEM_get_val(Prev@PlayerListitemPointer[playerid], listitemid);

			modelid = MEM_get_val(listitemPointer, 0);
			listitemTextPointer = Pointer:MEM_get_val(listitemPointer, 1);
			rx = Float:MEM_get_val(listitemPointer, 2);
			ry = Float:MEM_get_val(listitemPointer, 3);
			rz = Float:MEM_get_val(listitemPointer, 4);
			zoom = Float:MEM_get_val(listitemPointer, 5);
			color1 = MEM_get_val(listitemPointer, 6);
			color2 = MEM_get_val(listitemPointer, 7);

			TextDrawSetPreviewModel(Prev@ModelTD[textdrawid][1], modelid);
			TextDrawSetPreviewRot(Prev@ModelTD[textdrawid][1], rx, ry, rz, zoom);
			TextDrawSetPreviewVehCol(Prev@ModelTD[textdrawid][1], color1, color2);
			TextDrawShowForPlayer(playerid, Prev@ModelTD[textdrawid][1]);

			if ((textdrawid == selected && selected != 0)) {
				TextDrawColor(Prev@ModelTD[textdrawid][0], DIALOG_PREVIEW_SELECT_COLOR);
				TextDrawShowForPlayer(playerid, Prev@ModelTD[textdrawid][0]);
				if (listitemTextPointer != MEM_NULLPTR) {
					MEM_get_arr(listitemTextPointer, 0, text, MEM_get_size(listitemTextPointer));
					PlayerTextDrawSetString(playerid, Prev@ModelTextPTD[playerid][textdrawid], text);
					PlayerTextDrawShow(playerid, Prev@ModelTextPTD[playerid][textdrawid]);
				}
			} else {
				TextDrawColor(Prev@ModelTD[textdrawid][0], DIALOG_PREVIEW_UNSELECT_COLOR);
				TextDrawShowForPlayer(playerid, Prev@ModelTD[textdrawid][0]);
			}
		}
	}

	new string[13];
 	format(string, sizeof string, "Page: %i/%i", (page + 1), Prev_GetNumPages(playerid));
	PlayerTextDrawSetString(playerid, Prev@PageNumberPTD[playerid], string);
}

static Prev_DeletePointers(playerid) {
    new Pointer:listitemPointer;
	new Pointer:listitemTextPointer;

	for (new i = 0; i < Prev@PlayerDialogNumListitems[playerid]; i++) {
	    listitemPointer = Pointer:MEM_get_val(Prev@PlayerListitemPointer[playerid], i);

	    listitemTextPointer = Pointer:MEM_get_val(listitemPointer, 1);
		if (listitemTextPointer != MEM_NULLPTR) {
			MEM_delete(listitemTextPointer);
		}

		MEM_delete(listitemPointer);
	}

	MEM_delete(Prev@PlayerListitemPointer[playerid]);

	Prev@PlayerListitemPointer[playerid] = MEM_NULLPTR;
}

static Prev_HidePlayerDialog(playerid) {
    /*
	* FRAME
	*/
	for (new i = 0; i < sizeof Prev@FrameTD; i++) {
   	 	TextDrawHideForPlayer(playerid, Prev@FrameTD[i]);
	}

	/*
	* LEFT BUTTON
	*/
	TextDrawHideForPlayer(playerid, Prev@LeftButtonTD[0]);
	TextDrawHideForPlayer(playerid, Prev@LeftButtonTD[1]);

	/*
	* RIGHT BUTTON
	*/
	TextDrawHideForPlayer(playerid, Prev@RightButtonTD[0]);
	TextDrawHideForPlayer(playerid, Prev@RightButtonTD[1]);

	/*
	* CENTER BUTTON
	*/
	TextDrawHideForPlayer(playerid, Prev@CenterButtonTD[0]);
	TextDrawHideForPlayer(playerid, Prev@CenterButtonTD[1]);

	/*
	* PREVIEW MODEL LISTITEMS
	*/
	for (new i = 0; i < (MAX_DIALOG_PREVIEW_ROWS * MAX_DIALOG_PREVIEW_COLUMNS); i++) {
	    TextDrawHideForPlayer(playerid, Prev@ModelTD[i][0]);
	    TextDrawHideForPlayer(playerid, Prev@ModelTD[i][1]);
	}

	/*
	* DESTROY DIALOG PLAYER TEXTDRAWS
	*/
	Prev_DestroyPlayerTextDraws(playerid);

    Prev_DeletePointers(playerid);

	Prev@PlayerDialogID[playerid] = -1;

	return Prev_CancelSelectTextDraw(playerid);
}

static Prev_FetchListitemData(const listitem[], &modelid, text[], &Float:rx, &Float:ry, &Float:rz, &Float:zoom, &color1, &color2, text_size = sizeof(text)) {
	
	// Default rot of preview modelid
	rx = -10.000000;
	ry = 0.100000;
	rz = -20.000000;
	zoom = (0.940000 + frandom(0.060000));
	color1 = -1;
	color2 = -1;

	new pos, next, count;
	new valuestr[16];
	new modelstr[32 + (sizeof(valuestr) * 7)];

	pos = strfind(listitem, "\t");

	if (pos == -1) {
		strmid(modelstr, listitem, 0, strlen(listitem));
		text[0] = EOS;
 	} else {
		strmid(modelstr, listitem, 0, pos);
		format(text, text_size, listitem[pos + 1]);
 	}

	if (modelstr[0] == EOS) {
		return 0;
	}

	pos = strfind(modelstr, "(");
	if (pos == -1) {
	    modelid = strval(modelstr);
		return 1;
	}

	if (strfind(modelstr, ")", false, (pos + 1)) == -1) {
		return 0;
	}

	strmid(valuestr, modelstr, 0, pos);
	modelid = strval(valuestr);

	do {
	    next = strfind(modelstr, ",", false, pos);

	    strmid(valuestr, modelstr, pos, ((next == -1) ? strlen(modelstr) : next), sizeof(valuestr));

  		pos = (next == -1) ? -1 : (next + 1);

		switch (count) {
			case 0: rx = floatstr(valuestr);
			case 1: ry = floatstr(valuestr);
			case 2: rz = floatstr(valuestr);
			case 3: zoom = floatstr(valuestr);
			case 4: color1 = strval(valuestr);
			case 5: color2 = strval(valuestr);
		}
		++count;

	} while (pos != -1 && count != 6);

	return 1;
}

// hooked methods
public OnGameModeInit() {
    Prev_CreateTextDraws();

	#if defined PDialog_OnGameModeInit
		return PDialog_OnGameModeInit();
	#else
		return 1;
	#endif
}
#if defined _ALS_OnGameModeInit
	#undef OnGameModeInit
#else
	#define _ALS_OnGameModeInit
#endif
#define OnGameModeInit PDialog_OnGameModeInit
#if defined PDialog_OnGameModeInit
	forward PDialog_OnGameModeInit();
#endif

public OnGameModeExit() {
    Prev_DestroyTextDraws();

	#if defined PDialog_OnGameModeExit
		return PDialog_OnGameModeExit();
	#else
		return 1;
	#endif
}
#if defined _ALS_OnGameModeExit
	#undef OnGameModeExit
#else
	#define _ALS_OnGameModeExit
#endif
#define OnGameModeExit PDialog_OnGameModeExit
#if defined PDialog_OnGameModeExit
	forward PDialog_OnGameModeExit();
#endif

public OnFilterScriptInit() {
    Prev_CreateTextDraws();

	#if defined PDialog_OnFilterScriptInit
		return PDialog_OnFilterScriptInit();
	#else
		return 1;
	#endif
}
#if defined _ALS_OnFilterScriptInit
	#undef OnFilterScriptInit
#else
	#define _ALS_OnFilterScriptInit
#endif
#define OnFilterScriptInit PDialog_OnFilterScriptInit
#if defined PDialog_OnFilterScriptInit
	forward PDialog_OnFilterScriptInit();
#endif

public OnFilterScriptExit() {
    Prev_DestroyTextDraws();

	#if defined PDialog_OnFilterScriptExit
		return PDialog_OnFilterScriptExit();
	#else
		return 1;
	#endif
}
#if defined _ALS_OnFilterScriptExit
	#undef OnFilterScriptExit
#else
	#define _ALS_OnFilterScriptExit
#endif
#define OnFilterScriptExit PDialog_OnFilterScriptExit
#if defined PDialog_OnFilterScriptExit
	forward PDialog_OnFilterScriptExit();
#endif

public OnPlayerConnect(playerid) {
    Prev@CancelSelection[playerid] = false;
	Prev@PlayerDialogID[playerid] = -1;
	Prev@PlayerListitemPointer[playerid] = MEM_NULLPTR;

	#if defined PDialog_OnPlayerConnect
		return PDialog_OnPlayerConnect(playerid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerConnect
	#undef OnPlayerConnect
#else
	#define _ALS_OnPlayerConnect
#endif
#define OnPlayerConnect PDialog_OnPlayerConnect
#if defined PDialog_OnPlayerConnect
	forward PDialog_OnPlayerConnect(playerid);
#endif

public OnPlayerDisconnect(playerid, reason) {
    if (Prev@PlayerDialogID[playerid] != -1) {
		Prev_HidePlayerDialog(playerid);
	}

	#if defined PDialog_OnPlayerDisconnect
		return PDialog_OnPlayerDisconnect(playerid, reason);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerDisconnect
	#undef OnPlayerDisconnect
#else
	#define _ALS_OnPlayerDisconnect
#endif
#define OnPlayerDisconnect PDialog_OnPlayerDisconnect
#if defined PDialog_OnPlayerDisconnect
	forward PDialog_OnPlayerDisconnect(playerid, reason);
#endif

public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid) {
	if (playertextid == Prev@ScrollBarPTD[playerid]) {
		if ((Prev@PlayerDialogPage[playerid] + 1) < Prev_GetNumPages(playerid)) {
			Prev_UpdateListitems(playerid, ++Prev@PlayerDialogPage[playerid], 0, Prev@PlayerDialogNumListitems[playerid]);
			Prev_UpdateScrollBar(playerid, Prev@PlayerDialogPage[playerid], Prev_GetNumPages(playerid));

			Prev@PlayerDialogListitem[playerid] = 0;
		} else if (Prev@PlayerDialogPage[playerid] > 0) {
				Prev@PlayerDialogPage[playerid] = 0;
			    Prev_UpdateListitems(playerid, 0, 0, Prev@PlayerDialogNumListitems[playerid]);
			    Prev_UpdateScrollBar(playerid, 0, Prev_GetNumPages(playerid));

			    Prev@PlayerDialogListitem[playerid] = 0;
			}
	}
	#if defined PD_OnPlayerClickPlayerTextDraw
       	return PD_OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid);
	#else
	   	return 1;
	#endif
}
#if defined _ALS_OnPlayerClickPlayerTD
    #undef OnPlayerClickPlayerTextDraw
#else
    #define _ALS_OnPlayerClickPlayerTD
#endif
#define OnPlayerClickPlayerTextDraw PD_OnPlayerClickPlayerTextDraw
#if defined PD_OnPlayerClickPlayerTextDraw
    forward PD_OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid);
#endif

public OnPlayerClickTextDraw(playerid, Text:clickedid) {
	if (Prev@CancelSelection[playerid]) {
        Prev@CancelSelection[playerid] = false;

        #if defined PDialog_OnPlayerClickTextDraw
	       	return PDialog_OnPlayerClickTextDraw(playerid, Text:clickedid);
		#else
		   	return 1;
		#endif
	}

	if (Prev@PlayerDialogID[playerid] != -1) {
 		if (clickedid == Text:INVALID_TEXT_DRAW || clickedid == RIGHT_BUTTON_TEXTDRAW) {
		    new dialogid = Prev@PlayerDialogID[playerid];
		    new listitem = ((Prev@PlayerDialogPage[playerid] * (MAX_DIALOG_PREVIEW_ROWS * MAX_DIALOG_PREVIEW_COLUMNS)) + Prev@PlayerDialogListitem[playerid]);
    		new inputtext[16];
		    valstr(inputtext, MEM_get_val(Pointer:MEM_get_val(Prev@PlayerListitemPointer[playerid], listitem), 0));

			Prev_HidePlayerDialog(playerid);

			CallLocalFunction("OnDialogModelResponse", "iiii", playerid, dialogid, 0, listitem);

		} else if (clickedid == SCROLL_BAR_UP_TEXTDRAW) {
			if (Prev@PlayerDialogPage[playerid] > 0) {
			    Prev_UpdateListitems(playerid, --Prev@PlayerDialogPage[playerid], 0, Prev@PlayerDialogNumListitems[playerid]);
			    Prev_UpdateScrollBar(playerid, Prev@PlayerDialogPage[playerid], Prev_GetNumPages(playerid));

			    Prev@PlayerDialogListitem[playerid] = 0;
			} else if ((Prev@PlayerDialogPage[playerid] + 1) < Prev_GetNumPages(playerid)) {
			    Prev_UpdateListitems(playerid, ++Prev@PlayerDialogPage[playerid], 0, Prev@PlayerDialogNumListitems[playerid]);
			    Prev_UpdateScrollBar(playerid, Prev@PlayerDialogPage[playerid], Prev_GetNumPages(playerid));

			    Prev@PlayerDialogListitem[playerid] = 0;
			}

		} else if (clickedid == SCROLL_BAR_DOWN_TEXTDRAW) {
			if ((Prev@PlayerDialogPage[playerid] + 1) < Prev_GetNumPages(playerid)) {
			    Prev_UpdateListitems(playerid, ++Prev@PlayerDialogPage[playerid], 0, Prev@PlayerDialogNumListitems[playerid]);
			    Prev_UpdateScrollBar(playerid, Prev@PlayerDialogPage[playerid], Prev_GetNumPages(playerid));

			    Prev@PlayerDialogListitem[playerid] = 0;
			} else if (Prev@PlayerDialogPage[playerid] > 0) {
				Prev@PlayerDialogPage[playerid] = 0;
			    Prev_UpdateListitems(playerid, 0, 0, Prev@PlayerDialogNumListitems[playerid]);
			    Prev_UpdateScrollBar(playerid, 0, Prev_GetNumPages(playerid));

			    Prev@PlayerDialogListitem[playerid] = 0;
			}
		} else if (clickedid == LEFT_BUTTON_TEXTDRAW || clickedid == CENTER_BUTTON_TEXTDRAW) {
		    new dialogid = Prev@PlayerDialogID[playerid];
		    new listitem = ((Prev@PlayerDialogPage[playerid] * (MAX_DIALOG_PREVIEW_ROWS * MAX_DIALOG_PREVIEW_COLUMNS)) + Prev@PlayerDialogListitem[playerid]);
		    new inputtext[16];
		    valstr(inputtext, MEM_get_val(Pointer:MEM_get_val(Prev@PlayerListitemPointer[playerid], listitem), 0));

			Prev_HidePlayerDialog(playerid);

			CallLocalFunction("OnDialogModelResponse", "iiii", playerid, dialogid, 1, listitem);

		} else {
			for (new i = 0; i < (MAX_DIALOG_PREVIEW_ROWS * MAX_DIALOG_PREVIEW_COLUMNS); i++) {
				if (clickedid == LISTITEM_TEXTDRAW<i>) {

					if (Prev@PlayerDialogListitem[playerid] == i && (GetTickCount() - Prev@PlayerDialogTickCount[playerid]) <= 200) {
	                    new dialogid = Prev@PlayerDialogID[playerid];
		    			new listitem = ((Prev@PlayerDialogPage[playerid] * (MAX_DIALOG_PREVIEW_ROWS * MAX_DIALOG_PREVIEW_COLUMNS)) + Prev@PlayerDialogListitem[playerid]);
					    new inputtext[16];
		    			valstr(inputtext, MEM_get_val(Pointer:MEM_get_val(Prev@PlayerListitemPointer[playerid], listitem), 0));

						Prev_HidePlayerDialog(playerid);

						CallLocalFunction("OnDialogModelResponse", "iiii", playerid, dialogid, 1, listitem);

					} else {
						// reset previous listitem
						new previous = Prev@PlayerDialogListitem[playerid];
					 	TextDrawColor(Prev@ModelTD[previous][0], DIALOG_PREVIEW_UNSELECT_COLOR);
						TextDrawShowForPlayer(playerid, Prev@ModelTD[previous][0]);
						PlayerTextDrawHide(playerid, Prev@ModelTextPTD[playerid][previous]);

					    // update new selected listitem
					    TextDrawColor(Prev@ModelTD[i][0], DIALOG_PREVIEW_SELECT_COLOR);
						TextDrawShowForPlayer(playerid, Prev@ModelTD[i][0]);

						new 
							page,
							listitemid,
							Pointer:listitemPointer,
							Pointer:listitemTextPointer,
							text[MAX_DIALOG_PREVIEW_TEXTSIZE];

						page = Prev@PlayerDialogPage[playerid];
						listitemid = ((page * (MAX_DIALOG_PREVIEW_ROWS * MAX_DIALOG_PREVIEW_COLUMNS)) + i);
						listitemPointer = Pointer:MEM_get_val(Prev@PlayerListitemPointer[playerid], listitemid);
						listitemTextPointer = Pointer:MEM_get_val(listitemPointer, 1);
						MEM_get_arr(listitemTextPointer, 0, text, MEM_get_size(listitemTextPointer));

						if (listitemTextPointer != MEM_NULLPTR) {
							MEM_get_arr(listitemTextPointer, 0, text, MEM_get_size(listitemTextPointer));
							PlayerTextDrawSetString(playerid, Prev@ModelTextPTD[playerid][i], text);
							PlayerTextDrawShow(playerid, Prev@ModelTextPTD[playerid][i]);
						}

						Prev@PlayerDialogListitem[playerid] = i;
					    Prev@PlayerDialogTickCount[playerid] = GetTickCount();
					}

					break;
				}
			}
		}
	}

	#if defined PDialog_OnPlayerClickTextDraw
       	return PDialog_OnPlayerClickTextDraw(playerid, Text:clickedid);
	#else
	   	return 1;
	#endif
}
#if defined _ALS_OnPlayerClickTextDraw
    #undef OnPlayerClickTextDraw
#else
    #define _ALS_OnPlayerClickTextDraw
#endif
#define OnPlayerClickTextDraw PDialog_OnPlayerClickTextDraw
#if defined PDialog_OnPlayerClickTextDraw
    forward PDialog_OnPlayerClickTextDraw(playerid, Text:clickedid);
#endif

stock Prev_ShowPlayerDialog(playerid, dialogid, style, caption[], info[], button1[], button2[]) {
	if (playerid < 0 || playerid >= MAX_PLAYERS) {
	    return 0;
	}

	if (Prev@PlayerDialogID[playerid] != -1 && style != DIALOG_STYLE_PREVIEW_MODEL) {
		Prev_HidePlayerDialog(playerid);
		return 0;
  	}

	if (Prev@PlayerDialogID[playerid] != -1 && style == DIALOG_STYLE_PREVIEW_MODEL) {
		Prev_DestroyPlayerTextDraws(playerid);
		Prev_DeletePointers(playerid);
		Prev@PlayerDialogID[playerid] = -1;
  	}

	if (style != DIALOG_STYLE_PREVIEW_MODEL) {
	    return ShowPlayerDialog(playerid, dialogid, style, caption, info, button1, button2);
	}

	if (dialogid < 0) {
	    if (style == DIALOG_STYLE_PREVIEW_MODEL) {
	        return 1;
	    }

	    return ShowPlayerDialog(playerid, dialogid, style, caption, info, button1, button2);
	}

	if (info[0] == EOS) {
		return 0;
	}

	Prev@PlayerListitemPointer[playerid] = MEM_new(DEFAULT_DIALOG_INCREMENT_SIZE);

	new pos, next, count;

	new listitem[MAX_DIALOG_PREVIEW_TEXTSIZE + 64];
	new modelid, text[MAX_DIALOG_PREVIEW_TEXTSIZE], Float:rx, Float:ry, Float:rz, Float:zoom, color1, color2;

	new Pointer:listitemPointer, Pointer:listitemTextPointer;

	do {
	    next = strfind(info, "\n", false, pos);

	    strmid(listitem, info, pos, ((next == -1) ? strlen(info) : next), sizeof(listitem));

  		pos = (next == -1) ? -1 : (next + 1);

	    if (Prev_FetchListitemData(listitem, modelid, text, rx,  ry, rz, zoom, color1, color2) == 0) {
			continue;
		}

		listitemPointer = MEM_new(8);
		listitemTextPointer = (text[0] != EOS) ? MEM_new_arr(text, (strlen(text) + 1)) : MEM_NULLPTR;

		MEM_set_val(listitemPointer, 0, modelid);
		MEM_set_val(listitemPointer, 1, _:listitemTextPointer);
		MEM_set_val(listitemPointer, 2, _:rx);
		MEM_set_val(listitemPointer, 3, _:ry);
		MEM_set_val(listitemPointer, 4, _:rz);
		MEM_set_val(listitemPointer, 5, _:zoom);
		MEM_set_val(listitemPointer, 6, color1);
		MEM_set_val(listitemPointer, 7, color2);

		if (count == MEM_get_size(Prev@PlayerListitemPointer[playerid])) {
			new Pointer:tmpPointer = MEM_new(count + DEFAULT_DIALOG_INCREMENT_SIZE);
			MEM_copy(tmpPointer, Prev@PlayerListitemPointer[playerid], count);

			MEM_delete(Prev@PlayerListitemPointer[playerid]);

			Prev@PlayerListitemPointer[playerid] = tmpPointer;
		}

		MEM_set_val(Prev@PlayerListitemPointer[playerid], count++, _:listitemPointer);
	} while (pos != -1);

	// set player data
	Prev@PlayerDialogID[playerid] = dialogid;
	Prev@PlayerDialogListitem[playerid] = 0;
	Prev@PlayerDialogNumListitems[playerid] = count;
	Prev@PlayerDialogPage[playerid] = 0;
	Prev@PlayerDialogTickCount[playerid] = 0;

    /*
	* FRAME
	*/
	for (new i = 0; i < sizeof Prev@FrameTD - 2; i++) {
   	 	TextDrawShowForPlayer(playerid, Prev@FrameTD[i]);
	}

	/*
	* BUTTONS AND PLAYER DIALOG TEXTDRAWS
	*/
	if (button2[0] == EOS) { // only one center button
		TextDrawHideForPlayer(playerid, Prev@LeftButtonTD[0]);
		TextDrawHideForPlayer(playerid, Prev@LeftButtonTD[1]);

		TextDrawHideForPlayer(playerid, Prev@RightButtonTD[0]);
		TextDrawHideForPlayer(playerid, Prev@RightButtonTD[1]);

		TextDrawShowForPlayer(playerid, Prev@CenterButtonTD[0]);
		TextDrawShowForPlayer(playerid, Prev@CenterButtonTD[1]);

		Prev_CreatePlayerTextDraws(playerid, caption, "", "", button1, Prev@PlayerDialogNumListitems[playerid]);
    	PlayerTextDrawShow(playerid, Prev@CenterButtonPTD[playerid]);
	} else { // dual buttons
		TextDrawShowForPlayer(playerid, Prev@LeftButtonTD[0]);
		TextDrawShowForPlayer(playerid, Prev@LeftButtonTD[1]);

		TextDrawShowForPlayer(playerid, Prev@RightButtonTD[0]);
		TextDrawShowForPlayer(playerid, Prev@RightButtonTD[1]);

		TextDrawHideForPlayer(playerid, Prev@CenterButtonTD[0]);
		TextDrawHideForPlayer(playerid, Prev@CenterButtonTD[1]);

		Prev_CreatePlayerTextDraws(playerid, caption, button1, button2, "", Prev@PlayerDialogNumListitems[playerid]);
    	PlayerTextDrawShow(playerid, Prev@LeftButtonPTD[playerid]);
    	PlayerTextDrawShow(playerid, Prev@RightButtonPTD[playerid]);
	}

	/*
	* HEADER
	*/
	PlayerTextDrawShow(playerid, Prev@HeaderPTD[playerid]);

	/*
	* PAGE NUMBER
	*/
    PlayerTextDrawShow(playerid, Prev@PageNumberPTD[playerid]);

	/*
	* SCROLLBAR
	*/
 	Prev@ScrollBarPTD[playerid] = PlayerText:INVALID_TEXT_DRAW;
	if (Prev@PlayerDialogNumListitems[playerid] > (MAX_DIALOG_PREVIEW_ROWS * MAX_DIALOG_PREVIEW_COLUMNS)) {
        Prev_UpdateScrollBar(playerid, 0, Prev_GetNumPages(playerid));
	}

	/*
	* PREVIEW MODEL LISTITEMS
	*/
	Prev_UpdateListitems(playerid, 0, 0, Prev@PlayerDialogNumListitems[playerid]);

	return SelectTextDraw(playerid, DIALOG_PREVIEW_SELECT_COLOR);
}
#if defined _ALS_ShowPlayerDialog
    #undef ShowPlayerDialog
#else
    #define _ALS_ShowPlayerDialog
#endif
#define ShowPlayerDialog Prev_ShowPlayerDialog