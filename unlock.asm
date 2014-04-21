.386p

.xlist
include devhlp.inc
.list

_DATA   SEGMENT WORD PUBLIC USE16 'DATA'
EXTRN  C      Device_Help:DWORD
_DATA   ends

KEECode SEGMENT WORD PUBLIC USE16 'CODE'
       ASSUME cs:KEECode
       ASSUME ds:_DATA

;APIRET  APIENTRY KernUnlockThunkingSeg16 (KernVMLock_t _far *pLockHandle)
;
KernUnlockThunkingSeg16 PROC FAR PASCAL PUBLIC
       push bp
       mov  bp,sp
       and  sp,NOT 3
       push esi
       movzx esi,WORD PTR [bp+6]      ; pLockHandle
       mov   ax,WORD PTR [bp+8]       ; pLockHandle+2
       mov   dl,DevHlp_VirtToLin
       call  DWORD PTR Device_Help
       jc    short @F
       mov   esi,eax                  ; esi = lin. addr. of lock handle

       mov   dl,DevHlp_VMUnlock
       call  DWORD PTR Device_Help
       jc    short @F
       xor   eax,eax

@@:
       shld edx,eax,16
       pop esi
       mov sp,bp
       pop bp
       retf 4
KernUnlockThunkingSeg16 ENDP

KEECode ENDS


END
