#pragma once

#include "DirectOutput.h"

class CDirectOutput
{
public:
	CDirectOutput() : m_module(0),
		m_i(0), m_d(0), m_rdcc(0), m_e(0),
		m_gdt(0), m_gdi(0), m_rscc(0), m_rpcc(0),
		m_sl(0), m_ss(0), m_si(0), m_sp(0)
	{
		wchar_t* wszFilename(0);
		if (GetDirectOutputFileName(&wszFilename))
		{
#ifdef _DEBUG
			OutputDebugStringW(L"DirectOutput.dll filename : ");
			OutputDebugStringW(wszFilename);
			OutputDebugStringW(L"\n");
#endif
			m_module = LoadLibraryW(wszFilename);
			if (m_module)
			{
				m_i   = (Pfn_DirectOutput_Initialize)GetProcAddress(m_module, "DirectOutput_Initialize");
				m_d   = (Pfn_DirectOutput_Deinitialize)GetProcAddress(m_module, "DirectOutput_Deinitialize");
				m_rdcc= (Pfn_DirectOutput_RegisterDeviceChangeCallback)GetProcAddress(m_module, "DirectOutput_RegisterDeviceChangeCallback");
				m_e   = (Pfn_DirectOutput_Enumerate)GetProcAddress(m_module, "DirectOutput_Enumerate");
													
				m_gdt = (Pfn_DirectOutput_GetDeviceType)GetProcAddress(m_module, "DirectOutput_GetDeviceType");
				m_gdi = (Pfn_DirectOutput_GetDeviceInstance)GetProcAddress(m_module, "DirectOutput_GetDeviceInstance");
				m_rscc= (Pfn_DirectOutput_RegisterSoftButtonChangeCallback)GetProcAddress(m_module, "DirectOutput_RegisterSoftButtonChangeCallback");
				m_rpcc= (Pfn_DirectOutput_RegisterPageChangeCallback)GetProcAddress(m_module, "DirectOutput_RegisterPageChangeCallback");
													
				m_ap  = (Pfn_DirectOutput_AddPage)GetProcAddress(m_module, "DirectOutput_AddPage");
				m_rp  = (Pfn_DirectOutput_RemovePage)GetProcAddress(m_module, "DirectOutput_RemovePage");
				m_sl  = (Pfn_DirectOutput_SetLed)GetProcAddress(m_module, "DirectOutput_SetLed");
				m_ss  = (Pfn_DirectOutput_SetString)GetProcAddress(m_module, "DirectOutput_SetString");	
				m_si  = (Pfn_DirectOutput_SetImage)GetProcAddress(m_module, "DirectOutput_SetImage");
						 
				m_sp  = (Pfn_DirectOutput_SetProfile)GetProcAddress(m_module, "DirectOutput_SetProfile");

			} else
			{
#ifdef _DEBUG
				OutputDebugStringW(L"LoadLibrary failed\n");
#endif
			}
			delete [] wszFilename;					
		} else
		{
#ifdef _DEBUG
			OutputDebugStringW(L"GetDirectOutputFileName failed\n");
#endif
		}
	}
	~CDirectOutput()
	{
		if (m_module)
		{
			FreeLibrary(m_module);
			m_module = 0;
		}
	}
	static CDirectOutput& Instance()
	{
		static CDirectOutput inst;
		return inst;
	}
	bool GetDirectOutputFileName(wchar_t** pwszFilename)
	{
		bool bRet(false);
		HKEY hk;
		long lErr = RegOpenKeyExW(HKEY_LOCAL_MACHINE, L"SOFTWARE\\Saitek\\DirectOutput", 0, KEY_READ, &hk);
		if (ERROR_SUCCESS == lErr)
		{
			wchar_t wsz[4096] = { 0 };
			DWORD size(sizeof(wsz) - sizeof(wchar_t)); // will ensure there is a null at the end of the string
#ifdef _AMD64
			lErr = RegQueryValueExW(hk, L"DirectOutputX64", 0, 0, (LPBYTE)wsz, &size);
#else
			lErr = RegQueryValueExW(hk, L"DirectOutputX86", 0, 0, (LPBYTE)wsz, &size);
#endif
			if (ERROR_SUCCESS == lErr)
			{
				*pwszFilename = new wchar_t[1 + size / sizeof(wchar_t)];
				if (*pwszFilename)
				{
					memset(*pwszFilename, 0, size + sizeof(wchar_t));
					memcpy(*pwszFilename, wsz, size);
					bRet = true;
				}
			}
			RegCloseKey(hk);
		}
		return bRet;
	}
public:
	HRESULT Initialize			(IN const wchar_t* wszAppName)
	{
		if (m_module && m_i)
			return m_i(wszAppName);
		return E_NOTIMPL;
	}
	HRESULT Deinitialize			()
	{
		if (m_module && m_d)
			return m_d();
		return E_NOTIMPL;
	}
	HRESULT RegisterDeviceChangeCallback(IN Pfn_DirectOutput_Device_Callback pfnCb, IN void* pCtxt)
	{
		if (m_module && m_rdcc)
			return m_rdcc(pfnCb, pCtxt);
		return E_NOTIMPL;
	}
	HRESULT Enumerate			()
	{
		if (m_module && m_e)
			return m_e();
		return E_NOTIMPL;
	}

