#include <efi.h>
#include <efilib.h>
#include "boot.h"

void get_time(EFI_SYSTEM_TABLE *ptr){
    EFI_TIME efi_time;
    GENUX_TIME time;
    uefi_call_wrapper(ptr->RuntimeServices->GetTime,2,&efi_time,NULL);

        //This is time to use in Kernel
        time.Year = efi_time.Year;
        time.Month = efi_time.Month;
        time.Day = efi_time.Day;
        time.Hour = efi_time.Hour;
        time.Minute = efi_time.Minute;
        time.Second = efi_time.Second;
        time.Pad1 = efi_time.Pad1;
        time.Nanosecond = efi_time.Nanosecond;
        time.TimeZone = efi_time.TimeZone;
        time.Daylight = efi_time.Daylight;
        time.Pad2 = efi_time.Pad2;
}
BootInfo memory_map() {
    UINTN MemoryMapSize = 0;
    EFI_MEMORY_DESCRIPTOR *MemoryMap = NULL;
    UINTN MapKey;
    UINTN DescriptorSize;
    UINT32 DescriptorVersion;
   
    uefi_call_wrapper(gBS->GetMemoryMap, 5, &MemoryMapSize, NULL, &MapKey, &DescriptorSize, &DescriptorVersion);
    MemoryMapSize += 2 * DescriptorSize;
    uefi_call_wrapper(gBS->AllocatePool, 3, EfiLoaderData, MemoryMapSize, (VOID**)&MemoryMap);
    uefi_call_wrapper(gBS->GetMemoryMap, 5, &MemoryMapSize, MemoryMap, &MapKey, &DescriptorSize, &DescriptorVersion);

    BootInfo info;
    info.MemoryMap         = MemoryMap;
    info.MemoryMapSize     = MemoryMapSize;
    info.DescriptorSize    = DescriptorSize;
    info.DescriptorVersion = DescriptorVersion;
    info.MapKey            = MapKey;
    return info;
}
EFI_STATUS Open_Volume(EFI_SYSTEM_TABLE *Sptr){
    EFI_STATUS Status;
    EFI_FILE_PROTOCOL Root;
    Status = Sptr->MediaAccess->OpenVolume(&Sptr, &Root);
    Print(L"123");
    return EFI_SUCCESS;
}
EFI_STATUS
efi_main (EFI_HANDLE ImageHandle, EFI_SYSTEM_TABLE *SystemTable)
{
    // Efi main function
    InitializeLib(ImageHandle, SystemTable);
    // USE uefi_call_wrapper(Target_Function, Argument_Count, Argument_1, Argument_2, ...); to uefi call
        uefi_call_wrapper(SystemTable->ConOut->ClearScreen, 1, SystemTable->ConOut);

    Print(L"Genux Bootloader....\n");
    uefi_call_wrapper(SystemTable->BootServices->Stall, 1, 1000000); 
    Print(L"Other Print to Test\n");
    uefi_call_wrapper(SystemTable->BootServices->Stall, 1, 1000000);

    uefi_call_wrapper(SystemTable->ConOut->ClearScreen, 1, SystemTable->ConOut);
    get_time(SystemTable);
    BootInfo info = memory_map();
    Open_Volume(SystemTable);
    while(1);
    return EFI_SUCCESS;
    

}



