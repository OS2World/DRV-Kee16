.386p

KEECode SEGMENT WORD PUBLIC USE16 'CODE'
       ASSUME cs:KEECode
EXTRN C KernKEEVersion:DWORD

;ULONG APIENTRY KernKEEVersion16 (VOID)
KernKEEVersion16 PROC FAR PASCAL PUBLIC
       mov  eax,OFFSET KernKEEVersion
       shld edx,eax,16
       retf
KernKEEVersion16 ENDP

KEECode ENDS

END
