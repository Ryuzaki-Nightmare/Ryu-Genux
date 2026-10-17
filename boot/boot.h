#ifndef BOOT_H
#define BOOT_H
//TYPEDEFs

typedef unsigned char  uint8_t;
typedef unsigned short uint16_t;
typedef unsigned int   uint32_t;

typedef signed char  int8_t;
typedef short int16_t; 

//Genux Time Struct
typedef struct {
   uint16_t   Year;              // 1900 - 9999
   uint8_t Month;             // 1 - 12
   uint8_t Day;               // 1 - 31
   uint8_t   Hour;              // 0 - 23
   uint8_t  Minute;            // 0 - 59
   uint8_t    Second;            // 0 - 59
   uint8_t    Pad1;
   uint32_t    Nanosecond;        // 0 - 999,999,999
   int16_t    TimeZone;          // —1440 to 1440 or 2047
   uint8_t     Daylight;
   uint8_t     Pad2;
} GENUX_TIME;


typedef struct {
    EFI_MEMORY_DESCRIPTOR *MemoryMap;
    UINTN MemoryMapSize;
    UINTN DescriptorSize;
    UINT32 DescriptorVersion;
    UINTN MapKey;
} BootInfo; //memory map for Genux


#endif
