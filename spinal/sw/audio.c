#include <stdint.h>
#include "top_defines.h"
#include "audio.h"
#include "i2c.h"
#include "print.h"

#define WM8750L_I2C_ADR       0x34

short int audio_registers[][2] = {
    // For now, use default volume settings for LOUT1/ROUT1
//    { WM8750_LOUT1_VOL_ADDR,            -1 },
//    { WM8750_ROUT1_VOL_ADDR,            -1 },

    { WM8750_LOUT1_VOL_ADDR,            (0<<8) |    // LO2VU    : Don't update LOUT1 volume yet
                                        (0<<7) |    // LO2ZC    : Change gain on zero cross only
                                     (0x78<<0) },   // LOUT2VOL : Volume...

    { WM8750_ROUT1_VOL_ADDR,            (1<<8) |    // RO2VU    : Update LOUT1 and ROUT1 volume 
                                        (0<<7) |    // RO2ZC    : Change gain on zero cross only
                                     (0x78<<0) },   // ROUT2VOL : Volume...


    // Disable digital soft mute, no de-emphasis
    { WM8750_ADC_DAC_CTRL_ADDR,         (0<<3) |    // DACMU: Disable digital soft mute
                                        (0<<1) },   // DEEMP: No de-emphasis

    // DSP Mode, mode B, LRP=1, Slave (Figure 23), 16 bits
    { WM8750_AUDIO_INTFC_ADDR,          (0<<7) |    // BCLKINV: BCLK not inverted
                                        (0<<6) |    // MS     : Master mode
                                        (0<<5) |    // LRSWAP : No L/R swap
                                        (1<<4) |    // LRP    : DSP mode B: MSB on first clock cycle
                                        (0<<2) |    // WL     : 16 bits
                                        (3<<0) },   // FORMAT : DSP mode

    // MCLK 12MHz, 48kHz sample rate
    { WM8750_SAMPLE_RATE_ADDR,          (0<<7) |    // BCM    : Bit Clock Mode disabled
                                        (0<<6) |    // CLKDIV2: MCLK not divided by 2
                                        (0<<1) |    // SR     : ADC and DAC 48kHz
                                        (1<<0) },   // USB    : 12MHz USB clock mode 
    // Set left and right channel volume
    { WM8750_LCHAN_VOL_ADDR,            (0<<8) |    // LDVU   : No left DAC volume update
                                        (0xff) },   // LDACVOL: Set to 0 db
    { WM8750_RCHAN_VOL_ADDR,            (1<<8) |    // RDVU   : Update left and right DAC volume
                                        (0xff) },   // RDACVOL: Set to 0 db

    // Bass control
    { WM8750_BASS_CTRL_ADDR,            (0<<7) |    // BB  : Linear bass control
                                        (1<<6) |    // BC  : high bass cutoff
                                      (0xf<<0) },   // BASS: bass intensity bypass

    // Treble control
    { WM8750_TREBLE_CTRL_ADDR,          (0<<6) |    // TC  : high treble cutoff
                                      (0xf<<0) },   // TRBL: treble intensity bypass

    // Set DAC to mono, enable thermal shutdown
    { WM8750_3D_CTRL_ADDR,              (0<<0) },   // 3DEN: Disabled

    // Various...
    { WM8750_ADDITIONAL_CTRL1_ADDR,     (1<<8) |    // TSDEN   : Thermal shutdown enabled
                                        (3<<6) |    // VSEL    : Analog bias current optimized for 3.3V
                                        (3<<4) |    // DMONOMIX: mono goes to both DACL and DACR
                                        (0<<2) |    // DATSEL  : left data=left ADC, right data=right ADC
                                        (0<<1) |    // DACINV  : DAC phase not inverted 
                                        (1<<0) },   // TOEN    : Time-out enable on ADC zero cross detection on gain change


    // Invert ROUT for speaker
    { WM8750_ADDITIONAL_CTRL2_ADDR,     (0<<7) |    // OUT3SW  : OUT3 outputs VREF
                                        (1<<6) |    // HWSWEN  : for now, disable head-phone switch 
                                        (0<<5) |    // HWSWPOL : head-phone switch polarity (irrelevant when HWSEN=0) 
                                        (1<<4) |    // ROUT2INV: invert ROUT2 when using speaker
                                        (0<<3) |    // TRI     : Don't set tri-state mode
                                        (0<<2) |    // LRCM    : Disable ADCLRC and DACLRC when ADC resp. DAC are disabled.
                                        (0<<1) |    // ADCOSR  : ADC oversample rate x128
                                        (0<<0) },   // DACOSR  : DAC oversample rate x128

    { WM8750_PWR_MANAGEMENT1_ADDR,      (1<<7) |    // VMIDSEL: 50k divider for playback/record
                                        (1<<6) |    // VREF   : must be on
                                        (0<<5) |    // AINL   : Analog In PGA Right
                                        (0<<4) |    // AINR   : Analog In PGA Right
                                        (0<<3) |    // ADCL   : ADC Left
                                        (0<<2) |    // ADCR   : ADC Right
                                        (0<<1) |    // MICB   : MIC Bias
                                        (0<<0) },   // DIGENB : Don't gate MCLK internally

    { WM8750_PWR_MANAGEMENT2_ADDR,      (1<<8) |    // DACL : DAC Left
                                        (1<<7) |    // DACR : DAC Right
//                                        (0<<6) |    // LOUT1: Disable for now
//                                        (0<<5) |    // ROUT1: Disable for now
                                        (1<<6) |    // LOUT1: Disable for now
                                        (1<<5) |    // ROUT1: Disable for now
                                        (1<<4) |    // LOUT2: Speaker is on
                                        (1<<3) |    // ROUT2: Speaker is on
                                        (0<<2) |    // MONO : Mono output is not used
                                        (0<<1) },   // OUT3 : Out3 is not used

    { WM8750_ADDITIONAL_CTRL3_ADDR,     (0<<7) |    // ADCLRM : ADCLRC is ADC word clock input or output
                                        (0<<6) |    // VROI   : VREF to analog output resistance is 1.5k
                                        (0<<5) },   // HPFLREN: High Pass filter on left and right enabled/disabled together

    // Left and right DAC output goes to left output mixer
    { WM8750_LEFT_MIXER_CTRL1_ADDR,     (1<<8) |    // LD2LO   : Enable left DAC to left mixer
                                        (0<<7) |    // LI2LO   : Disable LMIXSEL signal to left mixer
                                        (0<<4) |    // LI2LOVOL: Irrelevant
                                        (0<<0) },   // LMIXSEL : Irrrelevan

    { WM8750_LEFT_MIXER_CTRL2_ADDR,     (1<<8) |    // RD2LO   : Enable right DAC to left mixer
                                        (0<<7) |    // RI2LO   : Disable RMIXSEL signal to left mixer
                                        (0<<4) },   // RI2LOVOL: Irrelevant

    // Left and right DAC output goes to right output mixer
    { WM8750_RIGHT_MIXER_CTRL1_ADDR,    (1<<8) |    // RD2RO   : Enable right DAC to right mixer
                                        (0<<7) |    // RI2RO   : Disable RMIXSEL signal to right mixer
                                        (0<<4) |    // RI2ROVOL: Irrelevant
                                        (0<<0) },   // RMIXSEL : Irrrelevan

    { WM8750_RIGHT_MIXER_CTRL2_ADDR,    (1<<8) |    // LD2RO   : Enable left DAC to right mixer
                                        (0<<7) |    // LI2RO   : Disable LMIXSEL signal to right mixer
                                        (0<<4) },   // LI2ROVOL: Irrelevant


    // Mono output isn't used
    { WM8750_MONO_MIXER_CTRL1_ADDR,     0 },
    { WM8750_MONO_MIXER_CTRL2_ADDR,     0 },

    // LOUT2/ROUT2 configuration for mono
    { WM8750_LOUT2_VOL_ADDR,            (0<<8) |    // LO2VU    : Don't update LOUT2 volume yet
                                        (0<<7) |    // LO2ZC    : Change gain on zero cross only
                                      (100<<0) },   // LOUT2VOL : Volume...

    { WM8750_ROUT2_VOL_ADDR,            (1<<8) |    // RO2VU    : Update LOUT2 and ROUT2 volume 
                                        (0<<7) |    // RO2ZC    : Change gain on zero cross only
                                      (100<<0) },   // ROUT2VOL : Volume...

    // Mono output isn't used
    { WM8750_MONOOUT_VOL_ADDR,          0 },
    { -1, -1 }
};


i2c_ctx_t codec_i2c_ctx;

void audio_init()
{
   int idx = 0;

   print("audio_init\n");
   codec_i2c_ctx.base_addr = CODEC_I2C_BASE_ADDR;
   codec_i2c_ctx.scl_pin_nr = 0;
   codec_i2c_ctx.sda_pin_nr = 1;

    i2c_init(&codec_i2c_ctx);

    while(audio_registers[idx][0] != -1){
        int addr  = audio_registers[idx][0];
        int value = audio_registers[idx][1];

        if(!i2c_write_reg(&codec_i2c_ctx, WM8750L_I2C_ADR, (addr<<1) | (value>>8), (value & 0xff))) {
           print("i2c_write_reg failed\n");
           break;
        }
        ++idx;
    }
}

