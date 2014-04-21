#/***********************************************************************/
#/*                                                                     */
#/* Driver Name: KEE16.LIB                                              */
#/*                                                                     */
#/* Source File Name: MAKEFILE                                          */
#/*                                                                     */
#/* Descriptive Name: MAKEFILE for the KEE library.                     */
#/*                                                                     */
#/* Function:                                                           */
#/*                                                                     */
#/*---------------------------------------------------------------------*/
#/*                                                                     */
#/* Change Log                                                          */
#/*                                                                     */
#/* Mark    Date      Programmer  Comment                               */
#/* ----    ----      ----------  -------                               */
#/* @nnnn   mm/dd/yy  NNN                                               */
#/*                                                                     */
#/*                                                                     */
#/***********************************************************************/

#
#       This makefile creates the OS/2 KEE16 libary
#       You can optionally generate the listing files.
#
#          make  [option]
#
#            option:     list     -> create listings
#                        kee16.lib -> create library
#            default:  create kee16.lib
#
# ******  NOTE  ******
#
#        If you are using a SED command with TAB characters, many editors
#        will expand tabs causing unpredictable results in other programs.
#
#        Documentation:
#
#        Using SED command with TABS. Besure to invoke set tab save option
#        on your editor. If you don't, the program 'xyz' will not work
#        correctly.
#

#****************************************************************************
#  Dot directive definition area (usually just suffixes)
#****************************************************************************

.SUFFIXES:
.SUFFIXES: .com .sys .exe .obj .mbj .asm .inc .def .lnk .lrf .crf .ref
.SUFFIXES: .lst .sym .map .c .h .lib

#****************************************************************************
#  Environment Setup for the component(s).
#****************************************************************************

#
# Conditional Setup Area and User Defined Macros
#

!ifndef DDK
!error DDK must be defined in environment
!endif

!ifndef TOOLKIT
!error TOOLKIT must be defined in environment
!endif

#
# Compiler Location w/ includes, libs and tools
#

INC    = $(DDK)\base\inc
H      = $(DDK)\base\h
TOOLSPATH = $(DDK)\base\tools
TKTOOLS = $(TOOLKIT)\bin


#
# Since the compiler/linker and other tools use environment
# variables ( INCLUDE, LIB, etc ) in order to get the location of files,
# the following line will check the environment for the LIFE of the
# makefile and will be specific to this set of instructions. All MAKEFILES
# are requested to use this format to insure that they are using the correct
# level of files and tools.
#

!if [SET CL=] || [SET INCLUDE=] || [set PATH=$(TKTOOLS);$(TOOLSPATH);]
!endif


#
# Compiler/tools Macros
#

AS=alp
LIBUTIL=lib

#
# Compiler and Linker Options
#


AINC   = -I:.;$(INC)
# environment variable DEBUG is used to switch between release and debug builds.
# use SET DEBUG=1 to build debug version of module.
!ifndef DEBUG
AFLAGS = -Mb
!else
AFLAGS = -Mb -Od:MS16
!endif

#****************************************************************************
# Set up Macros that will contain all the different dependencies for the
# executables and dlls etc. that are generated.
#****************************************************************************

#
#       OBJ Files
#
OBJ1 =  block.obj
OBJ2 =  mtxa.obj
OBJ3 =  mtxf.obj
OBJ4 =  mtxrele.obj
OBJ5 =  mtxrels.obj
OBJ6 =  mtxreqe.obj
OBJ7 =  mtxreqs.obj
OBJ8 =  mtxtreqe.obj
OBJ9 =  mtxtreqs.obj
OBJ10 = spna.obj
OBJ11 = spnacq.obj
OBJ12 = spnf.obj
OBJ13 = spnrel.obj
OBJ14 = strfucs.obj
OBJ15 = strtucs.obj
OBJ16 = uconv.obj
OBJ17 = wakeup.obj
OBJ18 = copyin.obj
OBJ19 = copyout.obj
OBJ20 = lock.obj
OBJ21 = unlock.obj
OBJ22 = version.obj

OBJS = $(OBJ1) $(OBJ2) $(OBJ3) $(OBJ4) $(OBJ5) $(OBJ6) $(OBJ7) $(OBJ8) $(OBJ9) $(OBJ10) $(OBJ11) $(OBJ12) $(OBJ13) $(OBJ14) $(OBJ15) $(OBJ16) $(OBJ17) $(OBJ18) $(OBJ19) $(OBJ20) $(OBJ21) $(OBJ22)
OBJL = -+$(OBJ1) -+$(OBJ2) -+$(OBJ3) -+$(OBJ4) -+$(OBJ5) -+$(OBJ6) -+$(OBJ7) -+$(OBJ8) -+$(OBJ9) -+$(OBJ10) -+$(OBJ11) -+$(OBJ12) -+$(OBJ13) -+$(OBJ14) -+$(OBJ15) -+$(OBJ16) -+$(OBJ17) -+$(OBJ18) -+$(OBJ19) -+$(OBJ20) -+$(OBJ21) -+$(OBJ22)
#
#       LIST Files
#
LIST=   block.lst mtxa.lst mtxf.lst mtxrele.lst mtxrels.lst mtxreqe.lst mtxreqs.lst mtxtreqe.lst mtxtreqs.lst \
        spna.lst spnacq.lst spnf.lst spnrel.lst strfucs.lst strtucs.lst uconv.lst wakeup.lst copyin.lst copyout.lst lock.lst unlock.lst version.lst

#****************************************************************************
#   Setup the inference rules for compiling and assembling source code to
#   object code.
#****************************************************************************


.asm.obj:
        $(AS) $(AFLAGS) $(AINC) $<

.asm.lst:
        $(AS) +Fl -Lr -Llp:0 +Lm +Ls $(AFLAGS) $(AINC) $<


#****************************************************************************
#   Target Information
#****************************************************************************
#
# This is a very important step. The following small amount of code MUST
# NOT be removed from the program. The following directive will do
# dependency checking every time this component is built UNLESS the
# following is performed:
#                    A specific tag is used -- ie. all
#
# This allows the developer as well as the B & I group to perform incremental
# build with a degree of accuracy that has not been used before.
# There are some instances where certain types of INCLUDE files must be
# created first. This type of format will allow the developer to require
# that file to be created first. In order to achive that, all that has to
# be done is to make the DEPEND.MAK tag have your required target. Below is
# an example:
#
#    depend.mak:   { your file(s) } dephold
#
# Please DON'T remove the following line
#

!include      "$(H)\version.mak"

#
# Should be the default tag for all general processing
#

all: kee16.lib

list: $(LIST)

clean:
        if exist *.cod  del *.cod
        if exist *.lnk  del *.lnk
        if exist *.obj  del *.obj
        if exist *.mbj  del *.mbj
        if exist *.map  del *.map
        if exist *.old  del *.old
        if exist *.lst  del *.lst
        if exist *.lsd  del *.lsd
        if exist *.sym  del *.sym
        if exist *.sys  del *.sys
        if exist *.dmd  del *.dmd
        if exist *.tff  del *.tff
        if exist kee16.lib  del kee16.lib
#*****************************************************************************
#   Specific Description Block Information
#*****************************************************************************

# This section would only be for specific direction as to how to create
# unique elements that are necessary to the build process. This could
# be compiling or assembling, creation of DEF files and other unique
# files.
# If all compiler and assembly rules are the same, use an inference rule to
# perform the compilation.
#

kee16.lib: $(OBJS) $(LIBS)  makefile
        $(LIBUTIL) $(LFLAGS) @<<$(@B).lnk
$@ $(OBJL),kee16.map;
<<keep

#****************************************************************************
