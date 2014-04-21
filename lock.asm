.386p

.xlist
include devhlp.inc
.list

_DATA   SEGMENT WORD PUBLIC USE16 'DATA'
       ASSUME ds:_DATA
EXTRN  C      Device_Help:DWORD
_DATA   ends

KEECode SEGMENT DWORD PUBLIC USE16 'CODE'
       ASSUME cs:KEECode
       ASSUME ds:_DATA

;APIRET  APIENTRY KernLockThunkingSeg16 (KernVMLock_t _far *pLockHandle)
;
KernLockThunkingSeg16 PROC FAR PASCAL PUBLIC
       push bp
       mov  bp,sp
       and  sp,NOT 3
       push ebx
       push esi
       push edi
       mov   ax,CODE32
       mov   dl,DevHlp_GetDescInfo
       call  DWORD PTR Device_Help    ; ecx = lin. base addr., edx = (limit+1) in bytes
       jc    short @F
       mov   ebx,ecx                  ; ebx = lin. base addr.
       mov   ecx,edx                  ; ecx = length
       movzx esi,WORD PTR [bp+6]      ; pLockHandle
       mov   ax,WORD PTR [bp+8]       ; pLockHandle+2
       mov   dl,DevHlp_VirtToLin
       call  DWORD PTR Device_Help
       jc    short @F
       mov   esi,eax                  ; esi = lin. addr. of lock handle

       mov   edi,-1                   ; we don't want page list
       mov   eax,010h                 ; long term lock,readonly,block until available
       mov   dl,DevHlp_VMLock
       call  DWORD PTR Device_Help
       jc    short @F
       xor   eax,eax

@@:
       shld edx,eax,16
       pop edi
       pop esi
       pop ebx
       mov sp,bp
       pop bp
       retf 4
KernLockThunkingSeg16 ENDP

KEECode ENDS


CODE32 SEGMENT DWORD PUBLIC USE32 'CODE'
CODE32 ENDS

END
