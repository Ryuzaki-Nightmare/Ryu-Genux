#include <efi.h>
#include <efilib.h>

EFI_STATUS
EFIAPI
efi_main (EFI_HANDLE ImageHandle, EFI_SYSTEM_TABLE *SystemTable)
{
    /*
     *Hi, This's Boot UEFI Main Function :D
     *
     *
    */ 
    
  InitializeLib(ImageHandle, SystemTable);
  Print(L"Genux Bootloader....\n");
  while(1);
  
  return EFI_SUCCESS;
}



