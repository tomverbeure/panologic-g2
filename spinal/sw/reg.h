#ifndef REG_H
#define REG_H

#define REG_WR(reg_name, wr_data)       (*((volatile uint32_t *)(0x80000000 | reg_name##_ADDR)) = (wr_data))
#define REG_RD(reg_name)                (*((volatile uint32_t *)(0x80000000 | reg_name##_ADDR)))

#define REG_WR_FP32(reg_name, wr_data)  (*((volatile uint32_t *)(0x80000000 | reg_name##_ADDR)) = float_to_fpxx(wr_data))

#define FP32_AS_INT(fp32)               (*((unsigned int *)(&fp32)))

#endif
