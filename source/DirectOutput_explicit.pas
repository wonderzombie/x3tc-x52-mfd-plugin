unit DirectOutput_explicit;

interface
uses Windows, Dialogs, SysUtils;

const
  X52PRO_GUID : TGuid = '{29DAD506-F93B-4F20-85FA-1E02C04FAC17}';

// the callback functions
type
  PFN_DIRECTOUTPUT_DEVICE_CALLBACK = procedure(hDevice:LongInt; bAdded: Boolean; lContext: LongInt); stdcall;
  PFN_DIRECTOUTPUT_SOFTBUTTON_CALLBACK = procedure (hDevice, lButtons, lContext: Longint); stdcall;
  PFN_DIRECTOUTPUT_PAGE_CALLBACK = procedure(hDevice, lPage : LongInt; bActivated: Boolean; lContext: Longint); stdcall;

  procedure FreeDLL;
  procedure LoadDLL(PathToDll: WideString);

var
	DllLoaded : Boolean = False;

  /// Initializes the DirectOutput library.
  /// <param name="wszAppName">A null-terminated wide character string that specifies the name of the application.</param>
  /// returns:
  /// S_OK: The call completed successfully.
  /// E_OUTOFMEMORY: Insufficient memory to complete the request.
  /// E_INVALIDARG: The argument is invalid. (According to Saitek. Not sure what would cause this in practice.)
  /// E_HANDLE: The DirectOutputManager process could not be found.
  /// This function must be called before calling any others. Call this function when you want to initialize the DirectOutput library.
  DirectOutput_Initialize : function(const wszAppName: PWideString): HRESULT cdecl stdcall;

  /// Cleans up the DirectOutput library.
  /// returns
  /// S_OK: The call completed successfully.
  /// E_HANDLE: DirectOutput was not initialized or was already deinitialized.
  /// This function must be called before termination. Call this function to clean up any resources allocated by DirectOutput_Initialize.
  DirectOutput_Deinitialize : function(): HRESULT cdecl stdcall;

  /// Registers a callback function to be called when a device is added or removed.
  /// <param name="pfnCb">A pointer to the callback function, to be called whenever a device is added or removed.</param>
  /// <param name="pCtxt">An application supplied context pointer that will be passed to the callback function.</param>
  /// returns:
  /// S_OK: The call completed successfully.
  /// E_HANDLE: DirectOutput was not initialized.
  /// Passing a NULL function pointer will disable the callback.
  DirectOutput_RegisterDeviceChangeCallback : function (pfnCb: PFN_DIRECTOUTPUT_DEVICE_CALLBACK; pCtxt: LongInt): HRESULT cdecl stdcall;

  /// Enumerates all currently attached DirectOutput devices.
  /// returns:
  /// S_OK: The call completed successfully.
  /// E_HANDLE: DirectOutput was not initialized.
  /// Call this third when using the Saitek SDK; it must be called after registering a device change callback via RegisterDeviceChange().
  DirectOutput_Enumerate : function(): HRESULT cdecl stdcall;

  /// Registers a callback with a device, that gets called whenever a "Soft Button" is pressed or released.
  /// <param name="hDevice">A handle to a device.</param>
  /// <param name="lButtons">A pointer to the callback function to be called whenever a "Soft Button" is pressed or released.</param>
  /// <param name="lContext">An application supplied context pointer that will be passed to the callback function.</param>
  /// returns:
  /// S_OK: The call completed successfully.
  /// E_HANDLE: The device handle specified is invalid.
  /// Passing a NULL function pointer will disable the callback.
  DirectOutput_RegisterSoftButtonChangeCallback : function (hDevice: LongInt; pfnCb: PFN_DIRECTOUTPUT_SOFTBUTTON_CALLBACK;
                                                            pCtxt: Longint): HRESULT cdecl stdcall;

  /// Registers a callback with a device, that gets called whenever the active page is changed.
  /// <param name="hDevice">A handle to a device</param>
  /// <param name="pfnCb">A pointer to the callback function to be called whenever the active page is changed.</param>
  /// <param name="pCtxt">An application supplied context pointer that will be passed to the callback function.</param>
  /// returns:
  /// S_OK: The call completed successfully.
  /// E_HANDLE: The device handle specified is invalid.
	DirectOutput_RegisterPageChangeCallback : function (hDevice: LongInt; pfnCb: PFN_DIRECTOUTPUT_PAGE_CALLBACK;
                                                      pCtxt: LongInt): HRESULT cdecl stdcall;

  /// Adds a page to the specified device.
  /// <param name="hDevice">A handle to a device.</param>
  /// <param name="dwPage">A numeric identifier of a page. Usually this is the 0 based number of the page.</param>
  /// <param name="wszValue">A string that specifies the name of this page.</param>
  /// <param name="bSetAsActive">If this is true, then this page will become the active page. If false, this page will not change the active page.</param>
  /// returns:
  /// S_OK: The call completed successfully.
  /// E_OUTOFMEMORY: Insufficient memory to complete the request.
  /// E_INVALIDARG: The dwPage parameter already exists.
  /// E_HANDLE: The device handle specified is invalid.
  /// Only one page per application should have bSetActive set to true.
  /// The driver-defined default page is 0; adding another page 0 will overwrite the default page.
  DirectOutput_AddPage : function(hDevice: LongInt; dwPage: LongInt;
                                 wszValue: PWideString; bSetAsActive: Boolean): HRESULT cdecl stdcall;

  /// Removes a page.
  /// <param name="hDevice">A handle to a device.</param>
  /// <param name="dwPage">A numeric identifier of a page. Usually this is the 0 based number of the page.</param>
  /// returns:
  /// S_OK: The call completed successfully.
  /// E_INVALIDARG: The dwPage argument does not reference a valid page id.
  /// E_HANDLE: The device handle specified is invalid.
  DirectOutput_RemovePage : function(hDevice: LongInt; dwPage: Longint): HRESULT cdecl stdcall;

  /// Sets the state of a given LED indicator.
  /// <param name="hDevice">A handle to a device.</param>
  /// <param name="dwPage">A numeric identifier of a page. Usually this is the 0 based number of the page.</param>
  /// <param name="dwIndex">A numeric identifier of the LED. Refer to the data sheet for each device to determine what LEDs are present.</param>
  /// <param name="dwValue">The numeric value of a given state of a LED. For the x52 Pro, 0 is off and 1 is on.</param>
  /// returns:
  /// S_OK: The call completes successfully.
  /// E_INVALIDARG: The dwPage argument does not reference a valid page id, or the dwLed argument does not specifiy a valid LED id.
  /// E_HANDLE: The device handle specified is invalid.
  /// To make a button's LED appear amber, enable both the Red and Yellow LEDs for that button.
  DirectOutput_SetLed : function(hDevice: LongInt; dwPage: Longint; dwIndex: Longint; dwValue: Longint): HRESULT cdecl stdcall;

  /// Sets text strings on the MFD.
  /// <param name="hDevice">A handle to a device.</param>
  /// <param name="dwPage">A numeric identifier of a page. Usually this is the 0 based number of the page.</param>
  /// <param name="dwIndex">A numeric identifier of the string. Refer to the data sheet for each device to determine what strings are present.</param>
  /// <param name="cchValue">The number of wide characters in the string.</param>
  /// <param name="wszValue">A null-terminated wide character string that specifies the value to display. Providing a null pointer will clear the string.</param>
  /// returns:
  /// S_OK: The call completed successfully.
  /// E_INVALIDARG: The dwPage argument does not reference a valid page id, or the dwString argument does not reference a valid string id.
  /// E_OUTOFMEMORY: Insufficient memory to complete the request.
  /// E_HANDLE: The device handle specified is invalid.
  /// AddPage() needs to be called before a string can be displayed.
  /// The x52 Pro has only 3 lines/page, and any string longer than 16 characters will automatically scroll.
  DirectOutput_SetString : function(hDevice, dwPage, dwIndex, cchValue: Longint; wszValue: PWideString): HRESULT cdecl stdcall;

  // pGdDevice & pGdInstance are pointers to a GUID structure:
  {  The LPGUID structure represents a long pointer to a GUID.
  typedef struct _GUID
    ULONG  Data1;
    USHORT  Data2;
    USHORT  Data3;
    UCHAR  Data4[8];  }

	DirectOutput_GetDeviceType: function(hDevice: LongInt; pGdDevice: pointer): HRESULT cdecl stdcall;

  DirectOutput_GetDeviceInstance: function(hDevice: LongInt; pGdInstance: pointer): HRESULT cdecl stdcall;

  // not implemented:
	// DirectOutput_SetImage: function(var hDevice: IN VOID; dwPage: IN Longint; dwIndex: IN Longint;
	//                                  cbValue: IN Longint; const pbValue: PIN UNSIGNED CHAR): HRESULT cdecl  {$IFDEF WIN32} stdcall {$ENDIF};
	// DirectOutput_SetProfile: function(var hDevice: IN VOID; cchFilename: IN Longint;
  //                                  const wszFilename: PIN WCHAR_T): HRESULT cdecl  {$IFDEF WIN32} stdcall {$ENDIF};

