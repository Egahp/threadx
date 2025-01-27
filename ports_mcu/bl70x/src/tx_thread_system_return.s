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
/**   Thread                                                              */
/**                                                                       */
/**************************************************************************/
/**************************************************************************/

/* #define TX_SOURCE_CODE  */


/* Include necessary system files.  */

/*  #include "tx_api.h"
    #include "tx_thread.h"
    #include "tx_timer.h"  */

    .extern      _tx_thread_execute_ptr
    .extern      _tx_thread_current_ptr
    .extern      _tx_timer_time_slice
    .extern      _tx_thread_system_stack_ptr
    .extern      _tx_thread_schedule
#ifdef TX_ENABLE_EXECUTION_CHANGE_NOTIFY
    .extern      _tx_execution_thread_exit
#endif

    .text
/**************************************************************************/ 
/*                                                                        */ 
/*  FUNCTION                                               RELEASE        */ 
/*                                                                        */ 
/*    _tx_thread_system_return                           RISC-V32/GCC     */
/*                                                           6.1          */
/*  AUTHOR                                                                */ 
/*                                                                        */ 
/*    William E. Lamie, Microsoft Corporation                             */ 
/*    Tom van Leeuwen, Technolution B.V.                                  */
/*                                                                        */ 
/*  DESCRIPTION                                                           */ 
/*                                                                        */ 
/*    This function is target processor specific.  It is used to transfer */ 
/*    control from a thread back to the system.  Only a minimal context   */ 
/*    is saved since the compiler assumes temp registers are going to get */ 
/*    slicked by a function call anyway.                                  */ 
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
/*    _tx_thread_schedule                   Thread scheduling loop        */ 
/*                                                                        */ 
/*  CALLED BY                                                             */ 
/*                                                                        */ 
/*    ThreadX components                                                  */ 
/*                                                                        */ 
/*  RELEASE HISTORY                                                       */ 
/*                                                                        */ 
/*    DATE              NAME                      DESCRIPTION             */ 
/*                                                                        */ 
/*  09-30-2020      William E. Lamie        Initial Version 6.1           */ 
/*                                                                        */ 
/**************************************************************************/ 
/* VOID   _tx_thread_system_return(VOID)
{  */
    .global  _tx_thread_system_return
_tx_thread_system_return:

    /* Save minimal context on the stack.  */

    addi    sp, sp, -64                                 /*!< Allocate space on the stack - without floating point enabled */ 

    sw      x0, 0(sp)                                   /*!< Solicited stack type */ 
    sw      x1, 0x34(sp)                                /*!< Save RA */ 
    sw      x8, 0x30(sp)                                /*!< Save s0 */ 
    sw      x9, 0x2C(sp)                                /*!< Save s1 */ 
    sw      x18, 0x28(sp)                               /*!< Save s2 */ 
    sw      x19, 0x24(sp)                               /*!< Save s3 */ 
    sw      x20, 0x20(sp)                               /*!< Save s4 */ 
    sw      x21, 0x1C(sp)                               /*!< Save s5 */ 
    sw      x22, 0x18(sp)                               /*!< Save s6 */ 
    sw      x23, 0x14(sp)                               /*!< Save s7 */ 
    sw      x24, 0x10(sp)                               /*!< Save s8 */ 
    sw      x25, 0x0C(sp)                               /*!< Save s9 */ 
    sw      x26, 0x08(sp)                               /*!< Save s10 */ 
    sw      x27, 0x04(sp)                               /*!< Save s11 */ 
    csrr    t0, mstatus                                 /*!< Pickup mstatus */ 
    sw      t0, 0x38(sp)                                /*!< Save mstatus */ 


   /* Lockout interrupts. - will be enabled in _tx_thread_schedule  */

    csrci   mstatus, 0xF 
    
#ifdef TX_ENABLE_EXECUTION_CHANGE_NOTIFY
    call    _tx_execution_thread_exit                   /*!< Call the thread execution exit function */ 
#endif

    la      t0, _tx_thread_current_ptr                  /*!< Pickup address of pointer */ 
    lw      t1, 0(t0)                                   /*!< Pickup current thread pointer */ 
    la      t2,_tx_thread_system_stack_ptr              /*!< Pickup stack pointer address */ 

    /* Save current stack and switch to system stack.  */
    /* _tx_thread_current_ptr -> tx_thread_stack_ptr =  SP;
    SP = _tx_thread_system_stack_ptr;  */

    sw      sp, 8(t1)                                   /*!< Save stack pointer */ 
    lw      sp, 0(t2)                                   /*!< Switch to system stack */ 

    /* Determine if the time-slice is active.  */
    /* if (_tx_timer_time_slice)
    {  */

    la      t4, _tx_timer_time_slice                    /*!< Pickup time slice variable addr */ 
    lw      t3, 0(t4)                                   /*!< Pickup time slice value */ 
    la      t2, _tx_thread_schedule                     /*!< Pickup address of scheduling loop */ 
    beqz    t3, _tx_thread_dont_save_ts                 /*!< If no time-slice, don't save it */ 

        /* Save time-slice for the thread and clear the current time-slice.  */
        /* _tx_thread_current_ptr -> tx_thread_time_slice =  _tx_timer_time_slice;
        _tx_timer_time_slice =  0;  */

    sw      t3, 24(t1)                                  /*!< Save current time-slice for thread */ 
    sw      x0, 0(t4)                                   /*!< Clear time-slice variable */ 

    /* }  */
_tx_thread_dont_save_ts:

    /* Clear the current thread pointer.  */
    /* _tx_thread_current_ptr =  TX_NULL;  */

    sw      x0, 0(t0)                                   /*!< Clear current thread pointer */ 
    jr      t2                                          /*!< Return to thread scheduler */ 

/* }  */

