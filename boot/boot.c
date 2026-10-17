#include <efi.h>
#include <efilib.h>
#include "boot.h"
void get_time(EFI_SYSTEM_TABLE *ptr){
    EFI_TIME efi_time;
    GENUX_TIME time;
    uefi_call_wrapper(ptr->RuntimeServices->GetTime,2,&efi_time,NULL);
       Print(L"Now, in GMT + 0 Hour is: %02d:%02d:%02d\n",efi_time.Hour, efi_time.Minute, efi_time.Second);
}

EFI_STATUS
efi_main (EFI_HANDLE ImageHandle, EFI_SYSTEM_TABLE *SystemTable)
{
    // Efi main function
    InitializeLib(ImageHandle, SystemTable);
    // USE uefi_call_wrapper(Target_Function, Argument_Count, Argument_1, Argument_2, ...); to uefi call
    
    Print(L"Genux Bootloader....\n");
    uefi_call_wrapper(SystemTable->BootServices->Stall, 1, 1000000); 
    Print(L"Other Print to Test\n");
    get_time(SystemTable);
    while(1);
    return EFI_SUCCESS;
    

}



