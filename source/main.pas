unit main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Contnrs, IniFiles, FileCtrl, ShlObj, StrUtils, DateUtils,
  ServiceUnit, DirectOutput_explicit, ExtCtrls, SyncObjs;

const
  //UUID
  DeviceTypeX52Pro = '29DAD506-F93B-4F20-85FA-1E02C04FAC17';
	// LED identifiers
  LED_MISSILE = 0;		// on or off, color cant be controlled
  LED_FIREA_RED = 1;
  LED_FIREA_GREEN = 2;
  LED_FIREB_RED = 3;
  LED_FIREB_GREEN = 4;
  LED_FIRED_RED = 5;
  LED_FIRED_GREEN = 6;
  LED_FIREE_RED = 7;
  LED_FIREE_GREEN = 8;
  LED_TOGGLE12_RED = 9;
  LED_TOGGLE12_GREEN = 10;
  LED_TOGGLE34_RED = 11;
  LED_TOGGLE34_GREEN = 12;
	LED_TOGGLE56_RED = 13;
  LED_TOGGLE56_GREEN = 14;
  LED_POV2_RED = 15;
  LED_POV2_GREEN = 16;
  LED_CLUTCH_RED = 17;
  LED_CLUTCH_GREEN = 18;
	LED_THROTTLE = 19;				//on or off only

// Soft Buttons
  SoftButton_Select	= $00000001;
  SoftButton_Up		= $00000002;
  SoftButton_Down		= $00000004;

  SoftButton_SelectUp = $00000003;
  SoftButton_SelectDown = $00000005;

  // led states
  _OFF = 0;
  _ON = 1;

// expected line count of input files
  LC_highprio = 9;
  LC_lowprio = 3;

  // because passing and empty string to X52 is simply discarded, does not clear a line...
  Emptyline='                ';

type
	TLedColor = (Off, Amber, Red, Green);
  TLedName = (MISSILE, FIRE_A, FIRE_B, FIRE_D, FIRE_E, TOGGLE_LEFT, TOGGLE_MIDDLE, TOGGLE_RIGHT, POV2, CLUTCH, THROTTLE);
  TLedBlinkSpeed = (VERY_SLOW, SLOW, NORMAL, FAST, VERY_FAST);
  TMFDPageNames = (PLAYERSHIP, COMPATIBLEMISSILE, EQUIPPEDMISSILE, TARGET, INCOMING, WEAPONS, CARGO);

  TGenericContainer<T> = class
    Value : T;
  end;

	// the state of each led
	TLedData = Class(TObject)
    private
      LedNumber : integer;
      State : integer;                    // this is the "remembered" state, the procedure deciding to update a led state or not uses this
      Blinking : Boolean;
      Blinking_speed : TLedBlinkSpeed;
      TimeSinceBlink : integer;
      BlinkState : integer;               // this is the blinking state, only used by the procedure responsible for the blinking
      Changed : Boolean;
      constructor Create(Number:integer);
  end;

  // the thread handling the leds
  TLedHandlerThread = class(TThread)
    private
      LedList : TObjectList;
      ActivePage : integer;   // same as in the MFD handler: the number of the active MFD page
      Act : string;
      constructor Create(CreateSuspended : Boolean);
      procedure SetLedGroup(Led1, Led2 : integer; Color: TLedColor; Blink: Boolean; BlinkSpeed: TLedBlinkSpeed);
      function SameState(Name: TLedName; Color: TLedColor; Blink: Boolean; BlinkSpeed: TLedBlinkSpeed) : Boolean;
      function RedOK(Color: TLedColor; LedIndex:integer) : Boolean;
      function GreenOK(Color: TLedColor; LedIndex:integer) : Boolean;
    protected
      procedure Execute; override;
    public
      MFDPageChanged : TEvent;          // pagechange callback needs to signal this thread because LED states are bound to MFD pages
      destructor Destroy(); override;
      procedure SetLedData(Name: TLedName; Color: TLedColor; Blink: Boolean; BlinkSpeed: TLedBlinkSpeed);
  end;

  TNamedStringList = class(TStringList)
    private
      constructor Create(ListName: TMFDPageNames);
    public
      Name : TMFDPageNames;
      PageChanged : Boolean;
      FirstLineOnMFD : integer;
  end;

  // this handles everyting happening of the MFD
  // - displays text, maintain pages
  // - handles softbutton events, scrolls text up-down
  TMFDHandlerThread = class(TThread)
    private
      Pages : TObjectList;          // all Pages
      ActivePage : integer;
      constructor Create(CreateSuspended : Boolean);
      procedure HandleKeypress();
      procedure UpdatePages();
    protected
      procedure Execute; override;
    public
      Buttons : LongInt;            // last softbutton event return value
      SoftButtonPressed : TEvent;   // signal object, the callback sets this if a button is pressed
      destructor Destroy(); override;
      procedure AddPage(PageName: TMFDPageNames);
      procedure ChangeLine(PageName:TMFDPageNames; LineNumber:integer; NewText: string);     // change an already existing line
      procedure AddLine(PageName:TMFDPageNames; txt: string);                               // add a new line to the end of the page
  end;

  TMoneyData = class(TObject)
    Amount : integer;
    GameTime : integer;
  end;

  TForm1 = class(TForm)

    ExitButton: TButton;
    Memo1: TMemo;
    ReInitButton: TButton;
    TestButton: TButton;
    TestTimer: TTimer;
    DllPath: TEdit;
    DLLBrowse: TButton;
    Label1: TLabel;
    Label2: TLabel;
    X3Path: TEdit;
    X3TCBrowse: TButton;
    MainTimer: TTimer;
    SaveButton: TButton;
    debug_mode_checkbox: TCheckBox;

    procedure FormShow(Sender: TObject);
		function Initialize() : Boolean;
    function DeInitialize() : HResult;
    procedure ReInitButtonClick(Sender: TObject);
    procedure RestartSaitekService();
    procedure ExitButtonClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure InitLeds(PageNumber : integer);      // Wordaround for DirectOutput.dll bug: unless all LEDs are filled up with 1's once its ignoring turn off command...
    procedure TestButtonClick(Sender: TObject);
    procedure Test();
    procedure TestTimerTimer(Sender: TObject);
    procedure ResetLeds();
    procedure MainTimerTimer(Sender: TObject);
    procedure ReadIni();
    procedure WriteIni();
    procedure DLLBrowseClick(Sender: TObject);
    procedure DetectDLLPath();
    procedure DetectX3Path();
    procedure X3TCBrowseClick(Sender: TObject);
    procedure SaveButtonClick(Sender: TObject);
    procedure ParseDelimited(sl : TStringList; const value : string; const delimiter : string);
    function Format16(String1, String2 : string) : string;
    function StrToIntNull(input:string) : integer;
    function MoneyPerMinute(CurrentMoney : integer; GTime : integer) : integer;
    procedure QuickSort(var A: array of Integer; iLo, iHi: Integer) ;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

procedure Device_CallBack(hDevice:LongInt; bAdded: Boolean; lContext: LongInt); stdcall;
procedure SoftButton_CallBack(hDevice, lButtons, lContext: Longint); stdcall;
procedure PageChange_Callback(hDevice, lPage : LongInt; bActivated: Boolean; lContext: Longint); stdcall;

procedure X52_AddPage(PageNumber : LongInt; PageName : WideString; SetAsActive : Boolean);
procedure X52_RemovePage(PageNumber:LongInt);
procedure X52_AddString(PageNumber, LineNumber : LongInt; Text:WideString);
procedure X52_SetLed(PageID, LedID, LedState: LongInt);

procedure logtodisk(loggolnivalo:string);
function FileVersion(AFileName: string): string;

var
  AppPath : string;
  Form1: TForm1;
  res : HResult;
  X52Handle : LongInt;
  Initialized : Boolean = False;
  Page : LongInt;
  PageActivated : Boolean;
  LedHandlerThread : TLedHandlerThread;
  MFDHandlerThread : TMFDHandlerThread;

  MoneyList : TObjectList;
implementation

{$R *.dfm}

/// This is the delegate specified in DirectOutput_RegisterDeviceChangeCallback. In practice, this should be defined
/// in your implementation code to set a globally accessible variable to the value of the hDevice, which is (as noted)
/// the handle to the device that is needed by all of the rest of the Saitek-provided functions.
/// <param name="hDevice">A handle to the device that changed.</param>
/// <param name="bAdded">True if the device was added, false if the device was removed.</param>
/// <param name="lContext">The application defined context value passed to DirectOutput_RegisterDeviceChangeCallback.</param>
procedure Device_CallBack(hDevice:LongInt; bAdded: Boolean; lContext: LongInt); stdcall;
begin
  if Form1.debug_mode_checkbox.Checked then
    logtodisk('Device_CallBack: hDevice '+inttostr(hDevice));

  if bAdded then X52Handle:=hDevice else X52Handle:=0;
end;

