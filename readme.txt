TERMINOLOGY
"nested/recursive call": a thread acquires a spinlock/mutex while it has already acquired this very same spinlock/mutex

"critical section": a piece of code from which you manipulate data that you don't want to have altered from another thread executing concurrently

"task thread context": a thread that will execute the strategy section, an IDC call, a context hook handler or any other device driver entry
point except for interrupt handler or timer tick handler

"interrupt thread context": a thread that will execute from an interrupt handler or a timer tick handler (!), be aware that this includes all
subfunctions called from the interrupt handler / timer tick handler ! On the other hand: a context hook handler runs in "task thread" context


WHAT IS IT
"KEE" is the "kernel execution environment", a set of functions like kernel mutexes and the like that you will need when you write a multi-core compliant device driver
KEE16 is a static library that contains thunking code to call the 32-bit KEE API from a 16-bit driver.


HOW TO USE
a) normally you will have an the assembly stub that controls the segment ordering. Add this to your segment ordering assembly stub:
KEECode  segment word public 'CODE'
KEECode  ends

and then add segment "KEECode" to CGROUP like so:
CGROUP  GROUP   RMCode, KEECode, LIBCODE, Code, _TEXT

c) include "dhcalls.h" (from the DDK) and then "bsekee16.h" in your source code. Make sure that directory path of "bsekee16.h"
is listed in the INCLUDE directories for the compiler

b) link to "kee16.lib". Additionally you will also need to link to the 32-bit KEE import library "kee.lib" as "kee16.lib" references the 32-bit KEE functions.
You will find the 32-bit KEE import library in the DDK source tree:
ddk\base32\rel\os2c\lib\os2\kee.lib

Finally, also link to os2286p.lib.

c) for the linker definition file add something like this to the segment definition section:
KEECode        CLASS 'CODE'     PRELOAD
CODE32         CLASS 'CODE'     PRELOAD
if you also use routines "KernLockThunkingSeg16,KernUnlockThunkingSeg16" (see below) then change 2. line to:
CODE32         CLASS 'CODE'     PRELOAD ALIAS
you HAVE to use a 32-bit linker like link386.exe in order to be able to link
also change the module type from LIBRARY to PHYSICAL DEVICE like this:
PHYSICAL DEVICE myDevice


HOW TO BUILD
see sources and makefile. You might need to adjust the makefile to your directory structure. You need "alp.exe" from the OS/2 toolkit and "lib.exe" from the DDK in order to assemble the files and build the static library.

FUNCTION EXPLANATION
For function explanations, see the contained HTML file "kee.html".
Note: not all 32-bit KEE functions have been provided with a thunking function in kee16.lib. I skipped those functions that have a fully equivalent DevHelp function counterpart or those that are not relevant for a 16-bit device driver.


FUNCTION PROPERTIES
all routines:
    you cannot debug across any of the routines (at least when you use ICAT via UDP), your system will hang completely if you try

KernAllocSpinLock16, KernFreeSpinLock16:
a)  SpinLock needs to be allocated in the data segment and not on the stack !

KernAcquireSpinLock16,KernReleaseSpinLock16:
a)  these routines CANNOT be called nested/recursively !
b)  interrupts will be globally DISABLED in between the calls to KernAcquireSpinLock16/KernReleaseSpinLock16:
    therefore you can use these Spinlocks to serialize access between interrupt thread / task thread context
    on the other hand, try to avoid these functions if you have lengthy processing to do as interrupts will be globally disabled
    during that time 
c)  you cannot debug in between calls to KernAcquireSpinLock16,KernReleaseSpinLock16 (at least when you use ICAT via UDP),
    the system will hang completely if you try:
d)  once you enter the critical section (to protect) DO NOT call DevHelp_Block,DevHelp_Yield directly or indirectly:
    use KernBlock16 instead, see further below

KernAllocMutexLock16,KernFreeMutexLock16:
a)  MutexLock needs to be allocated in the data segment and not on the stack !

KernRequestExclusiveMutex16,KernReleaseExclusiveMutex16:
a)  these routines can be called nested/recursively, you have to call KernReleaseExclusiveMutex16 as many times as 
    you have called KernRequestExclusiveMutex16
b)  interrupts will remain ENABLED in between the calls to KernRequestExclusiveMutex16,KernReleaseExclusiveMutex16:
    therefore you CANNOT use these Mutexlocks to serialize access between interrupt thread / task thread context !
c)  once you enter the critical section (to protect) DO NOT call DevHelp_Block,DevHelp_Yield directly or indirectly:
    use KernBlock16 instead, see further below

