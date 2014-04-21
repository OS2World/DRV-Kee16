/***************************************************************************
*
* Module Name: BSEKEE16.H
*
* OS/2 Base Include File For KEE
*
****************************************************************************
*
*
*
****************************************************************************/

#ifndef OS2DEF_INCLUDED
#define INCL_16
#define INCL_TYPES
#include <os2def.h>
#endif

#ifndef UNIKERN_INCLUDED
#include <unikern16.h>
#endif

/*------------------------------------------------------------------------*
 * Spinlocks                                                              *
 *------------------------------------------------------------------------*/

typedef struct _SpinLock_t /* SPL */
{
  char Spinlock[4];
} SpinLock_t;

VOID    APIENTRY KernAllocSpinLock16 (SpinLock_t FAR *pSpinLock);
VOID    APIENTRY KernFreeSpinLock16 (SpinLock_t FAR *pSpinLock);

VOID    APIENTRY KernAcquireSpinLock16 (SpinLock_t FAR *pSpinLock);
VOID    APIENTRY KernReleaseSpinLock16 (SpinLock_t FAR *pSpinLock);


/*------------------------------------------------------------------------*
 * Mutexlocks                                                             *
 *------------------------------------------------------------------------*/

typedef struct _MutexLock_t /* MUL */
{
  char Mutexlock[8];
} MutexLock_t;

VOID    APIENTRY KernAllocMutexLock16 (MutexLock_t FAR *pMutexLock);
VOID    APIENTRY KernFreeMutexLock16 (MutexLock_t FAR *pMutexLock);

VOID    APIENTRY KernRequestExclusiveMutex16 (MutexLock_t FAR *pMutexLock);
VOID    APIENTRY KernReleaseExclusiveMutex16 (MutexLock_t FAR *pMutexLock);
BOOL    APIENTRY KernTryRequestExclusiveMutex16 (MutexLock_t FAR *pMutexLock);

VOID    APIENTRY KernRequestSharedMutex16 (MutexLock_t FAR *pMutexLock);
VOID    APIENTRY KernReleaseSharedMutex16 (MutexLock_t FAR *pMutexLock);
BOOL    APIENTRY KernTryRequestSharedMutex16 (MutexLock_t FAR *pMutexLock);


/*------------------------------------------------------------------------*
 * copy buffer to/from user space from/to system space.                   *
 *------------------------------------------------------------------------*/
APIRET  APIENTRY KernCopyIn16 (VOID   FAR *Destination,
                               VOID   FAR *Source,
                               ULONG  Length);

APIRET  APIENTRY KernCopyOut16 (VOID   FAR *Destination,
                                VOID   FAR *Source,
                                ULONG  Length);

/*------------------------------------------------------------------------*
 * Process Management                                                     *
 *------------------------------------------------------------------------*/

/*
 * BlockFlags
 */

#define BLOCK_UNINTERRUPTABLE 0x01  /* (0000 0001B)
                                     * Block is uninterruptable
                                     */
#define BLOCK_SPINLOCK        0x02  /* (0000 0010B)
                                     * Release spinlock before BLOCK
                                     */
#define BLOCK_EXCLUSIVE_MUTEX 0x04  /* (0000 0100B)
                                     * Release exclusive mutex before BLOCK
                                     */
#define BLOCK_SHARED_MUTEX    0x08  /* (0000 1000B)
                                     * Release shared mutex before BLOCK
                                     */
#define BLOCK_NOACQUIRE       0x10  /* (0001 0000B)
                                     * Do not acquire lock after BLOCK
                                     */

APIRET APIENTRY KernBlock16 (ULONG  BlockID,      /* Non-zero block id         */
                             ULONG  Timeout,      /* Timeout in ms.            */
                             ULONG  BlockFlags,   /* Flags, see above          */
                             VOID   FAR *pLock,        /* Release lock before block */
                             ULONG  FAR *pData);       /* ptr to data from wakeup   */
/*
 * WakeupFlags
 */

#define WAKEUP_ONE   0x01  /* (0000 0001B)
                            * Wake up at most one thread
                            */
                           /* (0000 0010B)
                            * 0x02 is reserved
                            */
#define WAKEUP_BOOST 0x04  /* (0000 0100B)
                            * Boost priority of awakened threads
                            */
#define WAKEUP_DATA  0x08  /* (0000 1000B)
                            * Set wakeup data for awakened threads
                            */

VOID APIENTRY KernWakeup16 (ULONG  EventID,     /* wake threads blocked on ID */
                            ULONG  WakeupFlags, /* WakeupFlags, see above     */
                            ULONG  FAR *pNumThreads, /* Return count of threads awakened */
                            ULONG  Data);       /* Data to pass to awakened threads */

/*------------------------------------------------------------------------*
 * UniCode                                                                *
 *------------------------------------------------------------------------*/

APIRET  APIENTRY KernCreateUconvObject16 (SHORT     codepage,
                                          PUconvObj uhand);

APIRET  APIENTRY KernStrFromUcs16 (PUconvObj  co,
                                   char       FAR *target,
                                   UniChar    FAR *source,
                                   LONG       len,
                                   LONG       fromlen);

APIRET  APIENTRY KernStrToUcs16 (PUconvObj  co,
                                 UniChar    FAR *target,
                                 char       FAR *source,
                                 LONG       len,
                                 LONG       fromlen);

typedef struct _KernVMLock_t /* LH */
{
    char Lockhandle[12];
} KernVMLock_t;

APIRET  APIENTRY KernLockThunkingSeg16 (KernVMLock_t FAR *pLockHandle);
APIRET  APIENTRY KernUnlockThunkingSeg16 (KernVMLock_t FAR *pLockHandle);
ULONG APIENTRY KernKEEVersion16 (VOID); /* lower WORD: minor version, upper WORD: major version */
