#NoTrayIcon
#include <GUIConstants.au3>
#include <WindowsConstants.au3>
#include <EditConstants.au3>
#include <GuiComboBox.au3>
#include <GuiListView.au3>
#include <File.au3>
#include <Math.au3>
#include <Constants.au3>

Opt("TrayOnEventMode",1)
Opt("TrayMenuMode",1)
Opt("GUICoordMode", 1)

TraySetOnEvent($TRAY_EVENT_PRIMARYUP,"SpecialEvent")
TraySetClick(16)


Global $DropFilesArr[1]
global $prvdragnum = -1
Global $dragnum = 0
Global $IsStopped = false
Global $IWantQuit = false
Global $IsUserStop = false

$BatchDPGVersion = "v1.61"

$preview = ""
;[Title]
$lTitle = StringReplace(IniRead(@ScriptDir & "\Settings\lang\" & @OSLANG & ".ini", "Title", "Title","BatchDPG %v Unofficial"),"%v",$BatchDPGVersion)
$lSettingsTitle = IniRead(@ScriptDir & "\Settings\lang\" & @OSLANG & ".ini", "Title", "Settings","Settings")
;[Buttons]
$lBrowse = IniRead(@ScriptDir & "\Settings\lang\" & @OSLANG & ".ini", "Buttons", "Browse","Browse...")
$lAdd = IniRead(@ScriptDir & "\Settings\lang\" & @OSLANG & ".ini", "Buttons", "Add","Add")
$lDelete = IniRead(@ScriptDir & "\Settings\lang\" & @OSLANG & ".ini", "Buttons", "Delete","Delete")
$lClear = IniRead(@ScriptDir & "\Settings\lang\" & @OSLANG & ".ini", "Buttons", "Clear","Clear")
$lRun = IniRead(@ScriptDir & "\Settings\lang\" & @OSLANG & ".ini", "Buttons", "Run","Run")
$lStop = IniRead(@ScriptDir & "\Settings\lang\" & @OSLANG & ".ini", "Buttons", "Stop","Stop")
$lPreview = IniRead(@ScriptDir & "\Settings\lang\" & @OSLANG & ".ini", "Buttons", "Preview","Preview")
$lSettings = IniRead(@ScriptDir & "\Settings\lang\" & @OSLANG & ".ini", "Buttons", "Settings","Settings")
$lAbout = IniRead(@ScriptDir & "\Settings\lang\" & @OSLANG & ".ini", "Buttons", "About","About")
;[Menus]
$lListView_UpToTop = IniRead(@ScriptDir & "\Settings\lang\" & @OSLANG & ".ini", "Menus", "ListView_UpToTop","Up to Top")
$lListView_Up = IniRead(@ScriptDir & "\Settings\lang\" & @OSLANG & ".ini", "Menus", "ListView_Up","Up")
$lListView_Down = IniRead(@ScriptDir & "\Settings\lang\" & @OSLANG & ".ini", "Menus", "ListView_Down","Down")
$lListView_DownToBottom = IniRead(@ScriptDir & "\Settings\lang\" & @OSLANG & ".ini", "Menus", "ListView_DownToBottom","Down to Bottom")

;[Input]
$lInput = IniRead(@ScriptDir & "\Settings\lang\" & @OSLANG & ".ini", "Input", "Input","Input")
$lVideo = IniRead(@ScriptDir & "\Settings\lang\" & @OSLANG & ".ini", "Input", "Video","Video:")
$lAudio = IniRead(@ScriptDir & "\Settings\lang\" & @OSLANG & ".ini", "Input", "Audio","Audio:")
$lSubtitle = IniRead(@ScriptDir & "\Settings\lang\" & @OSLANG & ".ini", "Input", "Subtitle","Subtitle")
;[Output]
$lOutput = IniRead(@ScriptDir & "\Settings\lang\" & @OSLANG & ".ini", "Output", "Output","Output")
$lTempDir = IniRead(@ScriptDir & "\Settings\lang\" & @OSLANG & ".ini", "Output", "TempDir","Temp dir:")
$lOutputDir = IniRead(@ScriptDir & "\Settings\lang\" & @OSLANG & ".ini", "Output", "OutputDir","Output dir:")
;[Video]
$lVideo_g = IniRead(@ScriptDir & "\Settings\lang\" & @OSLANG & ".ini", "Video", "Video","Video")
$lFramerate = IniRead(@ScriptDir & "\Settings\lang\" & @OSLANG & ".ini", "Video", "Framerate","Framerate:")
$lWidth = IniRead(@ScriptDir & "\Settings\lang\" & @OSLANG & ".ini", "Video", "Width","Width:")
$lBitrate = IniRead(@ScriptDir & "\Settings\lang\" & @OSLANG & ".ini", "Video", "Bitrate","Bitrate:")
$lPasses = IniRead(@ScriptDir & "\Settings\lang\" & @OSLANG & ".ini", "Video", "Passes","Passes:")
$lProfile = IniRead(@ScriptDir & "\Settings\lang\" & @OSLANG & ".ini", "Video", "Profile","Profile:")
$lProfile_Combo = IniRead(@ScriptDir & "\Settings\lang\" & @OSLANG & ".ini", "Video", "Profile_Combo","Ultra|High|Med|Low")
$lHeight = IniRead(@ScriptDir & "\Settings\lang\" & @OSLANG & ".ini", "Video", "Height","Height:")
$lMaxBitrate = IniRead(@ScriptDir & "\Settings\lang\" & @OSLANG & ".ini", "Video", "MaxBitrate","Max bitrate:")
$lResizer = IniRead(@ScriptDir & "\Settings\lang\" & @OSLANG & ".ini", "Video", "Resizer","Resizer:")
;[Audio]
$lAudio_g = IniRead(@ScriptDir & "\Settings\lang\" & @OSLANG & ".ini", "Audio", "Audio","Audio")
$lAudio_Bitrate = IniRead(@ScriptDir & "\Settings\lang\" & @OSLANG & ".ini", "Audio", "Bitrate","Bitrate:")
$lSamplerate = IniRead(@ScriptDir & "\Settings\lang\" & @OSLANG & ".ini", "Audio", "Samplerate","Samplerate:")
$lMode = IniRead(@ScriptDir & "\Settings\lang\" & @OSLANG & ".ini", "Audio", "Mode","Mode:")
$lMode_Combo = IniRead(@ScriptDir & "\Settings\lang\" & @OSLANG & ".ini", "Audio", "Mode_Combo","Joint stereo|Mono")
$lNormalize = IniRead(@ScriptDir & "\Settings\lang\" & @OSLANG & ".ini", "Audio", "Normalize","Normalize")
;[Other]
$lOther = IniRead(@ScriptDir & "\Settings\lang\" & @OSLANG & ".ini", "Other", "Other","Other")
$lAfterEncoding = IniRead(@ScriptDir & "\Settings\lang\" & @OSLANG & ".ini", "Other", "AfterEncoding","After encoding:")
$lAfterEncoding_Combo = IniRead(@ScriptDir & "\Settings\lang\" & @OSLANG & ".ini", "Other", "AfterEncoding_Combo","Do nothing|Exit BatchDPG|Shutdown PC")
$lPriority = IniRead(@ScriptDir & "\Settings\lang\" & @OSLANG & ".ini", "Other", "Priority","Priority:")
$lPriority_Combo = IniRead(@ScriptDir & "\Settings\lang\" & @OSLANG & ".ini", "Other", "Priority_Combo","5 - Realtime|4 - High|3 - Above Normal|2 - Normal|1 - Below Normal|0 - Idle/Low")
;[OtherOption]
$lOtherOption = IniRead(@ScriptDir & "\Settings\lang\" & @OSLANG & ".ini", "OtherOption", "OtherOption","Other Options")
$lKeepAspectRatio = IniRead(@ScriptDir & "\Settings\lang\" & @OSLANG & ".ini", "OtherOption", "KeepAspectRatio","Keep Aspect Ratio")
;[Subtitle]
$lSubtitle_Title = IniRead(@ScriptDir & "\Settings\lang\" & @OSLANG & ".ini", "Subtitle", "Subtitle","Subtitle")
$lFont = IniRead(@ScriptDir & "\Settings\lang\" & @OSLANG & ".ini", "Subtitle", "Font","Font:")
$lSize = IniRead(@ScriptDir & "\Settings\lang\" & @OSLANG & ".ini", "Subtitle", "Size","Size:")
$lShadow = IniRead(@ScriptDir & "\Settings\lang\" & @OSLANG & ".ini", "Subtitle", "Shadow","Shadow:")
$lPos = IniRead(@ScriptDir & "\Settings\lang\" & @OSLANG & ".ini", "Subtitle", "Pos","Pos:")
;[AddParam]
$lAddParam = IniRead(@ScriptDir & "\Settings\lang\" & @OSLANG & ".ini", "AddParam", "AddParam","Additional MEncoder Parameter")
;[ETC]
$lLangFile = IniRead(@ScriptDir & "\Settings\lang\" & @OSLANG & ".ini", "ETC", "LangFile","Language File:")
$lMediaFiles = IniRead(@ScriptDir & "\Settings\lang\" & @OSLANG & ".ini", "ETC", "MediaFiles","Media Files")
$lAudioFiles = IniRead(@ScriptDir & "\Settings\lang\" & @OSLANG & ".ini", "ETC", "AudioFiles","Audio Files")
$lSubFiles = IniRead(@ScriptDir & "\Settings\lang\" & @OSLANG & ".ini", "ETC", "SubFiles","Subtitle Files")
;[EncoderSettings]
$lEncoderSettings = IniRead(@ScriptDir & "\Settings\lang\" & @OSLANG & ".ini", "EncoderSettings", "EncoderSettings","Encoder Settings")
$lEncodingMethod = IniRead(@ScriptDir & "\Settings\lang\" & @OSLANG & ".ini", "EncoderSettings", "EncodingMethod","Encoding Method:")
$lEncodingMethod_Combo = IniRead(@ScriptDir & "\Settings\lang\" & @OSLANG & ".ini", "EncoderSettings", "EncodingMethod_Combo","Normal(Recommended)|Fast(Buggy, Not Recommended)")

;[Messages]
$lStartPreview = IniRead(@ScriptDir & "\Settings\lang\" & @OSLANG & ".ini", "Messages", "StartPreview","Starting Preview...")
$lAudioEnc = IniRead(@ScriptDir & "\Settings\lang\" & @OSLANG & ".ini", "Messages", "AudioEnc","Transcoding audio")
$lVideoEnc = IniRead(@ScriptDir & "\Settings\lang\" & @OSLANG & ".ini", "Messages", "VideoEnc","Transcoding video")
$lMultiplexing = IniRead(@ScriptDir & "\Settings\lang\" & @OSLANG & ".ini", "Messages", "Multiplexing","Multiplexing...")
$lMultiplexFail = IniRead(@ScriptDir & "\Settings\lang\" & @OSLANG & ".ini", "Messages", "Multiplexfail","Multiplexing failed. Make sure the output directory has write access.")
$lAudioFail = IniRead(@ScriptDir & "\Settings\lang\" & @OSLANG & ".ini", "Messages", "AudioFail","Audio conversion failed. Make sure you've got the required audio codecs installed.")
$lVideoFail = IniRead(@ScriptDir & "\Settings\lang\" & @OSLANG & ".ini", "Messages", "VideoFail","Video conversion failed. Make sure you've got the required video codecs installed.")
$lConvFail = IniRead(@ScriptDir & "\Settings\lang\" & @OSLANG & ".ini", "Messages", "ConvFail","Conversion failed. Open ""%f"".avs' in a media player and take note of the error message.")
$lErrorTimeOut = IniRead(@ScriptDir & "\Settings\lang\" & @OSLANG & ".ini", "Messages", "ErrorTimeOut","This box will time out in %s seconds.")
$lNoAviSynth = IniRead(@ScriptDir & "\Settings\lang\" & @OSLANG & ".ini", "Messages", "NoAviSynth","AviSynth installation not detected. BatchDPG will not function correctly without AviSynth.")
$lEncodingStop = IniRead(@ScriptDir & "\Settings\lang\" & @OSLANG & ".ini", "Messages", "EncodingStop","Encoding Stopped.")
$lQuit = IniRead(@ScriptDir & "\Settings\lang\" & @OSLANG & ".ini", "Messages", "Quit","Stop Encoding and Quit?")
$lShutdownMessage = IniRead(@ScriptDir & "\Settings\lang\" & @OSLANG & ".ini", "Messages", "Shutdown","BatchDPG will shutdown your computer after 30 seconds.%CRLF%Press OK to Cancel")
;[DefaultValues]
$lDefProfile = IniRead(@ScriptDir & "\Settings\lang\" & @OSLANG & ".ini", "DefaultValues", "Profile","Med")
$lDefAudioMode = IniRead(@ScriptDir & "\Settings\lang\" & @OSLANG & ".ini", "DefaultValues", "AudioMode","Joint Stereo")
$lDefAfterEncoding = IniRead(@ScriptDir & "\Settings\lang\" & @OSLANG & ".ini", "DefaultValues", "AfterEncoding","Do Nothing")
$lDefPriority = IniRead(@ScriptDir & "\Settings\lang\" & @OSLANG & ".ini", "DefaultValues", "Priority","2 - Normal")
$lDefEncodingMethod = IniRead(@ScriptDir & "\Settings\lang\" & @OSLANG & ".ini", "DefaultValues", "EncodingMethod","Normal(Recommended)")

If Not RegRead("HKCR\CLSID\{E6D6B700-124D-11D4-86F3-DB80AFD98778}", "") Then MsgBox(0, "BatchDPG", $lNoAviSynth)

$sMedia = IniRead(@ScriptDir & "\Settings\BatchDPG.ini", "Input", "Media", "")
$sAudio = IniRead(@ScriptDir & "\Settings\BatchDPG.ini", "Input", "Audio", "")
$sSub = IniRead(@ScriptDir & "\Settings\BatchDPG.ini", "Input", "Sub", "")
$sTemp = IniRead(@ScriptDir & "\Settings\BatchDPG.ini", "Output", "Temp", "")
$sOutput = IniRead(@ScriptDir & "\Settings\BatchDPG.ini", "Output", "Output", "")
$sFramerate = IniRead(@ScriptDir & "\Settings\BatchDPG.ini", "Video", "Framerate", "auto")
$sProfile = IniRead(@ScriptDir & "\Settings\BatchDPG.ini", "Video", "Profile", $lDefProfile)
$sWidth = IniRead(@ScriptDir & "\Settings\BatchDPG.ini", "Video", "Width", "256")
$sHeight = IniRead(@ScriptDir & "\Settings\BatchDPG.ini", "Video", "Height", "192")
$sVideoBitrate = IniRead(@ScriptDir & "\Settings\BatchDPG.ini", "Video", "VideoBitrate", "256")
$sVideoBitrateMax = IniRead(@ScriptDir & "\Settings\BatchDPG.ini", "Video", "VideoBitrateMax", "384")
$sPasses = IniRead(@ScriptDir & "\Settings\BatchDPG.ini", "Video", "Passes", "1")
$sResizer = IniRead(@ScriptDir & "\Settings\BatchDPG.ini", "Video", "Resizer", "Bicubic")
$sAudioBitrate = IniRead(@ScriptDir & "\Settings\BatchDPG.ini", "Audio", "AudioBitrate", "128")
$sSamplerate = IniRead(@ScriptDir & "\Settings\BatchDPG.ini", "Audio", "Samplerate", "32768")
$sMode = IniRead(@ScriptDir & "\Settings\BatchDPG.ini", "Audio", "Mode", $lDefAudioMode)
$sNormalize = IniRead(@ScriptDir & "\Settings\BatchDPG.ini", "Audio", "Normalize", "0")
$sAfterEncoding = IniRead(@ScriptDir & "\Settings\BatchDPG.ini", "Other", "AfterEncoding", $lDefAfterEncoding)
$sProcessPriority = IniRead(@ScriptDir & "\Settings\BatchDPG.ini", "Other", "ProcessPriority", $lDefPriority)
$sKeepAspectRatio = IniRead(@ScriptDir & "\Settings\BatchDPG.ini", "Mod", "KeepAspectRatio", "0")
$sSubFont = IniRead(@ScriptDir & "\Settings\BatchDPG.ini", "Mod", "SubFont", "Arial")
$sSubSize = IniRead(@ScriptDir & "\Settings\BatchDPG.ini", "Mod", "SubSize", "20")
$sSubShadow = IniRead(@ScriptDir & "\Settings\BatchDPG.ini", "Mod", "SubShadow", "3")
$sSubPos = IniRead(@ScriptDir & "\Settings\BatchDPG.ini", "Mod", "SubPos", "10")
$sAddParam = IniRead(@ScriptDir & "\Settings\BatchDPG.ini", "Mod", "AddParam", "")
$sEncodingMethod = IniRead(@ScriptDir & "\Settings\BatchDPG.ini", "Mod", "EncodingMethod", $lDefEncodingMethod)

$sAllowedMediaExtensions = IniRead(@ScriptDir & "\Settings\BatchDPG.ini", "Mod", "AllowedMediaExtensions", "*.avi; *.wmv; *.flv; *.mkv; *.mpg; *.mpeg; *.mp4; *.mov;")
$sAllowedSubtitleExtensions = IniRead(@ScriptDir & "\Settings\BatchDPG.ini", "Mod", "AllowedSubtitleExtensions", "*.smi; *.saa; *.srt; *.ass;")
$sAllowedAudioExtensions = IniRead(@ScriptDir & "\Settings\BatchDPG.ini", "Mod", "AllowedAudioExtensions", "*.mp2; *.mp3; *.wav; *.ogg;")

$wMain = GuiCreate($lTitle, 520, 300,-1,-1,-1,$WS_EX_ACCEPTFILES)
GUIRegisterMsg(0x233, "WM_DROPFILES_FUNC")

GUISetIcon("BatchDPG.ico")

GuiCtrlCreateGroup($lInput, 4, 4, 512, 89)

GuiCtrlCreateLabel($lVideo, 13, 19)
GuiCtrlCreateLabel($lAudio, 13, 44)
GuiCtrlCreateLabel($lSubtitle, 13, 69)



$hMedia = GUICtrlCreateInput($sMedia, 74, 16, 370, -1)
$hAudio = GUICtrlCreateInput($sAudio, 74, 41)
$hSub = GUICtrlCreateInput($sSub, 74, 66)

$hMediaSel = GUICtrlCreateButton($lBrowse, 448, 14, 64)
$hAudioSel = GUICtrlCreateButton($lBrowse, 448, 39, 64)
$hSubSel = GUICtrlCreateButton($lBrowse, 448, 64, 64)

$hProgress = GUICtrlCreateProgress(252, 270, 265)
$hStatus = GUICtrlCreateInput("", 4, 270, 240, -1, $ES_READONLY)

$hListView = GUICtrlCreateListView("Media|Audio|Subtitle|Temp|Output|Framerate|Profile|Width|Height|Video Bitrate|Video Bitrate Max|Passes|Resizer|Audio Bitrate|Samplerate|Mode|Normalize|Crop|SubFont|SubSize|SubShadow|SubPos|AddParam|EncodingMethod", 4, 100, 512, 136)
_GUICtrlListView_InsertColumn($hListView,_GUICtrlListView_GetColumnCount($hListView),"Sub",10)



GUICtrlSendMsg($hListView, $LVM_SETEXTENDEDLISTVIEWSTYLE, $LVS_EX_FULLROWSELECT, $LVS_EX_FULLROWSELECT)


$mListView = GUICtrlCreateContextMenu($hListView)
$mListView_UpToTop = GUICtrlCreateMenuItem($lListView_UpToTop, $mListView)
$mListView_Up = GUICtrlCreateMenuItem($lListView_Up, $mListView)
$mListView_Down = GUICtrlCreateMenuItem($lListView_Down, $mListView)
$mListView_DownToBottom = GUICtrlCreateMenuItem($lListView_DownToBottom, $mListView)

GUICtrlSendMsg(-1, $LVM_SETEXTENDEDLISTVIEWSTYLE, $LVS_EX_HEADERDRAGDROP, $LVS_EX_HEADERDRAGDROP)
GUICtrlSetState(-1, $GUI_DROPACCEPTED)

$hAdd = GUICtrlCreateButton($lAdd, 4, 240, 40)
$hDelete = GUICtrlCreateButton($lDelete, 44, 240, 40)
$hClear = GUICtrlCreateButton($lClear, 84, 240, 64)

$hPreview = GUICtrlCreateButton($lPreview, 148, 240, 64)
$hSettings = GUICtrlCreateButton($lSettings, 212, 240, 64)
$hRun = GUICtrlCreateButton($lRun, 276, 240, 40)
$hStop = GUICtrlCreateButton($lStop, 316, 240, 40)
$hAbout = GUICtrlCreateButton($lAbout, 472, 240, 45)

_GUICtrlListView_SetColumnWidth($hListView, 0, 491)
For $i = 1 To _GUICtrlListView_GetColumnCount($hListView) - 1
	_GUICtrlListView_HideColumn($hListView, $i)
Next
;--------------------------------------------------------
GuiSetState()

$wSetting = GuiCreate($lSettingsTitle, 520, 400)
GUISetIcon("BatchDPG.ico")
$hProfile = GUICtrlCreateCombo("", 74, 109, 57, -1, $CBS_DROPDOWNLIST)
$hWidth = GUICtrlCreateCombo("", 184, 84, 56, -1, $CBS_DROPDOWNLIST)
$hHeight = GUICtrlCreateCombo("", 184, 109, 56, -1, $CBS_DROPDOWNLIST)
$hResizer = GUICtrlCreateCombo("", 434, 109, 72, -1, $CBS_DROPDOWNLIST)

$hAudioBitrate = GUICtrlCreateCombo("", 63, 152, 48, -1, $CBS_DROPDOWNLIST)
$hSamplerate = GUICtrlCreateCombo("", 198, 152, 56, -1, $CBS_DROPDOWNLIST)
$hMode = GUICtrlCreateCombo("", 310, 152, 90, -1, $CBS_DROPDOWNLIST)
$hAfterEncoding = GUICtrlCreateCombo("", 106, 195, 104, -1, $CBS_DROPDOWNLIST)
$hProcessPriority = GUICtrlCreateCombo("", 278, 195, 104, -1, $CBS_DROPDOWNLIST)

$hEncodingMethod = GUICtrlCreateCombo("", 130, 315, 220, -1, $CBS_DROPDOWNLIST)

GuiCtrlCreateGroup($lOutput, 4, 4, 512, 64)
GuiCtrlCreateGroup($lVideo, 4, 72)
GuiCtrlCreateGroup($lAudio, 4, 140, -1, 39)

GuiCtrlCreateGroup($lOther, 4, 183,-1,39)

GuiCtrlCreateGroup($lSubtitle_Title, 4, 226, -1, 32)


;GuiCtrlCreateGroup($lOtherOption, 4, 226, 135, 32)
GuiCtrlCreateGroup($lAddParam, 4, 260, 512, 40)
GuiCtrlCreateGroup($lEncoderSettings, 4, 305, 512, 65)

GuiCtrlCreateLabel($lTempDir, 13, 19)
GuiCtrlCreateLabel($lOutputDir, 13, 44)
GuiCtrlCreateLabel($lFramerate, 13, 87)
GuiCtrlCreateLabel($lProfile, 13, 112)

GuiCtrlCreateLabel($lWidth, 137, 87)
GuiCtrlCreateLabel($lHeight, 137, 112)
GuiCtrlCreateLabel($lBitrate, 246, 87)
GuiCtrlCreateLabel($lMaxBitrate, 246, 112)
GuiCtrlCreateLabel($lPasses, 375, 87)
GuiCtrlCreateLabel($lResizer, 375, 112)
GuiCtrlCreateLabel($lAudio_Bitrate, 13, 155)
GuiCtrlCreateLabel($lSamplerate, 118, 155)
GuiCtrlCreateLabel($lMode, 258, 155)
GuiCtrlCreateLabel($lAfterEncoding, 13, 198)
GuiCtrlCreateLabel($lPriority, 218, 198)

GuiCtrlCreateLabel($lEncodingMethod, 14, 320)

$hTemp = GUICtrlCreateInput($sTemp, 74, 16,370, -1)
$hOutput = GUICtrlCreateInput($sOutput, 74, 41)
$hFramerate = GUICtrlCreateInput($sFramerate, 78, 84, 52)
$hVideoBitrate = GUICtrlCreateInput($sVideoBitrate, 319, 84, 48)
$hVideoBitrateMax = GUICtrlCreateInput($sVideoBitrateMax, 319, 109, 48)
$hPasses = GUICtrlCreateInput($sPasses, 434, 84, 40)
$hNormalize = GUICtrlCreateCheckbox($lNormalize, 410, 152)


GuiCtrlCreateLabel($lFont, 10, 240,-1,13)
GuiCtrlCreateLabel($lSize, 120, 240,-1,13)
GuiCtrlCreateLabel($lShadow, 195, 240,-1,13)
GuiCtrlCreateLabel($lPos, 285, 240,-1,13)

$hKeepAspectRatio = GUICtrlCreateCheckbox($lKeepAspectRatio, 395, 195)
$hSubFont = GUICtrlCreateInput($sSubFont, 55, 235, 60)
$hSubSize = GUICtrlCreateInput($sSubSize, 155, 235, 30)
$hSubShadow = GUICtrlCreateInput($sSubShadow, 250, 235, 30)
$hSubPos = GUICtrlCreateInput($sSubPos, 320, 235, 30)

$hAddParam = GUICtrlCreateInput($sAddParam, 10, 271, 500)


GUICtrlSetData($hProfile, $lProfile_Combo, $sProfile)
GUICtrlSetData($hWidth, "256|240|224|208|192|176|160|144|128", $sWidth)
GUICtrlSetData($hHeight, "192|176|160|144|128|112|96", $sHeight)
GUICtrlSetData($hResizer, "Bilinear|Bicubic|Lanczos|Spline16",  $sResizer)
GUICtrlSetData($hAudioBitrate, "128|112|96|80|64|56|48|32", $sAudioBitrate)
GUICtrlSetData($hSamplerate, "48000|32768|32000", $sSamplerate)
GUICtrlSetData($hMode, $lMode_Combo, $sMode)
GUICtrlSetData($hEncodingMethod, $lEncodingMethod_Combo, $sEncodingMethod)

If Int($sNormalize) Then GUICtrlSetState($hNormalize, $GUI_CHECKED)
If Int($sKeepAspectRatio) Then GUICtrlSetState($hKeepAspectRatio, $GUI_CHECKED)
	
GUICtrlSetData($hAfterEncoding, $lAfterEncoding_Combo, $sAfterEncoding)
GUICtrlSetData($hProcessPriority, $lPriority_Combo, $sProcessPriority)

$hTempSel = GUICtrlCreateButton($lBrowse, 448, 14, 64)
$hOutputSel = GUICtrlCreateButton($lBrowse, 448, 39, 64)

GuiSetState(@SW_HIDE,$wSetting)
If FileExists(@ScriptDir & "\Settings\lang\" & @OSLANG & ".ini") = true then 
	$tLoaded = "(Loaded)"
Else
	$tLoaded = "(Not Found)"
EndIf
GuiCtrlCreateLabel($lLangFile & " lang/" & @OSLANG & ".ini " & $tLoaded, 8, 380)

$SavedListfile = FileOpen(@ScriptDir & "\Settings\BatchDPG_SavedList.dat", 0)

While 1
	If $SavedListFile <> -1 Then
		$line = FileReadLine($SavedListFile)
			if @error = -1 then ExitLoop
			$aAdd = StringSplit($line, "|")
			If FileExists($aAdd[1]) Then 
				_GUICtrlListView_InsertItem($hListView,"",-1)
				_GUICtrlListView_SetItemText($hListView, _GUICtrlListView_GetItemCount($hListView) - 1, $aAdd[1],0)
				_GUICtrlListView_SetItemText($hListView, _GUICtrlListView_GetItemCount($hListView) - 1, $aAdd[2],1)
				_GUICtrlListView_SetItemText($hListView, _GUICtrlListView_GetItemCount($hListView) - 1, $aAdd[3],2)
				_GUICtrlListView_SetItemText($hListView, _GUICtrlListView_GetItemCount($hListView) - 1, $aAdd[4],3)
				_GUICtrlListView_SetItemText($hListView, _GUICtrlListView_GetItemCount($hListView) - 1, $aAdd[5],4)
				_GUICtrlListView_SetItemText($hListView, _GUICtrlListView_GetItemCount($hListView) - 1, $aAdd[6],5)
				_GUICtrlListView_SetItemText($hListView, _GUICtrlListView_GetItemCount($hListView) - 1, $aAdd[7],6)
				_GUICtrlListView_SetItemText($hListView, _GUICtrlListView_GetItemCount($hListView) - 1, $aAdd[8],7)
				_GUICtrlListView_SetItemText($hListView, _GUICtrlListView_GetItemCount($hListView) - 1, $aAdd[9],8)
				_GUICtrlListView_SetItemText($hListView, _GUICtrlListView_GetItemCount($hListView) - 1, $aAdd[10],9)
				_GUICtrlListView_SetItemText($hListView, _GUICtrlListView_GetItemCount($hListView) - 1, $aAdd[11],10)
				_GUICtrlListView_SetItemText($hListView, _GUICtrlListView_GetItemCount($hListView) - 1, $aAdd[12],11)
				_GUICtrlListView_SetItemText($hListView, _GUICtrlListView_GetItemCount($hListView) - 1, $aAdd[13],12)
				_GUICtrlListView_SetItemText($hListView, _GUICtrlListView_GetItemCount($hListView) - 1, $aAdd[14],13)
				_GUICtrlListView_SetItemText($hListView, _GUICtrlListView_GetItemCount($hListView) - 1, $aAdd[15],14)
				_GUICtrlListView_SetItemText($hListView, _GUICtrlListView_GetItemCount($hListView) - 1, $aAdd[16],15)
				_GUICtrlListView_SetItemText($hListView, _GUICtrlListView_GetItemCount($hListView) - 1, $aAdd[17],16)
				_GUICtrlListView_SetItemText($hListView, _GUICtrlListView_GetItemCount($hListView) - 1, $aAdd[18],17)
				_GUICtrlListView_SetItemText($hListView, _GUICtrlListView_GetItemCount($hListView) - 1, $aAdd[19],18)
				_GUICtrlListView_SetItemText($hListView, _GUICtrlListView_GetItemCount($hListView) - 1, $aAdd[20],19)
				_GUICtrlListView_SetItemText($hListView, _GUICtrlListView_GetItemCount($hListView) - 1, $aAdd[21],20)
				_GUICtrlListView_SetItemText($hListView, _GUICtrlListView_GetItemCount($hListView) - 1, $aAdd[22],21)
				_GUICtrlListView_SetItemText($hListView, _GUICtrlListView_GetItemCount($hListView) - 1, $aAdd[23],22)
				_GUICtrlListView_SetItemText($hListView, _GUICtrlListView_GetItemCount($hListView) - 1, $aAdd[24],23)
				_GUICtrlListView_SetItemText($hListView, _GUICtrlListView_GetItemCount($hListView) - 1, $aAdd[25],24)
			EndIf
	Else
		ExitLoop
	EndIf
WEnd

While 1

	GUICtrlSendMsg($hListView, $LVM_SETCOLUMNWIDTH, 0, 465)
	GUICtrlSendMsg($hListView, $LVM_SETCOLUMNWIDTH, _GUICtrlListView_GetColumnCount($hListView) - 1, 40)
	
	$iMsg = GUIGetMsg(1)
	Select
		Case $iMsg[0] = $mListView_UpToTop
			For $i = 1 To _GUICtrlListView_GetItemCount($hListView)
				_GUICtrlListView_MoveItems($wMain, $hListview, -1)
			next
			_SaveList()
		Case $iMsg[0] = $mListView_Up
			_GUICtrlListView_MoveItems($wMain, $hListview, -1)
			_SaveList()
		Case $iMsg[0] = $mListView_Down
			_GUICtrlListView_MoveItems($wMain, $hListview, 1)
			_SaveList()
		Case $iMsg[0] = $mListView_DownToBottom
			For $i = 1 To _GUICtrlListView_GetItemCount($hListView)
				_GUICtrlListView_MoveItems($wMain, $hListview, 1)
			next
			_SaveList()
	    Case $iMsg[0] = $hMediaSel
			$sTmpFile = FileOpenDialog("", "", $lMediaFiles & " (" & $sAllowedMediaExtensions & ")", 1)
			If $sTmpFile Then GUICtrlSetData($hMedia, $sTmpFile)
				
		Case $iMsg[0] = $hAudioSel
			$sTmpFile = FileOpenDialog("", "", $lAudioFiles & " (" & $sAllowedAudioExtensions & ")")
			If $sTmpFile Then GUICtrlSetData($hAudio, $sTmpFile)
				
		Case $iMsg[0] = $hSubSel
			$sTmpFile = FileOpenDialog("", "", $lSubFiles & " (" & $sAllowedSubtitleExtensions & ")")
			If $sTmpFile Then GUICtrlSetData($hSub, $sTmpFile)
				
		Case $iMsg[0] = $hTempSel
			$sTmpFolder = FileSelectFolder("", "")
			If $sTmpFolder Then GUICtrlSetData($hTemp, $sTmpFolder)
		Case $iMsg[0] = $hOutputSel
			$sTmpFolder = FileSelectFolder("", "")
			If $sTmpFolder Then GUICtrlSetData($hOutput, $sTmpFolder)
		Case $iMsg[0] = $hAbout
			MsgBox(64, "About", "BatchDPG " & $BatchDPGVersion & " Unofficial by Ghost" & @LF & "http://iamghost.kr" & @LF & @LF & "Original BatchDPG by LS5" & @LF & "daanuitmoskou@hotmail.com" & @LF & @LF & "Thanks go out to:" & @LF & "- Firon, for coming up with a lot of optimizations." & @LF & "- mrsaturn, for making the official website and hosting it." & @LF & "- Takieda, for the information on handling MediaInfo." & @LF & "- ... all the testers, for helping out to fix the bugs!")
		
		Case $iMsg[0] = $hPreview
			$selected = ""
			$selected = _GUICtrlListView_GetSelectedIndices($hListView)
			if $selected Then
				$preview = $selected
				_Preview()
			EndIf
		Case $iMsg[0] = $hAdd
			$aAdd = StringSplit(GUICtrlRead($hMedia), "|")
		
			For $i = 1 + ($aAdd[0] > 1) To $aAdd[0]
				If $aAdd[0] > 1 Then $aAdd[$i] = StringReplace($aAdd[1] & "\" & $aAdd[$i], "\\", "\")
				
				If FileExists($aAdd[$i]) Then 
					_GUICtrlListView_InsertItem($hListView,"",-1)
					_GUICtrlListView_SetItemText($hListView, _GUICtrlListView_GetItemCount($hListView) - 1, $aAdd[$i],0)
					_GUICtrlListView_SetItemText($hListView, _GUICtrlListView_GetItemCount($hListView) - 1, GUICtrlRead($hAudio),1)
					_GUICtrlListView_SetItemText($hListView, _GUICtrlListView_GetItemCount($hListView) - 1, GUICtrlRead($hSub),2)
					_GUICtrlListView_SetItemText($hListView, _GUICtrlListView_GetItemCount($hListView) - 1, GUICtrlRead($hTemp),3)
					_GUICtrlListView_SetItemText($hListView, _GUICtrlListView_GetItemCount($hListView) - 1, GUICtrlRead($hOutput),4)
					_GUICtrlListView_SetItemText($hListView, _GUICtrlListView_GetItemCount($hListView) - 1, GUICtrlRead($hFramerate),5)
					_GUICtrlListView_SetItemText($hListView, _GUICtrlListView_GetItemCount($hListView) - 1, _GUICtrlComboBox_GetCurSel($hProfile),6)
					_GUICtrlListView_SetItemText($hListView, _GUICtrlListView_GetItemCount($hListView) - 1, GUICtrlRead($hWidth),7)
					_GUICtrlListView_SetItemText($hListView, _GUICtrlListView_GetItemCount($hListView) - 1, GUICtrlRead($hHeight),8)
					_GUICtrlListView_SetItemText($hListView, _GUICtrlListView_GetItemCount($hListView) - 1, GUICtrlRead($hVideoBitrate),9)
					_GUICtrlListView_SetItemText($hListView, _GUICtrlListView_GetItemCount($hListView) - 1, GUICtrlRead($hVideoBitrateMax),10)
					_GUICtrlListView_SetItemText($hListView, _GUICtrlListView_GetItemCount($hListView) - 1, GUICtrlRead($hPasses),11)
					_GUICtrlListView_SetItemText($hListView, _GUICtrlListView_GetItemCount($hListView) - 1, GUICtrlRead($hResizer),12)
					_GUICtrlListView_SetItemText($hListView, _GUICtrlListView_GetItemCount($hListView) - 1, GUICtrlRead($hAudioBitrate),13)
					_GUICtrlListView_SetItemText($hListView, _GUICtrlListView_GetItemCount($hListView) - 1, GUICtrlRead($hSamplerate),14)
					_GUICtrlListView_SetItemText($hListView, _GUICtrlListView_GetItemCount($hListView) - 1, _GUICtrlComboBox_GetCurSel($hMode),15)
					_GUICtrlListView_SetItemText($hListView, _GUICtrlListView_GetItemCount($hListView) - 1, BitAnd(GUICtrlRead($hNormalize), $GUI_CHECKED),16)
					_GUICtrlListView_SetItemText($hListView, _GUICtrlListView_GetItemCount($hListView) - 1, GUICtrlRead($hKeepAspectRatio),17)
					_GUICtrlListView_SetItemText($hListView, _GUICtrlListView_GetItemCount($hListView) - 1, GUICtrlRead($hSubFont),18)
					_GUICtrlListView_SetItemText($hListView, _GUICtrlListView_GetItemCount($hListView) - 1, GUICtrlRead($hSubSize),19)
					_GUICtrlListView_SetItemText($hListView, _GUICtrlListView_GetItemCount($hListView) - 1, GUICtrlRead($hSubShadow),20)
					_GUICtrlListView_SetItemText($hListView, _GUICtrlListView_GetItemCount($hListView) - 1, GUICtrlRead($hSubPos),21)
					_GUICtrlListView_SetItemText($hListView, _GUICtrlListView_GetItemCount($hListView) - 1, GUICtrlRead($hAddParam),22)
					_GUICtrlListView_SetItemText($hListView, _GUICtrlListView_GetItemCount($hListView) - 1, _GUICtrlComboBox_GetCurSel($hEncodingMethod),23)
					_SaveList()
				EndIf
			Next
		
		Case $iMsg[0] = $hDelete
			If _GUICtrlListView_GetSelectedCount($hListView) > 0 Then _GUICtrlListView_DeleteItemsSelected(GUICtrlGetHandle($hListView))
			_SaveList()
			
		Case $iMsg[0] = $hClear
			While 1
			if _GUICtrlListView_GetItemCount($hListview) = 0 then ExitLoop
				_GUICtrlListView_DeleteItem(GUICtrlGetHandle($hListView),0)				
			WEnd
			_SaveList()
			
		Case $iMsg[0] = $hRun
			GUICtrlSetData($hStatus,"")
			$isStopped = False
			While _GUICtrlListView_GetItemCount($hListView) > 0
				if $IsStopped = true Then ExitLoop
					_Run()
				if $isStopped = False Then
					_GUICtrlListView_DeleteItem(GUICtrlGetHandle($hListView), 0)
					GUICtrlSendMsg($hListView, $LVM_SETCOLUMNWIDTH, 0, 465)
					GUICtrlSendMsg($hListView, $LVM_SETCOLUMNWIDTH, _GUICtrlListView_GetColumnCount($hListView) - 1, 40)
					_SaveList()
				EndIf
			WEnd
			
			if $IsUserStop = false Then
				$afterEncoding = _GUICtrlComboBox_GetCurSel($hAfterEncoding)
				If $afterEncoding = 1 Then
					_Save()
					Exit
				ElseIf $afterEncoding = 2 Then
					$QuitMsg = MsgBox(0 + 48, "BatchDPG " & $BatchDPGVersion & " Unofficial", StringReplace($lShutdownMessage,"%CRLF%",@CRLF), 30)
					if $QuitMsg = -1 Then
					_Save()
					Shutdown(1 + 8)
					EndIf
				EndIf
			Else
				$IsUserStop = false
			EndIf
		Case $iMsg[0] = $hSettings
			GuiSetState(@SW_SHOW,$wSetting)
		Case $iMsg[0] = $GUI_EVENT_MINIMIZE
			if $iMsg[1] = $wMain Then
				GuiSetState(@SW_HIDE,$wMain)
				TraySetState(1) ; show
				TraySetToolTip("BatchDPG " & $BatchDPGVersion & " Unofficial")
			EndIf
		Case $iMsg[0] = $GUI_EVENT_CLOSE
			if $iMsg[1] = $wSetting then
				_Save()
				GuiSetState(@SW_HIDE,$wSetting)
			else
				_Save()
				Exit
			EndIf
			
        Case $iMsg[0] = $GUI_EVENT_DROPPED			
			if $dragnum <> $prvdragnum Then
				
            $NotValidExtPath = ""
            $ValidExtCount = 0
            For $o = 1 To UBound($DropFilesArr)-1
				
			Dim $mediaDrive, $mediaDir, $mediaName, $mediaExt
			_PathSplit($DropFilesArr[$o], $mediaDrive, $mediaDir, $mediaName, $mediaExt)

				$aAdd = StringSplit($DropFilesArr[$o], "|")
				$aSub = ""
		
				if FileExists($mediaDrive & $mediaDir & $mediaName & ".smi") Then
					$aSub = $mediaDrive & $mediaDir & $mediaName & ".smi"
				elseif FileExists($mediaDrive & $mediaDir & $mediaName & ".saa") Then
					$aSub = $mediaDrive & $mediaDir & $mediaName & ".saa"
				elseif FileExists($mediaDrive & $mediaDir & $mediaName & ".srt") Then
					$aSub = $mediaDrive & $mediaDir & $mediaName & ".srt"
				elseif FileExists($mediaDrive & $mediaDir & $mediaName & ".ass") Then
					$aSub = $mediaDrive & $mediaDir & $mediaName & ".ass"
				EndIf
				
					For $i = 1 + ($aAdd[0] > 1) To $aAdd[0]
						If $aAdd[0] > 1 Then $aAdd[$i] = StringReplace($aAdd[1] & "\" & $aAdd[$i], "\\", "\")
						
						If FileExists($aAdd[$i]) and StringInStr($sAllowedMediaExtensions,$mediaExt) Then 
							_GUICtrlListView_InsertItem($hListView,"",-1)
							_GUICtrlListView_SetItemText($hListView, _GUICtrlListView_GetItemCount($hListView) - 1, $aAdd[$i],0)
							;_GUICtrlListView_SetItemText($hListView, _GUICtrlListView_GetItemCount($hListView) - 1, GUICtrlRead($hAudio),1)
							_GUICtrlListView_SetItemText($hListView, _GUICtrlListView_GetItemCount($hListView) - 1, $aSub,2)
							_GUICtrlListView_SetItemText($hListView, _GUICtrlListView_GetItemCount($hListView) - 1, GUICtrlRead($hTemp),3)
							_GUICtrlListView_SetItemText($hListView, _GUICtrlListView_GetItemCount($hListView) - 1, GUICtrlRead($hOutput),4)
							_GUICtrlListView_SetItemText($hListView, _GUICtrlListView_GetItemCount($hListView) - 1, GUICtrlRead($hFramerate),5)
							_GUICtrlListView_SetItemText($hListView, _GUICtrlListView_GetItemCount($hListView) - 1, _GUICtrlComboBox_GetCurSel($hProfile),6)
							_GUICtrlListView_SetItemText($hListView, _GUICtrlListView_GetItemCount($hListView) - 1, GUICtrlRead($hWidth),7)
							_GUICtrlListView_SetItemText($hListView, _GUICtrlListView_GetItemCount($hListView) - 1, GUICtrlRead($hHeight),8)
							_GUICtrlListView_SetItemText($hListView, _GUICtrlListView_GetItemCount($hListView) - 1, GUICtrlRead($hVideoBitrate),9)
							_GUICtrlListView_SetItemText($hListView, _GUICtrlListView_GetItemCount($hListView) - 1, GUICtrlRead($hVideoBitrateMax),10)
							_GUICtrlListView_SetItemText($hListView, _GUICtrlListView_GetItemCount($hListView) - 1, GUICtrlRead($hPasses),11)
							_GUICtrlListView_SetItemText($hListView, _GUICtrlListView_GetItemCount($hListView) - 1, GUICtrlRead($hResizer),12)
							_GUICtrlListView_SetItemText($hListView, _GUICtrlListView_GetItemCount($hListView) - 1, GUICtrlRead($hAudioBitrate),13)
							_GUICtrlListView_SetItemText($hListView, _GUICtrlListView_GetItemCount($hListView) - 1, GUICtrlRead($hSamplerate),14)
							_GUICtrlListView_SetItemText($hListView, _GUICtrlListView_GetItemCount($hListView) - 1, _GUICtrlComboBox_GetCurSel($hMode),15)
							_GUICtrlListView_SetItemText($hListView, _GUICtrlListView_GetItemCount($hListView) - 1, BitAnd(GUICtrlRead($hNormalize), $GUI_CHECKED),16)
							_GUICtrlListView_SetItemText($hListView, _GUICtrlListView_GetItemCount($hListView) - 1, GUICtrlRead($hKeepAspectRatio),17)
							_GUICtrlListView_SetItemText($hListView, _GUICtrlListView_GetItemCount($hListView) - 1, GUICtrlRead($hSubFont),18)
							_GUICtrlListView_SetItemText($hListView, _GUICtrlListView_GetItemCount($hListView) - 1, GUICtrlRead($hSubSize),19)
							_GUICtrlListView_SetItemText($hListView, _GUICtrlListView_GetItemCount($hListView) - 1, GUICtrlRead($hSubShadow),20)
							_GUICtrlListView_SetItemText($hListView, _GUICtrlListView_GetItemCount($hListView) - 1, GUICtrlRead($hSubPos),21)
							_GUICtrlListView_SetItemText($hListView, _GUICtrlListView_GetItemCount($hListView) - 1, GUICtrlRead($hAddParam),22)
							_GUICtrlListView_SetItemText($hListView, _GUICtrlListView_GetItemCount($hListView) - 1, _GUICtrlComboBox_GetCurSel($hEncodingMethod),23)
							
							if $aSub then
								_GUICtrlListView_SetItemText($hListView, _GUICtrlListView_GetItemCount($hListView) - 1, "O",24)
							else
								_GUICtrlListView_SetItemText($hListView, _GUICtrlListView_GetItemCount($hListView) - 1, "X",24)
							EndIf
						EndIf
					Next
				
			Next
			_SaveList()
			$prvdragnum = $dragnum
			EndIf
	EndSelect
WEnd


Func _Run()
While 1	
	GUICtrlSendMsg($hListView, $LVM_SETCOLUMNWIDTH, 0, 465)
	GUICtrlSendMsg($hListView, $LVM_SETCOLUMNWIDTH, _GUICtrlListView_GetColumnCount($hListView) - 1, 40)
	
	$arraytmp = ""
	$arraytmp = _GUICtrlListView_GetItemTextArray($hListView,0)
	$media = $arraytmp[1]
	$audio = $arraytmp[2]
	$sub = $arraytmp[3]
	$temp = string($arraytmp[4])
	$output = $arraytmp[5]
	$framerate = Number($arraytmp[6])
	$profile = Number($arraytmp[7])
	$width = Number($arraytmp[8])
	$height = Number($arraytmp[9])
	$videoBitrate = Number($arraytmp[10])
	$videoBitrateMax = Number($arraytmp[11])
	$passes = Number($arraytmp[12])
	$resizer = $arraytmp[13]
	$audioBitrate = Number($arraytmp[14])
	$samplerate = Number($arraytmp[15])
	$mode = Number($arraytmp[16])
	$normalize = Number($arraytmp[17])
	$keepaspectratio = Number($arraytmp[18])
	$subfont = $arraytmp[19]
	$subsize = Number($arraytmp[20])
	$subshadow = Number($arraytmp[21])
	$subpos = Number($arraytmp[22])
	$addparam = $arraytmp[23]
	
	$encodingmethod = $arraytmp[24]
	
	if $encodingmethod = -1 Then $encodingmethod = 0
	
	
	if $encodingmethod = 1 Then $framerate = 15
	
	if $keepaspectratio = 1 Then
		$sMediaInfo = Run(@ComSpec & " /c " & FileGetShortName(@ScriptDir & "\bin\MediaInfo.exe") & " -f """ & $media & """", "", "", 2)
		$sMediaStats = ""
		While 1
			$sMediaStats &= StdoutRead($sMediaInfo)
			If @error Then ExitLoop
		WEnd
		$sAspectRatio = Number(StringTrimLeft($sMediaStats, StringInStr($sMediaStats, "Aspect ratio") + 22))
		
		If $sAspectRatio Then
			$width = _Min(256, 16 * Round(12 * $sAspectRatio))
			$height = _Min(192, 16 * Round(16 / $sAspectRatio))
		EndIf
	EndIF
	
	Dim $mediaDrive, $mediaDir, $mediaName, $mediaExt
	_PathSplit($media, $mediaDrive, $mediaDir, $mediaName, $mediaExt)

	If FileExists($temp) Then
		If StringRight($temp, 1) <> "\" Then $temp &= "\"
		$temp = $temp & $mediaName & $mediaExt
	Else
		$temp = $media
	EndIf

	If FileExists($output) Then
		If StringRight($output, 1) <> "\" Then $output &= "\"
		$output = $output & $mediaName & $mediaExt
	Else
		$output = $media
	EndIf


	If $framerate Then
		$framerate = Round(_Min($framerate, 60) * 256) / 256
	Else
		$sMediaStats = ""
		$sMediaInfo = Run(@ComSpec & " /c " & FileGetShortName(@ScriptDir & "\bin\MediaInfo.exe") & " -f """ & $media & """", "", "", 2)
		While 1
			$sMediaStats &= StdoutRead($sMediaInfo)
			If @error Then ExitLoop
		WEnd
		$framerateSource = Number(StringTrimLeft($sMediaStats, StringInStr($sMediaStats, "Frame rate") + 22))
		If Not $framerateSource Then $framerateSource = 60
		$framerate = _Min(Round(589824 / $width / $height + 8), $framerateSource)
	EndIf

	$videoBitrate = Round($videoBitrate * 60 / $framerate)
	$videoBitrateMax = Round($videoBitrateMax * 60 / $framerate)

	

	If $profile = 0 Then
		$mencoder = ":mbd=2:trell:cbp:mv0:vmax_b_frames=2:cmp=6:subcmp=6:precmp=6:dia=4:predia=4:vb_strategy=2:bidir_refine=4:mv0_threshold=0:last_pred=3:preme=2"
	ElseIf $profile = 1 Then
		$mencoder = ":mbd=2:trell:cbp:mv0:vmax_b_frames=1:cmp=6:subcmp=6:precmp=6:dia=3:predia=3"
	ElseIf $profile = 2 Then
		$mencoder = ":mbd=2:trell:cbp:mv0:vmax_b_frames=1:cmp=2:subcmp=2:precmp=2"
	Else
		$mencoder = ""
	EndIf

	If $mode = 0 Then
		$twoLame = "-m j"
	Else
		$twoLame = "-m m -a"
	EndIf

	$threads = ""
	$aviSynthFile = FileOpen(@ScriptDir & "\Settings\BatchDPG_Script.avs", 0)
	$aviSynth = FileOpen($temp & ".avs", 2)

	While 1
		If $aviSynth <> -1 Then
			$line = FileReadLine($aviSynthFile)
				if @error = -1 then ExitLoop
				FileWriteLine($aviSynth,_ProcessAVS($line,False,$media,$audio,$sub,$temp,$output,$framerate,$profile,$width,$height,$videobitrate,$videobitratemax,$passes,$resizer,$audiobitrate,$samplerate,$mode,$normalize,$keepaspectratio,$subfont,$subsize,$subshadow,$subpos,$addparam,$encodingmethod))
		Else
			ExitLoop
		EndIf
	WEnd
	
	FileClose($aviSynth)	
	
	if FileExists($sub) then
		
	$substylefile = FileOpen(@ScriptDir & "\Settings\BatchDPG_Subtitle.style", 0)
	$subStyle = FileOpen($sub & ".style", 2)
	
	While 1
		If $substylefile <> -1 Then
			$line = FileReadLine($substylefile)
				if @error = -1 then ExitLoop
				FileWriteLine($subStyle,_ProcessSubtitle($line,$subfont,$subsize,$subshadow,$subpos))
		Else
			ExitLoop
		EndIf
	WEnd
	FileClose($subStyle)

		
	EndIf
	
	GUICtrlSetData($hProgress, 0)
	GUICtrlSetData($hStatus, $lAudioEnc &	": 0%")
	
	if $encodingmethod = 0 then
		$progress = Run(@ComSpec & " /c " & FileGetShortName(@ScriptDir & "\Bin\BePipe.exe") & " --script ""Import(^" & $temp & ".avs^)"" | " & FileGetShortName(@ScriptDir & "\Bin\twolame.exe") & " -b " & $audioBitrate & " " & $twoLame & " - """ & $temp & ".mp2""", "", "", 4)
		While 1
			$iMsg = GUIGetMsg(1)
			if $iMsg[0] = $hStop or $IsStopped = True Then
				_Stop()
				ExitLoop
			elseif $iMsg[0] = $GUI_EVENT_MINIMIZE and $iMsg[1] = $wMain then
				GuiSetState(@SW_HIDE,$wMain)
				TraySetState(1) ; show
				TraySetToolTip("BatchDPG " & $BatchDPGVersion & " Unofficial")
			elseif $iMsg[0] = $GUI_EVENT_CLOSE and $iMsg[1] = $wMain Then
				if MsgBox(4+32,"BatchDPG " & $BatchDPGVersion & " Unofficial",$lQuit) = 6 Then
					$IWantQuit = True
					_Stop()
					ExitLoop
				EndIf
			EndIf
			
			$line = StderrRead($progress)
			If @error Then ExitLoop
				
			$percentage = Round(Number($line))
			If $percentage Then
				GUICtrlSetData($hProgress, $percentage)
				GUICtrlSetData($hStatus, $lAudioEnc & ": " & $percentage & "%")
				TraySetToolTip("BatchDPG (" & $lAudioEnc & ": " & $percentage & "%" & ")")
			EndIf
		Wend
	EndIf
	
	if $iMsg[0] = $hStop or $IsStopped = True Then
		ExitLoop
	EndIf

	For $i = 1 To $passes
		GUICtrlSetData($hProgress, 0)
		GUICtrlSetData($hStatus, $lVideoEnc & " (" & $i & "/" & $passes & "): 0%")

		If $i = 2 And $passes >= 3 Or $i > 3 Then
			$vpass = ":vpass=3"
		Else
			$vpass = ":vpass=" & $i
		EndIf
		$bizarrecommand = ":intra_matrix=8,9,12,22,26,27,29,34,9,10,14,26,27,29,34,37,12,14,18,27,29,34,37,38,22,26,27,31,36,37,38,40,26,27,29,36,39,38,40,48,27,29,34,37,38,40,48,58,29,34,37,38,40,48,58,69,34,37,38,40,48,58,69,79:inter_matrix=16,18,20,22,24,26,28,30,18,20,22,24,26,28,30,32,20,22,24,26,28,30,32,34,22,24,26,30,32,32,34,36,24,26,28,32,34,34,36,38,26,28,30,32,34,36,38,40,28,30,32,34,36,38,42,42,30,32,34,36,38,40,42,44"
		$bizarrecommand = ""
		if $encodingmethod = 0 Then
			$progress = Run(FileGetShortName(@ScriptDir & "\Bin\mencoder.exe") & " """ & $temp & ".avs"" -o """ & $temp & ".m1v"" -nosound -passlogfile """ & $temp & ".log"" -ovc lavc -lavcopts vcodec=mpeg1video:keyint=60:vrc_buf_size=327:vrc_maxrate=" & $videoBitrateMax & ":vbitrate=" & $videoBitrate & $vpass & $mencoder & $threads & ":intra_matrix=8,9,12,22,26,27,29,34,9,10,14,26,27,29,34,37,12,14,18,27,29,34,37,38,22,26,27,31,36,37,38,40,26,27,29,36,39,38,40,48,27,29,34,37,38,40,48,58,29,34,37,38,40,48,58,69,34,37,38,40,48,58,69,79:inter_matrix=16,18,20,22,24,26,28,30,18,20,22,24,26,28,30,32,20,22,24,26,28,30,32,34,22,24,26,30,32,32,34,36,24,26,28,32,34,34,36,38,26,28,30,32,34,36,38,40,28,30,32,34,36,38,42,42,30,32,34,36,38,40,42,44 -of rawvideo " & $addparam, "", "", 2)
		elseif $encodingmethod = 1 Then
			$progress = Run(FileGetShortName(@ScriptDir & "\Bin\mencoder.exe") & " """ & $temp & ".avs"" -o """ & $temp & ".mpg"" -passlogfile """ & $temp & ".log"" -oac lavc acodec=mp2:abitrate=" & $audiobitrate & " -ovc lavc -lavcopts vcodec=mpeg1video:keyint=60:vrc_buf_size=327:vrc_maxrate=" & $videoBitrateMax & ":vbitrate=" & $videoBitrate & $vpass & $mencoder & $threads & ":intra_matrix=8,9,12,22,26,27,29,34,9,10,14,26,27,29,34,37,12,14,18,27,29,34,37,38,22,26,27,31,36,37,38,40,26,27,29,36,39,38,40,48,27,29,34,37,38,40,48,58,29,34,37,38,40,48,58,69,34,37,38,40,48,58,69,79:inter_matrix=16,18,20,22,24,26,28,30,18,20,22,24,26,28,30,32,20,22,24,26,28,30,32,34,22,24,26,30,32,32,34,36,24,26,28,32,34,34,36,38,26,28,30,32,34,36,38,40,28,30,32,34,36,38,42,42,30,32,34,36,38,40,42,44 -of lavf" & $addparam, "", "", 2)
			ClipPut(FileGetShortName(@ScriptDir & "\Bin\mencoder.exe") & " """ & $temp & ".avs"" -o """ & $temp & ".mpg"" -passlogfile """ & $temp & ".log"" -oac lavc acodec=mp2:abitrate=" & $audiobitrate & " -ovc lavc -lavcopts vcodec=mpeg1video:keyint=60:vrc_buf_size=327:vrc_maxrate=" & $videoBitrateMax & ":vbitrate=" & $videoBitrate & $vpass & $mencoder & $threads & ":intra_matrix=8,9,12,22,26,27,29,34,9,10,14,26,27,29,34,37,12,14,18,27,29,34,37,38,22,26,27,31,36,37,38,40,26,27,29,36,39,38,40,48,27,29,34,37,38,40,48,58,29,34,37,38,40,48,58,69,34,37,38,40,48,58,69,79:inter_matrix=16,18,20,22,24,26,28,30,18,20,22,24,26,28,30,32,20,22,24,26,28,30,32,34,22,24,26,30,32,32,34,36,24,26,28,32,34,34,36,38,26,28,30,32,34,36,38,40,28,30,32,34,36,38,42,42,30,32,34,36,38,40,42,44 -of lavf" & $addparam)
		EndIf
		
		ProcessSetPriority("mencoder.exe", Int(GUICtrlRead($hProcessPriority)))

		While 1
			$iMsg = GUIGetMsg(1)
			if $iMsg[0] = $hStop or $IsStopped = True Then
				_Stop()
				ExitLoop
			elseif $iMsg[0] = $GUI_EVENT_MINIMIZE then
				if $iMsg[1] = $wMain Then
					GuiSetState(@SW_HIDE,$wMain)
					TraySetState(1) ; show
					TraySetToolTip("BatchDPG " & $BatchDPGVersion & " Unofficial")
				EndIf
			elseif $iMsg[0] = $GUI_EVENT_CLOSE and $iMsg[1] = $wMain Then
				if MsgBox(4+32,"BatchDPG " & $BatchDPGVersion & " Unofficial",$lQuit) = 6 Then
					$IWantQuit = True
					_Stop()
					ExitLoop
				EndIf
			EndIf
			
			$line = StdoutRead($progress)
			If @error Then ExitLoop
			$percentage = Int(StringMid($line, StringInStr($line, "f (") + 3))
			If $percentage Then
				GUICtrlSetData($hProgress, $percentage)
				GUICtrlSetData($hStatus, $lVideoEnc & " (" & $i & "/" & $passes & "): " & $percentage & "%")
				TraySetToolTip("BatchDPG (" & $lVideoEnc & " (" & $i & "/" & $passes & "): " & $percentage & "%" & ")")
			EndIf
		Wend
	Next
	
	if $iMsg[0] = $hStop or $IsStopped = True Then
		ExitLoop
	EndIf
	
	if $encodingmethod = 1 Then
		Dim $outputDrive, $outputDir, $outputName, $outputExt
		_PathSplit($temp, $outputDrive, $outputDir, $outputName, $outputExt)
	FileDelete($outputDrive & $outputDir & "\temp-0.m1v")
	FileDelete($outputDrive & $outputDir & "\temp-0.mp2")
	FileDelete($temp & ".m1v")
	FileDelete($temp & ".mp2")
	RunWait(FileGetShortName(@ScriptDir & "\Bin\mpgtx.exe") & " -d """ & $temp & ".mpg"" -b """ & $outputDrive & $outputDir & "temp""","",@SW_HIDE)
	FileMove($outputDrive & $outputDir & "\temp-0.m1v", $temp & ".m1v")
	FileMove($outputDrive & $outputDir & "\temp-0.mp2", $temp & ".mp2")
	GUICtrlSetData($hProgress, 0)
	GUICtrlSetData($hStatus, "")
	EndIf

	FileDelete($temp & ".log")
	
			$iMsg = GUIGetMsg(1)
			if $iMsg[0] = $hStop or $IsStopped = True Then
				_Stop()
			EndIf


	If FileExists($temp & ".mp2") And FileExists($temp & ".m1v") and $IsStopped = false Then
		
		GUICtrlSetData($hStatus, $lMultiplexing)
		TraySetToolTip("BatchDPG (" & $lMultiplexing & ")")


		RunWait(FileGetShortName(@ScriptDir & "\bin\mpeg_stat.exe") & " -offset """ & $temp & ".off"" """ & $temp & ".m1v""", "", @SW_HIDE)

		$stats = FileOpen($temp & ".off", 0)
		$gopList = FileOpen($temp & ".gop", 2)
		$frames = 0
		While 1
			$line = StringSplit(FileReadLine($stats), " ")
			If $line[0] < 2 Then ExitLoop
			If $line[1] = "picture" Then $frames += 1
			If $line[1] = "sequence" Then
				FileWrite($gopList, Binary($frames))
				FileWrite($gopList, Binary(Number(String($line[2] / 8))))
			EndIf
		WEnd
		FileClose($stats)
		FileClose($gopList)

		$header = FileOpen($temp & ".head", 2)
		FileWrite($header, Binary("DPG3"))
		FileWrite($header, Binary($frames))
		FileWrite($header, Binary(Chr(256 * ($framerate - Int($framerate)))))
		FileWrite($header, Binary(Chr($framerate)))
		FileWrite($header, Binary(Chr(0)))
		FileWrite($header, Binary(Chr(0)))
		FileWrite($header, Binary($samplerate))
		FileWrite($header, Binary(0))
		FileWrite($header, Binary(48))
		FileWrite($header, Binary(Number(String(FileGetSize($temp & ".mp2")))))
		FileWrite($header, Binary(Number(String(48 + FileGetSize($temp & ".mp2")))))
		FileWrite($header, Binary(Number(String(FileGetSize($temp & ".m1v")))))
		FileWrite($header, Binary(Number(String(48 + FileGetSize($temp & ".mp2") + FileGetSize($temp & ".m1v")))))
		FileWrite($header, Binary(Number(String(FileGetSize($temp & ".gop")))))
		FileWrite($header, Binary(3))
		FileClose($header)
		
		Dim $outputDrive, $outputDir, $outputName, $outputExt
		_PathSplit($output, $outputDrive, $outputDir, $outputName, $outputExt)
		$oname = $outputName & ".avs"

		$outputFinal = $outputDrive & $outputDir & $outputName & ".dpg"
		If FileExists($outputFinal) Then
			$i = 1
			While FileExists($outputDrive & $outputDir & $outputName & "_" & $i & ".dpg")
				$i += 1
			WEnd
			$outputFinal = $outputDrive & $outputDir & $outputName & "_" & $i & ".dpg"
		EndIf

		RunWait(@ComSpec & " /c copy /b """ & $temp & ".head"" + """ & $temp & ".mp2"" + """ & $temp & ".m1v"" + """ & $temp & ".gop"" """ & $outputFinal & """", "", @SW_HIDE)
		GUICtrlSetData($hStatus, "")	
		
		
		If Not FileExists($outputFinal) Then
				Dim $outputDrive, $outputDir, $outputName, $outputExt
				_PathSplit($output, $outputDrive, $outputDir, $outputName, $outputExt)
				$oname = $outputName & ".avs"
			FileCopy($temp & ".avs",@ScriptDir & "\ErrorLog\" & $oname,1 + 8)
			FileDelete($temp & ".avs")
			MsgBox(16, "Error", $lMultiplexFail & @LF & @LF & StringReplace($lErrorTimeout,"%s","15"), 15)
		EndIf
		
		ElseIf FileExists($temp & ".mp2") and $IsStopped = false Then
				Dim $outputDrive, $outputDir, $outputName, $outputExt
				_PathSplit($output, $outputDrive, $outputDir, $outputName, $outputExt)
				$oname = $outputName  & ".avs"
			FileCopy($temp & ".avs",@ScriptDir & "\ErrorLog\" & $oname,1 + 8)
			FileDelete($temp & ".avs")
			MsgBox(16, "Error", $lVideoFail & @LF & @LF & StringReplace($lErrorTimeout,"%s","15"), 15)
		ElseIf FileExists($temp & ".m1v") and $IsStopped = false Then
				Dim $outputDrive, $outputDir, $outputName, $outputExt
				_PathSplit($output, $outputDrive, $outputDir, $outputName, $outputExt)
				$oname = $outputName & ".avs"
			FileCopy($temp & ".avs",@ScriptDir & "\ErrorLog\" & $oname,1 + 8)
			FileDelete($temp & ".avs")
			MsgBox(16, "Error", $lAudioFail & @LF & @LF & StringReplace($lErrorTimeout,"%s","15"), 15)
		Elseif $IsStopped = false Then
				Dim $outputDrive, $outputDir, $outputName, $outputExt
				_PathSplit($output, $outputDrive, $outputDir, $outputName, $outputExt)
				$oname = $outputName & ".avs"
			FileCopy($temp & ".avs",@ScriptDir & "\ErrorLog\" & $oname,1 + 8)
			FileDelete($temp & ".avs")
			MsgBox(16, "Error", StringReplace($lConvFail,"%f",$temp) & @LF & @LF & StringReplace($lErrorTimeout,"%s","30"), 30)
		EndIf
	
	GUICtrlSetData($hProgress,0)
	ExitLoop
WEnd
	FileDelete($temp & ".avs")
	FileDelete($temp & ".head")
	FileDelete($temp & ".mpg")
	FileDelete($temp & ".mp2")
	FileDelete($temp & ".m1v")
	FileDelete($temp & ".off")
	FileDelete($temp & ".gop")
	FileDelete($sub & ".style")
	if $IWantQuit = True then Exit
EndFunc

Func _Save()
	IniWrite(@ScriptDir & "\Settings\BatchDPG.ini", "Input", "Media", GUICtrlRead($hMedia))
	IniWrite(@ScriptDir & "\Settings\BatchDPG.ini", "Input", "Audio", GUICtrlRead($hAudio))
	IniWrite(@ScriptDir & "\Settings\BatchDPG.ini", "Input", "Sub", GUICtrlRead($hSub))
	IniWrite(@ScriptDir & "\Settings\BatchDPG.ini", "Output", "Temp", GUICtrlRead($hTemp))
	IniWrite(@ScriptDir & "\Settings\BatchDPG.ini", "Output", "Output", GUICtrlRead($hOutput))
	IniWrite(@ScriptDir & "\Settings\BatchDPG.ini", "Video", "Framerate", GUICtrlRead($hFramerate))
	IniWrite(@ScriptDir & "\Settings\BatchDPG.ini", "Video", "Profile", GUICtrlRead($hProfile))
	IniWrite(@ScriptDir & "\Settings\BatchDPG.ini", "Video", "Width", GUICtrlRead($hWidth))
	IniWrite(@ScriptDir & "\Settings\BatchDPG.ini", "Video", "Height", GUICtrlRead($hHeight))
	IniWrite(@ScriptDir & "\Settings\BatchDPG.ini", "Video", "VideoBitrate", GUICtrlRead($hVideoBitrate))
	IniWrite(@ScriptDir & "\Settings\BatchDPG.ini", "Video", "VideoBitrateMax", GUICtrlRead($hVideoBitrateMax))
	IniWrite(@ScriptDir & "\Settings\BatchDPG.ini", "Video", "Passes", GUICtrlRead($hPasses))
	IniWrite(@ScriptDir & "\Settings\BatchDPG.ini", "Video", "Resizer", GUICtrlRead($hResizer))
	IniWrite(@ScriptDir & "\Settings\BatchDPG.ini", "Audio", "AudioBitrate", GUICtrlRead($hAudioBitrate))
	IniWrite(@ScriptDir & "\Settings\BatchDPG.ini", "Audio", "Samplerate", GUICtrlRead($hSamplerate))
	IniWrite(@ScriptDir & "\Settings\BatchDPG.ini", "Audio", "Mode", GUICtrlRead($hMode))
	IniWrite(@ScriptDir & "\Settings\BatchDPG.ini", "Audio", "Normalize", BitAnd(GUICtrlRead($hNormalize),$GUI_CHECKED))
	IniWrite(@ScriptDir & "\Settings\BatchDPG.ini", "Other", "AfterEncoding", GUICtrlRead($hAfterEncoding))
	IniWrite(@ScriptDir & "\Settings\BatchDPG.ini", "Other", "ProcessPriority", GUICtrlRead($hProcessPriority))
	IniWrite(@ScriptDir & "\Settings\BatchDPG.ini", "Mod", "KeepAspectRatio", BitAnd(GUICtrlRead($hKeepAspectRatio),$GUI_CHECKED))	
	IniWrite(@ScriptDir & "\Settings\BatchDPG.ini", "Mod", "SubFont", GUICtrlRead($hSubFont))	
	IniWrite(@ScriptDir & "\Settings\BatchDPG.ini", "Mod", "SubSize", GUICtrlRead($hSubSize))	
	IniWrite(@ScriptDir & "\Settings\BatchDPG.ini", "Mod", "SubShadow", GUICtrlRead($hSubShadow))	
	IniWrite(@ScriptDir & "\Settings\BatchDPG.ini", "Mod", "SubPos", GUICtrlRead($hSubPos))	
	IniWrite(@ScriptDir & "\Settings\BatchDPG.ini", "Mod", "AddParam", GUICtrlRead($hAddParam))	
	IniWrite(@ScriptDir & "\Settings\BatchDPG.ini", "Mod", "EncodingMethod", GUICtrlRead($hEncodingMethod))	
	IniWrite(@ScriptDir & "\Settings\BatchDPG.ini", "Mod", "AllowedMediaExtensions", $sAllowedMediaExtensions)	
	IniWrite(@ScriptDir & "\Settings\BatchDPG.ini", "Mod", "AllowedSubtitleExtensions", $sAllowedSubtitleExtensions)	
	IniWrite(@ScriptDir & "\Settings\BatchDPG.ini", "Mod", "AllowedAudioExtensions", $sAllowedAudioExtensions)	
EndFunc

Func _Stop()
	While 1
	ProcessClose("bepipe.exe")
	ProcessClose("twolame.exe")
	ProcessClose("mencoder.exe")
		if not ProcessExists("bepipe.exe") and not ProcessExists("twolame.exe") and not ProcessExists("mencoder.exe") then
			GUICtrlSetData($hStatus,$lEncodingStop)
			GUICtrlSetData($hProgress,0)
			$IsStopped = true
			$IsUserStop = true
			ExitLoop
		EndIf
	WEnd
EndFunc

Func _IsValidExt($sPath)
    For $i = 1 To $FilesAllowedMask[0]
        If StringRight($sPath, 4) = $FilesAllowedMask[$i] And _
            Not StringInStr(FileGetAttrib($sPath), $FilesAllowedMask[$i]) Then Return True
    Next
    Return False
EndFunc

Func WM_DROPFILES_FUNC($hWnd, $msgID, $wParam, $lParam)
    Local $nSize, $pFileName
    Local $nAmt = DllCall("shell32.dll", "int", "DragQueryFile", "hwnd", $wParam, "int", 0xFFFFFFFF, "ptr", 0, "int", 255)
    For $i = 0 To $nAmt[0] - 1
        $nSize = DllCall("shell32.dll", "int", "DragQueryFile", "hwnd", $wParam, "int", $i, "ptr", 0, "int", 0)
        $nSize = $nSize[0] + 1
        $pFileName = DllStructCreate("char[" & $nSize & "]")
        DllCall("shell32.dll", "int", "DragQueryFile", "hwnd", $wParam, "int", $i, "ptr", _
            DllStructGetPtr($pFileName), "int", $nSize)
        ReDim $DropFilesArr[$i + 2]
        $DropFilesArr[$i+1] = DllStructGetData($pFileName, 1)
        $pFileName = 0
    Next
    $DropFilesArr[0] = UBound($DropFilesArr)-1
	$dragnum = $dragnum + 1
EndFunc

Func _Preview()
	$arraytmp = ""
	$arraytmp = _GUICtrlListView_GetItemTextArray($hListView,Number($preview))
	$media = $arraytmp[1]
	$audio = $arraytmp[2]
	$sub = $arraytmp[3]
	$temp = string($arraytmp[4])
	$output = $arraytmp[5]
	$framerate = Number($arraytmp[6])
	$profile = Number($arraytmp[7])
	$width = Number($arraytmp[8])
	$height = Number($arraytmp[9])
	$videoBitrate = Number($arraytmp[10])
	$videoBitrateMax = Number($arraytmp[11])
	$passes = Number($arraytmp[12])
	$resizer = $arraytmp[13]
	$audioBitrate = Number($arraytmp[14])
	$samplerate = Number($arraytmp[15])
	$mode = Number($arraytmp[16])
	$normalize = Number($arraytmp[17])
	$keepaspectratio = Number($arraytmp[18])
	$subfont = $arraytmp[19]
	$subsize = Number($arraytmp[20])
	$subshadow = Number($arraytmp[21])
	$subpos = Number($arraytmp[22])
	$addparam = $arraytmp[23]
	$encodingmethod = $arraytmp[24]
	
	if $encodingmethod = 1 Then $framerate = 15
		
	
	
	if $keepaspectratio = 1 Then
		$sMediaInfo = Run(@ComSpec & " /c " & FileGetShortName(@ScriptDir & "\bin\MediaInfo.exe") & " -f """ & $media & """", "", "", 2)
		$sMediaStats = ""
		While 1
			$sMediaStats &= StdoutRead($sMediaInfo)
			If @error Then ExitLoop
		WEnd
		$sAspectRatio = Number(StringTrimLeft($sMediaStats, StringInStr($sMediaStats, "Aspect ratio") + 22))
		
		If $sAspectRatio Then
			$width = _Min(256, 16 * Round(12 * $sAspectRatio))
			$height = _Min(192, 16 * Round(16 / $sAspectRatio))
		EndIf
	EndIF
	GUICtrlSetData($hStatus, $lStartPreview)
	Dim $mediaDrive, $mediaDir, $mediaName, $mediaExt
	_PathSplit($media, $mediaDrive, $mediaDir, $mediaName, $mediaExt)

	If FileExists($temp) Then
		If StringRight($temp, 1) <> "\" Then $temp &= "\"
		$temp = $temp & $mediaName & $mediaExt
	Else
		$temp = $media
	EndIf

	If FileExists($output) Then
		If StringRight($output, 1) <> "\" Then $output &= "\"
		$output = $output & $mediaName & $mediaExt
	Else
		$output = $media
	EndIf


	If $framerate Then
		$framerate = Round(_Min($framerate, 60) * 256) / 256
	Else
		$sMediaStats = ""
		$sMediaInfo = Run(@ComSpec & " /c " & FileGetShortName(@ScriptDir & "\bin\MediaInfo.exe") & " -f """ & $media & """", "", "", 2)
		While 1
			$sMediaStats &= StdoutRead($sMediaInfo)
			If @error Then ExitLoop
		WEnd
		$framerateSource = Number(StringTrimLeft($sMediaStats, StringInStr($sMediaStats, "Frame rate") + 22))
		If Not $framerateSource Then $framerateSource = 60
		$framerate = _Min(Round(589824 / $width / $height + 8), $framerateSource)
	EndIf

	$videoBitrate = Round($videoBitrate * 60 / $framerate)
	$videoBitrateMax = Round($videoBitrateMax * 60 / $framerate)

	

	If $profile = 0 Then
		$mencoder = ":mbd=2:trell:cbp:mv0:vmax_b_frames=2:cmp=6:subcmp=6:precmp=6:dia=4:predia=4:vb_strategy=2:bidir_refine=4:mv0_threshold=0:last_pred=3:preme=2"
	ElseIf $profile = 1 Then
		$mencoder = ":mbd=2:trell:cbp:mv0:vmax_b_frames=1:cmp=6:subcmp=6:precmp=6:dia=3:predia=3"
	ElseIf $profile = 2 Then
		$mencoder = ":mbd=2:trell:cbp:mv0:vmax_b_frames=1:cmp=2:subcmp=2:precmp=2"
	Else
		$mencoder = ""
	EndIf

	If $mode = 0 Then
		$twoLame = "-m j"
	Else
		$twoLame = "-m m -a"
	EndIf

			$threads = ""


	$aviSynthFile = FileOpen(@ScriptDir & "\Settings\BatchDPG_Script.avs", 0)
	$aviSynth = FileOpen($temp & ".avs", 2)

	While 1
		If $aviSynth <> -1 Then
			$line = FileReadLine($aviSynthFile)
				if @error = -1 then ExitLoop
				FileWriteLine($aviSynth,_ProcessAVS($line,True,$media,$audio,$sub,$temp,$output,$framerate,$profile,$width,$height,$videobitrate,$videobitratemax,$passes,$resizer,$audiobitrate,$samplerate,$mode,$normalize,$keepaspectratio,$subfont,$subsize,$subshadow,$subpos,$addparam,$encodingmethod))
		Else
			ExitLoop
		EndIf
	WEnd
	
	FileClose($aviSynth)	
	
	FileWriteLine($aviSynth, "DirectShowSource(""" & $media & """,convertfps=true)")
	If FileExists($sub) Then FileWriteLine($aviSynth, "LoadPlugin(""" & @ScriptDir & "\Bin\VSFilter.dll"")")
	If FileExists($audio) Then FileWriteLine($aviSynth, "AudioDub(last,DirectShowSource(""" & $audio & """))")
	FileWriteLine($aviSynth, $resizer & "Resize(" & $width & "," & $height & ")")
	If FileExists($sub) Then FileWriteLine($aviSynth, "TextSub(""" & $sub & """)")

	FileClose($aviSynth)	
	
	if FileExists($sub) then
		
	$substylefile = FileOpen(@ScriptDir & "\Settings\BatchDPG_Subtitle.style", 0)
	$subStyle = FileOpen($sub & ".style", 2)
	
	While 1
		If $substylefile <> -1 Then
			$line = FileReadLine($substylefile)
				if @error = -1 then ExitLoop
				FileWriteLine($subStyle,_ProcessSubtitle($line,$subfont,$subsize,$subshadow,$subpos))
		Else
			ExitLoop
		EndIf
	WEnd
	FileClose($subStyle)

		
	EndIf
	
 	RunWait( FileGetShortName(@ScriptDir & "\Bin\mplayer.exe") & " """ & $temp & ".avs" & """")
	GUICtrlSetData($hStatus, "")
	FileDelete($sub & ".style")
	FileDelete($temp & ".avs")
	
EndFunc

Func SpecialEvent()
    GuiSetState(@SW_Show)
    TraySetState(2) ; hide
EndFunc

Func _SaveList()
	
	$SavedListfile = FileOpen(@ScriptDir & "\Settings\BatchDPG_SavedList.dat", 2)
	For $i = 1 to _GUICtrlListView_GetItemCount($hListView)
		$arraytmp = ""
		$arraytmp = _GUICtrlListView_GetItemTextArray($hListView,$i - 1)
		$media = $arraytmp[1]
		$audio = $arraytmp[2]
		$sub = $arraytmp[3]
		$temp = string($arraytmp[4])
		$output = $arraytmp[5]
		$framerate = Number($arraytmp[6])
		$profile = Number($arraytmp[7])
		$width = Number($arraytmp[8])
		$height = Number($arraytmp[9])
		$videoBitrate = Number($arraytmp[10])
		$videoBitrateMax = Number($arraytmp[11])
		$passes = Number($arraytmp[12])
		$resizer = $arraytmp[13]
		$audioBitrate = Number($arraytmp[14])
		$samplerate = Number($arraytmp[15])
		$mode = Number($arraytmp[16])
		$normalize = Number($arraytmp[17])
		$keepaspectratio = Number($arraytmp[18])
		$subfont = $arraytmp[19]
		$subsize = Number($arraytmp[20])
		$subshadow = Number($arraytmp[21])
		$subpos = Number($arraytmp[22])
		$addparam = $arraytmp[23]
		$encodingmethod = $arraytmp[24]
		$isthereissub = String($arraytmp[25])
		
		FileWrite($SavedListfile,$media & "|" & $audio & "|" & $sub & "|" & $temp & "|" & $output & "|" & $framerate & "|" & $profile & "|" & $width & "|" & $height & "|" & _
		$videoBitrate & "|" & $videoBitrateMax & "|" & $passes & "|" & $resizer & "|" & $audioBitrate & "|" & $samplerate & "|" & $mode & "|" & $normalize & "|" & _
		$keepaspectratio & "|" & $subfont & "|" & $subsize & "|" & $subshadow & "|" & $subpos & "|" & $addparam & "|" & $encodingmethod & "|" & $isthereissub & @CRLF)
	Next
	FileClose($SavedListfile)

EndFunc
Func _ProcessSubtitle($str,$prsubfont,$prsubsize,$prsubshadow,$prsubpos)
	$str = StringReplace($str,"%SUBFONT%",$prsubfont)
	$str = StringReplace($str,"%SUBSIZE%",$prsubsize)
	$str = StringReplace($str,"%SUBSHADOW%",$prsubshadow)
	$str = StringReplace($str,"%SUBPOS%",$prsubpos)
	return $str
EndFunc

Func _ProcessAVS($str,$ispreview,$prmedia,$praudio,$prsub,$prtemp,$proutput,$prframerate,$prprofile,$prwidth,$prheight,$prvideobitrate,$prvideobitratemax,$prpasses,$prresizer,$praudiobitrate,$prsamplerate,$prmode,$prnormalize,$prkeepaspectratio,$prsubfont,$prsubsize,$prsubshadow,$prsubpos,$praddparam,$prencodingmethod)
	$str = StringReplace($str,"%BATCHDPGDIR%",@ScriptDir)
	$str = StringReplace($str,"%MEDIA%",$prmedia)
	$str = StringReplace($str,"%AUDIO%",$praudio)
	$str = StringReplace($str,"%SUB%",$prsub)
	$str = StringReplace($str,"%TEMP%",$prtemp)
	$str = StringReplace($str,"%OUTPUT%",$proutput)
	$str = StringReplace($str,"%FRAMERATE%",$prframerate)
	$str = StringReplace($str,"%PROFILE%",$prprofile)
	$str = StringReplace($str,"%WIDTH%",$prwidth)
	$str = StringReplace($str,"%HEIGHT%",$prheight)
	$str = StringReplace($str,"%VIDEOBITRATE%",$prvideobitrate)
	$str = StringReplace($str,"%VIDEOBITRATEMAX%",$prvideobitratemax)
	$str = StringReplace($str,"%PASSES%",$prpasses)
	$str = StringReplace($str,"%RESIZER%",$prresizer)
	$str = StringReplace($str,"%AUDIOBITRATE%",$praudiobitrate)
	$str = StringReplace($str,"%SAMPLERATE%",$prsamplerate)
	$str = StringReplace($str,"%MODE%",$prmode)
	$str = StringReplace($str,"%NORMALIZE%",$prnormalize)
	$str = StringReplace($str,"%KEEPASPECTRATIO%",$prkeepaspectratio)
	$str = StringReplace($str,"%SUBFONT%",$prsubfont)
	$str = StringReplace($str,"%SUBSIZE%",$prsubsize)
	$str = StringReplace($str,"%SUBSHADOW%",$prsubshadow)
	$str = StringReplace($str,"%SUBPOS%",$prsubpos)
	$str = StringReplace($str,"%ADDPARAM%",$praddparam)
	$str = StringReplace($str,"%ENCODINGMETHOD%",$prencodingmethod)
	
	
	if StringInStr($str,"[{!PREVIEWONLY!}]") And $IsPreview Then
		$str = StringReplace($str,"[{!PREVIEWONLY!}]","[{!PREVIEW!}]")
	ElseIf StringInStr($str,"[{!PREVIEWONLY!}]") And Not $IsPreview Then
		$str = ""
	EndIf

	
	if StringInStr($str,"[{!SUB!}]") And FileExists($prsub) Then
		$str = StringReplace($str,"[{!SUB!}]","")
	ElseIf StringInStr($str,"[{!SUB!}]") And Not FileExists($prsub) Then
		$str = ""
	EndIf

	
	if StringInStr($str,"[{!AUDIO!}]") And FileExists($praudio) Then
		$str = StringReplace($str,"[{!AUDIO!}]","")
	ElseIf StringInStr($str,"[{!AUDIO!}]") And Not FileExists($praudio) Then
		$str = ""
	EndIf

	
	if StringInStr($str,"[{!METHOD1!}]") And $prencodingmethod == 0 Then
		$str = StringReplace($str,"[{!METHOD1!}]","")
	ElseIf StringInStr($str,"[{!METHOD1!}]") And $prencodingmethod == 1 Then
		$str = ""
	EndIf

	
	if StringInStr($str,"[{!METHOD2!}]") And $prencodingmethod == 1 Then
		$str = StringReplace($str,"[{!METHOD2!}]","")
	ElseIf StringInStr($str,"[{!METHOD2!}]") And $prencodingmethod == 0 Then
		$str = ""
	EndIf

	
	if StringInStr($str,"[{!SAMPLERATE_32768!}]") And $prsamplerate == 32768 Then
		$str = StringReplace($str,"[{!SAMPLERATE_32768!}]","")
	ElseIf StringInStr($str,"[{!SAMPLERATE_32768!}]") And Not $prsamplerate <> 32768 Then
		$str = ""
	EndIf

	
	if StringInStr($str,"[{!NORMALIZE!}]") And Int($prnormalize) Then
		$str = StringReplace($str,"[{!NORMALIZE!}]","")
	ElseIf StringInStr($str,"[{!NORMALIZE!}]") And Not Int($prnormalize) Then
		$str = ""
	EndIf
	
	$calci = 0
	
	while 1
		if StringInStr($str,"[calc" & $calci & "]") == 0 then ExitLoop
		$calcdata = StringMid($str,StringInStr($str,"[calc" & $calci & "]") + 7,StringInStr($str,"[/calc" & $calci & "]") - StringInStr($str,"[calc" & $calci & "]") - 7)
		$repdata = "[calc" & $calci & "]" & $calcdata & "[/calc" & $calci & "]"
		$calcdata = StringSplit($calcdata,",")
		
		if $calcdata[2] == "+" Then
			$calcdata = $calcdata[1] + $calcdata[3]
		ElseIf $calcdata[2] == "-" Then
			$calcdata = $calcdata[1] - $calcdata[3]
		ElseIf $calcdata[2] == "*" Then
			$calcdata = $calcdata[1] * $calcdata[3]
		ElseIf $calcdata[2] == "/" Then
			$calcdata = $calcdata[1] / $calcdata[3]
		ElseIf $calcdata[2] == "^" Then
			$calcdata = $calcdata[1] ^ $calcdata[3]
		EndIf
		$calci = $calci + 1
		$str = StringReplace($str,$repdata,$calcdata)
	WEnd
	
	
	if StringInStr($str,"[{!PREVIEW!}]") And $IsPreview Then
		$str = StringReplace($str,"[{!PREVIEW!}]","")
	ElseIf Not StringInStr($str,"[{!PREVIEW!}]") And $IsPreview Then
		$str = ""
	ElseIf StringInStr($str,"[{!PREVIEW!}]") And Not $IsPreview Then
		$str = StringReplace($str,"[{!PREVIEW!}]","")
	EndIf
	
	
	
	return $str
EndFunc
;===============================================================================
; Function Name:    _GUICtrlListView_MoveItems()
; Description:      Move selected item(s) in ListView Up or Down.
;
; Parameter(s):     $hWnd               - Window handle of ListView control (can be a Title).
;                   $vListView          - The ID/Handle/Class of ListView control.
;                   $iDirection         - [Optional], define in what direction item(s) will move:
;                                            1 (default) - item(s) will move Next.
;                                           -1 item(s) will move Back.
;                   $sIconsFile         - Icon file to set image for the items (only for internal usage).
;                   $iIconID_Checked    - Icon ID in $sIconsFile for checked item(s).
;                   $iIconID_UnChecked  - Icon ID in $sIconsFile for Unchecked item(s).
;
; Requirement(s):   #include <GuiListView.au3>, AutoIt 3.2.10.0.
;
; Return Value(s):  On seccess - Move selected item(s) Next/Back.
;                   On failure - Return "" (empty string) and set @error as following:
;                                                                  1 - No selected item(s).
;                                                                  2 - $iDirection is wrong value (not 1 and not -1).
;                                                                  3 - Item(s) can not be moved, reached last/first item.
;
; Note(s):          * This function work with external ListView Control as well.
;                   * If you select like 15-20 (or more) items, moving them can take a while sad.gif (depends on how many items moved).
;
; Author(s):        G.Sandler a.k.a CreatoR (http://creator-lab.ucoz.ru)
;===============================================================================
Func _GUICtrlListView_MoveItems($hWnd, $vListView, $iDirection=1, $sIconsFile="", $iIconID_Checked=0, $iIconID_UnChecked=0)
    Local $hListView = $vListView
    If Not IsHWnd($hListView) Then $hListView = ControlGetHandle($hWnd, "", $hListView)
   
    Local $aSelected_Indices = _GUICtrlListView_GetSelectedIndices($hListView, 1)
    If UBound($aSelected_Indices) < 2 Then Return SetError(1, 0, "")
    If $iDirection <> 1 And $iDirection <> -1 Then Return SetError(2, 0, "")
   
    Local $iTotal_Items = ControlListView($hWnd, "", $hListView, "GetItemCount")
    Local $iTotal_Columns = ControlListView($hWnd, "", $hListView, "GetSubItemCount")
   
    Local $iUbound = UBound($aSelected_Indices)-1, $iNum = 1, $iStep = 1
    Local $iCurrent_Index, $iUpDown_Index, $sCurrent_ItemText, $sUpDown_ItemText
    Local $iCurrent_Index, $iCurrent_CheckedState, $iUpDown_CheckedState
   
    If ($iDirection = -1 And $aSelected_Indices[1] = 0) Or _
        ($iDirection = 1 And $aSelected_Indices[$iUbound] = $iTotal_Items-1) Then Return SetError(3, 0, "")
   
    ControlListView($hWnd, "", $hListView, "SelectClear")
   
    Local $aOldSelected_IDs[1]
    Local $iIconsFileExists = FileExists($sIconsFile)
   
    If $iIconsFileExists Then
        For $i = 1 To $iUbound
            ReDim $aOldSelected_IDs[UBound($aOldSelected_IDs)+1]
            _GUICtrlListView_SetItemSelected($hListView, $aSelected_Indices[$i], True)
            $aOldSelected_IDs[$i] = GUICtrlRead($vListView)
            _GUICtrlListView_SetItemSelected($hListView, $aSelected_Indices[$i], False)
        Next
        ControlListView($hWnd, "", $hListView, "SelectClear")
    EndIf
   
    If $iDirection = 1 Then
        $iNum = $iUbound
        $iUbound = 1
        $iStep = -1
    EndIf
   
    For $i = $iNum To $iUbound Step $iStep
        $iCurrent_Index = $aSelected_Indices[$i]
        $iUpDown_Index = $aSelected_Indices[$i]+1
        If $iDirection = -1 Then $iUpDown_Index = $aSelected_Indices[$i]-1
       
        $iCurrent_CheckedState = _GUICtrlListView_GetItemChecked($hListView, $iCurrent_Index)
        $iUpDown_CheckedState = _GUICtrlListView_GetItemChecked($hListView, $iUpDown_Index)
       
        _GUICtrlListView_SetItemSelected($hListView, $iUpDown_Index)
       
        For $j = 0 To $iTotal_Columns-1
            $sCurrent_ItemText = _GUICtrlListView_GetItemText($hListView, $iCurrent_Index, $j)
            $sUpDown_ItemText = _GUICtrlListView_GetItemText($hListView, $iUpDown_Index, $j)
           
            _GUICtrlListView_SetItemText($hListView, $iUpDown_Index, $sCurrent_ItemText, $j)
            _GUICtrlListView_SetItemText($hListView, $iCurrent_Index, $sUpDown_ItemText, $j)
        Next
       
        _GUICtrlListView_SetItemChecked($hListView, $iUpDown_Index, $iCurrent_CheckedState)
        _GUICtrlListView_SetItemChecked($hListView, $iCurrent_Index, $iUpDown_CheckedState)
       
        If $iIconsFileExists Then
            If $iCurrent_CheckedState = 1 Then
                GUICtrlSetImage(GUICtrlRead($vListView), $sIconsFile, $iIconID_Checked, 0)
            Else
                GUICtrlSetImage(GUICtrlRead($vListView), $sIconsFile, $iIconID_UnChecked, 0)
            EndIf
           
            If $iUpDown_CheckedState = 1 Then
                GUICtrlSetImage($aOldSelected_IDs[$i], $sIconsFile, $iIconID_Checked, 0)
            Else
                GUICtrlSetImage($aOldSelected_IDs[$i], $sIconsFile, $iIconID_UnChecked, 0)
            EndIf
        EndIf
       
        _GUICtrlListView_SetItemSelected($hListView, $iUpDown_Index, 0)
    Next
   
    For $i = 1 To UBound($aSelected_Indices)-1
        $iUpDown_Index = $aSelected_Indices[$i]+1
        If $iDirection = -1 Then $iUpDown_Index = $aSelected_Indices[$i]-1
        _GUICtrlListView_SetItemSelected($hListView, $iUpDown_Index)
    Next
EndFunc
