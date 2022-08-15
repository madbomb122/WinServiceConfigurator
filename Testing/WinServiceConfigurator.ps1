##########
# Windows Service Configurator
#
# Script + Menu(GUI) By
#  Author: Madbomb122
$MySite = 'https://GitHub.com/madbomb122/WinServiceConfigurator'
#
[Version]$Script_Version = '1.1.1'
$Script_Date = 'Aug-14-2022'
#$Release_Type = 'Stable'
##########

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# !!                                         !!
# !!            SAFE TO EDIT ITEM            !!
# !!           AT BOTTOM OF SCRIPT           !!
# !!                                         !!
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# !!                                         !!
# !!                 CAUTION                 !!
# !!       DO NOT EDIT PAST THIS POINT       !!
# !!                                         !!
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

<#------------------------------------------------------------------------------#>
$Copyright = 'The MIT License (MIT) + an added Condition (Keep Donate Links)          
                                                                        
 Copyright (c) 2022 Madbomb122                                          
          - Windows Service Configurator Script                         
                                                                        
 Permission is hereby granted, free of charge, to any person obtaining  
 a copy of this software and associated documentation files (the        
 "Software"), to deal in the Software without restriction, including    
 without limitation the rights to use, copy, modify, merge, publish,    
 distribute, sublicense, and/or sell copies of the Software, and to     
 permit persons to whom the Software is furnished to do so, subject to  
 the following conditions:                                              
                                                                        
 The above copyright notice(s), this permission notice and ANY original 
 donation link shall be included in all copies or substantial portions  
 of the Software.                                                       
                                                                        
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY  
 KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE 
 WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR    
 PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS 
 OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR   
 OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
 OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE  
 SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.     
                                                            '
<#--------------------------------------------------------------------------------

.Prerequisite to run script
	System: Windows 7+
	Edition: Any
	Files: This script

.DESCRIPTION
	This script allows you to change service configuration, Manually
	or from a file. You can also Save or Load configurations.

.BASIC USAGE
	1. Run script with (Next Line)
powershell.exe -NoProfile -ExecutionPolicy Bypass -File WinServiceConfigurator.ps1
	2. Use bat file provided

	Use Gui to Select the desired Choices and click Run

.ADVANCED USAGE
	One of the following Methods...
	1. Edit values at bottom of the script then run script
	2. Edit bat file and run
	3. Run the script with one of these switches (space between multiple)
	4. Run the script and pick options in GUI

  Switch          Description of Switch
--Basic Switches--
  -atos            Accepts ToS
  -auto            Implies -atos...Runs the script to be Automated.. Closes on - User Input, Errors, or End of Script

--Service Configuration Switches--
  -lcsc File.csv   Loads Service Configuration, File.csv = Name of your backup/custom file

--Service Choice Switches--
  -sxb             Skips changes to all XBox Services
  -css             Change State of Service
  -sds             Stop Disabled Service

--Update Switches--
  -usc             Checks for Update to Script file before running
  -sic             Skips Internet Check, if you can't ping GitHub.com for some reason

--Backup/Log Switches--
  -bsc             Backup Current Service Configuration as csv File
  -log             Makes a log file using default name Script.log
  -log File.log    Makes a log file named File.log
  -baf             Log File of Services Configuration Before and After the script

--Display Switches--
  -sas             Show Already Set Services
  -snis            Show Not Installed Services
  -sss             Show Skipped Services

--Misc Switches--
  -dry             Runs the Script and Shows what services will be changed

--Dev Switches--
  -devl            Makes a log file with various Diagnostic information, Nothing is Changed
  -diag            Shows diagnostic information, Stops -auto
  -diagf           Forced diagnostic information, Script does nothing else

--Help--
  -help            Shows list of switches, then exits script.. alt -h
  -copy            Shows Copyright/License Information, then exits script

------------------------------------------------------------------------------#>
##########
# Pre-Script/Needed Variable -Start
##########

#https://microsoft.fandom.com/wiki/List_of_Microsoft_Windows_versions
#  7 = 6.1.7601
#  8 = 6.2.9200
#8.1 = 6.3.9600
# 10 = 10.0.19044
# 11 = 10.0.22000
$WindowVersionFull = [Environment]::OSVersion.Version
If(!($WindowVersionFull.Major -eq 10 -or ($WindowVersionFull.Major -ne 6 -and $WindowVersionFull.Minor -In 1..3))) {
	Write-Host 'Sorry, this Script ONLY supports Windows 7 and up' -ForegroundColor 'cyan' -BackgroundColor 'black'
	If($Automated -ne 1){ Read-Host -Prompt "`nPress Any key to Close..." } ;Exit
}

If($Release_Type -eq 'Stable'){ $ErrorActionPreference = 'SilentlyContinue' } Else{ $Release_Type = 'Testing' }

$PassedArg = $args

