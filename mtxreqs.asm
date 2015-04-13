.386p

KEECode SEGMENT WORD PUBLIC USE16 'CODE'
       ASSUME cs:KEECode
EXTRN  PASCAL DOS32FLATDS:ABS

;VOID APIENTRY KernRequestSharedMutex16(MutexLock_t _far *pMutexLock)
KernRequestSharedMutex16 PROC FAR PASCAL PUBLIC
       push bp
       mov  bp,sp
       jmp  FAR32 PTR FLAT:label32
label16 LABEL FAR16
       mov sp,bp
       pop bp
       retf 4
KernRequestSharedMutex16 ENDP

KEECode ENDS

CODE32 SEGMENT DWORD PUBLIC USE32 'CODE'
       ASSUME ds:FLAT
       ASSUME es:FLAT
EXTRN  SYSCALL KernThunkStackTo16:PROC
EXTRN  SYSCALL KernThunkStackTo32:PROC
EXTRN  SYSCALL KernSelToFlat:PROC
EXTRN  SYSCALL KernRequestSharedMutex:PROC 

label32 LABEL FAR32
       and  ebp,0FFFFh                  ; KernThunkStackTo32 expects upper 16 bits
       and  esp,0FFFCh                  ; of EBP and ESP to be zero ! That is not always the case ! Also: align stack to 4 bytes !
       push ebx
       push esi
       push edi
       push ds
       mov  eax,DOS32FLATDS
       mov  ds,eax                      ; KEE functions need flat selector set in DS
       mov  es,eax                      ; W4 kernel also needs flat selector set in ES !
       call KernThunkStackTo32          ; trashes eax,edx
       push DWORD PTR [ebp+6]           ; pMutexLock
       call KernSelToFlat
       mov  [esp],eax
       call KernRequestSharedMutex
       add  esp,4
       mov  ebx,eax                     ; save return code
       call KernThunkStackTo16          ; trashes eax,edx
       mov  eax,ebx
       shld edx,eax,16                  ; dx:ax = eax = return code
       pop ds
       pop edi
       pop esi
       pop ebx
       jmp  FAR16 PTR KEECode:label16

CODE32 ENDS

END
