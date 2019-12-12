# Project NaCl 

### Overview 
This project is to make sure all files meet the following reqirements:  
> Naming conventions are standardized  
> Have 2 database  
> > Ordered by patient, use for data keeping   
> > Ordered by sequence, use for data processing   
>
> Have a comprehensive excel sheet that will catalog all sequences aquired for each paitent w/ DOE  

### Renaming 
##### 1. Filter 
The following changes will be made to all files:  
> All file names wil be uppercase  
> CUBE > 3D  
> SAGITTAL > SAG  
> AXIAL > AX  
> CORONAL > COR   
> WHITTIER > WH  

The follwing sequences will be filtered through:  
> 3D\_T1  
> FLAIR  
> T2  
> BOLD  
> Diffusion  
> ASL  
> SWAN  
> CSF   
> CAROTID  
> AORTA  
> CBF  
> MPR  
> CANDY\_CANE  
> ARCH  
> PROBE (MRS)    

Things will will be filtered out:  
> Repeats (will have letter a-z attached to the end of the file name before file extension)  

##### 2. RENAME
The new naming convention established

###### General ID
> 2 letter cohort followed by identification number (i.e. AB1234)    

###### Scan Specific
> Perscription   
> > Please name future T1s as FSPGR     
> 
> ScanType   
> Location if exists    
> Notes if need be   
> > Notes must be in (), please do not put () in ()   
> > This is where you should specify repeats if exsists   
> > i.e. VENC, DIRECTION, INVERTED, HYPERVENTALATION, POST-PROCESS, etc     