If(!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {
	Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" $PassedArg" -Verb RunAs ;Exit
}

$WindowVersion = If($WindowVersionFull.Major -eq 10) {
	If($WindowVersionFull.Build -ge 22000){ 11 }Else{ 10 }
} ElseIf($WindowVersionFull.Major -eq 6) {
	If($WindowVersionFull.Minor -eq 1){ 7 }ElseIf($WindowVersionFull.Minor -In 2,3){ 8 }
}

$CimOS = Get-CimInstance Win32_OperatingSystem | Select-Object OperatingSystemSKU,Caption,BuildNumber,OSArchitecture,ProductType

$WorkServer = If($CimOS.ProductType -eq 1) {
	'Desktop'
} ElseIf($CimOS.ProductType -In 2,3) {
	'Server'
} Else {
	'Unknown'
}

$WinSku = $CimOS.OperatingSystemSKU
$WinSkuList = @(48,49,98,100,101)
# 48 = Pro, 49 = Pro N
# 98 = Home N, 100 = Home (Single Language), 101 = Home

$FullWinEdition = $CimOS.Caption
#$WinEdition = $FullWinEdition.Split(' ')[-1]

$MySite = 'https://GitHub.com/madbomb122/WinServiceConfigurator'
$URL_Base = $MySite.Replace('GitHub','raw.GitHub')+'/master/'
$Version_Url = $URL_Base + 'Version/Version.csv'
$Donate_Url = 'https://www.amazon.com/gp/registry/wishlist/YBAYWBJES5DE/'

$ServiceEnd = (Get-Service *_*).Where({$_.ServiceType -eq 224}, 'First') -Replace '^.+?_', '_'

$colors = @(
'black',      #0
'blue',       #1
'cyan',       #2
'darkblue',   #3
'darkcyan',   #4
'darkgray',   #5
'darkgreen',  #6
'darkmagenta',#7
'darkred',    #8
'darkyellow', #9
'gray',       #10
'green',      #11
'magenta',    #12
'red',        #13
'white',      #14
'yellow')     #15
$ColorsGUI = $Colors[14,15,7,3,4,5,6,2,8,9,10,11,12,13,0,1]

$ServicesTypeFull = @(
'Skip',    #0 -Skip/Not Installed
'Disabled',#1
'Manual',  #2
'Auto',    #3
'Auto (Delayed)') #4
$ServicesTypeList = $ServicesTypeFull[0,1,2,3,3]

$SrvStateList = @('Running','Stopped')
$XboxServiceArr = @('XblAuthManager','XblGameSave','XboxNetApiSvc','XboxGipSvc','xbgm')
$NetTCP = @('NetMsmqActivator','NetPipeActivator','NetTcpActivator')
$FilterList = @('CheckboxChecked','CName','ServiceName','CurrType','FileType','SrvState','SrvDesc','SrvPath','RowColor')
$DevLogList = @('WPF_ScriptLog_CB','WPF_Diagnostic_CB','WPF_LogBeforeAfter_CB','WPF_DryRun_CB','WPF_ShowNonInstalled_CB','WPF_ShowAlreadySet_CB')

$FileBase = $(If($Null -ne $psISE){ Split-Path $psISE.CurrentFile.FullPath -Parent } Else{ $PSScriptRoot }) + '\'
$SettingPath = $FileBase + 'Setting.xml'

$Service_Select = 0
$Automated = 0
$RunScript = 2
$ErrorDi = ''
$LogStarted = 0
$LoadServiceConfig = 0
$SelectedSerOld = 0
$ErrCount = $Error.Count
$RanScript = $False
$GuiSwitch = $False

$ArgList = @{ Arg = '-bsc' ;Var = 'BackupServiceConfig=1' ;Match = 1 ;Gui = $True },
@{ Arg = '-baf' ;Var = 'LogBeforeAfter=1' ;Match = 1 ;Gui = $True },
@{ Arg = '-snis' ;Var = 'ShowNonInstalled=1' ;Match = 1 ;Gui = $True },
@{ Arg = '-sss' ;Var = 'ShowSkipped=1' ;Match = 1 ;Gui = $True },
@{ Arg = '-sas' ;Var = 'ShowAlreadySet=1' ;Match = 1 ;Gui = $True },
@{ Arg = '-sds' ;Var = 'StopDisabled=1' ;Match = 1 ;Gui = $True },
@{ Arg = '-sic' ;Var = 'InternetCheck=1' ;Match = 1 ;Gui = $True },
@{ Arg = '-css' ;Var = 'ChangeState=1' ;Match = 1 ;Gui = $True },
@{ Arg = '-usc' ;Var = 'ScriptVerCheck=1' ;Match = 1 ;Gui = $True },
@{ Arg = '-atos' ;Var = 'AcceptToS=Accepted' ;Match = 1 ;Gui = $True },
@{ Arg = '-dry' ;Var = 'DryRun=1' ;Match = 1 ;Gui = $True },
@{ Arg = '-devl' ;Var = 'DevLog=1' ;Match = 1 ;Gui = $True },
@{ Arg = '-sxb' ;Var = 'XboxService=1' ;Match = 1 ;Gui = $True },
@{ Arg = '-auto' ;Var = @('Automated=1','AcceptToS=Accepted') ;Match = 1 ;Gui = $False },
@{ Arg = '-diag' ;Var = @('Diagnostic=1','Automated=0') ;Match = 2 ;Gui = $True },
@{ Arg = '-log' ;Var = @('ScriptLog=1','LogName=-') ;Match = -1 ;Gui = $True },
@{ Arg = '-logc' ;Var = @('ScriptLog=2','LogName=-') ;Match = -1 ;Gui = $True }

##########
# Pre-Script/Needed Variable -End
##########
# Multi Use Functions -Start
##########

Function AutomatedExitCheck([Int]$ExitBit) {
	If($Automated -ne 1){ Read-Host -Prompt "`nPress Any key to Close..." }
	If($ExitBit -eq 1){ LogEnd ;CloseExit }
}

Function LogEnd{ If(0 -NotIn $ScriptLog,$LogStarted){ Write-Output "--End of Log ($(Get-Date -Format 'MM/dd/yyyy hh:mm:ss tt'))--" | Out-File -LiteralPath $LogFile -Encoding Unicode -NoNewline -Append } }
Function GetTime{ Return Get-Date -Format 'hh:mm:ss tt' }
Function CloseExit{ If($GuiSwitch){ $Form.Close() } ;Exit }
Function ShowInvalid([Bool]$InvalidA){ If($InvalidA){ Write-Host "`nInvalid Input" -ForegroundColor Red -BackgroundColor Black -NoNewline } Return $False }
Function DownloadFile([String]$Url,[String]$FilePath){ (New-Object System.Net.WebClient).DownloadFile($Url, $FilePath) }
Function QMarkServices([String]$Srv){ If($Srv -Match '_\?+$'){ Return ($Srv -Replace '_\?+$',$ServiceEnd) } Return $Srv }
Function SearchSrv([String]$Srv,[String]$Fil){ Return ($CurrServices.Where({$_.ServiceName -eq $Srv},'First')).$Fil }
Function AutoDelayTest([String]$Srv){ $tmp = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\$Srv\").DelayedAutostart ;If($Null -ne $tmp){ Return $tmp } Return 0 }
Function AutoDelaySet([String]$Srv,[Int]$EnDi){ Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\$Srv\" -Name 'DelayedAutostart' -Type DWord -Value $EnDi }

Function GetCurrServices{
	$Script:CurrServices = Get-CimInstance Win32_service | Foreach-Object{
		$TMPName = $_.Name
		If($TMPName -NotIn $Skip_Services) {
			[PSCustomObject]@{
				ServiceName = $TMPName
				Status = $_.State
				StartType = $_.StartMode
				DisplayName = $_.DisplayName
				PathName = $_.PathName
				Description = $_.Description
				AutoDelay = AutoDelayTest $TMPName
			}
		}
	}
}

Function DisplayOut {
	Param(
		[Alias('T')] [String[]]$Text,
		[Alias('C')] [Int[]]$Color,
		[Alias('L')] [Switch]$Log,
		[Alias('G')] [Switch]$Gui
	)
	If($Gui){ TBoxService @args }
	For($i = 0 ;$i -lt $Text.Length ;$i++){ Write-Host $Text[$i] -ForegroundColor $colors[$Color[$i]] -BackgroundColor 'Black' -NoNewLine } ;Write-Host
	If($Log -and $ScriptLog -eq 1){ Write-Output "$(GetTime): $($Text -Join ' ')" | Out-File -LiteralPath $LogFile -Encoding Unicode -Append }
}

Function DisplayOutLML {
	Param( [Alias('T')] [String]$Text, [Alias('C')] [Int[]]$Color, [Alias('L')] [Switch]$Log )
	DisplayOut '| ',"$Text".PadRight(50),' |' -C 14,$Color,14 -L:$Log
}

Function DisplayMisc {
	Param( [Switch]$Menu, [Switch]$Line, [String]$Misc )
	$txt = If($Line){ '|'.PadRight(53,'-') + '|' } Else{ '|'.PadRight(53) + '|' } #Line or Blank Spaces
	$Splat = If($Menu) {
		@{ Text = $txt ;Color = 14 ;Log = [bool]$Misc }
	} Else { #For ToS
		@{ Text = $txt ;Color = [int]$Misc ;Log = $False }
	}
	DisplayOut @Splat
}

Function Error_Top {
	Clear-Host
	DiagnosticCheck 0
	DisplayMisc -Menu -Line -Misc $True
	DisplayOutLML (''.PadRight(22)+'Error') -C 13 -L
	DisplayMisc -Menu -Line -Misc $True
	DisplayMisc -Menu -Misc $True
}

Function Error_Bottom {
	DisplayMisc -Misc $True
	DisplayMisc -Line -Misc $True
	If($Diagnostic -eq 1){ DiagnosticCheck 0 }
	AutomatedExitCheck 1
}

##########
# Multi Use Functions -End
##########
# TOS -Start
##########

Function ShowCopyright { Clear-Host ;DisplayOut $Copyright -C 14 }

Function TOSDisplay([Switch]$C) {
	If(!$C){ Clear-Host }
	$BC = 14
	If($Release_Type -ne 'Stable') {
		$BC = 15
		DisplayMisc -Line -Misc 15
		DisplayOut '|'.PadRight(22),'Caution!!!'.PadRight(31),'|' -C 15,13,15
		DisplayMisc -Misc 15
		DisplayOut '|','         This script is still being tested.         ','|' -C 15,14,15
		DisplayOut '|'.PadRight(17),'USE AT YOUR OWN RISK.'.PadRight(36),'|' -C 15,14,15
		DisplayMisc -Misc 15
	}
	DisplayMisc -Line -Misc $BC
	DisplayOut '|'.PadRight(21),'Terms of Use'.PadRight(32),'|' -C $BC,11,$BC
	DisplayMisc -Line -Misc $BC
	DisplayMisc -Misc $BC
	DisplayOut '|',' This program comes with ABSOLUTELY NO WARRANTY.    ','|' -C $BC,2,$BC
	DisplayOut '|',' This is free software, and you are welcome to      ','|' -C $BC,2,$BC
	DisplayOut '|',' redistribute it under certain conditions.          ','|' -C $BC,2,$BC
	DisplayMisc -Misc $BC
	DisplayOut '|',' Read License file for full Terms.'.PadRight(52),'|' -C $BC,2,$BC
	DisplayMisc -Misc $BC
	DisplayOut '|',' Use the switch ','-copy',' to see License Information or ','|' -C $BC,2,14,2,$BC
	DisplayOut '|',' enter ','L',' bellow.'.PadRight(44),'|' -C $BC,2,14,2,$BC
	DisplayMisc -Misc $BC
	DisplayMisc -Line -Misc $BC
}

Function TOS {
	$Invalid = $False
	$CR = $False
	While($TOS -NotIn 'y','yes') {
		TOSDisplay -C:$CR
		$CR = $False
		$Invalid = ShowInvalid $Invalid
		$TOS = Read-Host "`nDo you Accept? (Y)es/(N)o"
		If($TOS -In 'n','no') {
			Exit
		} ElseIf($TOS -eq 'l') {
			$CR = $True
			ShowCopyright
		} Else {
			$Invalid = $True
		}
	}
	$Script:AcceptToS = 'Accepted'
	$Script:RunScript = 1
	If($LoadServiceConfig -eq 1){ Service_Select_Set } ElseIf($Service_Select -eq 0){ GuiStart } Else{ Service_Select_Set $Service_Select }
}

##########
# TOS -End
##########
# GUI -Start
##########

Function ScanForServiceFiles {
	$ScanDir = $FileBase + 'Win ' + $WindowVersion
	$Script:ListofServicesFilesFull = If(Test-Path $ScanDir){@(Get-ChildItem -Path "$ScanDir\*.csv" | Select-Object -ExpandProperty FullName) }
	[System.Collections.ArrayList]$Script:ListofServicesFiles = @()
	[Void] $ListofServicesFiles.Add([PSCustomObject] @{Name = '--Select Option Here--' ;FullPath = 'None'})
	Foreach($File in $ListofServicesFilesFull){ [Void] $ListofServicesFiles.Add([PSCustomObject] @{ Name = [System.IO.Path]::GetFileNameWithoutExtension($File) ;FullPath = $File}) }
	[Void] $ListofServicesFiles.Add([PSCustomObject] @{ Name = '--Browse for File--' ;FullPath = 'None'})
}

Function OpenSaveDiaglog([Int]$SorO) {
	$SOFileDialog = If($SorO -eq 0){ New-Object System.Windows.Forms.OpenFileDialog } Else{ New-Object System.Windows.Forms.SaveFileDialog }
	$SOFileDialog.InitialDirectory = $FileBase
	$SOFileDialog.Filter = 'CSV (*.csv)| *.csv'
	$SOFileDialog.ShowDialog()
	$SOFPath = $SOFileDialog.Filename
	If($SOFPath) {
		If($SorO -eq 0) {
			$Script:ServiceConfigFile = $SOFPath
			$WPF_LoadFileTxtBox.Text = $ServiceConfigFile
			RunDisableCheck
		} ElseIf($SorO -eq 1) {
			Save_Service $SOFPath
		}
	}
}

Function HideShowCustomSrvStuff {
	$Vis,$TF,$WPF_CustomNoteGrid.Visibility = If(($WPF_ServiceConfig.SelectedIndex+1) -eq $SFCount){ 'Visible',$False,'Visible' } Else{ 'Hidden',$True,'Collapsed' }
	$WPF_CustomNote, $WPF_LoadFileTxtBox, $WPF_btnOpenFile | Where-Object { $_.Visibility = $Vis }
}

Function ClickedDonate{ Start-Process $Donate_Url ;$Script:ConsideredDonation = 'Yes' }

Function UpdateSetting {
	$VarList.ForEach{
		$SetValue = If($_.Value.IsChecked){ 1 } Else{ 0 }
		Set-Variable -Name ($_.Name.Split('_')[1]) -Value $SetValue -Scope Script
	}
	$Script:LogName = $WPF_LogNameInput.Text
}

Function SaveSetting {
	UpdateSetting

	$Settings = @{
		AcceptToS = $AcceptToS
		BackupServiceConfig = $BackupServiceConfig
		InternetCheck = $InternetCheck
		ScriptVerCheck = $ScriptVerCheck
		ShowConsole = $ShowConsole
		XboxService = $XboxService
		StopDisabled = $StopDisabled
		ChangeState = $ChangeState
		ShowSkipped = $ShowSkipped
		ShowAllServices = $ShowAllServices
	}
	If($ConsideredDonation -eq 'Yes'){ $Settings.ConsideredDonation = 'Yes' }
	If($WPF_DevLogCB.IsChecked) {
		$Settings | ForEach-Object{
			$_.ScriptLog = $Script_Log
			$_.LogName = $Log_Name
			$_.Diagnostic = $Diagn_ostic
			$_.LogBeforeAfter = $Log_Before_After
			$_.DryRun = $Dry_Run
			$_.ShowNonInstalled = $Show_Non_Installed
			$_.ShowAlreadySet = $Show_Already_Set
		}
	} Else {
		$Settings | ForEach-Object{
			$_.ScriptLog = $ScriptLog
			$_.LogName = $LogName
			$_.Diagnostic = $Diagnostic
			$_.LogBeforeAfter = $LogBeforeAfter
			$_.DryRun = $DryRun
			$_.ShowNonInstalled = $ShowNonInstalled
			$_.ShowAlreadySet = $ShowAlreadySet
		}
	}

	If(Test-Path -LiteralPath $SettingPath -PathType Leaf) {
		$Tmp = (Import-Clixml -LiteralPath $SettingPath | ConvertTo-Xml).Objects.Object.Property."#text"
		If(($Tmp.Count/2) -eq $Settings.Count) {
			$T1 = While($Tmp){ $Key, $Val, $Tmp = $Tmp ;[PSCustomObject] @{ Name = $Key ;Val = $Val } }
			$Tmp = ($Settings | ConvertTo-Xml).Objects.Object.Property."#text"
			$T2 = While($Tmp){ $Key, $Val, $Tmp = $Tmp ;[PSCustomObject] @{ Name = $Key ;Val = $Val } }
			If(Compare-Object $T1 $T2 -Property Name,Val){ $SaveSettingFile = $True }
		} Else {
			$SaveSettingFile = $True
		}
	} Else {
		$SaveSettingFile = $True
	}
	If($SaveSettingFile){ $Settings | Export-Clixml -LiteralPath $SettingPath }
}

Function ShowConsoleWin([Int]$Choice){ [Console.Window]::ShowWindow($ConsolePtr, $Choice) }#0 = Hide, 5 = Show

Function GuiStart {
	#Needed to Hide Console window
	Add-Type -Name Window -Namespace Console -MemberDefinition '[DllImport("Kernel32.dll")] public static extern IntPtr GetConsoleWindow() ;[DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);'
	$Script:ConsolePtr = [Console.Window]::GetConsoleWindow()

	Clear-Host
	DisplayOut 'Preparing GUI, Please wait...' -C 15
	$Script:GuiSwitch = $True

    Add-Type -AssemblyName PresentationFramework,PresentationCore,WindowsBase,System.Windows.Forms

[xml]$XAML =@"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
  Title="Service Configurator Script By: MadBomb122" Height="540" Width="720" BorderBrush="Black" Background="White">
	<Window.Resources>
		<Style x:Key="SeparatorStyle1" TargetType="{x:Type Separator}">
			<Setter Property="SnapsToDevicePixels" Value="True"/>
			<Setter Property="Margin" Value="0,0,0,0"/>
			<Setter Property="Template">
				<Setter.Value>
					<ControlTemplate TargetType="{x:Type Separator}">
						<Border Height="24" SnapsToDevicePixels="True" Background="#FF4D4D4D" BorderBrush="#FF4D4D4D" BorderThickness="0,0,0,1"/>
					</ControlTemplate>
				</Setter.Value>
			</Setter>
		</Style>
		<Style TargetType="{x:Type ToolTip}"><Setter Property="Background" Value="#FFFFFFBF"/></Style>
	</Window.Resources>
	<Window.Effect><DropShadowEffect/></Window.Effect>
	<Grid>
		<Grid.RowDefinitions>
			<RowDefinition Height="24"/>
			<RowDefinition Height="*"/>
			<RowDefinition Height="48"/>
		</Grid.RowDefinitions>
		<Menu Grid.Row="0" IsMainMenu="True">
			<MenuItem Header="Help">
				<MenuItem Name="FeedbackButton" Header="Feedback/Bug Report"/>
				<MenuItem Name="FAQButton" Header="FAQ"/>
				<MenuItem Name="AboutButton" Header="About"/>
				<MenuItem Name="CopyrightButton" Header="Copyright"/>
				<MenuItem Name="ContactButton" Header="Contact Me"/>
			</MenuItem>
			<MenuItem Name="DonateButton" Header="Donate to Me" Background="Orange" FontWeight="Bold"/>
			<MenuItem Name="Madbomb122WSButton" Header="Madbomb122's GitHub" Background="Gold" FontWeight="Bold"/>
			<MenuItem Name="PublicServicesWSButton" Header="Shared Service Configuration" Background="#FF71E780" FontWeight="Bold"/>
		</Menu>
		<Grid Grid.Row="1">
			<TabControl BorderBrush="Gainsboro" Grid.Row="1" Name="TabControl">
				<TabControl.Resources>
					<Style TargetType="TabItem">
						<Setter Property="Template">
							<Setter.Value>
								<ControlTemplate TargetType="TabItem">
									<Border Name="Border" BorderThickness="1,1,1,0" BorderBrush="Gainsboro" CornerRadius="4,4,0,0" Margin="2,0">
										<ContentPresenter Name="ContentSite"  VerticalAlignment="Center" HorizontalAlignment="Center" ContentSource="Header" Margin="10,2"/>
									</Border>
									<ControlTemplate.Triggers>
										<Trigger Property="IsSelected" Value="True">
											<Setter TargetName="Border" Property="Background" Value="LightSkyBlue" />
										</Trigger>
										<Trigger Property="IsSelected" Value="False">
											<Setter TargetName="Border" Property="Background" Value="GhostWhite" />
										</Trigger>
									</ControlTemplate.Triggers>
								</ControlTemplate>
							</Setter.Value>
						</Setter>
					</Style>
				</TabControl.Resources>
				<TabItem Name="Services_Tab" Header="Services Options">
					<Grid Background="#FFE5E5E5">
						<Grid.RowDefinitions>
							<RowDefinition Height="1.5*"/>
							<RowDefinition Height="0.5*"/>
						</Grid.RowDefinitions>
						<GroupBox Grid.Row="0" FontWeight="Bold" Header="Service Configuration" Grid.RowSpan="2">
							<Grid Grid.Row="0" Margin="5">
								<Grid.RowDefinitions>
									<RowDefinition Height="*"/>
									<RowDefinition Height="*"/>
									<RowDefinition Height="*"/>
									<RowDefinition Height="*"/>
								</Grid.RowDefinitions>
								<Grid.ColumnDefinitions>
									<ColumnDefinition Width=".5*"/>
									<ColumnDefinition Width="3.5*"/>
									<ColumnDefinition Width=".5*"/>
								</Grid.ColumnDefinitions>
								<Grid Grid.Column="1" Margin="0,95,0,0" Grid.RowSpan="2">
									<Grid.ColumnDefinitions>
										<ColumnDefinition Width="4*"/>
										<ColumnDefinition Width="7*"/>
										<ColumnDefinition Width="3*"/>
									</Grid.ColumnDefinitions>
									<TextBlock Grid.Column="0" FontWeight="Bold" HorizontalAlignment="Right" VerticalAlignment="Center" Margin="5">Service Configurations:</TextBlock>
									<ComboBox Grid.Column="1" VerticalAlignment="Center" Name="ServiceConfig" Margin="5"/>
									<TextBlock Name="CustomNote" Grid.Column="2" FontWeight="Bold" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="5">Configure Below</TextBlock>
								</Grid>
								<TextBlock Grid.Column="1" Grid.Row="0" FontWeight="Bold" HorizontalAlignment="Center" VerticalAlignment="Bottom" Margin="5">Make sure to look at script options for settings.</TextBlock>
							</Grid>
						</GroupBox>
						<GroupBox Name="CustomNoteGrid" FontWeight="Bold" Header="Custom Configuration" Grid.Row="1">
							<Grid>
								<Grid.ColumnDefinitions>
									<ColumnDefinition Width="*"/>
									<ColumnDefinition Width="4*"/>
								</Grid.ColumnDefinitions>
								<Button Grid.Column="0" Name="btnOpenFile" Margin="5" Content="Browse"/>
								<TextBlock Grid.Column="1" Name="LoadFileTxtBox"/>
							</Grid>
						</GroupBox>
					</Grid>
				</TabItem>
				<TabItem Name="Options_tab" Header="Script Options">
					<Grid>
						<Grid.ColumnDefinitions>
							<ColumnDefinition Width="*"/>
							<ColumnDefinition Width="*"/>
							<ColumnDefinition Width="*"/>
						</Grid.ColumnDefinitions>
						<Grid Grid.Column="0">
							<Grid.RowDefinitions>
								<RowDefinition Height="2.5*"/>
								<RowDefinition Height="3*"/>
							</Grid.RowDefinitions>
							<GroupBox Grid.Row="0" Content="Display Options" FontWeight="Bold" Margin="5"/>
							<Grid Grid.Row="0">
								<Grid.RowDefinitions>
									<RowDefinition Height=".5*"/>
									<RowDefinition Height="*"/>
									<RowDefinition Height="*"/>
									<RowDefinition Height="*"/>
									<RowDefinition Height=".2*"/>
								</Grid.RowDefinitions>
								<Grid.ColumnDefinitions>
									<ColumnDefinition Width="10"/>
									<ColumnDefinition Width="*"/>
								</Grid.ColumnDefinitions>
								<CheckBox Grid.Row="1" Grid.Column="1" Margin="5" HorizontalAlignment="Left" VerticalAlignment="Center" Name="ShowAlreadySet_CB" Content="Show Already Set Services" IsChecked="True"/>
								<CheckBox Grid.Row="2" Grid.Column="1" Margin="5" HorizontalAlignment="Left" VerticalAlignment="Center" Name="ShowNonInstalled_CB" Content="Show Not Installed Services"/>
								<CheckBox Grid.Row="3" Grid.Column="1" Margin="5" HorizontalAlignment="Left" VerticalAlignment="Center" Name="ShowSkipped_CB" Content="Show Skipped Services"/>
							</Grid>
							<GroupBox Grid.Row="1" Content="Miscellaneous" FontWeight="Bold" Margin="5"/>
							<Grid Grid.Row="1">
								<Grid.RowDefinitions>
									<RowDefinition Height=".5*"/>
									<RowDefinition Height="*"/>
									<RowDefinition Height="*"/>
									<RowDefinition Height="*"/>
									<RowDefinition Height="*"/>
									<RowDefinition Height="*"/>
									<RowDefinition Height=".2*"/>
								</Grid.RowDefinitions>
								<Grid.ColumnDefinitions>
									<ColumnDefinition Width="10"/>
									<ColumnDefinition Width="*"/>
								</Grid.ColumnDefinitions>
								<CheckBox Grid.Row="1" Grid.Column="1" Margin="5" HorizontalAlignment="Left" VerticalAlignment="Center" Name="Dryrun_CB" Content="Dryrun / What if"/>
								<CheckBox Grid.Row="2" Grid.Column="1" Margin="5" HorizontalAlignment="Left" VerticalAlignment="Center" Name="XboxService_CB" Content="Skip All Xbox Services"/>
								<CheckBox Grid.Row="3" Grid.Column="1" Margin="5" HorizontalAlignment="Left" VerticalAlignment="Center" Name="ChangeState_CB" Content="Allow Change of Service State"/>
								<CheckBox Grid.Row="4" Grid.Column="1" Margin="5" HorizontalAlignment="Left" VerticalAlignment="Center" Name="StopDisabled_CB" Content="Stop Disabled Services"/>
								<CheckBox Grid.Row="5" Grid.Column="1" Margin="5" HorizontalAlignment="Left" VerticalAlignment="Center" Name="ShowAllServices_CB" Content="Show All Services"/>
							</Grid>
						</Grid>
						<Grid Grid.Column="1">
							<Grid.RowDefinitions>
								<RowDefinition Height="2.5*"/>
								<RowDefinition Height="3*"/>
							</Grid.RowDefinitions>
							<GroupBox Grid.Row="2" Content="Development" FontWeight="Bold" Margin="5"/>
							<Grid Grid.Row="2">
								<Grid.RowDefinitions>
									<RowDefinition Height=".5*"/>
									<RowDefinition Height="*"/>
									<RowDefinition Height="*"/>
									<RowDefinition Height="*"/>
									<RowDefinition Height="*"/>
									<RowDefinition Height=".2*"/>
								</Grid.RowDefinitions>
								<Grid.ColumnDefinitions>
									<ColumnDefinition Width="10"/>
									<ColumnDefinition Width="*"/>
									<ColumnDefinition Width="10"/>
								</Grid.ColumnDefinitions>
								<CheckBox Grid.Row="1" Grid.Column="1" Margin="5" HorizontalAlignment="Left" VerticalAlignment="Center" Name="Diagnostic_CB" Content="Diagnostic Output (On Error)"/>
								<CheckBox Grid.Row="2" Grid.Column="1" Margin="5" HorizontalAlignment="Left" VerticalAlignment="Center" Name="DevLogCB" Content="Enable Development Logging"/>
								<CheckBox Grid.Row="3" Grid.Column="1" Margin="5" HorizontalAlignment="Left" VerticalAlignment="Center" Name="ShowConsole_CB" Content="Show Console Window"/>
								<Button Grid.Row="4" Grid.Column="1" Margin="5" Content="Show Diagnostic" Name="ShowDiagButton"/>
							</Grid>
							<GroupBox Grid.Row="0" Content="Logging" FontWeight="Bold" Margin="5"/>
							<Grid Grid.Row="0">
								<Grid.RowDefinitions>
									<RowDefinition Height=".5*"/>
									<RowDefinition Height="*"/>
									<RowDefinition Height="*"/>
									<RowDefinition Height="*"/>
									<RowDefinition Height="*"/>
									<RowDefinition Height=".2*"/>
								</Grid.RowDefinitions>
								<Grid.ColumnDefinitions>
									<ColumnDefinition Width="10"/>
									<ColumnDefinition Width="*"/>
									<ColumnDefinition Width="10*"/>
								</Grid.ColumnDefinitions>
								<CheckBox Grid.Row="1" Grid.Column="1" Margin="5" HorizontalAlignment="Left" VerticalAlignment="Center" Name="LogBeforeAfter_CB" Content="Log Services Before &amp; After" Grid.ColumnSpan="2"/>
								<CheckBox Grid.Row="2" Grid.Column="1" Margin="5" HorizontalAlignment="Left" VerticalAlignment="Center" Name="ScriptLog_CB" Content="Script Log" Grid.ColumnSpan="2"/>
								<TextBox Grid.Row="3" Grid.Column="2" Margin="5" VerticalAlignment="Center" Name="LogNameInput" TextAlignment="Left" Text="$FullPath\Script.log"/>
								<CheckBox Grid.Row="4" Grid.Column="1" Margin="5" HorizontalAlignment="Left" VerticalAlignment="Center" Name="BackupServiceConfig_CB" Content="Backup Current Service" Grid.ColumnSpan="2"/>
							</Grid>
						</Grid>
						<Grid Grid.Column="2">
							<GroupBox Grid.Row="0" Content="Update Items" FontWeight="Bold" Margin="5"/>
							<Grid Grid.Row="0">
								<Grid.RowDefinitions>
									<RowDefinition Height="1.5*"/>
									<RowDefinition Height="3*"/>
									<RowDefinition Height="3*"/>
									<RowDefinition Height="3*"/>
									<RowDefinition Height="3*"/>
									<RowDefinition Height="10*"/>
								</Grid.RowDefinitions>
								<Grid.ColumnDefinitions>
									<ColumnDefinition Width="10"/>
									<ColumnDefinition Width="*"/>
									<ColumnDefinition Width="10"/>
								</Grid.ColumnDefinitions>
								<Button Grid.Row="1" Grid.Column="1" Margin="5" Name="UpdateScriptButton" Content="Check Service Utility Script"/>
								<CheckBox Grid.Row="2" Grid.Column="1" Margin="5" HorizontalAlignment="Left" VerticalAlignment="Center" Name="ScriptVerCheck_CB" Content="Auto Script Update"/>
								<CheckBox Grid.Row="3" Grid.Column="1" Margin="5" HorizontalAlignment="Left" VerticalAlignment="Center" Name="InternetCheck_CB" Content="Skip Internet Check"/>
							</Grid>
						</Grid>
					</Grid>
				</TabItem>
				<TabItem Name="ServicesDG_Tab" Header="Services List" Visibility="Hidden">
					<Grid>
						<Grid.RowDefinitions>
							<RowDefinition Height="75"/>
							<RowDefinition Height="*"/>
						</Grid.RowDefinitions>
						<Grid Grid.Row="0">
							<Grid.RowDefinitions>
								<RowDefinition Height="*"/>
								<RowDefinition Height="*"/>
							</Grid.RowDefinitions>
							<Grid.ColumnDefinitions>
								<ColumnDefinition Width="3*"/>
								<ColumnDefinition Width="3*"/>
								<ColumnDefinition Width="4*"/>
								<ColumnDefinition Width="6.7*"/>
							</Grid.ColumnDefinitions>
							<Button Grid.Column="0" Grid.Row="0" Name="LoadServicesButton" Content="Reload Services" VerticalAlignment="Center" Margin="8"/>
							<Button Grid.Column="1" Grid.Row="0" Name="SaveCustomSrvButton" Content="Save Selection" VerticalAlignment="Center" Margin="8"/>
							<TextBlock Grid.Column="4" Grid.RowSpan="2" Name="TableLegend" FontWeight="Bold" TextAlignment="Left" Margin="2"><Run Background="LightGreen" Text="Service within selected configuration compliance"/><LineBreak/><Run Background="LightCoral" Text="Service NOT in selected configuration compliance"/><LineBreak/><Run Background="Yellow" Text="Service Not covered in selected configuration"/><LineBreak/><Run Text="Uncheck services you don't want changed"/></TextBlock>
							<TextBox Grid.Column="0" Grid.ColumnSpan="2" Grid.Row="1" Name="FilterTxt" TextWrapping="Wrap" Margin="8"/>
							<ComboBox Grid.Column="2" Grid.Row="1" Name="FilterType" VerticalAlignment="Top" Margin="8">
								<ComboBoxItem Content="Checked"/>
								<ComboBoxItem Content="Common Name" IsSelected="True"/>
								<ComboBoxItem Content="Service Name"/>
								<ComboBoxItem Content="Current Setting"/>
								<ComboBoxItem Content="Loaded File"/>
								<ComboBoxItem Content="State"/>
								<ComboBoxItem Content="Description"/>
								<ComboBoxItem Content="Path"/>
								<ComboBoxItem Content="Row Color"/>
							</ComboBox>
						</Grid>
						<DataGrid Grid.Row="1" Name="dataGrid" FrozenColumnCount="2" AutoGenerateColumns="False" AlternationCount="2" HeadersVisibility="Column" CanUserResizeRows="False" CanUserAddRows="False" IsTabStop="True" IsTextSearchEnabled="True" SelectionMode="Extended">
							<DataGrid.RowStyle>
								<Style TargetType="{ x:Type DataGridRow }">
									<Style.Triggers>
										<Trigger Property="AlternationIndex" Value="0">
											<Setter Property="Background" Value="White"/>
										</Trigger>
										<Trigger Property="AlternationIndex" Value="1">
											<Setter Property="Background" Value="#FFD8D8D8"/>
										</Trigger>
										<Trigger Property="IsMouseOver" Value="True">
											<Setter Property="ToolTip">
												<Setter.Value>
													<TextBlock Text="{ Binding SrvDesc }" TextWrapping="Wrap" Width="400" Background="#FFFFFFBF" Foreground="Black"/>
												</Setter.Value>
											</Setter>
											<Setter Property="ToolTipService.ShowDuration" Value="360000000"/>
										</Trigger>
										<MultiDataTrigger>
											<MultiDataTrigger.Conditions>
												<Condition Binding="{ Binding checkboxChecked }" Value="True"/>
												<Condition Binding="{ Binding Matches }" Value="False"/>
											</MultiDataTrigger.Conditions>
											<Setter Property="Background" Value="#F08080"/>
										</MultiDataTrigger>
										<MultiDataTrigger>
											<MultiDataTrigger.Conditions>
												<Condition Binding="{ Binding checkboxChecked }" Value="False"/>
												<Condition Binding="{ Binding Matches }" Value="False"/>
											</MultiDataTrigger.Conditions>
											<Setter Property="Background" Value="#FFFFFF64"/>
										</MultiDataTrigger>
										<MultiDataTrigger>
											<MultiDataTrigger.Conditions>
												<Condition Binding="{ Binding checkboxChecked }" Value="True"/>
												<Condition Binding="{ Binding Matches }" Value="True"/>
											</MultiDataTrigger.Conditions>
											<Setter Property="Background" Value="LightGreen"/>
										</MultiDataTrigger>
									</Style.Triggers>
								</Style>
							</DataGrid.RowStyle>
							<DataGrid.Columns>
								<DataGridTemplateColumn SortMemberPath="checkboxChecked" CanUserSort="True">
									<DataGridTemplateColumn.Header>
										<CheckBox Name="ACUcheckboxChecked"/>
									</DataGridTemplateColumn.Header>
									<DataGridTemplateColumn.CellTemplate>
										<DataTemplate>
											<CheckBox IsChecked="{Binding checkboxChecked,Mode=TwoWay,UpdateSourceTrigger=PropertyChanged,NotifyOnTargetUpdated=True}"/>
										</DataTemplate>
									</DataGridTemplateColumn.CellTemplate>
								</DataGridTemplateColumn>
								<DataGridTextColumn Header="Common Name" Width="120" Binding="{Binding CName}" CanUserSort="True" IsReadOnly="True"/>
								<DataGridTextColumn Header="Service Name" Width="120" Binding="{Binding ServiceName}" IsReadOnly="True"/>
								<DataGridTextColumn Header="Current Setting" Width="95" Binding="{Binding CurrType}" IsReadOnly="True"/>
								<DataGridTemplateColumn Header="Loaded File" Width="105" SortMemberPath="FileType" CanUserSort="True">
									<DataGridTemplateColumn.CellTemplate>
										<DataTemplate>
											<ComboBox ItemsSource="{Binding ServiceTypeListDG}" Text="{Binding Path=FileType, Mode=TwoWay, UpdateSourceTrigger=PropertyChanged}"/>
										</DataTemplate>
									</DataGridTemplateColumn.CellTemplate>
								</DataGridTemplateColumn>
								<DataGridTemplateColumn Header="State" Width="80" SortMemberPath="SrvState" CanUserSort="True">
									<DataGridTemplateColumn.CellTemplate>
										<DataTemplate>
											<ComboBox ItemsSource="{Binding SrvStateListDG}" Text="{Binding Path=SrvState, Mode=TwoWay, UpdateSourceTrigger=PropertyChanged}"/>
										</DataTemplate>
									</DataGridTemplateColumn.CellTemplate>
								</DataGridTemplateColumn>
								<DataGridTextColumn Header="Description" Width="120" Binding="{Binding SrvDesc}" CanUserSort="True" IsReadOnly="True"/>
								<DataGridTextColumn Header="Path" Width="120" Binding="{Binding SrvPath}" CanUserSort="True" IsReadOnly="True"/>
							</DataGrid.Columns>
						</DataGrid>
					</Grid>
				</TabItem>
				<TabItem Name="ServiceChanges" Header="Service Changes" Visibility="Hidden">
					<ScrollViewer VerticalScrollBarVisibility="Visible">
						<TextBlock Name="ServiceListing" TextTrimming="CharacterEllipsis" Background="White"/>
					</ScrollViewer>
				</TabItem>
				<TabItem Name="DiagnosticTab" Header="Diagnostic" Visibility="Hidden">
					<ScrollViewer VerticalScrollBarVisibility="Visible">
						<TextBlock Name="DiagnosticOutput" TextTrimming="CharacterEllipsis" Background="White"/>
					</ScrollViewer>
				</TabItem>
			</TabControl>
		</Grid>
		<Grid Grid.Row="2">
			<Grid.RowDefinitions>
				<RowDefinition Height="*"/>
				<RowDefinition Height="*"/>
			</Grid.RowDefinitions>
			<Button Grid.Row="0" Grid.ColumnSpan="2" Name="RunScriptButton" Content="Run Script" FontWeight="Bold"/>
			<TextBox Grid.Row="1" Name="Script_Ver_Txt" TextAlignment="Center">Script Version: $Script_Version ($Script_Date) [$Release_Type]</TextBox>
		</Grid>
	</Grid>
</Window>
"@

	$Form = [Windows.Markup.XamlReader]::Load( (New-Object System.Xml.XmlNodeReader $xaml) )
	$xaml.SelectNodes('//*[@Name]').ForEach{Set-Variable -Name "WPF_$($_.Name)" -Value $Form.FindName($_.Name) -Scope Script}
	$Runspace = [RunSpaceFactory]::CreateRunspace()
	$PowerShell = [PowerShell]::Create()
	$PowerShell.RunSpace = $Runspace
	$Runspace.Open()

	[System.Collections.ArrayList]$Script:VarList = Get-Variable 'WPF_*_CB'
	$Script:DataGridListBlank = @{}

	$Form.add_closing{
		If(!$RanScript -And [Windows.Forms.Messagebox]::Show('Are you sure you want to exit?','Exit','YesNo') -eq 'No'){ $_.Cancel = $True }
		SaveSetting
		LogEnd
		ShowConsoleWin 5
	}
	$WPF_RunScriptButton.Add_Click{ RunScriptFun }

	$WPF_ACUcheckboxChecked.Add_Click{
		$tmp = $WPF_ACUcheckboxChecked.IsChecked
		If($WPF_FilterTxt.Text -ne '') {
			$Script:DGUpdate = $False
			$TxtFilter = $WPF_FilterTxt.Text
			$Filter = $FilterList[$WPF_FilterType.SelectedIndex]
			$TableFilter = $DataGridListCust.Where{ $_.$Filter -Match $TxtFilter }
			$TableFilter.ForEach{ $_.CheckboxChecked = $tmp }
			$WPF_dataGrid.ItemsSource = $TableFilter
			$Script:DGUpdate = $True
		} Else {
			$DataGridListCust.ForEach{ $_.CheckboxChecked = $tmp }
			$WPF_dataGrid.ItemsSource = $DataGridListBlank
			$WPF_dataGrid.ItemsSource = $DataGridListCust
		}
	}

	$WPF_DevLogCB.Add_Click{
		If(!$WPF_DevLogCB.IsChecked) {
			$Script:ScriptLog = $Script_Log
			$Script:LogName = $Log_Name
			$Script:Diagnostic = $Diagn_ostic
			$Script:Automated = $Auto_mated
			$Script:LogBeforeAfter = $Log_Before_After
			$Script:DryRun = $Dry_Run
			$Script:ShowNonInstalled = $Show_Non_Installed
			$Script:ShowSkipped = $Show_Skipped
			$Script:ShowAlreadySet = $Show_Already_Set
		} Else {
			UpdateSetting
			$Script:Script_Log = $ScriptLog
			$Script:Log_Name = $LogName
			$Script:Diagn_ostic = $Diagnostic
			$Script:Auto_mated = $Automated
			$Script:Log_Before_After = $LogBeforeAfter
			$Script:Dry_Run = $DryRun
			$Script:Show_Non_Installed = $ShowNonInstalled
			$Script:Show_Skipped = $ShowSkipped
			$Script:Show_Already_Set = $ShowAlreadySet
			DevLogSet
		}
		$DevLogList.ForEach{
			$TmpWPF = Get-Variable -Name $_ -ValueOnly
			$TmpWPF.IsChecked = If((Get-Variable -Name ($_.Split('_')[1]) -ValueOnly) -eq 0){ $False } Else{ $True }
		}
		$WPF_LogNameInput.Text = $LogName
	}

	[System.Windows.RoutedEventHandler]$DGclickEvent = {
		If($DGUpdate -and $WPF_dataGrid.SelectedItem) {
			If($Null -ne $($WPF_dataGrid.Items.SortDescriptions.PropertyName)) {
				$Script:SortCol = $WPF_dataGrid.Items.SortDescriptions.PropertyName
				$Script:SortDir = $WPF_dataGrid.Items.SortDescriptions.Direction
			}
			$CurrObj = $WPF_dataGrid.CurrentItem
			$CurrObj.Matches = If($CurrObj.CurrType -eq $CurrObj.FileType){ $True } Else{ $False }
			$CurrObj.RowColor = RowColorRet $CurrObj.Matches $CurrObj.CheckboxChecked
			$WPF_dataGrid.ItemsSource = $DataGridListBlank
			$WPF_dataGrid.ItemsSource = If($Null -ne $SortCol) {
				$Tmp = If($SortDir -eq 'Descending'){ $True} Else{ $False }
				If($WPF_FilterTxt.Text -eq '') {
					$DataGridListCust = $DataGridListCust | Sort-Object -Property @{Expression = $SortCol ;Descending = $Tmp }
					$DataGridListCust
				} Else {
					$DataGridListFilter = $DataGridListFilter | Sort-Object -Property @{Expression = $SortCol ;Descending = $Tmp }
					$DataGridListFilter
				}
			} Else {
				If($WPF_FilterTxt.Text -eq ''){ $DataGridListCust } Else{ $DataGridListFilter }
			}
		}
		$Script:DGUpdate = $True
	}
	$WPF_dataGrid.AddHandler([System.Windows.Controls.CheckBox]::CheckedEvent,$DGclickEvent)
	$WPF_dataGrid.AddHandler([System.Windows.Controls.CheckBox]::UnCheckedEvent,$DGclickEvent)
	$WPF_dataGrid.Add_PreviewMouseWheel{ $Script:DGUpdate = $False }
	$WPF_FilterTxt.Add_TextChanged{ DGFilter }
	$WPF_FilterType.Add_DropDownClosed{ DGFilter }
	$WPF_LoadServicesButton.Add_Click{ GenerateServices }
	$WPF_UpdateScriptButton.Add_Click{ UpdateCheckNow }
	$WPF_ShowAllServices_CB.Add_Click{ $ShowAllServices = If($WPF_ShowAllServices_CB.IsChecked){ 1 } Else{ 0 } ;GenerateServices }

	$WPF_ShowDiagButton.Add_Click{
		UpdateSetting
		$WPF_TabControl.Items[4].Visibility = 'Visible'
		$WPF_TabControl.Items[4].IsSelected = $True
		$WPF_DiagnosticOutput.text = ''
		Clear-Host
		$Script:DiagString = ''
		TBoxDiag " Diagnostic Information below, will be copied to the clipboard.`n" -C 13
		$Script:DiagString = [System.Collections.ArrayList]@{}
		TBoxDiag ' ********START********' -C 11
		TBoxDiag ' Diagnostic Output, Some items may be blank' -C 14
		TBoxDiag '' -C 14
		TBoxDiag ' --------Script Info--------' -C 2
		TBoxDiag ' Script Version: ',$Script_Version -C 14,15
		TBoxDiag ' Release Type: ',$Release_Type -C 14,15
		TBoxDiag '' -C 14
		TBoxDiag ' --------System Info--------' -C 2
		TBoxDiag ' Window: ',$FullWinEdition -C 14,15
		TBoxDiag ' Bit: ',$CimOS.OSArchitecture -C 14,15
		TBoxDiag ' Edition SKU#: ',$CimOS.OperatingSystemSKU -C 14,15
		TBoxDiag ' Desktop/Laptop: ',$IsLaptop -C 14,15
		TBoxDiag '' -C 14
		TBoxDiag ' --------Current Settings--------' 2
		TBoxDiag ' ToS: ',$AcceptToS -C 14,15
		TBoxDiag ' Automated: ',$Automated -C 14,15
		TBoxDiag ' ScriptVerCheck: ',$ScriptVerCheck -C 14,15
		TBoxDiag ' InternetCheck: ',$InternetCheck -C 14,15
		TBoxDiag ' ShowAlreadySet: ',$ShowAlreadySet -C 14,15
		TBoxDiag ' ShowNonInstalled: ',$ShowNonInstalled -C 14,15
		TBoxDiag ' ShowSkipped: ',$ShowSkipped -C 14,15
		TBoxDiag ' XboxService: ',$XboxService -C 14,15
		TBoxDiag ' StopDisabled: ',$StopDisabled -C 14,15
		TBoxDiag ' ChangeState: ',$ChangeState -C 14,15
		TBoxDiag ' DryRun: ',$DryRun -C 14,15
		TBoxDiag ' ScriptLog: ',$ScriptLog -C 14,15
		TBoxDiag ' LogName: ',$LogName -C 14,15
		TBoxDiag ' LogBeforeAfter: ',$LogBeforeAfter -C 14,15
		TBoxDiag ' DevLog: ',$DevLog -C 14,15
		TBoxDiag ' BackupServiceConfig: ',$BackupServiceConfig -C 14,15
		TBoxDiag ' ShowConsole: ',$ShowConsole -C 14,15
		TBoxDiag '' -C 14
		TBoxDiag ' --------Misc Info--------' -C 2
		TBoxDiag ' Run Button txt: ',$WPF_RunScriptButton.Content -C 14,15
		TBoxDiag ' Args: ',$PassedArg -C 14,15
		TBoxDiag '' -C 14
		TBoxDiag ' ********END********' -C 11
		$DiagString -join " " | Set-Clipboard
		[Windows.Forms.Messagebox]::Show('Diagnostic Information, has been copied to the clipboard.','Notice', 'OK') | Out-Null
	}

	ScanForServiceFiles
	$WPF_ServiceConfig.ItemsSource = $ListofServicesFiles.Name
	$WPF_ServiceConfig.SelectedIndex = 0
	$Script:SFCount = $WPF_ServiceConfig.Items.Count
	$WPF_ServiceConfig.Add_SelectionChanged{ HideShowCustomSrvStuff ;RunDisableCheck }

	$WPF_TabControl.Add_SelectionChanged{
		If($WPF_ServicesDG_Tab.IsSelected) {
			$TMPsel = $WPF_ServiceConfig.SelectedIndex
			If($TMPsel -ne 0 -and $TMPsel -ne $SelectedSerOld) {
				$Script:ServiceImport = 1
				$Script:SelectedSerOld = $TMPsel
				GenerateServices
			}
		}
	}

	$WPF_ShowConsole_CB.Add_Checked{ ShowConsoleWin 5 } #5 = Show
	$WPF_ShowConsole_CB.Add_UnChecked{ ShowConsoleWin 0 } #0 = Hide
	$WPF_btnOpenFile.Add_Click{ OpenSaveDiaglog 0 }
	$WPF_SaveCustomSrvButton.Add_Click{ OpenSaveDiaglog 1 }
	$WPF_ContactButton.Add_Click{ Start-Process 'mailto:madbomb122@gmail.com' }
	$WPF_Madbomb122WSButton.Add_Click{ Start-Process 'https://GitHub.com/madbomb122/' }
	$WPF_PublicServicesWSButton.Add_Click{ Start-Process 'https://www.dropbox.com/scl/fo/yh96ixe0ophoszppou8fa/h?dl=0&rlkey=ahkqqdbtckbjb77xwlxs4ge6q' }
	$WPF_FeedbackButton.Add_Click{ Start-Process "$MySite/issues" }
	$WPF_FAQButton.Add_Click{ Start-Process "$MySite/blob/master/README.md" }
	$WPF_DonateButton.Add_Click{ ClickedDonate }
	$WPF_CopyrightButton.Add_Click{ [Windows.Forms.Messagebox]::Show($Copyright,'Copyright', 'OK') | Out-Null }
	$WPF_AboutButton.Add_Click{ [Windows.Forms.Messagebox]::Show("This script allows you to change service configuration. You can Save your current service state, Load one.`n`nThis script was created by MadBomb122.",'About', 'OK') | Out-Null }
	$Script:RunScript = 0

	$VarList.ForEach{ $_.Value.IsChecked = If($(Get-Variable -Name ($_.Name.Split('_')[1]) -ValueOnly) -eq 1){ $True } Else{ $False } }

	$WPF_LogNameInput.Text = $LogName
	$WPF_LoadFileTxtBox.Text = $ServiceConfigFile

	If($Release_Type -ne 'Stable') {
		If($ShowConsole -eq 1){ $WPF_ShowConsole_CB.IsChecked = $True }
		$WPF_ShowConsole_CB.Visibility = 'Hidden'
	} ElseIf($ShowConsole -eq 0) {
		ShowConsoleWin 0
	}

	$Script:ServiceImport = 1
	HideShowCustomSrvStuff
	RunDisableCheck
	DisplayOut 'Displaying GUI Now' -C 14
	DisplayOut "`nTo exit you can close the GUI or PowerShell Window." -C 14

	$Form.ShowDialog() | Out-Null
}

Function RunScriptFun {
	SaveSetting
	If(!$GeneratedServices){ GenerateServices }
	$Script:RunScript = 1
	$Script:Service_Select = $WPF_ServiceConfig.SelectedIndex + 1
	If($Service_Select -eq $SFCount) {
		If(!(Test-Path -LiteralPath $ServiceConfigFile -PathType Leaf) -And $Null -ne $ServiceConfigFile) {
			[Windows.Forms.Messagebox]::Show("The File '$ServiceConfigFile' does not exist.",'Error', 'OK') | Out-Null
			$Script:RunScript = 0
		} Else {
			$Script:LoadServiceConfig = 1
			$Script:Service_Select = 0
		}
	}
	If($RunScript -eq 1) {
		$Script:RanScript = $True
		$WPF_RunScriptButton.IsEnabled = $False
		$WPF_RunScriptButton.Content = 'Run Disabled while changing services.'
		(New-Object -comobject wscript.shell).popup('Script will Run in 1 Second.',1,'This is to prevent clicking Run again.',0) | Out-Null
		$WPF_TabControl.Items[3].Visibility = 'Visible'
		$WPF_TabControl.Items[3].IsSelected = $True
		If($DataGridListCust) {
			$Script:LoadServiceConfig = 2
			$WPF_FilterTxt.text = ''
			$Script:csv = $WPF_dataGrid.Items.ForEach{
				$STF = $ServicesTypeFull.IndexOf($_.FileType)
				If(!$_.CheckboxChecked){ $STF *= -1 }
				[PSCustomObject] @{ ServiceName = $_.ServiceName ;StartType = $STF ;Status = $_.SrvState }
			}
		} ElseIf($Script:LoadServiceConfig -NotIn 1,2) {
			$Script:LoadServiceConfig = 0
		}
		Service_Select_Set
	} Else {
		RunDisableCheck
	}
}

Function RowColorRet([Bool]$Match,[Bool]$checkbox) {
	If(!$Match) {
		If($checkbox){ Return 'Red' } Return 'Yellow'
	} Else {
		If($checkbox){ Return 'Green' } Return 'None'
	}
}

Function DGFilter {
	$Script:DGUpdate = $False
	$TxtFilter = $WPF_FilterTxt.Text
	$Filter = $FilterList[$WPF_FilterType.SelectedIndex]
	$WPF_dataGrid.ItemsSource = $Script:DataGridListFilter = $DataGridListCust.Where{ $_.$Filter -Match $TxtFilter }
	$Script:DGUpdate = $True
}

Function RunDisableCheck {
	$SelectedIndex = $WPF_ServiceConfig.SelectedIndex

	$WPF_RunScriptButton.Content, $State = If(($SelectedIndex+1) -eq $SFCount) {
		If(!$ServiceConfigFile -or !(Test-Path -LiteralPath $ServiceConfigFile -PathType Leaf)) {
			'Run Disabled, No Custom Service List File Selected or Does not exist.' ;$False
		} Else {
			[System.Collections.ArrayList]$Tempcheck = Import-Csv -LiteralPath $ServiceConfigFile
			If($Null -In $Tempcheck[0].StartType) {
				'Run Disabled, Invalid Service File.' ;$False
			} Else {
				"Run Script with Custom Service File `"$([System.IO.Path]::GetFileNameWithoutExtension($ServiceConfigFile))`"" ;$True
			}
		}
	} ElseIf($WPF_ServiceConfig.SelectedIndex -In 1..($SFCount-1)) {
		"Run Script with `"$($ListofServicesFiles[$SelectedIndex].Name)`"" ;$True
	} Else {
		'Run Disabled, No Service Configuration selected.' ;$False
	}

	$WPF_TabControl.Items[2].Visibility = If($State){ 'Visible' } Else{ 'Hidden' }
	$WPF_RunScriptButton, $WPF_LoadServicesButton | Where-Object{ $_.IsEnabled = $State }
}

Function GenerateServices {
	$Script:DGUpdate = $False
	$SelectedIndex = $WPF_ServiceConfig.SelectedIndex

	$ServiceFilePath, $Script:LoadServiceConfig = If(($SelectedIndex + 1) -eq $SFCount) {
		$WPF_LoadFileTxtBox.Text ;1
	} Else {
		$ListofServicesFiles[$SelectedIndex].FullPath ;2
	}

	$Script:XboxService = If($WPF_XboxService_CB.IsChecked){ 1 } Else{ 0 }
	If($ServiceImport -eq 1 -and (Test-Path -LiteralPath $ServiceFilePath -PathType Leaf)) {
		[System.Collections.ArrayList] $Script:ServCB = Import-Csv -LiteralPath $ServiceFilePath
		$Script:ServiceImport = 0
	}

	$Script:DataGridListCust = $CurrServices.ForEach{
		$ServiceName = QMarkServices $_.ServiceName
		$ServiceCurrType = $_.StartType

		[Int]$ServiceTypeNum, $checkbox, $InFile = If($ServCB.ServiceName -Contains $ServiceName) {
			ForEach($srv in $ServCB){ If($srv.ServiceName -eq $ServiceName){ $srv.StartType ;Break } }
			$True ;$True
		} Else {
			0
			$False ;$False
		}
		If($ShowAllServices -eq 1 -or $InFile) {
			[Int]$ServiceCurrTypeNum = $ServicesTypeFull.IndexOf($ServiceCurrType)
			If($ServiceCurrTypeNum -eq 3 -and $_.AutoDelay -ge 1){ [Int]$ServiceCurrTypeNum = 4 }
			If($ServiceTypeNum -In -4..0) {
				$checkbox = $False
				$ServiceTypeNum *= -1
			}
			$ServiceCurrType = $ServicesTypeFull[$ServiceCurrTypeNum]
			$ServiceType = $ServicesTypeFull[$ServiceTypeNum]

			If($XboxService -eq 1 -and $XboxServiceArr -Contains $ServiceName){ $checkbox = $False }
			$Match = If($ServiceType -eq $ServiceCurrType){ $True } Else{ $False }
			$RowColor = RowColorRet $Match $checkbox
			[PSCustomObject] @{ CheckboxChecked = $checkbox ;CName = $_.DisplayName ;ServiceName = $ServiceName ;CurrType = $ServiceCurrType ;FileType = $ServiceType ;ServiceTypeListDG = $ServicesTypeFull ;SrvStateListDG = $SrvStateList ;SrvState = $_.Status ;SrvDesc = $_.Description ;SrvPath = $_.PathName ;Matches = $Match ;RowColor = $RowColor ;InFile = $InFile }
		}
	}

	$WPF_dataGrid.ItemsSource = $DataGridListCust
	$Script:GeneratedServices = $True
	$DGUpdate = $True
}

Function TBoxDiag {
	Param( [Alias('T')] [String[]]$Text, [Alias('C')] [Int[]]$Color )
	$WPF_DiagnosticOutput.Dispatcher.Invoke(
		[action]{
			For($i = 0 ;$i -lt $Text.Length ;$i++) {
				$Run = New-Object System.Windows.Documents.Run
				$Run.Foreground = $colorsGUI[($Color[$i])]
				$Run.Text = $Text[$i]
				$WPF_DiagnosticOutput.Inlines.Add($Run)
			}
			$WPF_DiagnosticOutput.Inlines.Add((New-Object System.Windows.Documents.LineBreak))
		},'Normal'
	)
	$Script:DiagString.Add("$($Text -Join '')`r`n")
	DisplayOut $Text -C $Color
}

##########
# GUI -End
##########
# Update Functions -Start
##########

Function InternetCheck{ If($InternetCheck -eq 1 -or (Test-Connection www.GitHub.com -Count 1 -Quiet)){ Return $True } Return $False }

Function UpdateCheckAuto {
	If(InternetCheck) {
		UpdateCheck -NAuto:$False
	} Else {
		$Script:ErrorDi = 'No Internet'
		Error_Top
		DisplayOutLML 'No Internet connection detected or GitHub.com' -C 2 -L
		DisplayOutLML 'is currently down.' -C 2 -L
		DisplayOutLML 'Tested by pinging GitHub.com' -C 2 -L
		DisplayMisc -Misc $True
		DisplayOutLML 'To skip use one of the following methods' -C 2 -L
		DisplayOut '|',' 1. Run Script or bat file with ','-sic',' switch'.PadRight(16),'|' -C 14,2,15,2,14 -L
		DisplayOut '|',' 2. Change ','InternetCheck',' in Script file'.PadRight(28),'|' -C 14,2,15,2,14 -L
		DisplayOut '|',' 3. Change ','InternetCheck',' in bat file'.PadRight(28),'|' -C 14,2,15,2,14 -L
		DisplayMisc -Misc $True
		DisplayMisc -Line -Misc $True
		AutomatedExitCheck 0
	}
}

Function UpdateCheckNow {
	If(InternetCheck) {
		UpdateCheck @args
	} Else {
		$Script:ErrorDi = 'No Internet'
		[Windows.Forms.Messagebox]::Show('No Internet connection detected or GitHub is down. If you are connected to the internet, Click the Skip internet checkbox.','Error: No Internet', 'OK','Error') | Out-Null
	}
}

Function UpdateCheck {
	Param (
		[Switch]$NAuto = $True,
		[Alias('Srp')] [Switch]$SrpCheck
	)

	Try {
		$CSV_Ver = Invoke-WebRequest $Version_Url -ErrorAction Stop | ConvertFrom-Csv
		$Message = ''
	} Catch {
		$CSV_Ver = $False
		$Message = 'Error: Unable to check for update, try again later.'
		If($ScriptLog -eq 1){ Write-Output "$(GetTime): $Message" | Out-File -LiteralPath $LogFile -Encoding Unicode -Append }
	}

	If(($SrpCheck -or $ScriptVerCheck -eq 1) -and !$CSV_Ver) {
		$CSVLine,$RT = If($Release_Type -eq 'Stable'){ 0,'' } Else{ 2,'Testing/' }
		[Version]$WebScriptVer = $CSV_Ver[$CSVLine].Version + "." + $CSV_Ver[$CSVLine].MinorVersion
		If($WebScriptVer -gt $Script_Version) {
			$Choice = 'Yes'
			If($NAuto){
				$Choice = [Windows.Forms.Messagebox]::Show("Update Script File from $Script_Version to $WebScriptVer ?",'Update Found', 4)
			}
			If($Choice -eq 'Yes') {
				$Script:RanScript = $True
				ScriptUpdateFun $RT
			} ElseIf($Message -eq '') {
				$NAuto = $False
			}
		} ElseIf($NAuto) {
			$Message = 'No Script update Found.'
		}
	}
	If($NAuto){ [Windows.Forms.Messagebox]::Show($Message,'Update','OK') | Out-Null }
}

Function ScriptUpdateFun([String]$RT) {
	SaveSetting
	$Script_Url = $URL_Base + $RT + 'WinServiceConfigurator.ps1'
	$ScrpFilePath = $FileBase + 'WinServiceConfigurator.ps1'
	$Script:RanScript = $True
	$FullVer = $WebScriptVer + '.' + $WebScriptMinorVer
	$Script:Uparg = If($true){
		$ArgList.ForEach{
			$TruCount = 0
			If($GuiSwitch -and !$_.Gui){ $TC = -1 } Else{ $tmp = $_.Var.Split('=') ;$Count = $_.Match ;$TC = $Count*2 }
			For($i = 0 ;$i -lt $TC ;$i += 2) {
				$var = Get-Variable -Name $tmp[$i] -ValueOnly
				If($var -eq $tmp[$i+1]){ $TruCount++ }
			}
			If($TruCount -eq $Count){ $_.Arg }
		}

		If($ScriptLog -eq 1){ "-logc $LogName" }
		If(!$GuiSwitch) {
			If($LoadServiceConfig -eq 1) {
				"-lcsc $ServiceConfigFile "
			} ElseIf($LoadServiceConfig -eq 2) {
				$TempSrv = $Env:Temp + '\TempSrv.csv'
				$Script:csv | Export-Csv -LiteralPath $TempSrv -Force -Delimiter ','
				"-lcsc $TempSrv"
			}
		}
	} -join " "

	Clear-Host
	DisplayMisc -Line -Misc $True
	DisplayMisc -Misc $True
	DisplayOutLML (''.PadRight(18)+'Update Found!') -C 13 -L
	DisplayMisc -Misc $True
	DisplayOut '|',' Updating from version ',"$Script_Version".PadRight(30),'|' -C 14,15,11,14 -L
	DisplayMisc -Misc $True
	DisplayOut '|',' Downloading version ',"$FullVer".PadRight(31),'|' -C 14,15,11,14 -L
	DisplayOutLML 'Will run after download is complete.' -C 15 -L
	DisplayMisc -Misc $True
	DisplayMisc -Line -Misc $True

	DownloadFile $Script_Url $ScrpFilePath
	Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$ScrpFilePath`" $UpArg" -Verb RunAs
	CloseExit
}

##########
# Update Functions -End
##########
# Log/Backup Functions -Start
##########

Function ServiceBAfun([String]$ServiceBA) {
	If($LogBeforeAfter -eq 1) {
		$ServiceBAFile = "$FileBase$Env:computername-$ServiceBA.log"
		If($ServiceBA -eq 'Services-Before'){ $CurrServices | Out-File -LiteralPath $ServiceBAFile } Else{ Get-Service | Select-Object DisplayName, Name, StartType, Status | Out-File -LiteralPath $ServiceBAFile }
	} ElseIf($LogBeforeAfter -eq 2) {
		$TMPServices = If($ServiceBA -eq 'Services-Before'){ $CurrServices } Else{ Get-Service | Select-Object DisplayName, Name, StartType, Status }
		Write-Output "`n$ServiceBA -Start" | Out-File -LiteralPath $LogFile -Encoding Unicode -Append
		Write-Output ''.PadRight(37,'-') | Out-File -LiteralPath $LogFile -Encoding Unicode -Append
		Write-Output $TMPServices | Out-File -LiteralPath $LogFile -Encoding Unicode -Append
		Write-Output ''.PadRight(37,'-') | Out-File -LiteralPath $LogFile -Encoding Unicode -Append
		Write-Output "$ServiceBA -End`n" | Out-File -LiteralPath $LogFile -Encoding Unicode -Append
	}
}

Function Save_Service([String]$SavePath) {
	If($SavePath) {
		$SaveService = $WPF_dataGrid.Items.ForEach{
			$STF = $ServicesTypeFull.IndexOf($_.FileType)
			If(!$_.CheckboxChecked){ $STF *= -1 }
			$ServiceName = $_.ServiceName
			If($ServiceName -Like "*$ServiceEnd"){ $ServiceName = $ServiceName -Replace '_.+','_?????' }
			[PSCustomObject] @{ ServiceName = $ServiceName ;StartType = $STF ;Status = $_.SrvState }
		}
	} Else {
		$SavePathFolder = $FileBase + 'Backup\'
		If(!(Test-Path -LiteralPath $SavePathFolder)){ New-Item -Path $SavePathFolder -ItemType Directory }
		$DateRun = Get-Date -Format "MM-dd-yyyy HH;mm"
		$SavePath = $SavePathFolder + $Env:computername + "-Service-Backup ($DateRun).csv"
		$SaveService = $AllService.ForEach{
			$ServiceName = $_.ServiceName
			[Int]$StartType = $ServicesTypeFull.IndexOf($_.StartType)
			If($StartType -eq 3 -and $_.AutoDelay -ge 1){ [Int]$StartType = 4 }
			If($ServiceName -Like "*$ServiceEnd"){ $ServiceName = $ServiceName -Replace '_.+','_?????' }
			[PSCustomObject] @{ ServiceName = $ServiceName ;StartType = $StartType ;Status = $_.Status }
		}
	}
	$SaveService | Export-Csv -LiteralPath $SavePath -Encoding Unicode -Force -Delimiter ','
	If($SavePath){ [Windows.Forms.Messagebox]::Show("File saved as '$SavePath'",'File Saved', 'OK') | Out-Null }
}

Function DevLogSet {
	$Script:ScriptLog = 1
	$Script:LogName = 'Dev-Log.log'
	$Script:Diagnostic = 1
	$Script:Automated = 0
	$Script:LogBeforeAfter = 2
	$Script:DryRun = 1
	$Script:AcceptToS = 'Accepted'
	$Script:ShowNonInstalled = 1
	$Script:ShowSkipped = 1
	$Script:ShowAlreadySet = 1
}

Function CreateLog {
	If($DevLog -eq 1){ DevLogSet }
	If($ScriptLog -ne 0) {
		$Script:LogFile = $FileBase + $LogName
		$Time = Get-Date -Format 'MM/dd/yyyy hh:mm:ss tt'
		If($ScriptLog -eq 2) {
			Write-Output '$(GetTime): Updated Script File running' | Out-File -LiteralPath $LogFile -Encoding Unicode -NoNewline -Append
			Write-Output "`n--Start of Log ($Time)--" | Out-File -LiteralPath $LogFile -Encoding Unicode -NoNewline -Append
			$ScriptLog = 1
		} Else {
			Write-Output "--Start of Log ($Time)--" | Out-File -LiteralPath $LogFile -Encoding Unicode
		}
	}
	$Script:LogStarted = 1
}

Function DiagnosticCheck([Int]$Bypass) {
	If($Release_Type -ne 'Stable' -or 1 -In $Bypass,$Diagnostic) {
		DisplayOut ' ********START********' -C 11 -L
		DisplayOut ' Diagnostic Output, Some items may be blank' -C 14 -L
		DisplayOut "`n --------Script Info--------" -C 2 -L
		DisplayOut ' Script Version: ',$Script_Version -C 14,15 -L
		DisplayOut ' Release Type: ',$Release_Type -Color 14,15 -L
		DisplayOut "`n --------System Info--------" -C 2 -L
		DisplayOut ' Window: ',$FullWinEdition -C 14,15 -L
		DisplayOut ' Bit: ',$CimOS.OSArchitecture -C 14,15 -L
		DisplayOut ' Edition SKU#: ',$CimOS.OperatingSystemSKU -C 14,15 -L
		DisplayOut ' PC Type: ',$PCType -C 14,15 -L
		DisplayOut ' Desktop/Laptop: ',$IsLaptop -C 14,15 -L
		DisplayOut "`n --------Misc Info--------" -C 2 -L
		DisplayOut ' Args: ',$PassedArg -C 14,15 -L
		DisplayOut ' Error: ',$ErrorDi -C 13,15 -L
		DisplayOut "`n --------Settings--------" -C 2 -L
		DisplayOut ' Selected Option: ',$Service_Select -C 14,15 -L
		DisplayOut ' ToS: ',$AcceptToS -C 14,15 -L
		DisplayOut ' Automated: ',$Automated -C 14,15 -L
		DisplayOut ' ScriptVerCheck: ',$ScriptVerCheck -C 14,15 -L
		DisplayOut ' InternetCheck: ',$InternetCheck -C 14,15 -L
		DisplayOut ' ShowAlreadySet: ',$ShowAlreadySet -C 14,15 -L
		DisplayOut ' ShowNonInstalled: ',$ShowNonInstalled -C 14,15 -L
		DisplayOut ' ShowSkipped: ',$ShowSkipped -C 14,15 -L
		DisplayOut ' XboxService: ',$XboxService -C 14,15 -L
		DisplayOut ' StopDisabled: ',$StopDisabled -C 14,15 -L
		DisplayOut ' ChangeState: ',$ChangeState -C 14,15 -L
		DisplayOut ' DryRun: ',$DryRun -C 14,15 -L
		DisplayOut ' ScriptLog: ',$ScriptLog -C 14,15 -L
		DisplayOut ' LogName: ',$LogName -C 14,15 -L
		DisplayOut ' LogBeforeAfter: ',$LogBeforeAfter -C 14,15 -L
		DisplayOut ' DevLog: ',$DevLog -C 14,15 -L
		DisplayOut ' BackupServiceConfig: ',$BackupServiceConfig -C 14,15 -L
		DisplayOut ' ShowConsole: ',$ShowConsole -C 14,15 -L
		DisplayOut "`n ********END********" -C 11 -L
	}
}

##########
# Log/Backup Functions -End
##########
# Service Change Functions -Start
##########

Function TBoxService {
	[Alias('T')] [String[]]$Text,
	[Alias('C')] [Int[]]$Color,
	$WPF_ServiceListing.Dispatcher.Invoke(
		[action]{
			For($i = 0 ;$i -lt $Text.Length ;$i++) {
				$Run = New-Object System.Windows.Documents.Run
				$Run.Foreground = $colorsGUI[($Color[$i])]
				$Run.Text = $Text[$i]
				$WPF_ServiceListing.Inlines.Add($Run)
			}
			$WPF_ServiceListing.Inlines.Add((New-Object System.Windows.Documents.LineBreak))
		},'Normal'
	)
}

Function Service_Select_Set {
	PreScriptCheck
	If($LogBeforeAfter -eq 2){ DiagnosticCheck 1 }
	ServiceBAfun 'Services-Before'
	ServiceSet $ServiceSetOpt
}

Function ServiceSet{
	$StopWatch = New-Object System.Diagnostics.Stopwatch
	If($GuiSwitch){ $WPF_ServiceListing.text = '' }
	$SRVChanged = 0
	$SRVAlready = 0
	$SRVSkipped = 0
	$SRVStopped = 0
	$SRVRunning = 0
	$SRVError = 0
	$SRVNotInstalled = 0
	$Txtd = If($DryRun -ne 1){ "`n Changing Service Please wait...`n" ;$StopWatch.Start() } Else{ "`n List of Service that would be changed on Non-Dry Run/Dev Log...`n" }
	DisplayOut $Txtd -C 14 -L -G:$GuiSwitch
	DisplayOut ' Service_Name - Current -> Change_To' -C 14 -L -G:$GuiSwitch
	DisplayOut ''.PadRight(40,'-') -C 14 -L -G:$GuiSwitch
	$csv.ForEach{
		$DispSrv = $True
		$DispTempT = ''
		$DispTempC = ''
		$DispTempS = ''
		$DispTempSC = ''
		[Int] $ServiceTypeNum = $_.StartType
		$ServiceType = $ServicesTypeList[$ServiceTypeNum]
		$ServiceName = QMarkServices $_.ServiceName
		$ServiceCommName = SearchSrv $ServiceName 'DisplayName'
		$ServiceCurrType = ServiceCheck $ServiceName $ServiceType
		$State = $_.Status
		If($Null -In $ServiceName,$ServiceCurrType) {
			If($ShowNonInstalled -eq 1){ $DispTempT = " No service with name $($_.ServiceName)" ;$DispTempC = 13 }
			$SRVNotInstalled++
			$ServiceTypeNum = 9
		} ElseIf($ServiceTypeNum -In -4..0) {
			If($ShowSkipped -eq 1) {
				$DispTempT = If($Null -ne $ServiceCommName){ " Skipping $ServiceCommName ($ServiceName)" } Else{ " Skipping $($_.ServiceName)" }
				$DispTempC = 14
			}
			$ServiceTypeNum = 9
			$SRVSkipped++
		} ElseIf($ServiceTypeNum -In 1..4) {
			If($ServicesTypeList -Contains $ServiceCurrType) {
				Try {
					If($DryRun -ne 1) {
						Set-Service $ServiceName -StartupType $ServiceType -ErrorAction Stop
						If($ServiceTypeNum -eq 4){ AutoDelaySet $ServiceName 1 }
					}
					$DispTempT = If($ServiceTypeNum -eq 4){
						" $ServiceCommName ($ServiceName) - $ServiceCurrType -> $ServiceType (Delayed)"
					} Else {
						" $ServiceCommName ($ServiceName) - $ServiceCurrType -> $ServiceType"
					}
					$DispTempC = 11
					$SRVChanged++
				} Catch {
					$DispTempT = "Unable to Change $ServiceCommName ($ServiceName)"
					$DispTempC = 12
					$SRVError++
				}
			} ElseIf($ServiceCurrType -eq 'Already') {
				$ADT = $_.AutoDelay
				If($ADT -eq 1 -and $ServiceTypeNum -eq 3) {
					If($DryRun -ne 1){ AutoDelaySet $ServiceName 0 }
					$DispTempT = " $ServiceCommName ($ServiceName) - $ServiceType (Delayed) -> $ServiceType"
					$DispTempC = 11
					$SRVChanged++
				} ElseIf($ADT -eq 0 -and $ServiceTypeNum -eq 4) {
					If($DryRun -ne 1){ AutoDelaySet $ServiceName 1 }
					$DispTempT = " $ServiceCommName ($ServiceName) - $ServiceType -> $ServiceType (Delayed)"
					$DispTempC = 11
					$SRVChanged++
				} Else {
					If($ShowAlreadySet -eq 1){
						$DispTempT = If($ServiceTypeNum -eq 4){
							" $ServiceCommName ($ServiceName) is already $ServiceType (Delayed)"
						} Else {
							" $ServiceCommName ($ServiceName) is already $ServiceType"
						}
					} Else {
						$DispSrv = $False
					}
					$DispTempC = 15
					$SRVAlready++
				}
			} ElseIf($ServiceCurrType -eq 'Xbox') {
				$DispTempT = " $ServiceCommName ($ServiceName) is an Xbox Service and will be skipped"
				$DispTempC = 2
				$ServiceTypeNum = 9
				$SRVSkipped++
			} ElseIf($ServiceCurrType -eq 'Denied') {
				$DispTempT = " $ServiceCommName ($ServiceName) can't be changed."
				$DispTempC = 14
				$ServiceTypeNum = 9
				$SRVError++
			} Else{
				$DispTempT = "$ServiceCurrType -Unkown"
				$DispTempC = 2
				$ServiceTypeNum = 9
			}
			If($DryRun -ne 1 -And $Null -ne $ServiceName -And ($ChangeState -eq 1 -or ($StopDisabled -eq 1 -And $ServiceTypeNum -eq 1))) {
				$CurState = SearchSrv $ServiceName 'Status'
				If($State -eq 'Stopped') {
					If($CurState -eq 'Running') {
						Try {
							Stop-Service $ServiceName -ErrorAction Stop
							$DispTempS = ' -Stopping Service'
							$DispTempSC = 13
							$SRVStopped++
						} Catch {
							$DispTempS = ' -Unable to Stop Service'
							$DispTempSC = 12
							$SRVError++
						}
						$DispSrv = $True
					} Else {
						$DispTempS = ' -Already Stopped'
						$DispTempSC = 11
					}
				} ElseIf($State -eq 'Running' -And $ChangeState -eq 1) {
					If($CurState -eq 'Stopped') {
						Try {
							Start-Service $ServiceName -ErrorAction Stop
							$DispTempS = ' -Starting Service'
							$DispTempSC = 11
							$SRVRunning++
						} Catch {
							$DispTempS = ' -Unable to Start Service'
							$DispTempSC = 12
							$SRVError++
						}
						$DispSrv = $True
					} Else {
						$DispTempS = ' -Already Started'
						$DispTempSC = 15
					}
				}
			}
		} Else {
			DisplayOut " Error: $($_.ServiceName) does not have a valid Setting." -C 13 -L -G:$GuiSwitch
			$SRVError++
		}
		If($DispTempT -ne '' -and $DispSrv){ DisplayOut @($DispTempT,$DispTempS) -C @($DispTempC,$DispTempSC) -L -G:$GuiSwitch }
	}
	DisplayOut ''.PadRight(40,'-') -C 14 -L -G:$GuiSwitch

	If($DryRun -ne 1) {
		$StopWatch.Stop()
		$StopWatchTime = $StopWatch.Elapsed
		$StopWatch.Reset()
		DisplayOut ' Service Changed...' -C 14 -L -G:$GuiSwitch
		DisplayOut ' Elapsed Time: ',$StopWatchTime -C 14,15 -L -G:$GuiSwitch
		If(1 -In $StopDisabled,$ChangeState){ DisplayOut ' Stopped: ',$SRVStopped -C 14,15 -L -G:$GuiSwitch }
		If($ChangeState -eq 1){ DisplayOut ' Running: ',$SRVRunning -C 14,15 -L -G:$GuiSwitch }
	} Else {
		DisplayOut ' List of Service Done...' -C 14 -L -G:$GuiSwitch
		DisplayOut "`n If not Non-Dry Run/Dev Log " -C 14 -L -G:$GuiSwitch
	}
	DisplayOut ' Changed: ',$SRVChanged -C 14,15 -L -G:$GuiSwitch
	DisplayOut ' Already: ',$SRVAlready -C 14,15 -L -G:$GuiSwitch
	DisplayOut ' Skipped: ',$SRVSkipped -C 14,15 -L -G:$GuiSwitch
	If($ShowNonInstalled -eq 1){ DisplayOut ' Not Installed: ',$SRVNotInstalled -C 14,15 -L -G:$GuiSwitch }
	If($SRVError -ge 1){ DisplayOut '  Errors: ',$SRVError -C 14,15 -L -G:$GuiSwitch }
	If($BackupServiceConfig -eq 1){ DisplayOut ' Backup of Services Saved as CSV file in script directory.' -C 14 -L -G:$GuiSwitch }
	If($DryRun -ne 1) {
		DisplayOut "`nThanks for using my script." -C 11
		DisplayOut 'If you like this script please consider giving me a donation,' -C 11
		DisplayOut 'Min of $1 from the adjustable Amazon Gift Card.' -C 11
		DisplayOut "`nLink to donation:" -C 15
		DisplayOut $Donate_Url -C 2
		If($ConsideredDonation -ne 'Yes' -and $GuiSwitch) {
			$Choice = [Windows.Forms.Messagebox]::Show("Thanks for using my script.`nIf you like this script please consider giving me a donation, Min of `$1 from the adjustable Amazon Gift Card.`n`nWould you Consider giving a Donation?",'Thanks Please Donate', 4)
			If($Choice -eq 'Yes'){ ClickedDonate }
		}
	}
	ServiceBAfun 'Services-After'
	If($DevLog -eq 1 -and $Error.Count -gt $ErrCount){ Write-Output $Error | Out-File -LiteralPath $LogFile -Encoding Unicode -Append ;$ErrCount = $Error.Count }
	If($GuiSwitch) {
		GetCurrServices ;RunDisableCheck
		DisplayOut "`n To exit you can close the GUI or PowerShell Window." 14 -G:$GuiSwitch
	} Else {
		AutomatedExitCheck 1
	}
}

Function ServiceCheck([String]$S_Name,[String]$S_Type) {
	If($CurrServices.ServiceName -Contains $S_Name) {
		If($Skip_Services -Contains $S_Name){ Return 'Denied' }
		If($XboxService -eq 1 -and $XboxServiceArr -Contains $S_Name){ Return 'Xbox' }
		$C_Type = SearchSrv $S_Name 'StartType'
		If($S_Type -ne $C_Type) {
			If($S_Name -eq 'lfsvc' -And $C_Type -eq 'disabled' -And (Test-Path 'HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\TriggerInfo\3')) {
				Remove-Item -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\TriggerInfo\3' -Recurse -Force
			} ElseIf($S_Name -eq 'NetTcpPortSharing' -And $NetTCP -Contains $CurrServices.ServiceName) {
				Return 'Manual'
			}
			Return $C_Type
		}
		Return 'Already'
	}
	Return $Null
}

##########
# Service Change Functions -End
##########
# Misc Functions -Start
##########

Function PreScriptCheck {
	If($RunScript -eq 0){ CloseExit }
	If($LogStarted -eq 0){ CreateLog }
	$Script:ErrorDi = ''

	If($BackupServiceConfig -eq 1){ Save_Service }
	If($LoadServiceConfig -eq 1) {
		[System.Collections.ArrayList]$Script:csv = Import-Csv -LiteralPath $ServiceConfigFile
	} ElseIf($LoadServiceConfig -ne 2) {
		[System.Collections.ArrayList]$Script:csv = Import-Csv -LiteralPath $ServiceFilePath
	}
	If(1 -In $ScriptVerCheck){ UpdateCheckAuto }
}

Function GetArgs {
	If($PassedArg -In '-help','-h'){ ShowHelp }
	If($PassedArg -Contains '-copy'){ ShowCopyright ;Exit }
	If($PassedArg -Contains '-lcsc') {
		$tmp = $PassedArg[$PassedArg.IndexOf('-lcsc')+1]
		$Script:LoadServiceConfig = 1
		If($Null -ne $tmp -and !$tmp.StartsWith('-')) {
			Set-Location $FileBase
			If(!(Test-Path -LiteralPath $tmp -PathType Leaf)) {
				$Script:ErrorDi = "Missing File $tmp"
				Error_Top
				$SrvConFileLen = $tmp.length
				If($SrvConFileLen -gt 42){ $SrvConFileLen = 42 }
				DisplayOut '|',' The File ',$tmp,' is missing.'.PadRight(42-$SrvConFileLen),'|' -C 14,2,15,2,14 -L
				Error_Bottom
			} Else {
				[System.Collections.ArrayList]$Tempcheck = Import-Csv -LiteralPath $tmp
				If($Null -In $Tempcheck[0].StartType,$Tempcheck[0].ServiceName) {
					Error_Top
					DisplayOut '|',' The File ',"$tmp".PadRight(41),' |' -C 14,2,15,14 -L
					DisplayOutLML 'is Invalid or Corrupt.' 2 -L
					$Script:ErrorDi = 'Invalid CSV File'
					Error_Bottom
				}
				$Script:ServiceConfigFile = $tmp
				$Script:ServiceFilePath = $tmp
			}
		} Else {
			$Script:ErrorDi = "No File Specified."
			Error_Top
			DisplayOut '|'," No File Specified with",' -lcsc ','switch.              ',' |' -C 14,2,15,2,14 -L
			Error_Bottom
		}
	}
	$ArgList.ForEach{
		If($_.Arg -In $PassedArg) {
			$tmp = $_.Var.Split('=')
			$tc = $tmp.count
			For($i = 0 ;$i -lt $tc ;$i += 2) {
				$t1 = $tmp[$i+1] ;$t = $tmp[$i]
				If($t1 -eq '-') {
					$tmpV = $PassedArg[$PassedArg.IndexOf($_.Arg)+1]
					If(!$tmpV.StartsWith('-')){ $t1 = $tmpV } Else{ $t = $False }
				}
				If($t){ Set-Variable $t $t1 -Scope Script }
			}
		}
	}
	If($PassedArg -Contains '-diagf'){ $Script:Diagnostic = 2 ;$Script:Automated = 0 ;$Script:ErrorDi = 'Forced Diag Output' }
}

Function ShowHelp {
	Clear-Host
	DisplayOut '             List of Switches' -C 13
	DisplayOut ''.PadRight(53,'-') -C 14
	DisplayOut ' Switch ',"Description of Switch`n".PadLeft(31) -C 14,15
	DisplayOut '-- Basic Switches --' -C 2
	DisplayOut '  -atos    ','        Accepts ToS' -C 14,15
	DisplayOut '  -auto    ','        Implies ','-atos','...Runs the script to be Automated.. Closes on - User Input, Errors, or End of Script' -C 14,15,14,15
	DisplayOut "`n--Service Configuration Switches--" -C 2
	DisplayOut '  -lcsc ','File.csv ','  Loads Custom Service Configuration, ','File.csv',' = Name of your backup/custom file' -C 14,11,15,11,15
	DisplayOut "`n--Service Choice Switches--" -C 2
	DisplayOut '  -sxb     ','        Skips changes to all XBox Services' -C 14,15
	DisplayOut '  -css     ','        Change State of Service' -C 14,15
	DisplayOut '  -sds     ','        Stop Disabled Service' -C 14,15
	DisplayOut "`n--Update Switches--" -C 2
	DisplayOut '  -usc     ','        Checks for Update to Script file before running' -C 14,15
	DisplayOut '  -sic     ',"        Skips Internet Check, if you can't ping GitHub.com for some reason" -C 14,15
	DisplayOut "`n--Backup/Log Switches--" -C 2
	DisplayOut '  -bsc    ','         Backup Current Service Configuration as Csv File' -C 14,15
	DisplayOut '  -log     ','        Makes a log file named using default name ','Script.log' -C 14,15,11
	DisplayOut '  -log ','File.log ',' Makes a log file named ','File.log' -C 14,11,15,11
	DisplayOut '  -baf     ','        Log File of Services Configuration Before and After the script' -C 14,15
	DisplayOut "`n--Display Switches--" -C 2
	DisplayOut '  -sas     ','        Show Already Set Services' -C 14,15
	DisplayOut '  -snis    ','        Show Not Installed Services' -C 14,15
	DisplayOut '  -sss     ','        Show Skipped Services' -C 14,15
	DisplayOut "`n--Misc Switches--" -C 2
	DisplayOut '  -dry     ','        Runs the Script and Shows what services will be changed' -C 14,15
	DisplayOut "`n--Dev Switches--" -C 2
	DisplayOut '  -devl    ','        Makes a log file with various Diagnostic information, Nothing is Changed ' -C 14,15
	DisplayOut '  -diag    ','        Shows diagnostic information, Stops ','-auto' -C 14,15,14
	DisplayOut '  -diagf   ','        Forced diagnostic information, Script does nothing else' -C 14,15
	DisplayOut "`n--Help--" -C 2
	DisplayOut '  -help    ','        Shows list of switches, then exits script.. alt ','-h' -C 14,15,14
	DisplayOut '  -copy    ','        Shows Copyright/License Information, then exits script' -C 14,15
	AutomatedExitCheck 1
	Exit
}

Function StartScript {
	If(Test-Path -LiteralPath $SettingPath -PathType Leaf) {
		$Tmp = (Import-Clixml -LiteralPath $SettingPath | ConvertTo-Xml).Objects.Object.Property."#text"
		While($Tmp){ $Key,$Val,$Tmp = $Tmp ;Set-Variable $Key $Val -Scope Script }
	}

	$Script:IsLaptop = If($PCType -eq 1){ 'Desktop' } Else{ 'Laptop' }

	If($PassedArg.Length -gt 0){ GetArgs }
	[System.Collections.ArrayList]$Skip_Services = @(
	"BcastDVRUserService$ServiceEnd",
	"DevicePickerUserSvc$ServiceEnd",
	"DevicesFlowUserSvc$ServiceEnd",
	"PimIndexMaintenanceSvc$ServiceEnd",
	"PrintWorkflowUserSvc$ServiceEnd",
	"UnistoreSvc$ServiceEnd",
	"UserDataSvc$ServiceEnd",
	"WpnUserService$ServiceEnd",
	'AppXSVC',
	'BrokerInfrastructure',
	'ClipSVC',
	'CoreMessagingRegistrar',
	'DcomLaunch',
	'EntAppSvc',
	'gpsvc',
	'GamingServicesNet',
	'GamingServices',
	'LSM',
	'MpsSvc',
	'msiserver',
	'NgcCtnrSvc',
	'NgcSvc',
	'RpcEptMapper',
	'RpcSs',
	'Schedule',
	'SecurityHealthService',
	'sppsvc',
	'StateRepository',
	'SystemEventsBroker',
	'tiledatamodelsvc',
	'UsoSvc'
	'WdNisSvc',
	'WinDefend',
	'xbgm',
	'uhssvc')

	GetCurrServices
	$Script:AllService = $CurrServices | Select-Object ServiceName, StartType, Status

	If($Diagnostic -In 1,2){ $Script:Automated = 0 }
	If($Diagnostic -eq 2) {
		Clear-Host
		DiagnosticCheck 1
		Exit
	} ElseIf($LoadServiceConfig -eq 1) {
		$Script:RunScript = 1
		If($AcceptToS -ne 0) {
			Service_Select_Set
		} Else {
			TOS
		}
	} ElseIf($Automated -eq 1) {
		CreateLog
		$Script:ErrorDi = 'Automated Selected, No Service Selected'
		Error_Top
		DisplayOutLML 'Script is set to Automated and no Service' 2 -L
		DisplayOutLML 'Configuration option was selected.' 2 -L
		Error_Bottom
	} ElseIf($AcceptToS -ne 0) {
		$Script:RunScript = 1
		GuiStart
	} Else {
		TOS
	}
}

##########
# Misc Functions -End
##########
#--------------------------------------------------------------------------
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# !!                                         !!
# !!           SAFE TO EDIT VALUES           !!
# !!                                         !!
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

# Edit values (Option) to your Choice

# Function = Option
# List of Options

$AcceptToS = 0
# 0 = See ToS
# Anything Else = Accept ToS

$DryRun = 0
# 0 = Runs script normally
# 1 = Runs script but shows what will be changed

$ShowAlreadySet = 1
# 0 = Don't Show Already set Services
# 1 = Show Already set Services

$ShowNonInstalled = 0
# 0 = Don't Show Services not present
# 1 = Show Services not present

$ShowSkipped = 0
# 0 = Don't Show Skipped Services
# 1 = Show Skipped Services

$XboxService = 0
# 0 = Change Xbox Services
# 1 = Skip Change Xbox Services

$StopDisabled = 0
# 0 = Dont change running status
# 1 = Stop services that are disabled

$ChangeState = 0
# 0 = Dont Change State of service to specified/loaded
# 1 = Change State of service to specified/loaded

$ShowAllServices = 0
# 0 = Dont show services NOT in File
# 1 = Show all services

#----- Log/Backup Items -----
$ScriptLog = 0
# 0 = Don't make a log file
# 1 = Make a log file
# Will be script's directory named `Script.log` (default)
# Change name on next line

$LogName = "Script.log"
# Name of log file (if ScriptLog is set to 1)

$LogBeforeAfter = 0
# 0 = Don't make a file of all the services before and after the script
# 1 = Make a file of all the services before and after the script
# Will be in script's directory file named
#	'(ComputerName)-Services-Before.log'
#	'(ComputerName)-Services-After.log'

$BackupServiceConfig = 0
# 0 = Don't backup Your Current Service Configuration before services are changes
# 1 = Backup Your Current Service Configuration before services are changes

#--- Update Related Items ---
$ScriptVerCheck = 0
# 0 = Skip Check for update of Script File
# 1 = Check for update of Script File
# Note: If found will Auto download and run

$InternetCheck = 0
# 0 = Checks if you have Internet
# 1 = Bypass check if your pings are blocked
# Use if Pings are Blocked or can't ping GitHub.com

#---------- Dev Item --------
$Diagnostic = 0
# 0 = Doesn't show Shows diagnostic information
# 1 = Shows diagnostic information

$DevLog = 0
# 0 = Doesn't make a Dev Log
# 1 = Makes a log files
# Devlog Contains -> Service Change, Before & After for Services, and Diagnostic Info --Runs as Dryrun

$ShowConsole = 0
# 0 = Hides console window -Default in Stable release
# 1 = Shows console window -Forced in Testing release

#--------------------------------------------------------------------------
# Do not change
StartScript
