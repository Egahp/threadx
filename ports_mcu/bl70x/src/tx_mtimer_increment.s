/**************************************************************************/
/**************************************************************************/
/**                                                                       */ 
/** ThreadX Component                                                     */ 
/**                                                                       */
/**   timer  increment                                                    */
/**                                                                       */
/**************************************************************************/
/**************************************************************************/


/* #define TX_SOURCE_CODE  */

/* Include necessary system files.  */

    MTIME_CLOCK  = 1000000                          /*!< MTIME  CLOCK 1 MHz */  
    SYSTEM_CLOCK = 1000                             /*!< SYSTEM CLOCK 1 KHz */       
    SYSTEM_CYCLE = (MTIME_CLOCK/SYSTEM_CLOCK)

    .extern     _tx_systick_increment

    .text
/**************************************************************************/ 
/*                                                                        */ 
/*  FUNCTION                                                              */ 
/*                                                                        */ 
/*    _tx_mtimer_increment                                RISC-V32/GCC    */
/*                                                                        */
/*  AUTHOR                                                                */ 
/*                                                                        */ 
/*                                                                        */ 
/*  DESCRIPTION                                                           */ 
/*                                                                        */ 
/*    This function is responsible for RISC-V32 mtime cmp increment       */ 
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
/*    _tx_initialize_low_level       Low-level Processor Initialization   */ 
/*                                                                        */ 
/*  RELEASE HISTORY                                                       */ 
/*                                                                        */ 
/*    DATE              NAME                      DESCRIPTION             */ 
/*                                                                        */ 
/*                                                                        */ 
/**************************************************************************/ 
.global     _tx_mtimer_increment
/* VOID   _tx_mtimer_increment(VOID)
{  */
_tx_mtimer_increment:
    lui     t0, 0x200B                  
    li      t2, 0xFF8
    add     t0, t0, t2                  /*!< 加载 mtime 地址 */

_tx_read_mtime:
    lw      t2, 0(t0)                   /*!< 加载 mtime [31: 0] */
    lw      t3, 4(t0)                   /*!< 加载 mtime [63:32] */
    li      t4, SYSTEM_CYCLE            /*!< 加载一次时钟数量 */

    add     t5, t2, t4                  /*!< 与 mtime [31:0] 相加 */
    lui     t0, 0x2004                  /*!< 加载 cmp 地址 */
    bltu    t2, t5, _time_no_overflow   /*!< 如果未溢出就跳转 */

    addi    t3, t3, 1                   /*!< 溢出 cmp [63:32] + 1 */
    li      t2, -1                      /*!< 加载 0xffffffff */
    sw      t2, 0(t0)                   /*!< 保存 cmp [31: 0] */
    sw      t3, 4(t0)                   /*!< 保存 cmp [63:32] */
    
_time_no_overflow:                      
    sw      t5, 0(t0)                   /*!< 保存 cmp [31: 0] */

    ret                                 /*!< 返回 */

/*
} */