KernRequestSharedMutex16,KernReleaseSharedMutex16:
a)  these routines can be called nested/recursively, you have to call KernReleaseSharedMutex16 as many times as 
    you have called KernRequestSharedMutex16
b)  interrupts will remain ENABLED in between the calls to KernRequestSharedMutex16,KernReleaseSharedMutex16:
    therefore you CANNOT use these Mutexlocks to serialize access between interrupt thread / task thread context !
c)  once you enter the critical section (to protect) DO NOT call DevHelp_Block,DevHelp_Yield directly or indirectly:
    use KernBlock16 instead, see further below

  
KernRequestExclusiveMutex16,KernReleaseExclusiveMutex16,KernRequestSharedMutex16,KernReleaseSharedMutex16:
a)  this set implements reader/writer mutex when invoked on the VERY SAME mutex:
    the "Shared" Variants will not block on a subsequent use of "Shared" Variant:
    use these if you only want to read but not modify data in the protected critical section
    the "Shared" Variants WILL block when used if the "Exclusive" Variant has been called before:
    use "Exclusive if you want to modify data in the protected critical section
    the "Exclusive" Variants WILL block when used if the "Exclusive" Variant has been called before
    Example:
    KernRequestSharedMutex16(&Mutex);    /* called from thread A: thread A will now enter its critical section */
    KernRequestSharedMutex16(&Mutex);    /* called from thread B: thread B will NOT block and enter its critical section */
    KernRequestExclusiveMutex16(&Mutex); /* called from thread C: thread C will block until thread A and B release */
    KernRequestExclusiveMutex16(&Mutex); /* called from thread D: thread D will block until thread A and B and C release */
    KernReleaseSharedMutex16(&Mutex);    /* called from thread A  thread A will now leave its critical section */
    KernReleaseSharedMutex16(&Mutex);    /* called from thread B: thread B will now leave its critical section, thread C will now enter its critical section */
    KernReleaseExclusiveMutex(&Mutex);   /* called from thread C: thread C will now leave its critical section, thread D will now enter its critical section */
    KernReleaseExclusiveMutex(&Mutex);   /* called from thread D: thread D will now leave its critical section */
    KernRequestExclusiveMutex16(&Mutex); /* called from thread A: thread A will now enter its critical section */
    KernRequestSharedMutex16(&Mutex);    /* called from thread B: thread B will block */
    KernReleaseExclusiveMutex16(&Mutex); /* called from thread A: thread A will now leave its critical section, thread B will now enter its critical section */
    KernReleaseSharedMutex16(&Mutex);    /* called from thread b: thread B will now leave its critical section */

KernTryRequestExclusiveMutex16:
a)  will work the same as KernRequestExclusiveMutex16 if the Mutex is available, otherwise it will return WITHOUT blocking with indication of error

KernTryRequestSharedMutex16:
a)  will work the same as KernRequestSharedMutex16 if the Mutex is available, otherwise it will return WITHOUT blocking with indication of error

KernBlock16,KernWakeup16:
a)  these will work much like DevHelp_Block,DevHelp_Run with the exception that if you hold a spinlock, a shared mutex or an exclusive mutex
    you can specify the handle in the call to KernBlock16 (in the pLock parameter). The spinlock/mutex will then be freed on entry to KernBlock16
    and reacquired once KernBlock16 returns. The intention is to allow another thread blocking on that semaphore/mutex to 
    run while your thread is being blocked anyway

KernLockThunkingSeg16,KernUnlockThunkingSeg16:
a)  these routines will lock in memory the 32-bit segment that contains the thunking code, however calling these routines should NEVER be necessary
    as, in contrast to what many mixed 16-bit/32-bit driver samples seem to imply, the 32-bit segments are ALWAYS resident in memory, that is, they will
    never be swapped to disk or moved in memory anyways therefore there is no need to explicitely lock these segments.
    If you think you need to use these functions, call KernLockThunkingSeg16 BEFORE you use any of the other functions in this package.
    KernUnlockThunkingSeg16 should only be called if you want to abort driver loading or the like.

KernKEEVersion16:
returns the KEE version info: major version in upper 16-bits, minor version in the lower 16-bits:
ULONG  version = KernKEEVersion16();
USHORT majorVersion = HIUSHORT(version);
USHORT minorVersion = LOUSHORT(version);
Currently, the KEE version number is 1.0.

KernCreateUconvObject16,KernStrFromUcs16,KernStrToUcs16:
a)  these routines cannot be called from INIT or BASEDEVINIT strategy routine. They can be called
    on INITCOMPLETE at the earliest. In order for the UniCode functions to work you have to have
    UNICODE.SYS loaded through config.sys (which is also the reason why you cannot use these
    functions on INIT or BASEDEVINIT).