# ARCHIVING_CHECKLIST

## Preparing steps
- Study dossiers and approvals in Ethics
- Databases in Data_collection \ Databases
- Raw data in Data_collection
- Published manuscript in Publications
- Analysis scripts in Data_analysis
- Stimulus and standard scripts in Methods_and_materials 
- Info about materials in Methods_and_materials
- Check content of Heimel\Projects
- Check content of Heimel\Archive\Projects
- Run prepare_project_for_archiving to check presence of raw data

## Tarring
- Move all files in Data_collection into folders
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


- Delete original folders, except for 1. Publication folder with last version of the paper, 2. Ethics folder, 3. Presentations, 4. Experiment database 5. Project notes

## Storing on Surf Archive
- Move tarfiles to Surfarchive:  archive.surfsara.nl:/archive/nincsf  
  info on https://servicedesk.surf.nl/wiki/display/WIKI/Data+Archive#DataArchive-Guidelines
  account on archive.surfsara.nl is same as on surfportal
  This can be done with command.exe shell if OpenSsh has been installed as an windows optional feature (Settings/App/Optional features).
    scp -r W:\TarredForSurfArchive\PROJECTNAME aheimel@archive.surfsara.nl:\archive\nincsf
  Powershell (instead of CMD) also works, but causes disconnects due to time-out (2023-01-20)
Files larger than 200Gb need to be split.
This can be done using 'split -b 200G largefile.tar' (more ideal would be to split at creation)


2024-07-07 ** Check out option to use dmftar (tool from Surf) via HPC linux computer connected to VS03 **

