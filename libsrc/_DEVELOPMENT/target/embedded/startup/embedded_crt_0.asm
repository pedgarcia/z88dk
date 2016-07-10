;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;              embedded standalone rom target               ;;
;; generated by target/embedded/startup/embedded_crt_rom.m4  ;;
;;                                                           ;;
;;                  flat 64k address space                   ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; CRT AND CLIB CONFIGURATION ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

include "../crt_defaults.inc"
include "crt_target_defaults.inc"
include "../crt_rules.inc"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; SET UP MEMORY MODEL ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

include "memory_model.inc"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; GLOBAL SYMBOLS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

include "../clib_constants.inc"
include "clib_target_constants.inc"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; INSTANTIATE DRIVERS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; The embedded target has no device drivers so it cannot
; instantiate FILEs.

; It can use sprint/sscanf + family and it can create
; memstreams in the default configuration.


; When FILEs and FDSTRUCTs are instantiated labels are assigned
; to point at created structures.
;
; The label formats are:
;
; __i_stdio_file_n     = address of static FILE structure #n (0..__I_STDIO_NUM_FILE-1)
; __i_fcntl_fdstruct_n = address of static FDSTRUCT #n (0..__I_FCNTL_NUM_FD-1)
; __i_fcntl_heap_n     = address of allocation #n on heap (0..__I_FCNTL_NUM_HEAP-1)



   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   ;; create open and closed FILE lists
   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

   ; __clib_fopen_max   = max number of open FILEs specified by user
   ; 0 = number of static FILEs instantiated in crt
   ; __i_stdio_file_n   = address of static FILE structure #n (0..I_STDIO_FILE_NUM-1)

   SECTION data_clib
   SECTION data_stdio

   IF (__clib_fopen_max > 0) || (0 > 0)

      ; number of FILEs > 0

      ; construct list of open files

      IF 0 > 0
   
         ; number of FILEs statically generated > 0
      
         SECTION data_clib
         SECTION data_stdio
      
         PUBLIC __stdio_open_file_list
      
         __stdio_open_file_list:  defw __i_stdio_file_-1
   
      ELSE
   
         ; number of FILEs statically generated = 0
   
         SECTION bss_clib
         SECTION bss_stdio
      
         PUBLIC __stdio_open_file_list
      
         __stdio_open_file_list:  defw 0

      ENDIF
   
      ; construct list of closed / available FILEs
   
      SECTION data_clib
      SECTION data_stdio
  
      PUBLIC __stdio_closed_file_list
   
      __stdio_closed_file_list:   defw 0, __stdio_closed_file_list
   
      IF __clib_fopen_max > 0

         ; create extra FILE structures
     
         SECTION bss_clib
         SECTION bss_stdio
      
         __stdio_file_extra:      defs (__clib_fopen_max - 0) * 15
      
         SECTION code_crt_init
      
            ld bc,__stdio_closed_file_list
            ld de,__stdio_file_extra
            ld l,__clib_fopen_max - 0
     
         loop:
      
            push hl
         
            EXTERN asm_p_forward_list_alt_push_front
            call asm_p_forward_list_alt_push_front
         
            ld de,15
            add hl,de
            ex de,hl
         
            pop hl
         
            dec l
            jr nz, loop

      ENDIF   

   ENDIF

   IF (__clib_fopen_max = 0) && (0 = 0)
   
      ; create empty file lists
      
      SECTION bss_clib
      SECTION bss_stdio
      
      PUBLIC __stdio_open_file_list
      __stdio_open_file_list:  defw 0
      
      SECTION data_clib
      SECTION data_stdio
      
      PUBLIC __stdio_closed_file_list
      __stdio_closed_file_list:   defw 0, __stdio_closed_file_list

   ENDIF

   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   ;; create fd table
   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   
   ; __clib_open_max  = max number of open fds specified by user
   ; 0 = number of static file descriptors created

   PUBLIC __fcntl_fdtbl
   PUBLIC __fcntl_fdtbl_size
   
   IF 0 > 0
   
      ; create rest of fd table in data segment
      
      SECTION data_fcntl_fdtable_body
      
      EXTERN ASMHEAD_data_fcntl_fdtable_body
      
      defc __fcntl_fdtbl = ASMHEAD_data_fcntl_fdtable_body
      
      IF __clib_open_max > 0
      
         SECTION data_fcntl_fdtable_body
         
         defs (__clib_open_max - 0) * 2
         defc __fcntl_fdtbl_size = __clib_open_max
      
      ELSE
      
         defc __fcntl_fdtbl_size = 0
      
      ENDIF
   
   ELSE

      IF __clib_open_max > 0
   
         ; create fd table in bss segment

         SECTION bss_clib
         SECTION bss_fcntl
         
         __fcntl_fdtbl:        defs __clib_open_max * 2
      
      ELSE
      
         ; no fd table at all
         
         defc __fcntl_fdtbl = 0
      
      ENDIF
   
      defc __fcntl_fdtbl_size = __clib_open_max
   
   ENDIF
   
   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   ;; finalize stdio heap
   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   
   ; __clib_stdio_heap_size  = desired stdio heap size in bytes
   ; 0  = byte size of static FDSTRUCTs
   ; 0   = number of heap allocations
   ; __i_fcntl_heap_n     = address of allocation #n on heap (0..__I_FCNTL_NUM_HEAP-1)

   IF 0 > 0
   
      ; static FDSTRUCTs have been allocated in the heap
      
      SECTION data_clib
      SECTION data_fcntl

      PUBLIC __stdio_heap
      
      __stdio_heap:            defw __stdio_block

      SECTION data_fcntl_stdio_heap_head
      
      __stdio_block:
      
         defb 0                ; no owner
         defb 0x01             ; mtx_plain
         defb 0                ; number of lock acquisitions
         defb 0xfe             ; spinlock (unlocked)
         defw 0                ; list of threads blocked on mutex
      
      IF __clib_stdio_heap_size > (0 + 14)
      
         ; expand stdio heap to desired size
         
         SECTION data_fcntl_stdio_heap_body
         
         __i_fcntl_heap_0:
          
            defw __i_fcntl_heap_1
            defw 0
            defw __i_fcntl_heap_-1
            defs __clib_stdio_heap_size - 0 - 14
         
         ; terminate stdio heap
         
         SECTION data_fcntl_stdio_heap_tail
         
         __i_fcntl_heap_1:   defw 0
      
      ELSE
      
         ; terminate stdio heap
      
         SECTION data_fcntl_stdio_heap_tail
      
         __i_fcntl_heap_0:   defw 0
      
      ENDIF
      
   ELSE
   
      ; no FDSTRUCTs statically created
      
      IF __clib_stdio_heap_size > 14
      
         SECTION data_clib
         SECTION data_fcntl
         
         PUBLIC __stdio_heap
         
         __stdio_heap:         defw __stdio_block
         
         SECTION bss_clib
         SECTION bss_fcntl
         
         PUBLIC __stdio_block
         
         __stdio_block:         defs __clib_stdio_heap_size
         
         SECTION code_crt_init
         
         ld hl,__stdio_block
         ld bc,__clib_stdio_heap_size
         
         EXTERN asm_heap_init
         call asm_heap_init
      
      ENDIF

   ENDIF


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; STARTUP ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SECTION CODE

