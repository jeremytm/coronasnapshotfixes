# Corona SDK Snapshot Fixes

Drop-in fixes for 2 corona snapshot issues.

### Problems Fixed
1. Some items in the top and left halves of your snapshot are not rendered.
2. Snapshots going black after switching apps on Android.

### How To Use
Simply paste the code from snapshots.lua into your project somewhere before you use snapshots. Preferably in a fixes.lua file which you call before anything else.

Or require the file with:
``` lua
require("snapshots")
```


Enjoy.
