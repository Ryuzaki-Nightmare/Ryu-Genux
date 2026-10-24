//GNU-EFI INCLUDES
#include <efi.h>
#include <efilib.h>
#include "boot.h" //this is a local Include

/*IMPORTANTS VARIABLES, SET HERE*/
EFI_STATUS Status ;
EFI_FILE_PROTOCOL **KernelFile = NULL;
EFI_FILE_PROTOCOL *Root = NULL;
UINT64   *GetKernel = 0;
UINT64 MHex =  0xFFFFFFFFFFFFFFFF; //Max Value
void get_time(EFI_SYSTEM_TABLE *ptr){
    EFI_TIME efi_time;
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
    Print(L"Success to Get Memory Map\n");
    return info;
}
EFI_STATUS Open_Volume(EFI_SYSTEM_TABLE *Sptr,EFI_FILE_PROTOCOL **Root){
    EFI_STATUS Status;
    EFI_SIMPLE_FILE_SYSTEM_PROTOCOL *FileSystem = NULL;
    Status = uefi_call_wrapper(
        Sptr->BootServices->LocateProtocol, 
        3, 
        &FileSystemProtocol,
        NULL, 
        (VOID **)&FileSystem
    );
    if(EFI_ERROR(Status))
        return Status;
    Status = uefi_call_wrapper(FileSystem->OpenVolume, 2, FileSystem, Root); 
    Print(L"Success in  Open Volume\n");
    return EFI_SUCCESS;
}
EFI_STATUS Load_Kernel(EFI_FILE_PROTOCOL *Root,EFI_FILE_PROTOCOL **KernelFile){
    EFI_STATUS Status;
     //Pointer to kernel.bin is *KernelFile  
    Status = uefi_call_wrapper(
        Root->Open,
        5,
        Root,
        &KernelFile,
        L"\\kernel.bin",
        EFI_FILE_MODE_READ,
        EFI_FILE_READ_ONLY
     );

    if(EFI_ERROR(Status)){
        Print(L"Error in  Open: %r (Cod: %X)\n",Status,Status);
        return Status; //Return error if can't load the  kernel
    }
    
    Print(L"Success in Load Kernel\n");
   return EFI_SUCCESS;
}
EFI_STATUS set_kernel(EFI_FILE_PROTOCOL **Kernel){
    EFI_FILE_PROTOCOL *This;
    This = *Kernel;
    Print(L"kernel %p, the kernel file is %p\n",Kernel,KernelFile);
    Print(L"this %p\n",This);
    (**Kernel).SetPosition(
        //TODO IN EFI_FILE_PROTOCOL *THIS and UINT64 POSITION
        This,       
        MHex
    );
    Print(L"GG\n");
    return EFI_SUCCESS;
}



EFI_STATUS efi_main (EFI_HANDLE ImageHandle, EFI_SYSTEM_TABLE *SystemTable)
{
    // Efi main function
    InitializeLib(ImageHandle, SystemTable);
    // USE uefi_call_wrapper(Target_Function, Argument_Count, Argument_1, Argument_2, ...); to uefi call
    uefi_call_wrapper(SystemTable->ConOut->ClearScreen, 1, SystemTable->ConOut); //CLEAR THE SCREEN
    EFI_SIMPLE_FILE_SYSTEM_PROTOCOL *FileSystem = NULL;
    Print(L"Welcome to Genux Bootloader!\n");
    uefi_call_wrapper(SystemTable->BootServices->Stall, 1, 2000000);
    uefi_call_wrapper(SystemTable->ConOut->ClearScreen, 1, SystemTable->ConOut); 
    Print(L"Genux Bootloader....\n");
    get_time(SystemTable);
    uefi_call_wrapper(SystemTable->BootServices->Stall, 1, 1000000);



    Open_Volume(SystemTable,&Root);
    uefi_call_wrapper(SystemTable->BootServices->Stall, 1, 1000000);
    Load_Kernel(Root,KernelFile);
    //set_kernel(KernelFile); // Set kernel to 0xFFFFFFFFFFFFFFFFFFFFF
    Print(L"All Of Success");
    while(1); //Remove this line to finish EFI!
    return EFI_SUCCESS; // Good Bye EFI :D
    

}


 