	HRESULT GetDeviceType		(IN void* hDevice, OUT LPGUID pGdDevice)
	{
		if (m_module && m_gdt)
			return m_gdt(hDevice, pGdDevice);
		return E_NOTIMPL;
	}
	HRESULT GetDeviceInstance	(IN void* hDevice, OUT LPGUID pGdInstance)
	{
		if (m_module && m_gdi)
			m_gdi(hDevice, pGdInstance);
		return E_NOTIMPL;
	}
	HRESULT RegisterSoftButtonChangeCallback(IN void* hDevice, IN Pfn_DirectOutput_SoftButton_Callback pfnCb, IN void* pCtxt)
	{
		if (m_module && m_rscc)
			return m_rscc(hDevice, pfnCb, pCtxt);
		return E_NOTIMPL;
	}
	HRESULT RegisterPageChangeCallback(IN void* hDevice, IN Pfn_DirectOutput_Page_Callback pfnCb, IN void* pCtxt)
	{
		if (m_module && m_rpcc)
			return m_rpcc(hDevice, pfnCb, pCtxt);
		return E_NOTIMPL;
	}

	HRESULT AddPage				(IN void* hDevice, IN DWORD dwPage, IN const wchar_t* wszValue, IN BOOL bSetAsActive)
	{
		if (m_module && m_ap)
			return m_ap(hDevice, dwPage, wszValue, bSetAsActive);
		return E_NOTIMPL;
	}
	HRESULT RemovePage			(IN void* hDevice, IN DWORD dwPage)
	{
		if (m_module && m_rp)
			return m_rp(hDevice, dwPage);
		return E_NOTIMPL;
	}
	HRESULT SetLed				(IN void* hDevice, IN DWORD dwPage, IN DWORD dwIndex, IN DWORD dwValue)
	{
		if (m_module && m_sl)
			return m_sl(hDevice, dwPage, dwIndex, dwValue);
		return E_NOTIMPL;
	}
	HRESULT SetString			(IN void* hDevice, IN DWORD dwPage, IN DWORD dwIndex, IN DWORD cchValue, IN const wchar_t* wszValue)
	{
		if (m_module && m_ss)
			return m_ss(hDevice, dwPage, dwIndex, cchValue, wszValue);
		return E_NOTIMPL;
	}
	HRESULT SetImage				(IN void* hDevice, IN DWORD dwPage, IN DWORD dwIndex, IN DWORD cbValue, IN const unsigned char* pbValue)
	{
		if (m_module && m_si)
			return m_si(hDevice, dwPage, dwIndex, cbValue, pbValue);
		return E_NOTIMPL;
	}

	HRESULT SetProfile			(IN void* hDevice, IN DWORD cchFilename, IN const wchar_t* wszFilename)
	{
		if (m_module && m_sp)
			return m_sp(hDevice, cchFilename, wszFilename);
		return E_NOTIMPL;
	}
	
private:
	HMODULE												m_module;

	Pfn_DirectOutput_Initialize							m_i;
	Pfn_DirectOutput_Deinitialize						m_d;
	Pfn_DirectOutput_RegisterDeviceChangeCallback		m_rdcc;
	Pfn_DirectOutput_Enumerate							m_e;

	Pfn_DirectOutput_GetDeviceType						m_gdt;
	Pfn_DirectOutput_GetDeviceInstance					m_gdi;
	Pfn_DirectOutput_RegisterSoftButtonChangeCallback	m_rscc;
	Pfn_DirectOutput_RegisterPageChangeCallback			m_rpcc;

	Pfn_DirectOutput_AddPage							m_ap;
	Pfn_DirectOutput_RemovePage							m_rp;
	Pfn_DirectOutput_SetLed								m_sl;
	Pfn_DirectOutput_SetString							m_ss;
	Pfn_DirectOutput_SetImage							m_si;

	Pfn_DirectOutput_SetProfile							m_sp;
};