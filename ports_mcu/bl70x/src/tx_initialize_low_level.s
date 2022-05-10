/**************************************************************************/
/*                                                                        */
/*       Copyright (c) Microsoft Corporation. All rights reserved.        */
/*                                                                        */
/*       This software is licensed under the Microsoft Software License   */
/*       Terms for Microsoft Azure RTOS. Full text of the license can be  */
/*       found in the LICENSE file at https://aka.ms/AzureRTOS_EULA       */
/*       and in the root directory of this software.                      */
/*                                                                        */
/**************************************************************************/


/**************************************************************************/
/**************************************************************************/
/**                                                                       */ 
/** ThreadX Component                                                     */ 
/**                                                                       */
/**   Initialize                                                          */
/**                                                                       */
/**************************************************************************/
/**************************************************************************/


/* #define TX_SOURCE_CODE  */


/* Include necessary system files.  */

/*  #include "tx_api.h"
    #include "tx_initialize.h"
    #include "tx_thread.h"
    #include "tx_timer.h"  */

    .extern      _tx_thread_system_stack_ptr
    .extern      _tx_initialize_unused_memory
    .extern      _tx_thread_context_save
    .extern      _tx_thread_context_restore
    .extern      _tx_timer_interrupt
    .extern      _tx_mtimer_initialize
    .extern      _tx_mtimer_increment


    
    

    .text
/**************************************************************************/ 
/*                                                                        */ 
/*  FUNCTION                                               RELEASE        */ 
/*                                                                        */ 
/*    _tx_initialize_low_level                           RISC-V32/GCC     */
/*                                                           6.1          */
/*  AUTHOR                                                                */ 
/*                                                                        */ 
/*    William E. Lamie, Microsoft Corporation                             */ 
/*    Tom van Leeuwen, Technolution B.V.                                  */
/*                                                                        */ 
/*  DESCRIPTION                                                           */ 
/*                                                                        */ 
/*    This function is responsible for any low-level processor            */ 
/*    initialization, including setting up interrupt vectors, setting     */ 
/*    up a periodic timer interrupt source, saving the system stack       */ 
/*    pointer for use in ISR processing later, and finding the first      */ 
/*    available RAM memory address for tx_application_define.             */ 
/*                                                                        */ 
/*  INPUT                                                                 */ 
/*                                                                        */ 
/*    None                                                                */ 
/*                                                                        */ 
/*  OUTPUT                                                                */ 
/*                                                                        */ 
/*    None                                                                */ 
/*                                                                        */ 
/*  CALLS                                                                 */ 
/*                                                                        */ 
/*    None                                                                */ 
/*                                                                        */ 
/*  CALLED BY                                                             */ 
/*                                                                        */ 
/*    _tx_initialize_kernel_enter           ThreadX entry function        */ 
/*                                                                        */ 
/*  RELEASE HISTORY                                                       */ 
/*                                                                        */ 
/*    DATE              NAME                      DESCRIPTION             */ 
/*                                                                        */ 
/*  09-30-2020     William E. Lamie         Initial Version 6.1           */
/*                                                                        */ 
/**************************************************************************/ 
.global      _tx_initialize_low_level
/* VOID   _tx_initialize_low_level(VOID)
{  */
_tx_initialize_low_level:
    
    sw      sp, _tx_thread_system_stack_ptr, t0     /*!< Save system stack pointer */

    la      t0, __tx_free_memory_start              /*!< Pickup first free address */ 
    sw      t0, _tx_initialize_unused_memory, t1    /*!< Save unused memory address */ 
    
    addi    sp, sp, -16
    sw      ra, 12(sp)

    call    _tx_mtimer_initialize

    lw      ra, 12(sp)
    addi    sp, sp, 16
    ret
    

/* 
    li      a0, 1000
    li      a1, 0
    la      a2, _tx_timer_interrupt_handler

    addi    sp,sp,-16
    sw      ra,12(sp)

    call    mtimer_set_alarm_time

    lw      ra,12(sp)
    addi    sp,sp,16

    ret

*/


    /* Define the actual timer interrupt/exception handler.  */
.global      clic_mtimer_handler_Wrapper
clic_mtimer_handler_Wrapper:
.global      _tx_timer_interrupt_handler
_tx_timer_interrupt_handler:

    /* Before calling _tx_thread_context_save, we have to allocate an interrupt
       stack frame and save the current value of x1 (ra). */

    addi    sp, sp, -128                            /*!< Allocate space for all registers - without floating point enabled */ 

    sw      x1, 0x70(sp)                            /*!< Store RA */ 
    call    _tx_thread_context_save                 /*!< Call ThreadX context save */ 

    call    _tx_mtimer_increment
    /* Call the ThreadX timer routine.  */
    call    _tx_timer_interrupt                     /*!< Call timer interrupt handler */ 

    /* Timer interrupt processing is done, jump to ThreadX context restore.  */
    j       _tx_thread_context_restore              /*!< Jump to ThreadX context restore function. Note: this does not return! */ 