PUBLIC __Start, __Exit

EXTERN _main

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; USER PREAMBLE ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

IF __crt_include_preamble

   include "crt_preamble.asm"

ENDIF

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; PAGE ZERO ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

IF (ASMPC = 0) && (__crt_org_code = 0)

   include "../crt_page_zero.inc"

ENDIF

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; CRT INIT ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

__Start:

   include "../crt_save_stack_address.inc"
   
__Restart:

   include "../crt_restart_eidi.inc"

   IF __register_sp != -1
   
      ; crt supplies sp
      
      ld sp,__register_sp

   ENDIF
   
   ; command line
   
   IF __crt_enable_commandline
   
      include "../crt_cmdline_empty.inc"
      
      IF __SDCC | __SDCC_IX | __SDCC_IY

         push hl               ; argv
         push bc               ; argc
      
      ELSE
      
         push bc               ; argc
         push hl               ; argv

      ENDIF
   
   ENDIF

   ; initialize data section

   include "../clib_init_data.inc"

   ; initialize bss section

   include "../clib_init_bss.inc"

   ; enforce code section name
   
   include "../crt_enforce_code_section_name.inc"

SECTION code_crt_init          ; user and library initialization
SECTION code_crt_main

   ; call user program
   
   call _main                  ; hl = return status

   ; run exit stack

   IF __clib_exit_stack_size > 0
   
      EXTERN asm_exit
      jp asm_exit              ; exit function jumps to __Exit
   
   ENDIF

__Exit:

   IF !(__crt_on_exit & 0x10008)
   
      ; not restarting
      
      push hl                  ; save return status
   
   ENDIF

SECTION code_crt_exit          ; user and library cleanup
SECTION code_crt_return

   ; close files
   
   include "../clib_close.inc"

   ; terminate
   
   include "../crt_exit_eidi.inc"
   include "../crt_program_exit.inc"      

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; RUNTIME VARS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

IF (__crt_on_exit & 0x1000e)

   SECTION BSS_UNINITIALIZED
   __sp_or_ret:  defw 0

ENDIF

include "../clib_variables.inc"
include "clib_target_variables.inc"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; CLIB STUBS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

include "../clib_stubs.inc"