/// This is the delegate specified in DirectOutput_RegisterSoftButtonChangeCallback.
/// <param name="hDevice">A handle to the device that changed.</param>
/// <param name="lButtons">Integer value of the button(s) pressed.</param>
/// <param name="lContext">The application defined context value passed to DirectOutput_RegisterSoftButtonChangeCallback.</param>
procedure SoftButton_CallBack(hDevice, lButtons, lContext: Longint); stdcall;
begin
  if Form1.debug_mode_checkbox.Checked then
    logtodisk('SoftButton_CallBack: hDevice '+inttostr(hDevice)+' lButtons '+inttostr(lButtons));

  if not Assigned(MFDHandlerThread) then exit;  // if the handler thread is not running we cant do anything
  if lButtons = 0 then exit;  // no reason to handle this

  MFDHandlerThread.Buttons:=lButtons;
  MFDHandlerThread.SoftButtonPressed.SetEvent;
end;

/// The delegate function specified in DirectOutput_RegisterPageChangeCallback. Gets called both when a page becomes inactive,
/// and also when the next page becomes active.
/// <param name="hDevice">A handle to the device that changed.</param>
/// <param name="lPage">Int value of the changing page (as defined when page was added).</param>
/// <param name="bActivated">True if the page is being enabled, false if the page is being disabled.</param>
/// <param name="lContext">The application defined context value passed to DirectOutput_RegisterSoftButtonChangeCallback.</param>
procedure PageChange_Callback(hDevice, lPage : LongInt; bActivated: Boolean; lContext: Longint); stdcall;
begin
  if Form1.debug_mode_checkbox.Checked then
  begin
    logtodisk('PageChange_CallBack: hDevice '+inttostr(hDevice)+' lPage '+inttostr(lPage));
    if bActivated then logtodisk('PageChange_CallBack: bActivated True') else logtodisk('PageChange_CallBack: bActivated False');
  end;

  if (not Assigned(MFDHandlerThread)) or (not Assigned(LEDHandlerThread)) then exit;  // if the handler threads are not running we cant do anything
    if bActivated then LEDHandlerThread.Act:='True' else LEDHandlerThread.Act:='False';

    MFDHandlerThread.ActivePage:=lPage;    // store the currently active page number in both threads
    LEDHandlerThread.ActivePage:=lPage;
    LEDHandlerThread.MFDPageChanged.SetEvent;  // signal LED handler thread that the active page has changed
end;

procedure TForm1.ReadIni;
var IniFile: TIniFile;
begin
  if Form1.debug_mode_checkbox.Checked then logtodisk('Reading Ini file');

  IniFile := TIniFile.Create(AppPath +'\settings.ini');
  try
    Form1.DllPath.Text := IniFile.ReadString('Settings', 'DllPath', '');
    Form1.X3Path.Text := IniFile.ReadString('Settings', 'X3LogPath', '');
  finally
    IniFile.Free
  end;
end;

procedure TForm1.WriteIni;
var IniFile: TIniFile;
begin
  if Form1.debug_mode_checkbox.Checked then logtodisk('Writing Ini file');

  IniFile := TIniFile.Create(AppPath +'\settings.ini');
  try
    IniFile.WriteString('Settings', 'DllPath', Form1.DllPath.Text);
    IniFile.WriteString('Settings', 'X3LogPath', Form1.X3Path.Text);
  finally
    IniFile.Free
  end;
end;

procedure TForm1.X3TCBrowseClick(Sender: TObject);
var
  lpItemID : PItemIDList;
  BrowseInfo : TBrowseInfo;
  DisplayName : array[0..MAX_PATH] of char;
  SelectedPath : array[0..MAX_PATH] of char;
