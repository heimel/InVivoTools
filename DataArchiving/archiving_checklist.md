# ARCHIVING\_CHECKLIST

## Preparing steps



* Move project into \\\\vs03\\vs03-csf-XXX\\PreparingForSurfArchive
* Fill out README.md
* Copy study dossiers and approvals in Ethics
* Copy databases in Data\_collection\\Databases
* Move raw data in folders in Data\_collection
* Check that there are no loose files in Data\_collection. Only folders are archived!
* Collect all other related content, e.g. Heimel\\Projects
* Copy published manuscript in Publications
* Move analysis scripts in Data\_analysis
* Move Stimulus and standard scripts in Methods\_and\_materials
* Copy info about materials in Methods\_and\_materials
* For data acquired with InVivoTools, run prepare\_project\_for\_archiving to check presence of raw data

## Tarring

* Remove empty folders
* For storage at Surf Data Archive the tar-files should be between 1GB and 200GB in size. Make sure that folders in Data\_collection folder do not exceed 200 GB and definitely not more than 1 Tb. Distribute over multiple folders if necessary
* More guidelines at https://servicedesk.surf.nl/wiki/display/WIKI/Data+Archive#DataArchive-Guidelines
and info about filesize:
https://servicedesk.surf.nl/wiki/display/WIKI/Data+Archive%3A+Effective+archive+file+management
* Run tar\_project\_folders.m followed by tarcommands.bat to tar all folders

On windows use 7zip to cut tar files into volumes.

On linux (e.g. Surf Cloud)
tar -cvf - FOLDER | split --bytes=100G -d -a 3 - FOLDER.tar.

To unpack:
cat Y\* | tar -xvf -

* Create filelist by:
dir /b/s > filelist.txt
* Copy Literature folders into personal paper library
* Copy Publication and Presentation folders into personal project archive
* Delete original folders
* Delete tarcommands.bat

## Storing on Surf Archive

* Copy tarfiles to Surfarchive:  archive.surfsara.nl:/archive/nincsf  \* on 2024-10-29 Chris vdT told me this will now be /archive/ninda/csf \*

  scp -r W:\\TarredForSurfArchive\\PROJECTNAME aheimel@archive.surfsara.nl:\\archive\\nincsf#SEE COMMENT ABOVE ABOUT ninda/csf

  info on https://servicedesk.surf.nl/wiki/display/WIKI/Data+Archive#DataArchive-Guidelines
account on archive.surfsara.nl is same as on surfportal
This can be done with command.exe shell if OpenSsh has been installed as an windows optional feature (Settings/App/Optional features).
Powershell (instead of CMD) also works, but causes disconnects due to time-out (2023-01-20)

  ## Clean up

* Delete tar files except for Publications.tar, which contains pdfs and movies that could be useful for talks
* Move folder to archived projects

