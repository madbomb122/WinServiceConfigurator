# WinServiceConfigurator
This script allows you to change service configuration, Manually or from a file. You can also Save or Load configurations.

[![Donate](https://img.shields.io/badge/Donate-Amazon-yellowgreen.svg?style=plastic)](https://www.amazon.com/gp/registry/wishlist/YBAYWBJES5DE/)
[![GitHub Issues](https://img.shields.io/github/issues/madbomb122/WinServiceConfigurator.svg?style=plastic)](https://github.com/madbomb122/WinServiceConfigurator/issues)
# 
To Download go to -> [Win Service Configurator Script -Release](https://github.com/madbomb122/WinServiceConfigurator/releases)  

**Current Version**   
**Script:** `1.2.0` (Oct 30, 2022)   


## Contents
 - [Description](#description)
 - [Requirements](#requirements)
 - [How to Use](#how-to-use)
 - [Usage](#usage)
 - [Advanced Usage](#advanced-usage)
 - [FAQ](#faq)


## Description
This script allows you to change service configuration, Manually or from a file. You can also Save or Load configurations.   
Black Viper's Service Configurations from http://www.blackviper.com/ (not the downloaded csv files from the site)    

## Requirements   
Windows 7 to Windows 11   

**_Need Files_**   
WinServiceConfigurator.ps1

**Recommended Files**   
One or More of the CSV in the appropriate windows version   
_WinServiceConfigurator.bat (To run script easier)   
README.md (This Readme)   

## How to Use
Download/Save the release file in - [WinServiceConfigurator Script -Release](https://github.com/madbomb122/WinServiceConfigurator/releases)  
  **Note 1: DO NOT RENAME THE FILES**  
  **Note 2: HAVE THE FILES IN THE SAME DIRECTORY**  
Next follow the **Basic Usage** or **Advanced Usage**

## Usage
Run the Script by bat file `_WinServiceConfigurator.bat` (Recommended)  
or  
`powershell.exe -NoProfile -ExecutionPolicy Bypass -File c:/WinServiceConfigurator.ps1`  
*For the above, Please note you need change the c:/ to the fullpath of your file*  
Select desired Services Configuration  
Select the options you want and then click run script  

## Advanced Usage
Use one of the following Methods you can 
1. Run script or bat file with one (or more) of the switches below
2. Edit the script (bottom of file) to change the values
3. Edit the bat file (top of file) to change the values to add the switch


|     Switch     |                                   Description                                  |                          Notes                          |
| :------------- | :------------------------------------------------------------------------------| :-------------------------------------------------------|
| -atos          | Accepts the ToS                                                                |                                                         |
| -auto          | Runs the script to be Automated.. Closes on User input, Errors, End of Script) | Implies `-atos`                                         |
| -lcsc File.csv | Loads Custom Service Configuration                                             | `File.csv` Name of backup/custom file                   |
| -sxb           | Skips Change to All Xbox Services                                              |                                                         |
| -usc           | Checks for Update to Script file before running                                | Auto downloads and runs if found                        |
| -sic           | Skips Internet Check (If checking for update)                                  | Tests by pinging GitHub.com                             |
| -log           | Makes a log file using default name `Script.log` (default)                     | Logs Notices, Errors, & Services changed                |
| -log File.log  | Makes a log file named File.log                                                | Logs Notices, Errors, & Services changed                |
| -baf           | File of all the services before and after the script                           | `Services-Before.log` and `Services-After.log`          |
| -bsc           | Backup Current Service Configuration (CSV file)                                | Filename will be `COMPUTERNAME-Service-Backup.csv`      |
| -sas           | Show Already Set Services                                                      |                                                         |
| -snis          | Shows NOT Installed Services                                                   |                                                         |
| -sss           | Show Skipped Services                                                          |                                                         |
| -dry           | Runs script and shows what will be changed if ran normaly                      | **No Services are changes**                             |
| -css           | Change State of Service                                                        | From non BlackViper File Only                           |
| -sds           | Stop Disabled Service                                                          |                                                         |
| -diag          | Shows some diagnostic information on error messages                            | **Stops automation**                                    |
| -diagf         | Forced diagnostic information, Script does nothing else                        | **No Services are changes**                             |
| -devl          | Makes a log file with various Diagnostic information                           | **No Services are changes**                             |
| -help          | Lists of all the switches, Then exits script                                   | Alt `-h`                                                |
| -copy          | Shows Copyright/License Information, Then exits script                         |                                                         |


Switch Examples:   
`powershell.exe -NoProfile -ExecutionPolicy Bypass -File WinServiceConfigurator.ps1 -lcsc MyComp-Service-Backup.csv`   

******

## FAQ
**Q:** The script file looks all messy in notepad, How do I view it?   
**A:** Try using wordpad or what I recommend, Notepad++ [https://notepad-plus-plus.org/](https://notepad-plus-plus.org/) 

**Q:** Do you accept any donations?   
**A:** If you would like to donate to me Please pick an item/giftcard from my amazon wishlist or Contact me about donating, Thanks. BTW The giftcard amount can be changed to a min of $1.   
**Wishlist:** [https://www.amazon.com/gp/registry/wishlist/YBAYWBJES5DE/](https://www.amazon.com/gp/registry/wishlist/YBAYWBJES5DE/)  

**Q:** I have a suggestion/Issue for the script, how do I suggest it?   
**A:** Do a pull request with the change or submit it as an issue with the suggestion.   

**Q:** How can I contact you?  
**A:** You can also PM me on reddit or email me  
         1. reddit /u/madbomb122 [https://www.reddit.com/user/madbomb122](https://www.reddit.com/user/madbomb122)  
         2. You can email me @ madbomb122@gmail.com.  
**Note** Before contacting me, please make sure you have ALL the needed files (Look above under requirements).   

**Q:** Are you going to add more Service Configurations?   
**A:** No, but I created a Dropbox folder for people to add/download there own service config files [Here](https://www.dropbox.com/scl/fo/yh96ixe0ophoszppou8fa/h?dl=0&rlkey=ahkqqdbtckbjb77xwlxs4ge6q)   
**Note** If you know a better place than dropbox let me know   

**Q:** *BLAH* isn't working after I used your script.  
**A:** Check over what services were changed and make sure it isn't tied to your issue.   
**Example** `WlanSvc` is disabled when using safe/tweaked on desktops (but not laptops/tables). This service is needed for wifi on your computer.   

**Q:** Can I use a Backup File(s) on another computer?   
**A:** You can use/load them on another computer, but be careful.   

**Q:** Can I use the file created from your BlackViper Script?   
**A:** Yes you can use the file from the script, just not the `blackviper.csv` file.   

**Q:** The script wont run, can you help me?   
**A:** Yes, but first if you are using automation.. turn off automation and see if it gives and error that you can correct.   

**Q:** The script window closes or gives an error saying script is blocked, what do I do?   
**A:** By default windows blocks ps1 scripts, you can use one of the following   
         1. Use the bat file to run the script (recommended)   
         2. On an admin powershell console `Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted`   	 

**Q:** Why does you script not change the service *BLAH*?   
**A:** One of the following it cant be changed, it's not in the file, it's unchecked, or some other good reason.

**Q:** I have an issue with the script, what do I do?   
**A:** Post it as an issue using github's issues tab up top.

**Q:** Can I run the script safely?   
**A:** Yes/No, it's safe to change the services back to default. Using the Safe or Tweaked option may cause problems for program(s) that depends on one of those services.

**Q:** Can I run the script repeatedly?   
**A:** Yes, with same or different settings.

**Q:** I've run the script and it did *BLAH*, can I undo it?   
**A:** Yes, run the script again and select again or load the backup configuration (if you made one).   

**Q:** Can I use the script or modify it for my / my company's needs?   
**A:** Sure. Just don't forget to include copyright notice as per the license requirements, and leave any Copyright in script too, if you make money from using it please consider a donation as thanks.

**Q:** The script messed up my computer because it did *BLAH*.   
**A:** Any problems you have/had is your own problem.

**Q:** Can I download the csv file from Black Viper's website and use that?   
**A:** No, my file is not the same.   

**Q:** Can I add a service to be changed or stop one from changing?   
**A:** Yes, edit the file needed or use the gui and uncheck the services you dont want changed    
---To add put it in the proper format
---Indead of removeing it i suggesst adding a - (minus sign) to the number in the service
**Note 1:** Number meaning `0 -Not Installed/Skip`, `1 -Disable`, `2 -Manual`, `3 -Automatic`, `4 -Auto (Delayed)`   
**Note 2:** Negative Numbers are the same as above but wont be used unless you select it in the GUI   

**Q:** How long are you going to maintain the script?   
**A:** No Clue.   