begin
  FillChar(BrowseInfo, sizeof(TBrowseInfo), #0);
  with BrowseInfo do begin
    hwndOwner := Application.Handle;
    pszDisplayName := @DisplayName;
    lpszTitle := PChar('Select the folder where X3:TC saves log files');
    ulFlags := 0;
  end;
  lpItemID := SHBrowseForFolder(BrowseInfo);
  if lpItemId <> nil then begin
    SHGetPathFromIDList(lpItemID, SelectedPath);
    GlobalFreePtr(lpItemID);
    X3Path.Text:=SelectedPath;
  end;
end;

procedure TForm1.DLLBrowseClick(Sender: TObject);
var
  openDialog : TOpenDialog;    // Open dialog variable
begin
  openDialog := TOpenDialog.Create(self);
  openDialog.InitialDir := GetCurrentDir;
  openDialog.Options := [ofFileMustExist];
  openDialog.Filter := 'Dll files|*.dll';
  openDialog.FilterIndex := 1;
  if openDialog.Execute then DllPath.Text:=OpenDialog.FileName;
  openDialog.Free;
end;

procedure TForm1.ExitButtonClick(Sender: TObject);
begin
  Form1.Close;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Assigned(LedHandlerThread) then LedHandlerThread.Terminate;
  if Assigned(MFDHandlerThread) then MFDHandlerThread.Terminate;
  if Assigned(MoneyList) then MoneyList.Free;

  if DllLoaded then FreeDLL();
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  logtodisk('');
  logtodisk('Program start');

  GetDir(0, AppPath);
//  logtodisk('Exe version: '+FileVersion(AppPath+'\'+Application.ExeName));

  ReadIni();
  MoneyList:=TObjectList.Create(True);

  if Form1.DllPath.Text='' then DetectDLLPath();
  if Form1.X3Path.Text='' then DetectX3Path();

  logtodisk('DLL version: '+FileVersion(DllPath.Text));

  LoadDll(WideString(DllPath.Text));

  if DllLoaded then
    if not Initialize then
    	Memo1.Lines.Add('Error initializing the controller, verify connection, DLL path, driver installation.');
end;

procedure TForm1.ReInitButtonClick(Sender: TObject);
begin
  if Form1.debug_mode_checkbox.Checked then logtodisk('Starting reinit sequence');

  if Assigned(LedHandlerThread) then LedHandlerThread.Terminate;
  if Form1.debug_mode_checkbox.Checked then logtodisk('  LedHandlerThread terminated');

  if Assigned(MFDHandlerThread) then MFDHandlerThread.Terminate;
  if Form1.debug_mode_checkbox.Checked then logtodisk('  MFDHadnlerThread terminated');

  If Initialized then
  begin
    DeInitialize();
    if Form1.debug_mode_checkbox.Checked then logtodisk('  Controller DeInitialized');
  end else
    if Form1.debug_mode_checkbox.Checked then logtodisk('  Controller not Initialized, skipping DeInit');

  If DLLLoaded then
  begin
   FreeDLL();
   if Form1.debug_mode_checkbox.Checked then logtodisk('  DLL unloaded');
  end else
    if Form1.debug_mode_checkbox.Checked then logtodisk('  DLL not loaded, skipping unload');

  RestartSaitekService();
  if Form1.debug_mode_checkbox.Checked then logtodisk('  Saitek service restarted');

  LoadDLL(Form1.DllPath.Text);
  if Form1.debug_mode_checkbox.Checked then logtodisk('  DLL loaded');
  Logtodisk('DLL version: '+FileVersion(DllPath.Text));

  if DllLoaded then
    if not Initialize then
    begin
    	Memo1.Lines.Add('Error initializing the controller, verify connection, DLL path, driver installation.');
      logtodisk('Error initializing the controller, verify connection, DLL path, driver installation.');
    end;
end;

procedure TForm1.RestartSaitekService();
var ServiceState : DWord;
begin
  try
	  ServiceState:=ServiceGetStatus(nil, PChar('SaiDOutput'));
  except
  	On E:Exception do
    begin
    	Memo1.Lines.Add('Error querying the Saitek DirectOutput service state: '+E.Message);
      logtodisk('Error querying the Saitek DirectOutput service state: '+E.Message);
      exit;
    end;
  end;

	case ServiceState of
  	 50 : Memo1.Lines.Add('Error querying the Saitek DirectOutput service state.');
     1 : if ServiceStart('','SaiDOutput') then Memo1.Lines.Add('Saitek DirectOutput service successfully started.')
     			else Memo1.Lines.Add('Error starting Saitek DirectOutput service.'); //stopped
     2 : Memo1.Lines.Add('Saitek DirectOutput service is trying to start now, try again.'); //start pending
     3 : Memo1.Lines.Add('Saitek DirectOutput service is trying to stop now, try again.'); //stop pending
     4 : 	begin //running
          	ServiceStop('','SaiDOutput');
          	sleep(2000);
            if ServiceStart('','SaiDOutput') then Memo1.Lines.Add('Saitek DirectOutput service successfully restarted.')
            	else Memo1.Lines.Add('Error starting Saitek DirectOutput service.');
     			end;
     5 : Memo1.Lines.Add('Saitek DirectOutput service state invalid.'); //continue pending
     6 : Memo1.Lines.Add('Saitek DirectOutput service state invalid.'); //pause pending
     7 : Memo1.Lines.Add('Saitek DirectOutput service state invalid.'); //paused
  end;
end;

procedure TForm1.TestButtonClick(Sender: TObject);
begin
  if not TestTimer.Enabled then
  begin
    Form1.TestButton.Caption:='Stop test';
    X52_AddString(0,0,' Christmas Tree ');
    X52_AddString(0,1,'      Mode      ');
    X52_AddString(0,2,'   *** ON ***   ');
    TestTimer.Enabled:=True;
    exit;
  end;

  if TestTimer.Enabled then
  begin
    Form1.TestButton.Caption:='Test';
    X52_AddString(0,0,EmptyLine);
    X52_AddString(0,1,EmptyLine);
    X52_AddString(0,2,EmptyLine);
    TestTimer.Enabled:=False;
    ResetLeds();
    exit;
  end;
end;

procedure TForm1.TestTimerTimer(Sender: TObject);
begin
  // call the test procedure every 50ms to change a led
  Test();
end;

procedure TForm1.InitLeds(PageNumber : integer);
var
  i: Integer;
begin
  logtodisk('InitLeds starting');
  for i := 0 to 19 do
    X52_SetLed(PageNumber,i,1);
  sleep(1000);
end;

procedure TForm1.MainTimerTimer(Sender: TObject);
const  log_weapons : string = 'log01109.txt';
       log_cargo   : string = 'log01110.txt';
       log_highpri : string = 'log01111.txt';
       log_lowpri  : string = 'log01112.txt';
var
       weaponslist, cargolist, highlist, lowlist : TStringList;
       i: Integer;
       BreakDown : TStringList;
       LinesOut : TStringList;

       // input data
       // high prio file
       MissileType, MissileYield, MissileRange, MissileSpeed, MissileStock, MissileFlags : string;
       PlayerMaxHull, PlayerCurrentHull, PlayerMaxShield, PlayerCurrentShield : string;
       PlayerMaxLaser, PlayerCurrentLaser, PlayerSpeed : string;
       TargetName, TargetDistance, TargetClass, TargetRace : string;
       TargetMaxHull, TargetCurrentHull, TargetMaxShield, TargetCurrentShield : string;
       IsEnemy, IsNeutral, IsFriend : string;
       MissileIncoming, MissileIncomingDamage, MissileIncomingDistance, MissileIncomingSpeed : string;
       NumMissiles, TotalDamage : string;
       // low prio file
       PlayerShipName, PlayerShipClass : string;
       Money, TimePlayed : integer;

       // converted values for calculations
       MRange, MSpeed, MFlags : integer;
       MYield : integer;
       PMaxHull, PCurrentHull, PMaxShield, PCurrentShield : integer;
       PMaxLaser, PCurrentLaser, PSpeed : integer;
       PHullPercent, PShieldPercent, PLaserPercent : integer;
       TDistance : integer;
       TMaxHull, TCurrentHull, TMaxShield, TCurrentShield : integer;
       THullPercent, TShieldPercent : integer;
       MIncomingDamage, MIncomingDistance, MIncomingSpeed : integer;
       NMissiles, TDamage : integer;

       // calculated values
       TimeToHit : integer;
       TimeUntilImpact : integer;
       MIncomingDistDisplayed : real;

       //led feedback
       LedColor1, LedColor2, LedColor3 : TLedColor;
       LedFlash : TLedBlinkSpeed;
       EmergencyState : Boolean;
       LED: TLedName;
       EnemyStronger : Boolean;
begin
  // this timer triggers reading X3 exported data
  WeaponsList:=TStringList.Create;
  CargoList:=TStringList.Create;
  HighList:=TStringList.Create;
  LowList:=TStringList.Create;

  BreakDown:=TStringList.Create;

  try
    WeaponsList.LoadFromFile(X3Path.Text+'\'+log_weapons);
    CargoList.LoadFromFile(X3Path.Text+'\'+log_cargo);
    HighList.LoadFromFile(X3Path.Text+'\'+log_highpri);
    LowList.LoadFromFile(X3Path.Text+'\'+log_lowpri);
  except
    on E:Exception do	// error occured, bail out
    begin
      WeaponsList.Free;
      CargoList.Free;
      HighList.Free;
      LowList.Free;

      exit;
    end;
  end;

  // if any input file has less lines than expected than X3 is being updating the file, we skip this processing turn
  if (Highlist.Count <> LC_Highprio) or (LowList.Count < LC_Lowprio) then
  begin
    WeaponsList.Free;
    CargoList.Free;
    HighList.Free;
    LowList.Free;

    exit;
  end;

  LinesOut:=TStringList.Create;

  // parse logfiles
  try
    ParseDelimited(BreakDown, HighList[0], ';');
    MissileType:=BreakDown[1];
    MissileRange:=BreakDown[2];
    MissileYield:=BreakDown[3];
    MissileSpeed:=BreakDown[4];
    MissileStock:=BreakDown[5];

    ParseDelimited(BreakDown, HighList[1], ';');
    MissileFlags:=BreakDown[1];

    ParseDelimited(BreakDown, HighList[2], ';');
    PlayerMaxHull:=BreakDown[1];
    PlayerCurrentHull:=BreakDown[2];
    PlayerMaxShield:=BreakDown[3];
    PlayerCurrentShield:=BreakDown[4];

    ParseDelimited(BreakDown, HighList[3], ';');
    PlayerMaxLaser:=BreakDown[1];
    PlayerCurrentLaser:=BreakDown[2];
    PlayerSpeed:=BreakDown[3];

    ParseDelimited(BreakDown, HighList[4], ';');
    TargetName:=BreakDown[1];
    TargetDistance:=BreakDown[2];
    TargetClass:=BreakDown[3];
    TargetRace:=BreakDown[4];

    ParseDelimited(BreakDown, HighList[5], ';');
    TargetMaxHull:=BreakDown[1];
    TargetCurrentHull:=BreakDown[2];
    TargetMaxShield:=BreakDown[3];
    TargetCurrentShield:=BreakDown[4];

    ParseDelimited(BreakDown, HighList[6], ';');
    IsEnemy:=BreakDown[1];
    IsFriend:=BreakDown[2];
    IsNeutral:=BreakDown[3];

    ParseDelimited(BreakDown, HighList[7], ';');
    MissileIncoming:=BreakDown[1];
    MissileIncomingDamage:=BreakDown[2];
    MissileIncomingDistance:=BreakDown[3];
    MissileIncomingSpeed:=BreakDown[4];

    ParseDelimited(BreakDown, HighList[8], ';');
    NumMissiles:=BreakDown[1];
    TotalDamage:=BreakDown[2];

    ParseDelimited(BreakDown, LowList[0], ';');
    PlayerShipName:=BreakDown[1];
    PlayerShipClass:=BreakDown[2];

    Money:=strtoint(LowList[1]);
    TimePlayed:=strtoint(LowList[2]);
  except
    On E:Exception do ;   //suppress errors
  end;

  // convert to numbers those that are needed for calculations
  if MissileType<>'null' then
  begin
      MRange:=strtointnull(MissileRange);
      MYield:=strtointnull(MissileYield);
      MFlags:=strtointnull(MissileFlags);
      MSpeed:=strtointnull(MissileSpeed);
  end;

  PMaxHull:=strtointnull(PlayerMaxHull);
  PCurrentHull:=strtointnull(PlayerCurrentHull);
  PMaxShield:=strtointnull(PlayerMaxShield);
  PCurrentShield:=strtointnull(PlayerCurrentShield);
  PMaxLaser:=strtointnull(PlayerMaxLaser);
  PCurrentLaser:=strtointnull(PlayerCurrentLaser);
  PSpeed:=strtointnull(PlayerSpeed);

  if TargetName<>'null' then
  begin
    TDistance:=strtointnull(TargetDistance);
    TMaxHull:=strtointnull(TargetMaxHull);
    TCurrentHull:=strtointnull(TargetCurrentHull);
    TMaxShield:=strtointnull(TargetMaxShield);
    TCurrentShield:=strtointnull(TargetCurrentShield);
    if TMaxHull<>0 then THullPercent:=Round(TCurrentHull/TMaxHull*100) else THullPercent:=0;
    if TMaxShield<>0 then TShieldPercent:=Round(TCurrentShield/TMaxShield*100) else TShieldPercent:=0;
  end else
  begin
    TDistance:=0;
    TMaxHull:=0;
    TCurrentHull:=0;
    TMaxShield:=0;
    TCurrentShield:=0;
    THullPercent:=0;
    TShieldPercent:=0;
  end;

  if MissileIncoming<>'null' then
  begin
//    Form1.Memo1.Lines.Add('MissileIncoming: '+MissileIncoming+' Dam: '+MissileIncomingDamage+' Dist: '+MissileIncomingDistance+' Spd: '+MissileIncomingSpeed+' Num: '+NumMissiles+' TDam: '+TotalDamage);
    MIncomingDamage:=strtointnull(MissileIncomingDamage);
    MIncomingDistance:=strtointnull(MissileIncomingDistance);
    MIncomingSpeed:=strtointnull(MissileIncomingSpeed);
    NMissiles:=strtointnull(NumMissiles);
    TDamage:=strtointnull(TotalDamage);
  end else
  begin
    MIncomingDamage:=0;
    MIncomingDistance:=0;
    MIncomingSpeed:=0;
    NMissiles:=0;
    TDamage:=0;
  end;

  if PMaxShield=0 then PShieldPercent:=0 else PShieldPercent:=Round(PCurrentShield/PMaxShield*100);
  if PMaxHull=0 then PHullPercent:=0 else PHullPercent:=Round(PCurrentHull/PMaxHull*100);
  if PMaxLaser=0 then PLaserPercent:=0 else PLaserPercent:=Round(PCurrentLaser/PMaxLaser*100);

  {
  If you have shields<15% and hull<20% ALL LEDs will flash red.
  If the shields power up only the T LEDs continue to flash until hull is repaired, all other LEDs resume normal operation.
  }
  if (PShieldPercent<15) and (PHullPercent<20) then EmergencyState:=True else EmergencyState:=False;
  if EmergencyState then
    with LedHandlerThread do
      for LED := MISSILE TO THROTTLE do
        SetLEDData(LED, Red, True, FAST);

  // D LED is not used now, reset it if emergency is over
  if not EmergencyState then LedHandlerThread.SetLedData(FIRE_D,OFF,False,NORMAL);

  // WEAPONS page
  LinesOut.Clear;
  LinesOut.Add('*   Equipped   *');
  for i := 1 to WeaponsList.Count - 1 do  //0 skipped, thats the header
  begin
    ParseDelimited(BreakDown, WeaponsList[i], ';');
    LinesOut.Add(Format16(BreakDown[1],BreakDown[2]));
  end;
  for i := LinesOut.Count to 99 do
    LinesOut.Add(EmptyLine);
  for i := 0 to LinesOut.Count-1 do
    MFDHandlerThread.ChangeLine(WEAPONS,i,LinesOut[i]);

  // CARGO page
  LinesOut.Clear;
  LinesOut.Add('*  Cargo hold  *');
  for i := 1 to CargoList.Count - 1 do  //0 skipped, thats the header
  begin
    ParseDelimited(BreakDown, CargoList[i], ';');
    LinesOut.Add(Format16(BreakDown[1],BreakDown[2]));
  end;
  for i := LinesOut.Count to 99 do
    LinesOut.Add(EmptyLine);
  for i := 0 to LinesOut.Count-1 do
    MFDHandlerThread.ChangeLine(CARGO,i,LinesOut[i]);

  // COMPATIBLE MISSILES
  LinesOut.Clear;
  LinesOut.Add('* Compatible M.*');
  if LowList.Count>3 then       // missiles start on line 4 if any
  begin
    for i := 3 to LowList.Count - 1 do
      LinesOut.Add(AnsiLeftStr(LowList[i],16));
  end
  else begin
    LinesOut.Add('None');
    for i := 1 to 99 do
      LinesOut.Add(Emptyline);
  end;
  for i := 0 to LinesOut.Count-1 do
    MFDHandlerThread.ChangeLine(COMPATIBLEMISSILE,i,LinesOut[i]);

  // MISSILE page
  LinesOut.Clear;
  LinesOut.Add('*   Missile    *');
  if MissileType<>'null' then
  begin
    LinesOut.Add(Format16(MissileType, MissileStock));

    if MYield<10000 then LinesOut.Add('R:'+inttostr(Round(MRange/1000))+'km D:'+inttostr(MYield)+'kJ')
      else LinesOut.Add('R:'+inttostr(Round(MRange/1000))+'km D:'+inttostr(Round(MYield/1000))+'MJ');

    if TargetName<>'null' then
    begin
      TimeToHit:=Round(TDistance/MSpeed);
      LinesOut.Add('Spd:'+MissileSpeed+'m/s T:'+inttostr(TimeToHit)+'s');
    end else LinesOut.Add('Spd:'+MissileSpeed+'m/s');

    if MFlags AND 1 = 1 then LinesOut.Add('Freefire');
    if MFlags AND 2 = 2 then LinesOut.Add('Dumbfire');
    if MFlags AND 4 = 4 then LinesOut.Add('Swarm, Single t.');
    if MFlags AND 8 = 8 then LinesOut.Add('Heat seaking');
    if MFlags AND 16 = 16 then LinesOut.Add('Swarm, Multi t.');
    if MFlags AND 32 = 32 then LinesOut.Add('Proximity det.');
    if MFlags AND 64 = 64 then LinesOut.Add('Manual det.');
    // 128 is Firestorm torpedo, no reason to display twice
    if MFlags AND 256 = 256 then LinesOut.Add('Manually guided');

    // if the page is not filled, remaining lines are overwritten with an empty line
    for I := LinesOut.Count to 99 do
      LinesOut.Add(Emptyline);
  end
  else begin
    LinesOut.add('No missile');
    for i := 1 to 99 do
      LinesOut.add(EmptyLine);
  end;
  for i := 0 to LinesOut.Count-1 do
    MFDHandlerThread.ChangeLine(EQUIPPEDMISSILE,i,LinesOut[i]);

  // Missile LED feedbacks
  if not EmergencyState then
    if (MissileType = 'null') or (TargetName = 'null') then
    begin
      LedHandlerThread.SetLedData(FIRE_A, Off, False, Normal);
      LedHandlerThread.SetLedData(MISSILE, Off, False, Normal);
    end else
    begin
      // FIRE_A
      if MYield<TCurrentShield then LedHandlerThread.SetLedData(FIRE_A, Green, False, Normal);
      if (MYield>TCurrentShield) and (MYield < TCurrentHull-TCurrentShield) then LedHandlerThread.SetLedData(FIRE_A, Amber, False, Normal);
      if MYield > TCurrentHull+TCurrentShield then LedHandlerThread.SetLedData(FIRE_A, Red, False, Normal);

      // MISSILE
      if TDistance <= MRange then LedHandlerThread.SetLedData(MISSILE, Green, False, Normal);  // in range - no blinking, lit
      if (TDistance > MRange) and (TDistance <= MRange*1.2) then LedHandlerThread.SetLedData(MISSILE, Green, TRUE, VERY_FAST);  // out of range - very close
      if (TDistance > MRange*1.2) and (TDistance <= MRange*1.4) then LedHandlerThread.SetLedData(MISSILE, Green, TRUE, FAST);  // out of range - closer
      if (TDistance > MRange*1.4) and (TDistance <= MRange*1.6) then LedHandlerThread.SetLedData(MISSILE, Green, TRUE, NORMAL);  // out of range - close
      if (TDistance > MRange*1.6) and (TDistance <= MRange*1.8) then LedHandlerThread.SetLedData(MISSILE, Green, TRUE, SLOW);  // out of range - not that close
      if (TDistance > MRange*1.8) and (TDistance <= MRange*2) then LedHandlerThread.SetLedData(MISSILE, Green, TRUE, VERY_SLOW);  // out of range - quite far
      if TDistance > MRange*2 then LedHandlerThread.SetLedData(MISSILE, Off, False, NORMAL);  // out of range * 2 - LED off
    end;

  // PLAYERSHIP page
  LinesOut.Clear;
  LinesOut.Add('* Player ship  *');
  if PlayerShipName<>'null' then
  begin
    LinesOut.Add(PlayerShipName+' / '+PlayerShipClass);
    LinesOut.Add(Format16('Hu: '+inttostr(PHullPercent)+'% ',PlayerCurrentHull));
    if PMaxShield=0 then
      LinesOut.Add('No shields')
    else
      LinesOut.Add(Format16('Sh: '+inttostr(PShieldPercent)+'% ',PlayerCurrentShield));
    if PMaxLaser=0 then
      LinesOut.Add('No weapons')
    else begin
      if PCurrentLaser<9999 then
        LinesOut.Add(Format16('Las: '+inttostr(PLaserPercent)+'% ',PlayerCurrentLaser))
      else
        LinesOut.Add(Format16('Las: '+inttostr(PLaserPercent)+'% ',inttostr(Round(PCurrentLaser/1000))+'k'));
    end;

    LinesOut.Add(Format16('Money:',inttostr(Money)));
    // money/minute
    LinesOut.Add(Format16('Money/min:',inttostr(Round(MoneyPerMinute(Money,TimePlayed)/1000))+'k'));

    // if the page is not filled, remaining lines are overwritten with an empty line
    for I := LinesOut.Count to 99 do
      LinesOut.Add(Emptyline);
  end
  else begin
    LinesOut.add('No player ship');
    for i := 1 to 99 do
      LinesOut.add(EmptyLine);
  end;
  for i := 0 to LinesOut.Count-1 do
    MFDHandlerThread.ChangeLine(PLAYERSHIP,i,LinesOut[i]);

  // Playership-related LED feedbacks
  // first determine the 3 colors
  if PShieldPercent>=85 then
  begin
    LedColor1:=Green; LedColor2:=Green; LedColor3:=Green;
  end;
  if (PShieldPercent<85) and (PShieldPercent>=71)  then
  begin
    LedColor1:=Green; LedColor2:=Green; LedColor3:=Amber;
  end;
  if (PShieldPercent<71) and (PShieldPercent>=57)  then
  begin
    LedColor1:=Green; LedColor2:=Amber; LedColor3:=Amber;
  end;
  if (PShieldPercent<57) and (PShieldPercent>=44)  then
  begin
    LedColor1:=Amber; LedColor2:=Amber; LedColor3:=Amber;
  end;
  if (PShieldPercent<44) and (PShieldPercent>=30)  then
  begin
    LedColor1:=Amber; LedColor2:=Amber; LedColor3:=Red;
  end;
  if (PShieldPercent<30) and (PShieldPercent>=16)  then
  begin
    LedColor1:=Amber; LedColor2:=Red; LedColor3:=Red;
  end;
  if (PShieldPercent<16) and (PShieldPercent>=0)  then
  begin
    LedColor1:=Red; LedColor2:=Red; LedColor3:=Red;
  end;

  //determine flash speed
  if (PHullPercent<100) and (PHullPercent>=80) then
    LedFlash:=VERY_SLOW;
  if (PHullPercent<80) and (PHullPercent>=60) then
    LedFlash:=SLOW;
  if (PHullPercent<60) and (PHullPercent>=40) then
    LedFlash:=NORMAL;
  if (PHullPercent<40) and (PHullPercent>=20) then
    LedFlash:=FAST;
  if (PHullPercent<20) then LedFlash:=VERY_FAST;

  // Set leds
  if not EmergencyState then
    with LedHandlerThread do
    begin
      if PHullPercent=100 then
      begin
        SetLedData(TOGGLE_LEFT,LedColor1,False,NORMAL);  // no flash
        SetLedData(TOGGLE_MIDDLE,LedColor2,False,NORMAL);  // no flash
        SetLedData(TOGGLE_RIGHT,LedColor3,False,NORMAL);  // no flash
      end
      else begin
        SetLedData(TOGGLE_LEFT,LedColor1, True, LedFlash);
        SetLedData(TOGGLE_MIDDLE,LedColor2, True, LedFlash);
        SetLedData(TOGGLE_RIGHT,LedColor3, True, LedFlash);
      end;

      if PMaxLaser=0 then SetLedData(FIRE_B, OFF, False, NORMAL)
      else begin
        if PLaserPercent>=75 then SetLedData(FIRE_B, Green, False, NORMAL);
        if (PLaserPercent<75) and (PLaserPercent>=50) then SetLedData(FIRE_B, Amber, False, NORMAL);
        if (PLaserPercent<50) and (PLaserPercent>=20) then SetLedData(FIRE_B, Red, False, NORMAL);
        if PLaserPercent<20 then SetLedData(FIRE_B, Red, True, FAST);
      end;

      if PSpeed = 0 then SetLedData(THROTTLE, OFF, False, NORMAL);
      if PSpeed>0 then SetledData(THROTTLE, Green, False, NORMAL);
      if PSpeed<0 then SetledData(THROTTLE, Green, True, NORMAL);
  end;

  // TARGET
  LinesOut.Clear;
  if TargetName<>'null' then
  begin
    if isEnemy='1' then   LinesOut.Add('* Enemy target *');
    if isNeutral='1' then LinesOut.Add('* Neutral tar. *');
    if isFriend='1' then  LinesOut.Add('* Friendly tar.*');
    LinesOut.Add(TargetName+' / '+TargetClass);
    LinesOut.Add(Format16('Hu: '+inttostr(THullPercent)+'% ',TargetCurrentHull));
    LinesOut.Add(Format16('Sh: '+inttostr(TShieldPercent)+'% ',TargetCurrentShield));
    //Total equipped laser str ?
    // if the page is not filled, remaining lines are overwritten with an empty line
    for I := LinesOut.Count to 99 do
      LinesOut.Add(Emptyline);
  end
  else begin
    LinesOut.Add('*   No target  *');
    for i := 1 to 99 do
      LinesOut.add(EmptyLine);
  end;
  for i := 0 to LinesOut.Count-1 do
    MFDHandlerThread.ChangeLine(TARGET,i,LinesOut[i]);

  if not EmergencyState then
    with LedHandlerThread do
    begin
      if PMaxHull+PMaxShield > TMaxHull+TMaxShield then EnemyStronger:=False else EnemyStronger:=True;

      if TargetName='null' then SetLedData(POV2, OFF, False, NORMAL);
      if (TargetName<>'null') and (isFriend='1') then SetLedData(POV2, Green, False, NORMAL);
      if (TargetName<>'null') and (isNeutral='1') then SetLedData(POV2, Amber, False, NORMAL);
      if (TargetName<>'null') and (isEnemy='1') then SetLedData(POV2, Red, EnemyStronger, NORMAL);
    end;

  // INCOMING
  LinesOut.Clear;
  if MissileIncoming<>'null' then
  begin
    LinesOut.Add('*   Incoming   *');
    LinesOut.Add(MissileIncoming);

    if MIncomingDamage<10000 then LinesOut.Add('Spd:'+MissileIncomingSpeed+'m/s D:'+MissileIncomingDamage+'kJ')
      else LinesOut.Add('Spd:'+MissileIncomingSpeed+'m/s D:'+inttostr(Round(MIncomingDamage/1000))+'MJ');

    if MSpeed<>0 then TimeUntilImpact := Round(MIncomingDistance/MSpeed) else TimeUntilImpact:=0;

    if MIncomingDistance>1000 then LinesOut.Add('Dist:'+floattostrf(MIncomingDistance/1000,ffGeneral,4,2)+'km T:'+inttostr(TimeUntilImpact)+'s')
    else LinesOut.Add('Dist:'+MissileIncomingDistance+'m T:'+inttostr(TimeUntilImpact)+'s');

    if NMissiles>1 then LinesOut.Add('Total: '+NumMissiles+' D: '+inttostr(Round(TDamage/1000))+'MJ');
    for I := LinesOut.Count to 99 do
      LinesOut.Add(Emptyline);
  end
  else begin
    LinesOut.Add('* No incoming  *');
    for i := 1 to 99 do
      LinesOut.add(EmptyLine);
  end;
  for i := 0 to LinesOut.Count-1 do
    MFDHandlerThread.ChangeLine(INCOMING,i,LinesOut[i]);

  if not EmergencyState then
    with LedHandlerThread do
    begin
      if MissileIncoming='null' then
      begin
        SetLedData(CLUTCH,Off,False,NORMAL);
        SetLedData(FIRE_E,Off,False,NORMAL);
      end
      else begin
        if MIncomingDamage<PCurrentShield then SetLedData(CLUTCH,Green,True,NORMAL);
        if (MIncomingDamage>PCurrentShield) and (MIncomingDamage<PCurrentShield+PCurrentHull) then SetLedData(CLUTCH,Amber,True,FAST);
        if MIncomingDamage>PCurrentShield+PCurrentHull then SetLedData(CLUTCH,Red,True,VERY_FAST);

        if NMissiles=1 then SetLedData(FIRE_E,Off,False,NORMAL);
        if (NMissiles>1) and (TDamage<PCurrentShield) then SetLedData(FIRE_E,Green,True,NORMAL);
        if (NMissiles>1) and (TDamage>PCurrentShield) and (TDamage<PCurrentShield+PCurrentHull)then SetLedData(FIRE_E,Amber,True,FAST);
        if (NMissiles>1) and (TDamage>PCurrentShield+PCurrentHull)then SetLedData(FIRE_E,Red,True,VERY_FAST);
      end;
    end;

  WeaponsList.Free;
  CargoList.Free;
  HighList.Free;
  LowList.Free;
  BreakDown.Free;
  LinesOut.Free;
end;

// stores current money amount, returns money/minute increase
function TForm1.MoneyPerMinute(CurrentMoney : integer; GTime : integer) : integer;
const SampleInterval = 30;   // how many seconds should pass to store new sample
var M : TMoneyData;
    I : Integer;
    DeltaTotal : Int64;
    NumToSkip : integer;
    NumSamples : integer;
    Average : integer;
begin
  if MoneyList.Count=0 then
  begin
    M:=TMoneyData.Create;
    M.Amount:=CurrentMoney;
    M.GameTime:=GTime;
    MoneyList.Add(M);
    Result:=0;
    exit;
  end;

  // store current if its at least 30 seconds newer then the last
  if TMoneyData(MoneyList.Last).GameTime+SampleInterval <= GTime then
  begin
    M:=TMoneyData.Create;
    M.Amount:=CurrentMoney;
    M.GameTime:=GTime;
    MoneyList.Add(M);
  end;

  // exit if low sample number
  if MoneyList.Count<2 then
  begin
    Result:=0;
    exit;
  end;

  //use only samples from the last hour, remove older if present
  with MoneyList do
    if Count>120 then Remove(MoneyList[0]);

  DeltaTotal:=TMoneyData(MoneyList.Last).Amount - TMoneyData(MoneyList.First).Amount;
  Result:=Round(DeltaTotal/(MoneyList.Count/(60/SampleInterval)));
end;


procedure TForm1.QuickSort(var A: array of Integer; iLo, iHi: Integer) ;
 var
   Lo, Hi, Pivot, T: Integer;
 begin
   Lo := iLo;
   Hi := iHi;
   Pivot := A[(Lo + Hi) div 2];
   repeat
     while A[Lo] < Pivot do Inc(Lo) ;
     while A[Hi] > Pivot do Dec(Hi) ;
     if Lo <= Hi then
     begin
       T := A[Lo];
       A[Lo] := A[Hi];
       A[Hi] := T;
       Inc(Lo) ;
       Dec(Hi) ;
     end;
   until Lo > Hi;
   if Hi > iLo then QuickSort(A, iLo, Hi) ;
   if Lo < iHi then QuickSort(A, Lo, iHi) ;
 end;

function TForm1.StrToIntNull(input:string) : integer;
begin
  try
    if input<>'null' then Result:=StrToInt(input) else Result:=0;
  except
  end;
end;

function TForm1.Format16(String1, String2 : string) : string;
begin
  String1:=String1+'                   ';  //dirty workaround
  Result:=AnsiLeftStr(StuffString(String1,16-length(String2),1+length(String2),' '+String2),16);
end;

procedure TForm1.ParseDelimited(sl : TStringList; const value : string; const delimiter : string);
var
   dx : integer;
   ns : string;
   txt : string;
   delta : integer;
begin
   delta := Length(delimiter);
   sl.Clear;
   txt := value + delimiter;
   try
     while Length(txt) > 0 do
     begin
       dx := Pos(delimiter, txt);
       ns := Copy(txt,0,dx-1);
       sl.Add(ns);
       txt := Copy(txt,dx+delta,MaxInt);
     end;
   finally
   end;
end;

function TForm1.Initialize() : Boolean;
var AppName : WideString;
    DeviceGUID : TGuid;
    MFDPage: TMFDPageNames;
  i: Integer;
begin
	X52Handle:=-1;
  Result:=False;

	//initialize DLL
	Appname:='X3TC_Plugin';
  res:= DirectOutput_Initialize(PWideString(AppName));
  case res of
  	S_OK : if Form1.debug_mode_checkbox.Checked then logtodisk('DirectOutput library initialized.');
    E_OUTOFMEMORY : Memo1.Lines.Add('Out of memory error while initializing DirectOutput.dll.');
    E_INVALIDARG : Memo1.Lines.Add('Invalid argument encountered while initializing DirectOutput.dll.');
    E_HANDLE: Memo1.Lines.Add('The DirectOutputManager process cant be found.');
  end;
  if res<>S_OK then exit;

	// register device callback procedure
 	res := DirectOutput_RegisterDeviceChangeCallback(@Device_Callback, 6666);
  case res of
  	S_OK : if Form1.debug_mode_checkbox.Checked then logtodisk('Device change callback procedure registered.');
    E_HANDLE: Memo1.Lines.Add('DirectOutput was not initialized.');
  end;
  if res<>S_OK then exit;

	//enumerate connected devices
 	DirectOutput_Enumerate();

  if X52Handle<=0 then
  begin
  	Memo1.Lines.Add('Saitek X52 Pro not connected!');
    if Form1.debug_mode_checkbox.Checked then logtodisk('Saitek X52 Pro not connected!');
    exit;
  end;

  //verify device GUID
  res := DirectOutput_GetDeviceType(X52Handle, @DeviceGUID);
  if res<>S_OK then
  begin
    Memo1.Lines.Add('Error identifying Saitek device, verify connection and driver installation.');
    exit;
  end;
  if not CompareMem(@DeviceGUID, @X52Pro_GUID, SizeOf(TGuid)) then
  begin
    Memo1.Lines.Add('The connected device is not a Saitek X52 Pro, other devices are not supported.');
    exit;
  end;

	//register softbutton callback procedure
	res := DirectOutput_RegisterSoftButtonChangeCallback(X52Handle, @Softbutton_Callback, 6666);
  case res of
  	S_OK : if Form1.debug_mode_checkbox.Checked then logtodisk('SoftButton callback procedure registered.');
    E_HANDLE: Memo1.Lines.Add('Device handle is invalid.');
  end;
  if res<>S_OK then exit;

	//register pagechange callback procedure
	res := DirectOutput_RegisterPageChangeCallback(X52Handle, @PageChange_Callback, 6666);
  case res of
  	S_OK : if Form1.debug_mode_checkbox.Checked then logtodisk('PageChange callback procedure registered.');
    E_HANDLE: Memo1.Lines.Add('Device handle is invalid.');
  end;
  if res<>S_OK then exit;

  //create the MFD handler and add a Page 0
  MFDHandlerThread:=TMFDHandlerThread.Create(False);

  // create pages and 100 lines of text on each
  for MFDPage := PLAYERSHIP to CARGO do
  begin
    MFDHandlerThread.AddPage(MFDPage);
    for i := 0 to 99 do
      MFDHandlerThread.AddLine(MFDPage,EmptyLine);
  end;

  // init LEDs and create LED handler
  InitLeds(0);
  LedHandlerThread:=TLedHandlerThread.Create(False);

  Memo1.Lines.Add('X52 Pro found and initialized!');

  // enable X3 data reader timer
  MainTimer.Enabled:=True;

  Initialized:=True;
  Result:=True;
end;

procedure TForm1.DetectDLLPath;
const DefaultPath1 = 'C:\Program Files (x86)\Saitek\DirectOutput\DirectOutput.dll';   //x64 systems
const DefaultPath2 = 'C:\Program Files\Saitek\DirectOutput\DirectOutput.dll';        //x86 systems
begin
  if FileExists(DefaultPath1) then
  begin
    Form1.DllPath.Text:=DefaultPath1;
    exit;
  end;

  if FileExists(DefaultPath2) then
  begin
    Form1.DllPath.Text:=DefaultPath2;
    exit;
  end;
end;

procedure TForm1.DetectX3Path;
var path: array[0..Max_Path] of Char;
    X3Path : string;
    searchResult : TSearchRec;
    OldDir : string;
begin
  if not ShGetSpecialFolderPath(0, path, CSIDL_Personal, False) then exit else X3Path := Path+'\Egosoft\X3TC';

  OldDir:=GetCurrentDir;

  if SetCurrentDir(X3Path) then
    if FindFirst('log*.txt', faAnyFile, searchResult) = 0 then
    begin
      Form1.X3Path.Text:=X3Path;
      FindClose(searchResult);
      SetCurrentDir(OldDir);
    end;
end;

procedure TForm1.SaveButtonClick(Sender: TObject);
begin
  WriteINI();
end;

function TForm1.DeInitialize() : HResult;
begin
  Result := DirectOutput_Deinitialize();
  MainTimer.Enabled:=False;
  Initialized:=False;
end;

procedure X52_AddPage(PageNumber : LongInt; PageName : WideString; SetAsActive : Boolean);
begin
	if X52Handle<=0 then
  begin
  	Form1.Memo1.Lines.Add('Error adding page, X52 handle invalid.');
  	exit;
  end;

  res := DirectOutput_AddPage(X52Handle, PageNumber, PWideString(PageName), SetAsActive);
  case res of
    E_OUTOFMEMORY : Form1.Memo1.Lines.Add('Out of memory while adding new page.');
    E_INVALIDARG : Form1.Memo1.Lines.Add('Page ID already exists.');
		E_HANDLE : Form1.Memo1.Lines.Add('Device handle invalid.');
  end;
end;

procedure X52_RemovePage(PageNumber:LongInt);
begin
  res:=DirectOutput_RemovePage(X52Handle, PageNumber);
  case res of
    E_INVALIDARG : Form1.Memo1.Lines.Add('Page ID invalid.');
		E_HANDLE : Form1.Memo1.Lines.Add('Device handle invalid.');
  end;
end;

procedure X52_AddString(PageNumber, LineNumber : LongInt; Text:WideString);
begin
	if X52Handle<=0 then
  begin
  	Form1.Memo1.Lines.Add('Error changing line, X52 handle invalid.');
  	exit;
  end;

  res := DirectOutput_SetString(X52Handle, PageNumber, LineNumber, Length(Text), PWideString(Text));
  case res of
    E_OUTOFMEMORY : Form1.Memo1.Lines.Add('Out of memory while changing text.');
    E_INVALIDARG : Form1.Memo1.Lines.Add('Page ID invalid.');
		E_HANDLE : Form1.Memo1.Lines.Add('Device handle invalid.');
  end;
end;

procedure X52_SetLed(PageID, LedID, LedState: LongInt);
begin
	if X52Handle<=0 then
  begin
  	Form1.Memo1.Lines.Add('Error setting led, X52 handle invalid.');
  	exit;
  end;

	res := DirectOutput_SetLed(X52Handle, PageID, LedID, LedState);
  case res of
  	E_INVALIDARG : Form1.Memo1.Lines.Add('Page ID invalid.');
    E_HANDLE : Form1.Memo1.Lines.Add('Device handle invalid.');
  end;
end;

{ TLedHandlerThread }
constructor TLedHandlerThread.Create(CreateSuspended: Boolean);
var i : integer;
begin
  inherited Create(CreateSuspended);
  Self.FreeOnTerminate:=True;
  Self.Priority:=tpHigher;
	LedList:=TObjectList.Create(True);
  MFDPageChanged:=TEvent.Create(nil,True,False,'');
  ActivePage:=0;
  //Fill the list with the initial led objects
	for i := 0 to 19 do
  	LedList.Add(TLedData.Create(i));
end;

destructor TLedHandlerThread.Destroy;
begin
	LedList.Free;
  MFDPageChanged.Free;
  inherited;
end;

procedure TLedHandlerThread.Execute;
var
  I: Integer;
  Led : TLedData;
  SleepTime : integer;
begin
  SleepTime:=50;
  while not Terminated do
  begin
    // if the MFD page has changed set every LED's status to changed so they will be updated
    if MFDPageChanged.WaitFor(sleeptime) = wrSignaled then
    begin
      MFDPageChanged.ResetEvent;
      for i := 0 to LedList.Count - 1 do
        TLedData(LedList[i]).Changed:=True;
      end;

    // set the state of the leds every 50ms
    for I := 0 to LedList.Count - 1 do
    begin
    	Led:=TLedData(LedList[i]);

      if not Led.Blinking then
      begin
        if not Led.Changed then Continue; // only send to unit if the led state changed
        X52_SetLed(ActivePage, Led.LedNumber, Led.State);
        Led.Changed:=False; //reset state
      end;

      // Blinking LEDs need to be verified always to to able to actually make them blink :)
      if Led.Blinking then
      begin
        inc(Led.TimeSinceBlink, SleepTime);
        case Led.Blinking_speed of
          VERY_SLOW:  if Led.TimeSinceBlink>=500 then
                      begin
                        if Led.BlinkState=_OFF then Led.BlinkState:=_ON else Led.BlinkState:=_OFF;
                        X52_SetLed(ActivePage, Led.LedNumber, Led.BlinkState);
                        Led.TimeSinceBlink:=0;
                      end;
          SLOW:       if Led.TimeSinceBlink>=400 then
                      begin
                        if Led.BlinkState=_OFF then Led.BlinkState:=_ON else Led.BlinkState:=_OFF;
                        X52_SetLed(ActivePage, Led.LedNumber, Led.BlinkState);
                        Led.TimeSinceBlink:=0;
                      end;
          NORMAL:     if Led.TimeSinceBlink>=300 then
                      begin
                        if Led.BlinkState=_OFF then Led.BlinkState:=_ON else Led.BlinkState:=_OFF;
                        X52_SetLed(ActivePage, Led.LedNumber, Led.BlinkState);
                        Led.TimeSinceBlink:=0;
                      end;
          FAST:       if Led.TimeSinceBlink>=200 then
                      begin
                        if Led.BlinkState=_OFF then Led.BlinkState:=_ON else Led.BlinkState:=_OFF;
                        X52_SetLed(ActivePage, Led.LedNumber, Led.BlinkState);
                        Led.TimeSinceBlink:=0;
                      end;
          VERY_FAST:  if Led.TimeSinceBlink>=100 then
                      begin
                        if Led.BlinkState=_OFF then Led.BlinkState:=_ON else Led.BlinkState:=_OFF;
                        X52_SetLed(ActivePage, Led.LedNumber, Led.BlinkState);
                        Led.TimeSinceBlink:=0;
                      end;
        end; //case
      end; //else
    end; //for
  end; //while
end;

procedure TLedHandlerThread.SetLedData(Name: TLedName; Color: TLedColor; Blink: Boolean; BlinkSpeed: TLedBlinkSpeed);
begin
  //verify current state and change only if needed
  if SameState(Name, Color, Blink, BlinkSpeed) then Exit;

  case Name of
    MISSILE:          begin  // LED_MISSILE - 0
                        if Color=OFF then TLedData(LedList[0]).State:=_OFF else TLedData(LedList[0]).State:=_ON;  //color doesnt matter
                        TLedData(LedList[0]).Blinking:=Blink; TLedData(LedList[0]).Blinking_speed:=BlinkSpeed; TLedData(LedList[0]).TimeSinceBlink:=0;
                        TLedData(LedList[0]).changed:=True;
                      end;
    FIRE_A:           SetLedGroup(1,2, Color, Blink, BlinkSpeed);
    FIRE_B:           SetLedGroup(3,4, Color, Blink, BlinkSpeed);
    FIRE_D:           SetLedGroup(5,6, Color, Blink, BlinkSpeed);
    FIRE_E:           SetLedGroup(7,8, Color, Blink, BlinkSpeed);
    TOGGLE_LEFT:      SetLedGroup(9,10, Color, Blink, BlinkSpeed);
    TOGGLE_MIDDLE:    SetLedGroup(11,12, Color, Blink, BlinkSpeed);
    TOGGLE_RIGHT:     SetLedGroup(13,14, Color, Blink, BlinkSpeed);
    POV2:             SetLedGroup(15,16, Color, Blink, BlinkSpeed);
    CLUTCH:           SetLedGroup(17,18, Color, Blink, BlinkSpeed);
    THROTTLE:         begin  // LED_THROTTLE - 19
                        if Color=OFF then TLedData(LedList[19]).State:=_OFF else TLedData(LedList[19]).State:=_ON;  //color doesnt matter
                        TLedData(LedList[19]).Blinking:=Blink; TLedData(LedList[19]).Blinking_speed:=BlinkSpeed; TLedData(LedList[19]).TimeSinceBlink:=0;
                        TLedData(LedList[19]).changed:=True;
                      end;
  end;

end;

// return True if the LED is already in the given state
function TLedHandlerThread.SameState(Name: TLedName; Color: TLedColor; Blink: Boolean; BlinkSpeed: TLedBlinkSpeed) : Boolean;
var LedColorOK: Boolean;
begin
  LedColorOK:=False;

  // default return value is False, we set it to True if every parameter is the same
  Result:=False;

  case Name of
    // only one led in this, color check is different
    MISSILE:  with TLedData(LedList[0]) do
              begin
                case Color of
                  Off:    if State=_OFF then LedColorOK:=True;
                  Amber:  if State=_ON then LedColorOK:=True;
                  Red:    if State=_ON then LedColorOK:=True;
                  Green:  if State=_ON then LedColorOK:=True;
                end;
                if LedColorOK and (Blinking = Blink) and (Blinking_speed = BlinkSpeed) then Result:=True;
              end;

    // these need double checks
    FIRE_A: with TLedData(Ledlist[1]) do      // blinking is common on the connected leds, needs to be checked only once
              if RedOK(Color,1) and GreenOK(Color,2) and (Blinking = Blink) and (Blinking_speed = BlinkSpeed) then Result:=True;

    FIRE_B: with TLedData(Ledlist[3]) do
              if RedOK(Color,3) and GreenOK(Color,4) and (Blinking = Blink) and (Blinking_speed = BlinkSpeed) then Result:=True;

    FIRE_D: with TLedData(Ledlist[5]) do
              if RedOK(Color,5) and GreenOK(Color,6) and (Blinking = Blink) and (Blinking_speed = BlinkSpeed) then Result:=True;

    FIRE_E: with TLedData(Ledlist[7]) do
              if RedOK(Color,7) and GreenOK(Color,8) and (Blinking = Blink) and (Blinking_speed = BlinkSpeed) then Result:=True;

    TOGGLE_LEFT: with TLedData(Ledlist[9]) do
              if RedOK(Color,9) and GreenOK(Color,10) and (Blinking = Blink) and (Blinking_speed = BlinkSpeed) then Result:=True;

    TOGGLE_MIDDLE: with TLedData(Ledlist[11]) do
              if RedOK(Color,11) and GreenOK(Color,12) and (Blinking = Blink) and (Blinking_speed = BlinkSpeed) then Result:=True;

    TOGGLE_RIGHT: with TLedData(Ledlist[13]) do
              if RedOK(Color,13) and GreenOK(Color,14) and (Blinking = Blink) and (Blinking_speed = BlinkSpeed) then Result:=True;

    POV2: with TLedData(Ledlist[15]) do
              if RedOK(Color,15) and GreenOK(Color,16) and (Blinking = Blink) and (Blinking_speed = BlinkSpeed) then Result:=True;

    CLUTCH: with TLedData(Ledlist[17]) do
              if RedOK(Color,17) and GreenOK(Color,18) and (Blinking = Blink) and (Blinking_speed = BlinkSpeed) then Result:=True;

    // only one led in this, color check is different
    THROTTLE: with TLedData(LedList[19]) do
              begin
                case Color of
                  Off:    if State=_OFF then LedColorOK:=True;
                  Amber:  if State=_ON then LedColorOK:=True;
                  Red:    if State=_ON then LedColorOK:=True;
                  Green:  if State=_ON then LedColorOK:=True;
                end;
                if LedColorOK and (Blinking = Blink) and (Blinking_speed = BlinkSpeed) then Result:=True;
              end;
  end;
end;

//return True if the selected LED should be turned on - for red leds
function TLedHandlerThread.RedOK(Color: TLedColor; LedIndex:integer) : Boolean;
begin
  Result:=False;  //just to suppress compiler warning
  with TLedData(LedList[LedIndex]) do
    case Color of
      Off:    if State=_OFF then Result:=True else Result:=False;
      Amber:  if State=_ON then Result:=True else Result:=False;
      Red:    if State=_ON then Result:=True else Result:=False;
      Green:  if State=_ON then Result:=False else Result:=True;
    end;
end;

//return True if the selected LED should be turned on - for green leds
function TLedHandlerThread.GreenOK(Color: TLedColor; LedIndex:integer) : Boolean;
begin
  Result:=False;  //just to suppress compiler warning
  with TLedData(LedList[LedIndex]) do
    case Color of
      Off:    if State=_OFF then Result:=True else Result:=False;
      Amber:  if State=_ON then Result:=True else Result:=False;
      Red:    if State=_ON then Result:=False else Result:=True;
      Green:  if State=_ON then Result:=True else Result:=False;
    end;
end;

procedure TLedHandlerThread.SetLedGroup(Led1, Led2: integer; Color: TLedColor; Blink: Boolean; BlinkSpeed: TLedBlinkSpeed);
begin
  case Color of
    Off: begin
      with TLedData(LedList[Led1]) do
      begin
        State:=_OFF; Blinking:=False;
      end;
      with TLedData(LedList[Led2]) do
      begin
        State:=_OFF; Blinking:=False;
      end;
    end;
    Amber: begin
      with TLedData(LedList[Led1]) do
      begin
        State:=_ON; Blinking:=Blink; Blinking_speed:=BlinkSpeed;
      end;
      with TLedData(LedList[Led2]) do
      begin
        State:=_ON;  Blinking:=Blink; Blinking_speed:=BlinkSpeed;
      end;
    end;
    Red: begin
      with TLedData(LedList[Led1]) do
      begin
        State:=_ON; Blinking:=Blink; Blinking_speed:=BlinkSpeed;
      end;
      with TLedData(LedList[Led2]) do
      begin
        State:=_OFF; Blinking:=False;
      end;
    end;
    Green: begin
      with TLedData(LedList[Led1]) do
      begin
        State:=_OFF; Blinking:=False;
      end;
      with TLedData(LedList[Led2]) do
      begin
        State:=_ON; Blinking:=Blink; Blinking_speed:=BlinkSpeed;
      end;
    end;
  end;
  TLedData(LedList[Led1]).TimeSinceBlink:=0;
  TLedData(LedList[Led2]).TimeSinceBlink:=0;
  TLedData(LedList[Led1]).Changed:=True;
  TLedData(LedList[Led2]).Changed:=True; // set changed state
end;

{ TLedData }
constructor TLedData.Create(Number:integer);
begin
  inherited Create();
  with Self do
  begin
	  LedNumber:=Number;
   	State:=_OFF;
    Blinking:=False;
    Blinking_speed := NORMAL;
    BlinkState := _OFF;
    TimeSinceBlink := 0;
    Changed:=True;
  end;
end;

procedure TForm1.ResetLeds();
var Led : TLedName;
begin
  for Led := MISSILE to THROTTLE do
    LedHandlerThread.SetLedData(Led,Off,False,NORMAL);
end;

procedure TForm1.Test();
var Name : TLedName;
    Cl : TLedColor;
begin
  Name:=MISSILE;    //suppress warnings
  Cl:=Off;

  case Random(11) of
    0 : Name:=MISSILE;
    1 : Name:=FIRE_A;
    2 : Name:=FIRE_B;
    3 : Name:=FIRE_D;
    4 : Name:=FIRE_E;
    5 : Name:=TOGGLE_LEFT;
    6 : Name:=TOGGLE_MIDDLE;
    7 : Name:=TOGGLE_RIGHT;
    8 : Name:=POV2;
    9 : Name:=CLUTCH;
    10 : Name:=THROTTLE;
  end;

  case Random(4) of
    0 : Cl:=Off;
    1 : Cl:=Red;
    2 : Cl:=Green;
    3 : Cl:=Amber;
  end;

  LedHandlerThread.SetLedData(Name, Cl, False, NORMAL);
end;

{ TMFDHandlerThread }
procedure TMFDHandlerThread.AddLine(PageName:TMFDPageNames; txt: string);
var  I: Integer;
begin
  //loop through pages and add the line if the page exists
  for I := 0 to Pages.Count - 1 do
    with TNamedStringList(Pages[i]) do
      if Name = PageName then
      begin
        Add(txt);
        PageChanged:=True;
        break;
      end;
end;

procedure TMFDHandlerThread.AddPage(PageName: TMFDPageNames);
var SetPageActive : Boolean;
begin
  Pages.Add(TNamedStringList.Create(PageName));
  SetPageActive:=False;

  //first page is active
  if Pages.Count=1 then SetPageActive:=True else SetPageActive:=False;

  X52_AddPage(Pages.Count-1,'Page'+inttostr(Pages.Count-1),SetPageActive);
end;

procedure TMFDHandlerThread.ChangeLine(PageName: TMFDPageNames; LineNumber: integer; NewText: string);
var
  I: Integer;
begin
  for I := 0 to Pages.Count - 1 do
    with TNamedStringList(Pages[i]) do
    if Name = PageName then
    begin
      if Count<LineNumber+1 then break;//if line does not exists just exit

      // if exists check if really changed
      if Strings[LineNumber]=NewText then break;    // if its the same just exit

      Strings[LineNumber]:=NewText;   // if changed write new value and mark as changed
      PageChanged:=True;
      break;
    end;
end;

constructor TMFDHandlerThread.Create(CreateSuspended: Boolean);
begin
  inherited Create(CreateSuspended);
  Self.FreeOnTerminate:=True;
  Self.Priority:=tpHigher;
  Pages := TObjectList.Create(True);
  ActivePage:=0;
  SoftButtonPressed:=TEvent.Create(nil,True,False,'');   // manual reset
end;

destructor TMFDHandlerThread.Destroy;
begin
  Pages.Free;
  SoftButtonPressed.Free;
  inherited;
end;

procedure TMFDHandlerThread.Execute;
begin
  while not Terminated do
  begin
    if SoftButtonPressed.WaitFor(10) = wrSignaled then HandleKeypress();
    UpdatePages();
  end;
end;

procedure TMFDHandlerThread.HandleKeypress;
begin
  SoftButtonPressed.ResetEvent;   // reset the event signal
  case Buttons of
    SoftButton_Select	: with TNamedStringList(Pages[ActivePage]) do
                          if FirstLineOnMFD<>0 then
                          begin
                            FirstLineOnMFD:=0;
                            PageChanged:=True;
                          end;
    SoftButton_Down		  : with TNamedStringList(Pages[ActivePage]) do
                          if Count>FirstLineOnMFD+3 then
                          begin
                            if (Strings[FirstLineOnMFD+3]='') or (Strings[FirstLineOnMFD+3]=Emptyline) then exit;
                            inc(FirstLineOnMFD);   //scroll down
                            PageChanged:=True;
                          end;
    SoftButton_Up		: with TNamedStringList(Pages[ActivePage]) do
                          if FirstLineOnMFD>0 then
                          begin
                            dec(FirstLineOnMFD);         //scroll up
                            PageChanged:=True;
                          end;
    SoftButton_SelectUp : ;
    SoftButton_SelectDown : ;
  end;
end;


procedure TMFDHandlerThread.UpdatePages;
var
  i,j: Integer;
  MFDLine : integer;
begin
  // check pages for changed state and write out
  for i := 0 to Pages.Count - 1 do
  begin
    with TNamedStringList(Pages[i]) do
    begin
      if not PageChanged then Continue;
      MFDLine:=0;
      for j := FirstLineOnMFD to Count - 1 do
      begin
        X52_AddString(i,MFDLine,Strings[j]);
        inc(MFDLine);
        if MFDLine=3 then break;          // maximum of 3 lines are written out, scrolling is done by altering FirstLineOnMFD
      end;
      PageChanged:=False;  // reset flag, its written out
    end;
  end;
end;

{ TNamedStringList }
constructor TNamedStringList.Create(ListName: TMFDPageNames);
begin
  inherited Create();
  Self.Name:=ListName;
  PageChanged:=False;
  FirstLineOnMFD:=0;
end;

procedure logtodisk(loggolnivalo:string);
var logfile : Textfile;
    logfile_name : string;
begin
  logfile_name:=AppPath+'\logs\debug.log';
  if not DirectoryExists(AppPath+'\logs') then CreateDir(AppPath+'\logs');
  AssignFile(logfile, logfile_name);

  if fileexists(logfile_name) then Append(logfile) else ReWrite(logfile);

  WriteLn(logfile, FormatDateTime('hh:nn:ss.zzz',Now)+': '+loggolnivalo);
  CloseFile(logfile);
end;

function FileVersion(AFileName: string): string;
var
  szName: array[0..255] of Char;
  P: Pointer;
  Value: Pointer;
  Len: UINT;
  GetTranslationString: string;
  FFileName: PChar;
  FValid: boolean;
  FSize: DWORD;
  FHandle: DWORD;
  FBuffer: PChar;
begin
  try
    FFileName := StrPCopy(StrAlloc(Length(AFileName) + 1), AFileName);
    FValid := False;
    FSize := GetFileVersionInfoSize(FFileName, FHandle);
    if FSize > 0 then
    try
      GetMem(FBuffer, FSize);
      FValid := GetFileVersionInfo(FFileName, FHandle, FSize, FBuffer);
    except
      FValid := False;
      raise;
    end;
    Result := '';
    if FValid then
      VerQueryValue(FBuffer, '\VarFileInfo\Translation', p, Len)
    else
      p := nil;
    if P <> nil then
      GetTranslationString := IntToHex(MakeLong(HiWord(Longint(P^)),
        LoWord(Longint(P^))), 8);
    if FValid then
    begin
      StrPCopy(szName, '\StringFileInfo\' + GetTranslationString +
        '\FileVersion');
      if VerQueryValue(FBuffer, szName, Value, Len) then
        Result := StrPas(PChar(Value));
    end;
  finally
    try
      if FBuffer <> nil then
        FreeMem(FBuffer, FSize);
    except
    end;
    try
      StrDispose(FFileName);
    except
    end;
  end;
end;

end.
