/**************************************************************************/
/**************************************************************************/
/**                                                                       */ 
/** ThreadX Component                                                     */ 
/**                                                                       */
/**   timer  initialize                                                   */
/**                                                                       */
/**************************************************************************/
/**************************************************************************/


/* #define TX_SOURCE_CODE  */

/* Include necessary system files.  */

    .global     _tx_mtimer_initialize

    .text
/**************************************************************************/ 
/*                                                                        */ 
/*  FUNCTION                                                              */ 
/*                                                                        */ 
/*    _tx_mtimer_initialize                               RISC-V32/GCC    */
/*                                                                        */
/*  AUTHOR                                                                */ 
/*                                                                        */ 
/*                                                                        */ 
/*  DESCRIPTION                                                           */ 
/*                                                                        */ 
/*    This function is responsible for RISC-V32 mtime initialization      */ 
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

/* VOID   _tx_mtimer_initialize(VOID)
{  */
_tx_mtimer_initialize:
    lui     t0, 0x2800
    addi    t0, t0, 0x407
    sb      zero, 0(t0)                 /*!< 禁止 mtime 中断 */

    lui     t0, 0x2004                  /*!< 加载 cmp 地址 */
    sw      zero, 4(t0)                 /*!< 清零 cmp [63:32] */
    sw      zero, 0(t0)                 /*!< 清零 cmp [31: 0] */

_tx_read_mtime:
    lw      t4, 4(t0)                   /*!< 加载 cmp [63:32] */
    lw      t2, 0(t0)                   /*!< 加载 cmp [31: 0] */
    lw      t3, 4(t0)                   /*!< 加载 cmp [63:32] */
    bne     t3, t4, _tx_read_mtime      /*!< 两次值相同跳出循环 */

    li      t4, 1000                    /*!< 加载初始时钟数量 */
    add     t5, t2, t4                  /*!< 与 cmp [31:0] 相加 */
    bltu    t2, t5, _time_no_overflow   /*!< 如果没有溢出就跳转 */

    addi    t3, t3, 1                   /*!< 溢出 cmp [63:32] + 1 */

_time_no_overflow:                      
    lui     t0, 0x200B                  
    li      t2, 0xFF8
    add     t0, t0, t2                  /*!< 加载 mtime 地址 */

    li      t2, -1                      /*!< 加载 0xffffffff */
    sw      t2, 0(t0)                   /*!< 保存 mtime [31:0] , 这时低32位会马上清零 */
    sw      t3, 4(t0)                   /*!< 保存 mtime [31:0] */
    sw      t5, 0(t0)                   /*!< 保存 mtime [31:0] */

    lui     t0, 0x2004                  /*!< 加载 cmp 地址 */
    lui     t2, 0x10                    /*!< 加载 0x10000 */
    sw      t2, 0(t0)                   /*!< 保存 cmp [31: 0] */

    li      t5, 1                       
    lui     t0, 0x2800
    addi    t0, t0, 0x407
    sb      t5, 0(t0)                   /*!< 使能 mtime 中断 */

    ret                                 /*!< 返回 */

/*
} */