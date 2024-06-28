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
- For storage at Surf Data Archive the tar-files should be between 1GB and 200GB in size. Make sure that folders in Data_collection folder do not exceed 200 GB. Distribute over multiple folders if necessary
- More guidelines at https://servicedesk.surf.nl/wiki/display/WIKI/Data+Archive#DataArchive-Guidelines
- Run tar_project_folders.m followed by tarcommands.bat to tar all folders
- Delete original folders, except for 1. Publication folder with last version of the paper, 2. Ethics folder, 3. Presentations, 4. Experiment database 5. Project notes

## Storing on Surf Archive
- Move tarfiles to Surfarchive:  archive.surfsara.nl:/archive/nincsf  
  info on https://servicedesk.surf.nl/wiki/display/WIKI/Data+Archive%3A+Login+and+general+usage
  account on archive.surfsara.nl is same as on surfportal
  This can be done with command.exe shell if OpenSsh has been installed as an windows optional feature (Settings/App/Optional features).
    scp -r W:\TarredForSurfArchive\PROJECTNAME aheimel@archive.surfsara.nl:\archive\nincsf
  Powershell (instead of CMD) also works, but causes disconnects due to time-out (2023-01-20)