implementation
uses main;
var
  SaveExit: pointer;
  DLLHandle: THandle;

procedure UnloadLibrary; far;
begin
  ExitProc := SaveExit;
  FreeLibrary(DLLHandle);
end {NewExit};

procedure FreeDLL;
begin
  if DLLLoaded then
  begin
    UnloadLibrary();
    DLLLoaded:=False;
  end;
end;

procedure LoadDLL(PathToDll: WideString);
begin
  if DLLLoaded then Exit;
  DLLHandle := LoadLibrary(PWideChar(PathToDll));
  if DLLHandle >= 32 then
  begin
    DLLLoaded := True;
    SaveExit := ExitProc;
    ExitProc := @UnloadLibrary;

    @DirectOutput_Initialize := GetProcAddress(DLLHandle,'DirectOutput_Initialize');
    Assert(@DirectOutput_Initialize <> nil);

    @DirectOutput_Deinitialize := GetProcAddress(DLLHandle,'DirectOutput_Deinitialize');
    Assert(@DirectOutput_Deinitialize <> nil);

    @DirectOutput_RegisterDeviceChangeCallback := GetProcAddress(DLLHandle,'DirectOutput_RegisterDeviceChangeCallback');
    Assert(@DirectOutput_RegisterDeviceChangeCallback <> nil);

    @DirectOutput_Enumerate := GetProcAddress(DLLHandle,'DirectOutput_Enumerate');
    Assert(@DirectOutput_Enumerate <> nil);

    @DirectOutput_RegisterSoftButtonChangeCallback := GetProcAddress(DLLHandle,'DirectOutput_RegisterSoftButtonChangeCallback');
    Assert(@DirectOutput_RegisterSoftButtonChangeCallback <> nil);

    @DirectOutput_RegisterPageChangeCallback := GetProcAddress(DLLHandle,'DirectOutput_RegisterPageChangeCallback');
    Assert(@DirectOutput_RegisterPageChangeCallback <> nil);

    @DirectOutput_AddPage := GetProcAddress(DLLHandle,'DirectOutput_AddPage');
    Assert(@DirectOutput_AddPage <> nil);

    @DirectOutput_RemovePage := GetProcAddress(DLLHandle,'DirectOutput_RemovePage');
    Assert(@DirectOutput_RemovePage <> nil);

    @DirectOutput_SetLed := GetProcAddress(DLLHandle,'DirectOutput_SetLed');
    Assert(@DirectOutput_SetLed <> nil);

    @DirectOutput_SetString := GetProcAddress(DLLHandle,'DirectOutput_SetString');
    Assert(@DirectOutput_SetString <> nil);

    @DirectOutput_GetDeviceType := GetProcAddress(DLLHandle,'DirectOutput_GetDeviceType');
    Assert(@DirectOutput_GetDeviceType <> nil);

    @DirectOutput_GetDeviceInstance := GetProcAddress(DLLHandle,'DirectOutput_GetDeviceInstance');
    Assert(@DirectOutput_GetDeviceInstance <> nil);

//      @DirectOutput_SetImage := GetProcAddress(DLLHandle,'DirectOutput_SetImage');
//      Assert(@DirectOutput_SetImage <> nil);

//      @DirectOutput_SetProfile := GetProcAddress(DLLHandle,'DirectOutput_SetProfile');
//      Assert(@DirectOutput_SetProfile <> nil);
  end
  else
    begin
      DLLLoaded := False;
      { Error: DIRECTOUTPUT.DLL could not be loaded !! }
      Form1.Memo1.Lines.add('Error loading DirectOutput.dll, error code: '+InttoStr(GetLastError));
    end;
end;


begin
  // LoadDLL;    // this is called from the main app instead after letting the user to set the path
end.

