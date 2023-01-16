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
- Run tar_project_folders.m to tar all folders
- Delete original folders 

## Storing on Surf Archive
- Move data to Surfarchive:  archive.surfsara.nl:/archive/nincsf  
  info on https://servicedesk.surf.nl/wiki/display/WIKI/Data+Archive%3A+Login+and+general+usage
  account on archive.surfsara.nl is same as on surfportal
  This can be with putty but also from powershell if OpenSsh has been installed as an windows optional feature (Settings/App/Optional features).
    scp -r W:\TarredForSurfArchive\PROJECTNAME aheimel@archive.surfsara.nl:\archive\nincsf
