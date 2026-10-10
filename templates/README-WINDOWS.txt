EIF for Windows
===============

1. Extract EIF-Windows-x64.zip to a normal folder, for example C:\EIF.
2. Double-click EIF.exe.
3. EIF starts the local backend and opens the embedded frontend automatically.
4. Keep the EIF console window open while using the application.
5. If EIF cannot start, it shows a Windows error dialog instead of closing silently.
   The same error is written to %LOCALAPPDATA%\Yunomix2834\EIF\startup-error.log.

Security defaults:
- EIF listens on 127.0.0.1 by default, so it is local to this computer.
- The session encryption key is generated automatically on first start and
  protected for the current Windows user with Windows DPAPI.

Session recovery:
- First read startup-error.log to identify the error.
- Only if the saved session is corrupt, move hddtgdt-sessions.enc out of
  %LOCALAPPDATA%\Yunomix2834\EIF, then restart EIF and sign in again.
- Keep the moved file as a backup. Other startup errors do not require a session reset.
