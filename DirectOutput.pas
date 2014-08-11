unit DIRECTOUTPUT;

interface
uses Windows;

const
	DLL = 'DirectOutput.dll';

//  DeviceType_X52Pro =  {0x29DAD506, 0xF93B, 0x4F20, { 0x85, 0xFA, 0x1E, 0x02, 0xC0, 0x4F, 0xAC, 0x17 } };

// Soft Buttons
  SoftButton_Select	= $00000001;
  SoftButton_Up		= $00000002;
  SoftButton_Down		= $00000004;
// Unused soft buttons
  SoftButton_Left		= $00000008;
  SoftButton_Right		= $00000010;
  SoftButton_Back		= $00000020;
  Softbutton_Increment = $00000040;
  SoftButton_Decrement = $00000080;

type
  PFN_DIRECTOUTPUT_DEVICE_CALLBACK = procedure(HDEVICE:THandle; bAdded:Boolean; PCTXT:pointer);
  PFN_DIRECTOUTPUT_SOFTBUTTON_CALLBACK = procedure(HDEVICE:THandle; DWBUTTONS:DWord; PCTXT:pointer);
  PFN_DIRECTOUTPUT_PAGE_CALLBACK = procedure(HDEVICE:THandle; DWPAGE:Dword; BACTIVATED:Boolean; PCTXT:pointer);

{///============================================================================= }
{/// functions }
{///============================================================================= }
  function DirectOutput_Initialize(const wszAppName: PWideString): HRESULT; stdcall; external DLL;
        /// Initializes the DirectOutput library.
        /// <param name="wszAppName">A null-terminated wide character string that specifies the name of the application.</param>
      	/// returns:
        /// S_OK: The call completed successfully.
        /// E_OUTOFMEMORY: Insufficient memory to complete the request.
        /// E_INVALIDARG: The argument is invalid. (According to Saitek. Not sure what would cause this in practice.)
        /// E_HANDLE: The DirectOutputManager process could not be found.
        /// This function must be called before calling any others. Call this function when you want to initialize the DirectOutput library.

  function DirectOutput_Deinitialize(): HRESULT cdecl stdcall; external DLL;
        /// Cleans up the DirectOutput library.
        /// returns
        /// S_OK: The call completed successfully.
        /// E_HANDLE: DirectOutput was not initialized or was already deinitialized.
        /// This function must be called before termination. Call this function to clean up any resources allocated by DirectOutput_Initialize.

  function DirectOutput_RegisterDeviceChangeCallback(pfnCb: PFN_DIRECTOUTPUT_DEVICE_CALLBACK; var pCtxt: pointer): HRESULT cdecl stdcall; external DLL;
        /// Registers a callback function to be called when a device is added or removed.
        /// <param name="pfnCb">A pointer to the callback function, to be called whenever a device is added or removed.</param>
        /// <param name="pCtxt">An application supplied context pointer that will be passed to the callback function.</param>
        /// returns:
        /// S_OK: The call completed successfully.
        /// E_HANDLE: DirectOutput was not initialized.
        /// Passing a NULL function pointer will disable the callback.

  function DirectOutput_Enumerate() : HRESULT cdecl stdcall; external DLL;
        /// Enumerates all currently attached DirectOutput devices.
        /// returns:
        /// S_OK: The call completed successfully.
        /// E_HANDLE: DirectOutput was not initialized.
        /// Call this third when using the Saitek SDK; it must be called after registering a device change callback via RegisterDeviceChange().

  function DirectOutput_RegisterSoftButtonChangeCallback(var hDevice: THandle; pfnCb: PFN_DIRECTOUTPUT_SOFTBUTTON_CALLBACK;
                                                          var pCtxt: pointer): HRESULT cdecl stdcall; external DLL;
        /// Registers a callback with a device, that gets called whenever a "Soft Button" is pressed or released.
        /// <param name="hDevice">A handle to a device.</param>
        /// <param name="lButtons">A pointer to the callback function to be called whenever a "Soft Button" is pressed or released.</param>
        /// <param name="lContext">An application supplied context pointer that will be passed to the callback function.</param>
        /// returns:
        /// S_OK: The call completed successfully.
        /// E_HANDLE: The device handle specified is invalid.
        /// Passing a NULL function pointer will disable the callback.

  function DirectOutput_RegisterPageChangeCallback(var hDevice: THandle; pfnCb: PFN_DIRECTOUTPUT_PAGE_CALLBACK;
                                                    var pCtxt: pointer): HRESULT cdecl stdcall; external DLL;
        /// Registers a callback with a device, that gets called whenever the active page is changed.
        /// <param name="hDevice">A handle to a device</param>
        /// <param name="pfnCb">A pointer to the callback function to be called whenever the active page is changed.</param>
        /// <param name="pCtxt">An application supplied context pointer that will be passed to the callback function.</param>
        /// returns:
        /// S_OK: The call completed successfully.
        /// E_HANDLE: The device handle specified is invalid.

  function DirectOutput_AddPage(var hDevice: THandle; dwPage: DWord;
                                 const wszValue: string; bSetAsActive: Boolean): HRESULT cdecl stdcall; external DLL;
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

  function DirectOutput_RemovePage(var hDevice: THandle; dwPage: DWord): HRESULT cdecl stdcall; external DLL;
        /// Removes a page.
        /// <param name="hDevice">A handle to a device.</param>
        /// <param name="dwPage">A numeric identifier of a page. Usually this is the 0 based number of the page.</param>
        /// returns:
        /// S_OK: The call completed successfully.
        /// E_INVALIDARG: The dwPage argument does not reference a valid page id.
        /// E_HANDLE: The device handle specified is invalid.

  function DirectOutput_SetLed(var hDevice: THandle; dwPage: DWORD; dwIndex: DWORD; dwValue: DWORD): HRESULT cdecl stdcall; external DLL;
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

  function DirectOutput_SetString(var hDevice: THandle; dwPage: DWORD; dwIndex: DWORD;
                                   cchValue: DWORD; const wszValue: WideString): HRESULT cdecl stdcall; external DLL;
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

	// DirectOutput_GetDeviceType: function(var hDevice: IN VOID; pGdDevice: OUT LPGUID): HRESULT cdecl  {$IFDEF WIN32} stdcall {$ENDIF};
				// not implemented

	// DirectOutput_GetDeviceInstance: function(var hDevice: IN VOID; pGdInstance: OUT LPGUID): HRESULT cdecl  {$IFDEF WIN32} stdcall {$ENDIF};
				// not implemented

	//  DirectOutput_SetImage: function(var hDevice: IN VOID; dwPage: IN DWORD; dwIndex: IN DWORD;
	//                                  cbValue: IN DWORD; const pbValue: PIN UNSIGNED CHAR): HRESULT cdecl  {$IFDEF WIN32} stdcall {$ENDIF};
		   // not implemented, the x52 pro does not support this

	//  DirectOutput_SetProfile: function(var hDevice: IN VOID; cchFilename: IN DWORD;
  //                                  const wszFilename: PIN WCHAR_T): HRESULT cdecl  {$IFDEF WIN32} stdcall {$ENDIF};
		  // not implemented, there is no documentation

implementation

end.
