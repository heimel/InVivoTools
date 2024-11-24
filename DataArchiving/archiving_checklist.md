# ARCHIVING_CHECKLIST

## Preparing steps
- Fill out README.md
- Copy study dossiers and approvals in Ethics
- Copy databases in Data_collection\Databases
- Move raw data in folders in Data_collection 
- Check that there are no loose files in Data_collection. Only folders are archived!
- Copy published manuscript in Publications
- Move analysis scripts in Data_analysis
- Move Stimulus and standard scripts in Methods_and_materials 
- Copy info about materials in Methods_and_materials
- Check content of Heimel\Projects
- Check content of Heimel\Archive\Projects
- For data acquired with InVivoTools, run prepare_project_for_archiving to check presence of raw data

## Tarring
- Remove empty folders
- For storage at Surf Data Archive the tar-files should be between 1GB and 200GB in size. Make sure that folders in Data_collection folder do not exceed 200 GB and definitely not more than 1 Tb. Distribute over multiple folders if necessary
- More guidelines at https://servicedesk.surf.nl/wiki/display/WIKI/Data+Archive#DataArchive-Guidelines
and info about filesize:
https://servicedesk.surf.nl/wiki/display/WIKI/Data+Archive%3A+Effective+archive+file+management

- Run tar_project_folders.m followed by tarcommands.bat to tar all folders

On linux (e.g. Surf Cloud) 
tar -cvf - FOLDER | split --bytes=100G -d -a 3 - FOLDER.tar.

To unpack:
cat Y* | tar -xvf -

- Create filelist by:
dir /b/s > filelist.txt

- Copy Literature folders into personal paper archive
- Delete original folders
- Delete tarcommands.bat

## Storing on Surf Archive
- Copy tarfiles to Surfarchive:  archive.surfsara.nl:/archive/nincsf  * on 2024-10-29 Chris vdT told me this will now be /archive/ninda/csf *
  
  scp -r W:\TarredForSurfArchive\PROJECTNAME aheimel@archive.surfsara.nl:\archive\nincsf#SEE COMMENT ABOVE ABOUT ninda/csf
  
  info on https://servicedesk.surf.nl/wiki/display/WIKI/Data+Archive#DataArchive-Guidelines
  account on archive.surfsara.nl is same as on surfportal
  This can be done with command.exe shell if OpenSsh has been installed as an windows optional feature (Settings/App/Optional features).
  Powershell (instead of CMD) also works, but causes disconnects due to time-out (2023-01-20)

## Clean up
- Delete tar files except for Publications.tar, which contains pdfs and movies that could be useful for talks
- Move folder to archived projects 
