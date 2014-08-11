#ifndef DIRECTOUTPUT_H
#define DIRECTOUTPUT_H

#pragma once

#ifdef __cplusplus
extern "C" {
#endif

//=============================================================================
// constants
//=============================================================================

// Device Type Guids
// {29DAD506-F93B-4f20-85FA-1E02C04FAC17}
static const GUID DeviceType_X52Pro		= { 0x29DAD506, 0xF93B, 0x4F20, { 0x85, 0xFA, 0x1E, 0x02, 0xC0, 0x4F, 0xAC, 0x17 } };

// Soft Buttons
static const DWORD SoftButton_Select	= 0x00000001;
static const DWORD SoftButton_Up		= 0x00000002;
static const DWORD SoftButton_Down		= 0x00000004;
// Unused soft buttons
static const DWORD SoftButton_Left		= 0x00000008;
static const DWORD SoftButton_Right		= 0x00000010;
static const DWORD SoftButton_Back		= 0x00000020;
static const DWORD Softbutton_Increment = 0x00000040;
static const DWORD SoftButton_Decrement = 0x00000080;

//=============================================================================
// callbacks
//=============================================================================

typedef void (__stdcall *Pfn_DirectOutput_Device_Callback)(IN void* hDevice, IN bool bAdded, IN void* pCtxt);
typedef void (__stdcall *Pfn_DirectOutput_SoftButton_Callback)(IN void* hDevice, IN DWORD dwButtons, IN void* pCtxt);
typedef void (__stdcall *Pfn_DirectOutput_Page_Callback)(IN void* hDevice, IN DWORD dwPage, IN bool bActivated, IN void* pCtxt);

//=============================================================================
// functions
//=============================================================================

HRESULT __stdcall DirectOutput_Initialize			(IN const wchar_t* wszAppName);
HRESULT __stdcall DirectOutput_Deinitialize			();
HRESULT __stdcall DirectOutput_RegisterDeviceChangeCallback(IN Pfn_DirectOutput_Device_Callback pfnCb, IN void* pCtxt);
HRESULT __stdcall DirectOutput_Enumerate			();

HRESULT __stdcall DirectOutput_GetDeviceType		(IN void* hDevice, OUT LPGUID pGdDevice);
HRESULT __stdcall DirectOutput_GetDeviceInstance	(IN void* hDevice, OUT LPGUID pGdInstance);
HRESULT __stdcall DirectOutput_RegisterSoftButtonChangeCallback(IN void* hDevice, IN Pfn_DirectOutput_SoftButton_Callback pfnCb, IN void* pCtxt);
HRESULT __stdcall DirectOutput_RegisterPageChangeCallback(IN void* hDevice, IN Pfn_DirectOutput_Page_Callback pfnCb, IN void* pCtxt);

HRESULT __stdcall DirectOutput_AddPage				(IN void* hDevice, IN DWORD dwPage, IN const wchar_t* wszValue, IN BOOL bSetAsActive);
HRESULT __stdcall DirectOutput_RemovePage			(IN void* hDevice, IN DWORD dwPage);
HRESULT __stdcall DirectOutput_SetLed				(IN void* hDevice, IN DWORD dwPage, IN DWORD dwIndex, IN DWORD dwValue);
HRESULT __stdcall DirectOutput_SetString			(IN void* hDevice, IN DWORD dwPage, IN DWORD dwIndex, IN DWORD cchValue, IN const wchar_t* wszValue);
HRESULT __stdcall DirectOutput_SetImage				(IN void* hDevice, IN DWORD dwPage, IN DWORD dwIndex, IN DWORD cbValue, IN const unsigned char* pbValue);

HRESULT __stdcall DirectOutput_SetProfile			(IN void* hDevice, IN DWORD cchFilename, IN const wchar_t* wszFilename);

//=============================================================================
// function pointers
//=============================================================================

typedef HRESULT (__stdcall *Pfn_DirectOutput_Initialize)		(IN const wchar_t* wszAppName);
typedef HRESULT (__stdcall *Pfn_DirectOutput_Deinitialize)		();
typedef HRESULT (__stdcall *Pfn_DirectOutput_RegisterDeviceChangeCallback)(IN Pfn_DirectOutput_Device_Callback pfnCb, IN void* pCtxt);
typedef HRESULT (__stdcall *Pfn_DirectOutput_Enumerate)			();

typedef HRESULT (__stdcall *Pfn_DirectOutput_GetDeviceType)		(IN void* hDevice, OUT LPGUID pGdDevice);
typedef HRESULT (__stdcall *Pfn_DirectOutput_GetDeviceInstance)	(IN void* hDevice, OUT LPGUID pGdInstance);
typedef HRESULT (__stdcall *Pfn_DirectOutput_RegisterSoftButtonChangeCallback)(IN void* hDevice, IN Pfn_DirectOutput_SoftButton_Callback pfnCb, IN void* pCtxt);
typedef HRESULT (__stdcall *Pfn_DirectOutput_RegisterPageChangeCallback)(IN void* hDevice, IN Pfn_DirectOutput_Page_Callback pfnCb, IN void* pCtxt);

typedef HRESULT (__stdcall *Pfn_DirectOutput_AddPage)			(IN void* hDevice, IN DWORD dwPage, IN const wchar_t* wszValue, IN BOOL bSetAsActive);
typedef HRESULT (__stdcall *Pfn_DirectOutput_RemovePage)		(IN void* hDevice, IN DWORD dwPage);
typedef HRESULT (__stdcall *Pfn_DirectOutput_SetLed)			(IN	void* hDevice, IN DWORD dwPage, IN DWORD dwIndex, IN DWORD dwValue);
typedef HRESULT (__stdcall *Pfn_DirectOutput_SetString)			(IN void* hDevice, IN DWORD dwPage, IN DWORD dwIndex, IN DWORD cchValue, IN const wchar_t* wszValue);
typedef HRESULT (__stdcall *Pfn_DirectOutput_SetImage)			(IN void* hDevice, IN DWORD dwPage, IN DWORD dwIndex, IN DWORD cbValue, IN const unsigned char* pbValue);

typedef HRESULT (__stdcall *Pfn_DirectOutput_SetProfile)		(IN void* hDevice, IN DWORD cchFilename, IN const wchar_t* wszFilename);

//=============================================================================

#ifdef __cplusplus
};
#endif


#endif