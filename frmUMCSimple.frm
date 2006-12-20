VERSION 5.00
Object = "{BDC217C8-ED16-11CD-956C-0000C04E4C0A}#1.1#0"; "TABCTL32.OCX"
Begin VB.Form frmUMCSimple 
   BackColor       =   &H00FF8080&
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Unique Molecular Mass Classes Definition"
   ClientHeight    =   6390
   ClientLeft      =   45
   ClientTop       =   405
   ClientWidth     =   9270
   ControlBox      =   0   'False
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   6390
   ScaleWidth      =   9270
   ShowInTaskbar   =   0   'False
   StartUpPosition =   1  'CenterOwner
   Begin VB.CommandButton cmdResetToDefaults 
      Caption         =   "Set to Defaults"
      Height          =   375
      Left            =   120
      TabIndex        =   19
      Top             =   4950
      Width           =   1455
   End
   Begin VB.Frame fraDrawType 
      BackColor       =   &H00FF8080&
      Caption         =   "UMC  Draw Type"
      Height          =   735
      Left            =   120
      TabIndex        =   16
      Top             =   4080
      Width           =   2415
      Begin VB.ComboBox cmbUMCDrawType 
         Height          =   315
         ItemData        =   "frmUMCSimple.frx":0000
         Left            =   120
         List            =   "frmUMCSimple.frx":000D
         Style           =   2  'Dropdown List
         TabIndex        =   17
         Top             =   300
         Width           =   2175
      End
   End
   Begin VB.CommandButton cmdReport 
      Caption         =   "&Report"
      Height          =   375
      Left            =   960
      TabIndex        =   2
      ToolTipText     =   "Generates various statistics on current UMC"
      Top             =   5400
      Width           =   735
   End
   Begin VB.Frame fraTol 
      BackColor       =   &H00FF8080&
      Caption         =   "Molecular Mass Tolerance"
      Height          =   1095
      Left            =   120
      TabIndex        =   11
      Top             =   2880
      Width           =   2415
      Begin VB.TextBox txtTol 
         Alignment       =   1  'Right Justify
         Height          =   285
         Left            =   240
         TabIndex        =   13
         Text            =   "10"
         Top             =   520
         Width           =   735
      End
      Begin VB.OptionButton optTolType 
         BackColor       =   &H00FF8080&
         Caption         =   "&Dalton"
         Height          =   255
         Index           =   1
         Left            =   1200
         TabIndex        =   15
         Top             =   666
         Width           =   855
      End
      Begin VB.OptionButton optTolType 
         BackColor       =   &H00FF8080&
         Caption         =   "&ppm"
         Height          =   255
         Index           =   0
         Left            =   1200
         TabIndex        =   14
         Top             =   333
         Value           =   -1  'True
         Width           =   735
      End
      Begin VB.Label Label2 
         BackColor       =   &H00FF8080&
         BackStyle       =   0  'Transparent
         Caption         =   "Tolerance:"
         Height          =   255
         Left            =   240
         TabIndex        =   12
         Top             =   280
         Width           =   735
      End
   End
   Begin VB.Frame fraMWField 
      BackColor       =   &H00FF8080&
      Caption         =   "Molecular Mass Field"
      Height          =   1335
      Left            =   120
      TabIndex        =   7
      Top             =   1440
      Width           =   2415
      Begin VB.OptionButton optMWField 
         BackColor       =   &H00FF8080&
         Caption         =   "&The Most Abundant"
         Height          =   255
         Index           =   2
         Left            =   240
         TabIndex        =   10
         Top             =   920
         Width           =   1815
      End
      Begin VB.OptionButton optMWField 
         BackColor       =   &H00FF8080&
         Caption         =   "&Monoisotopic"
         Height          =   255
         Index           =   1
         Left            =   240
         TabIndex        =   9
         Top             =   600
         Value           =   -1  'True
         Width           =   1335
      End
      Begin VB.OptionButton optMWField 
         BackColor       =   &H00FF8080&
         Caption         =   "A&verage"
         Height          =   255
         Index           =   0
         Left            =   240
         TabIndex        =   8
         Top             =   280
         Width           =   1335
      End
   End
   Begin VB.Frame fraUMCScope 
      BackColor       =   &H00FF8080&
      Caption         =   "Definition Scope"
      Height          =   975
      Left            =   120
      TabIndex        =   4
      Top             =   360
      Width           =   2415
      Begin VB.OptionButton optDefScope 
         BackColor       =   &H00FF8080&
         Caption         =   "&Current View"
         Height          =   255
         Index           =   1
         Left            =   240
         TabIndex        =   6
         Top             =   600
         Value           =   -1  'True
         Width           =   1455
      End
      Begin VB.OptionButton optDefScope 
         BackColor       =   &H00FF8080&
         Caption         =   "&All Data Points"
         Height          =   255
         Index           =   0
         Left            =   240
         TabIndex        =   5
         Top             =   280
         Width           =   1455
      End
   End
   Begin VB.CommandButton cmdCancel 
      Caption         =   "&Close"
      Default         =   -1  'True
      Height          =   375
      Left            =   1800
      TabIndex        =   1
      Top             =   5400
      Width           =   735
   End
   Begin VB.CommandButton cmdOK 
      Caption         =   "&UMC"
      Height          =   375
      Left            =   120
      TabIndex        =   0
      ToolTipText     =   "Generates UM Classes and returns number of it"
      Top             =   5400
      Width           =   735
   End
   Begin VB.CommandButton cmdAbortProcessing 
      Caption         =   "Abort!"
      Height          =   375
      Left            =   120
      TabIndex        =   87
      Top             =   5400
      Width           =   735
   End
   Begin TabDlg.SSTab tbsTabStrip 
      Height          =   5715
      Left            =   2760
      TabIndex        =   18
      Top             =   360
      Width           =   4935
      _ExtentX        =   8705
      _ExtentY        =   10081
      _Version        =   393216
      Style           =   1
      Tab             =   1
      TabHeight       =   520
      BackColor       =   16744576
      TabCaption(0)   =   "UMC Definition"
      TabPicture(0)   =   "frmUMCSimple.frx":003D
      Tab(0).ControlEnabled=   0   'False
      Tab(0).Control(0)=   "Label3(2)"
      Tab(0).Control(1)=   "Label1(2)"
      Tab(0).Control(2)=   "Label1(1)"
      Tab(0).Control(3)=   "Label3(1)"
      Tab(0).Control(4)=   "Label3(0)"
      Tab(0).Control(5)=   "Label1(0)"
      Tab(0).Control(6)=   "lblChargeStateAbuType"
      Tab(0).Control(7)=   "txtInterpolateMaxGapSize"
      Tab(0).Control(8)=   "chkInterpolateMissingIons"
      Tab(0).Control(9)=   "chkAllowSharing"
      Tab(0).Control(10)=   "cmbUMCMW"
      Tab(0).Control(11)=   "cmbUMCAbu"
      Tab(0).Control(12)=   "txtHoleSize"
      Tab(0).Control(13)=   "txtHoleNum"
      Tab(0).Control(14)=   "cmbCountType"
      Tab(0).Control(15)=   "chkUseMostAbuChargeStateStatsForClassStats"
      Tab(0).Control(16)=   "cboChargeStateAbuType"
      Tab(0).ControlCount=   17
      TabCaption(1)   =   "Auto Refine Options"
      TabPicture(1)   =   "frmUMCSimple.frx":0059
      Tab(1).ControlEnabled=   -1  'True
      Tab(1).Control(0)=   "fraSplitUMCsOptions"
      Tab(1).Control(0).Enabled=   0   'False
      Tab(1).Control(1)=   "fraOptionFrame(10)"
      Tab(1).Control(1).Enabled=   0   'False
      Tab(1).ControlCount=   2
      TabCaption(2)   =   "Adv Class Stats"
      TabPicture(2)   =   "frmUMCSimple.frx":0075
      Tab(2).ControlEnabled=   0   'False
      Tab(2).Control(0)=   "fraClassAbundanceTopX"
      Tab(2).Control(1)=   "fraClassMassTopX"
      Tab(2).ControlCount=   2
      Begin VB.Frame fraOptionFrame 
         Height          =   2700
         Index           =   10
         Left            =   120
         TabIndex        =   88
         Top             =   360
         Width           =   4545
         Begin VB.TextBox txtHiCnt 
            Alignment       =   1  'Right Justify
            Height          =   285
            Left            =   3000
            TabIndex        =   47
            Text            =   "500"
            Top             =   1200
            Width           =   495
         End
         Begin VB.CheckBox chkRemoveHiCnt 
            Caption         =   "Remove cls. with length over"
            Height          =   255
            Left            =   240
            TabIndex        =   46
            Top             =   1200
            Width           =   2535
         End
         Begin VB.TextBox txtLoCnt 
            Alignment       =   1  'Right Justify
            Height          =   285
            Left            =   3000
            TabIndex        =   44
            Text            =   "3"
            Top             =   880
            Width           =   495
         End
         Begin VB.CheckBox chkRemoveLoCnt 
            Caption         =   "Remove cls. with less than"
            Height          =   255
            Left            =   240
            TabIndex        =   43
            Top             =   880
            Width           =   2295
         End
         Begin VB.TextBox txtHiAbuPct 
            Alignment       =   1  'Right Justify
            Height          =   285
            Left            =   3000
            TabIndex        =   41
            Text            =   "30"
            Top             =   560
            Width           =   495
         End
         Begin VB.CheckBox chkRemoveHiAbu 
            Caption         =   "Remove high intensity classes"
            Height          =   255
            Left            =   240
            TabIndex        =   40
            Top             =   560
            Width           =   2550
         End
         Begin VB.TextBox txtLoAbuPct 
            Alignment       =   1  'Right Justify
            Height          =   285
            Left            =   3000
            TabIndex        =   38
            Text            =   "30"
            Top             =   240
            Width           =   495
         End
         Begin VB.CheckBox chkRemoveLoAbu 
            Caption         =   "Remove low intensity classes"
            Height          =   255
            Left            =   240
            TabIndex        =   37
            Top             =   240
            Width           =   2550
         End
         Begin VB.CheckBox chkRefineUMCLengthByScanRange 
            Caption         =   "Test UMC length using scan range"
            Height          =   375
            Left            =   240
            TabIndex        =   55
            ToolTipText     =   "If True, then considers scan range for the length tests; otherwise, considers member count"
            Top             =   2200
            Value           =   1  'Checked
            Width           =   1695
         End
         Begin VB.TextBox txtAutoRefineMinimumMemberCount 
            Alignment       =   1  'Right Justify
            Height          =   285
            Left            =   3480
            TabIndex        =   57
            Text            =   "3"
            Top             =   2300
            Width           =   495
         End
         Begin VB.TextBox txtPercentMaxAbuToUseToGaugeLength 
            Alignment       =   1  'Right Justify
            Height          =   285
            Left            =   3000
            TabIndex        =   53
            Text            =   "33"
            Top             =   1840
            Width           =   495
         End
         Begin VB.CheckBox chkRemoveMaxLengthPctAllScans 
            Caption         =   "Remove cls. with length over"
            Height          =   255
            Left            =   240
            TabIndex        =   49
            Top             =   1520
            Width           =   2535
         End
         Begin VB.TextBox txtMaxLengthPctAllScans 
            Alignment       =   1  'Right Justify
            Height          =   285
            Left            =   3000
            TabIndex        =   50
            Text            =   "20"
            Top             =   1520
            Width           =   495
         End
         Begin VB.Label lblAutoRefineLengthLabel 
            Caption         =   "members"
            Height          =   255
            Index           =   1
            Left            =   3600
            TabIndex        =   48
            Top             =   1230
            Width           =   900
         End
         Begin VB.Label lblAutoRefineLengthLabel 
            Caption         =   "members"
            Height          =   255
            Index           =   0
            Left            =   3600
            TabIndex        =   45
            Top             =   915
            Width           =   900
         End
         Begin VB.Label lblAutoRefineMinimumMemberCount 
            Caption         =   "Minimum member count:"
            Height          =   375
            Left            =   2280
            TabIndex        =   56
            Top             =   2200
            Width           =   1125
         End
         Begin VB.Label lblPercentMaxAbuToUseToGaugeLength 
            Caption         =   "Percent max abu for gauging width"
            Height          =   240
            Left            =   360
            TabIndex        =   52
            Top             =   1845
            Width           =   2565
         End
         Begin VB.Label lblAutoRefineLengthLabel 
            Caption         =   "%"
            Height          =   255
            Index           =   2
            Left            =   3600
            TabIndex        =   54
            Top             =   1870
            Width           =   285
         End
         Begin VB.Label lblAutoRefineLengthLabel 
            Caption         =   "% all scans"
            Height          =   255
            Index           =   3
            Left            =   3600
            TabIndex        =   51
            Top             =   1545
            Width           =   855
         End
         Begin VB.Label lblAutoRefineLengthLabel 
            Caption         =   "%"
            Height          =   255
            Index           =   4
            Left            =   3600
            TabIndex        =   39
            Top             =   270
            Width           =   270
         End
         Begin VB.Label lblAutoRefineLengthLabel 
            Caption         =   "%"
            Height          =   255
            Index           =   5
            Left            =   3600
            TabIndex        =   42
            Top             =   590
            Width           =   270
         End
      End
      Begin VB.Frame fraClassAbundanceTopX 
         Caption         =   "Class Abundance Top X"
         Height          =   1215
         Left            =   -74880
         TabIndex        =   72
         Top             =   480
         Width           =   4095
         Begin VB.TextBox txtClassAbuTopXMinAbu 
            Alignment       =   1  'Right Justify
            Height          =   285
            Left            =   2880
            TabIndex        =   74
            Text            =   "0"
            Top             =   240
            Width           =   900
         End
         Begin VB.TextBox txtClassAbuTopXMaxAbu 
            Alignment       =   1  'Right Justify
            Height          =   285
            Left            =   2880
            TabIndex        =   76
            Text            =   "0"
            ToolTipText     =   "Maximum abundance to include; use 0 to indicate there infinitely large abundance"
            Top             =   540
            Width           =   900
         End
         Begin VB.TextBox txtClassAbuTopXMinMembers 
            Alignment       =   1  'Right Justify
            Height          =   285
            Left            =   2880
            TabIndex        =   78
            Text            =   "3"
            Top             =   840
            Width           =   900
         End
         Begin VB.Label lblClassAbuTopXMinAbu 
            BackStyle       =   0  'Transparent
            Caption         =   "Minimum Abundance to Include"
            Height          =   255
            Left            =   120
            TabIndex        =   73
            Top             =   270
            Width           =   2535
         End
         Begin VB.Label lblClassAbuTopXMaxAbu 
            BackStyle       =   0  'Transparent
            Caption         =   "Maximum Abundance to Include"
            Height          =   255
            Left            =   120
            TabIndex        =   75
            Top             =   560
            Width           =   2535
         End
         Begin VB.Label lblClassAbuTopXMinMembers 
            BackStyle       =   0  'Transparent
            Caption         =   "Minimum members to include"
            Height          =   255
            Left            =   120
            TabIndex        =   77
            Top             =   870
            Width           =   2535
         End
      End
      Begin VB.Frame fraClassMassTopX 
         Caption         =   "Class Mass Top X"
         Height          =   1215
         Left            =   -74880
         TabIndex        =   79
         Top             =   1800
         Width           =   4095
         Begin VB.TextBox txtClassMassTopXMinMembers 
            Alignment       =   1  'Right Justify
            Height          =   285
            Left            =   2880
            TabIndex        =   85
            Text            =   "3"
            Top             =   840
            Width           =   900
         End
         Begin VB.TextBox txtClassMassTopXMaxAbu 
            Alignment       =   1  'Right Justify
            Height          =   285
            Left            =   2880
            TabIndex        =   83
            Text            =   "0"
            ToolTipText     =   "Maximum abundance to include; use 0 to indicate there infinitely large abundance"
            Top             =   540
            Width           =   900
         End
         Begin VB.TextBox txtClassMassTopXMinAbu 
            Alignment       =   1  'Right Justify
            Height          =   285
            Left            =   2880
            TabIndex        =   81
            Text            =   "0"
            Top             =   240
            Width           =   900
         End
         Begin VB.Label lblClassMassTopXMinMembers 
            BackStyle       =   0  'Transparent
            Caption         =   "Minimum members to include"
            Height          =   255
            Left            =   120
            TabIndex        =   84
            Top             =   870
            Width           =   2535
         End
         Begin VB.Label lblClassMassTopXMaxAbu 
            BackStyle       =   0  'Transparent
            Caption         =   "Maximum Abundance to Include"
            Height          =   255
            Left            =   120
            TabIndex        =   82
            Top             =   560
            Width           =   2535
         End
         Begin VB.Label lblClassMassTopXMinAbu 
            BackStyle       =   0  'Transparent
            Caption         =   "Minimum Abundance to Include"
            Height          =   255
            Left            =   120
            TabIndex        =   80
            Top             =   270
            Width           =   2535
         End
      End
      Begin VB.ComboBox cboChargeStateAbuType 
         Height          =   315
         Left            =   -74880
         Style           =   2  'Dropdown List
         TabIndex        =   27
         Top             =   2520
         Width           =   3135
      End
      Begin VB.CheckBox chkUseMostAbuChargeStateStatsForClassStats 
         Caption         =   "Use most abundant charge state group stats for class stats"
         Height          =   405
         Left            =   -74880
         TabIndex        =   28
         ToolTipText     =   "Make single-member classes from unconnected nodes"
         Top             =   2880
         Width           =   2535
      End
      Begin VB.Frame fraSplitUMCsOptions 
         Caption         =   "Split UMC's Options"
         Height          =   2400
         Left            =   120
         TabIndex        =   58
         Top             =   3120
         Width           =   3800
         Begin VB.CheckBox chkSplitUMCsByExaminingAbundance 
            Caption         =   "Split UMC's by Examining Abundance"
            Height          =   255
            Left            =   120
            TabIndex        =   59
            Top             =   240
            Width           =   3015
         End
         Begin VB.TextBox txtSplitUMCsMinimumDifferenceInAvgPpmMass 
            Alignment       =   1  'Right Justify
            Height          =   285
            Left            =   2400
            TabIndex        =   61
            Text            =   "4"
            Top             =   660
            Width           =   495
         End
         Begin VB.TextBox txtSplitUMCsMaximumPeakCount 
            Alignment       =   1  'Right Justify
            Height          =   285
            Left            =   2400
            TabIndex        =   64
            Text            =   "6"
            Top             =   1140
            Width           =   495
         End
         Begin VB.TextBox txtSplitUMCsPeakDetectIntensityThresholdPercentageOfMax 
            Alignment       =   1  'Right Justify
            Height          =   285
            Left            =   2400
            TabIndex        =   67
            Text            =   "15"
            Top             =   1620
            Width           =   495
         End
         Begin VB.TextBox txtSplitUMCsPeakPickingMinimumWidth 
            Alignment       =   1  'Right Justify
            Height          =   285
            Left            =   2400
            TabIndex        =   70
            Text            =   "4"
            Top             =   1980
            Width           =   495
         End
         Begin VB.Label lblUnits 
            Caption         =   "ppm"
            Height          =   255
            Index           =   2
            Left            =   3000
            TabIndex        =   62
            Top             =   690
            Width           =   495
         End
         Begin VB.Label lblSplitUMCsMinimumDifferenceInAvgPpmMass 
            Caption         =   "Minimum difference in average mass"
            Height          =   405
            Left            =   120
            TabIndex        =   60
            Top             =   600
            Width           =   1455
         End
         Begin VB.Label lblUnits 
            Caption         =   "peaks"
            Height          =   255
            Index           =   3
            Left            =   3000
            TabIndex        =   65
            Top             =   1200
            Width           =   495
         End
         Begin VB.Label lblSplitUMCsMaximumPeakCount 
            Caption         =   "Maximum peak count to split UMC"
            Height          =   405
            Left            =   120
            TabIndex        =   63
            Top             =   1080
            Width           =   1455
         End
         Begin VB.Label lblUnits 
            Caption         =   "% of max"
            Height          =   255
            Index           =   4
            Left            =   3000
            TabIndex        =   68
            Top             =   1680
            Width           =   735
         End
         Begin VB.Label lblSplitUMCsPeakDetectIntensityThresholdPercentageOfMax 
            Caption         =   "Peak picking intensity threshold"
            Height          =   405
            Left            =   120
            TabIndex        =   66
            Top             =   1560
            Width           =   1455
         End
         Begin VB.Label lblUnits 
            Caption         =   "scans"
            Height          =   255
            Index           =   5
            Left            =   3000
            TabIndex        =   71
            Top             =   2010
            Width           =   735
         End
         Begin VB.Label lblSplitUMCsPeakPickingMinimumWidth 
            Caption         =   "Peak picking minimum width"
            Height          =   255
            Left            =   120
            TabIndex        =   69
            Top             =   2010
            Width           =   2295
         End
      End
      Begin VB.ComboBox cmbCountType 
         Height          =   315
         ItemData        =   "frmUMCSimple.frx":0091
         Left            =   -74880
         List            =   "frmUMCSimple.frx":00AA
         Style           =   2  'Dropdown List
         TabIndex        =   21
         Top             =   600
         Width           =   3135
      End
      Begin VB.TextBox txtHoleNum 
         Alignment       =   1  'Right Justify
         Height          =   285
         Left            =   -72240
         TabIndex        =   30
         Text            =   "0"
         Top             =   3420
         Width           =   495
      End
      Begin VB.TextBox txtHoleSize 
         Alignment       =   1  'Right Justify
         Height          =   285
         Left            =   -72240
         TabIndex        =   32
         Text            =   "0"
         Top             =   3900
         Width           =   495
      End
      Begin VB.ComboBox cmbUMCAbu 
         Height          =   315
         ItemData        =   "frmUMCSimple.frx":012E
         Left            =   -74880
         List            =   "frmUMCSimple.frx":0141
         Style           =   2  'Dropdown List
         TabIndex        =   23
         Top             =   1240
         Width           =   3135
      End
      Begin VB.ComboBox cmbUMCMW 
         Height          =   315
         ItemData        =   "frmUMCSimple.frx":01BB
         Left            =   -74880
         List            =   "frmUMCSimple.frx":01C8
         Style           =   2  'Dropdown List
         TabIndex        =   25
         Top             =   1920
         Width           =   3135
      End
      Begin VB.CheckBox chkAllowSharing 
         Caption         =   "Allow members sharing among classes"
         Height          =   255
         Left            =   -74880
         TabIndex        =   33
         Top             =   4440
         Width           =   3015
      End
      Begin VB.CheckBox chkInterpolateMissingIons 
         Caption         =   "Interpolate gaps abundances"
         Height          =   255
         Left            =   -74880
         TabIndex        =   34
         Top             =   4800
         Width           =   3015
      End
      Begin VB.TextBox txtInterpolateMaxGapSize 
         Alignment       =   1  'Right Justify
         Height          =   285
         Left            =   -72240
         TabIndex        =   36
         Text            =   "0"
         Top             =   5040
         Width           =   495
      End
      Begin VB.Label lblChargeStateAbuType 
         BackStyle       =   0  'Transparent
         Caption         =   "Most Abu Charge State Group Type"
         Height          =   255
         Left            =   -74880
         TabIndex        =   26
         Top             =   2280
         Width           =   3135
      End
      Begin VB.Label Label1 
         BackStyle       =   0  'Transparent
         Caption         =   "Count Type"
         Height          =   255
         Index           =   0
         Left            =   -74880
         TabIndex        =   20
         Top             =   360
         Width           =   1335
      End
      Begin VB.Label Label3 
         BackStyle       =   0  'Transparent
         Caption         =   "Maximum number of scan gaps in the Unique Mass Class:"
         Height          =   495
         Index           =   0
         Left            =   -74880
         TabIndex        =   29
         Top             =   3360
         Width           =   2535
      End
      Begin VB.Label Label3 
         BackStyle       =   0  'Transparent
         Caption         =   "Maximum size of scan gap in the Unique Mass Class:"
         Height          =   495
         Index           =   1
         Left            =   -74880
         TabIndex        =   31
         Top             =   3840
         Width           =   2535
      End
      Begin VB.Label Label1 
         BackStyle       =   0  'Transparent
         Caption         =   "Class Abundance"
         Height          =   255
         Index           =   1
         Left            =   -74880
         TabIndex        =   22
         Top             =   1000
         Width           =   1335
      End
      Begin VB.Label Label1 
         BackStyle       =   0  'Transparent
         Caption         =   "Class Molecular Mass"
         Height          =   255
         Index           =   2
         Left            =   -74880
         TabIndex        =   24
         Top             =   1680
         Width           =   1575
      End
      Begin VB.Label Label3 
         BackStyle       =   0  'Transparent
         Caption         =   "Maximum size of gap to interpolate:"
         Height          =   255
         Index           =   2
         Left            =   -74880
         TabIndex        =   35
         Top             =   5100
         Width           =   2535
      End
   End
   Begin VB.Label lblStatus 
      Appearance      =   0  'Flat
      BackColor       =   &H80000005&
      BackStyle       =   0  'Transparent
      ForeColor       =   &H80000008&
      Height          =   285
      Left            =   120
      TabIndex        =   86
      Top             =   6100
      Width           =   4455
   End
   Begin VB.Label lblGelName 
      BackStyle       =   0  'Transparent
      Height          =   255
      Left            =   120
      TabIndex        =   3
      Top             =   60
      Width           =   6255
   End
End
Attribute VB_Name = "frmUMCSimple"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'unique mass class function - simpler version
'breaks gel to unique mass classes
'--------------------------------------------
'last modified 03/12/2003 nt
'--------------------------------------------
Option Explicit
Dim CallerID As Long

'data from GelData structures

Dim CSCnt As Long               'count of CS data points included in count
Dim ISCnt As Long               'count of IS data points included in count

Dim O_Cnt As Long               'total number of
Dim O_Index() As Long           'index in CS/Iso arrays
Dim O_Type() As Long            'type of data(CS/Iso)
Dim O_MW() As Double            'mass array
Dim O_Abu() As Double           'abundance (we need it anyway for class abundance calc)
Dim O_Order() As Double         'Fit/StDev or Abundance
Dim O_Scan() As Long            'just to have it

Dim S_MW() As Double            'sorted mass array used for fast search

Dim IndMW() As Long             'index on mass
Dim IndScan() As Long           'index on scan
Dim IndOrder() As Long          'index on order

Dim IsRep() As Boolean          'is representative
Dim IsUsed() As Boolean         'is used already

Dim MWRangeFinder As MWUtil     'fast search of mass range


'following variables are used on module level during class breakup
Dim CurrOrderInd As Long        'index of current class representative
Dim CurrMW As Double            'mass of class representative
Dim CurrScan As Long            'scan number of class representative

Dim CurrRepInd_O As Long        'index of current representative in original arrays
Dim CurrMWRangeInd_O() As Long  'indexes in original arrays of potential class members(including representative)
Dim CurrMWRangeCnt As Long      'and their number
Dim CurrRepMWRangeInd As Long   'index of current class representative in MWRange arrays(potential in fact)

Private Sub FillComboBoxes()
    With cmbCountType
        .Clear
        .AddItem "Favor Higher Intensity"
        .AddItem "Favor Better Fit"
        .AddItem "Minimize Count"
        .AddItem "Maximize Count"
        .AddItem "Unique MT"
        .AddItem "Shrinking Box Favor Intensity"
        .AddItem "Shrinking Box Favor Fit"
    End With
    
    With cmbUMCAbu
        .Clear
        .AddItem "Average of Class Abu."
        .AddItem "Sum of Class Abu."
        .AddItem "Abu. of Class Representative"
        .AddItem "Median of Class Abundance"
        .AddItem "Max of Class Abu."
        .AddItem "Sum of Top X Members of Class"
    End With
    
    With cmbUMCMW
        .Clear
        .AddItem "Class Average"
        .AddItem "Mol.Mass Of Class Representative"
        .AddItem "Class Median"
        .AddItem "Average of Top X Members of Class"
        .AddItem "Median of Top X Members of Class"
    End With
    
    With cmbUMCDrawType
        .Clear
        .AddItem "Actual UMC"
        .AddItem "UMC Full Region"
        .AddItem "UMC Intensity"
    End With
    
    With cboChargeStateAbuType
        .Clear
        .AddItem "Highest Abu Sum"
        .AddItem "Most Abu Member"
        .AddItem "Most Members"
    End With

End Sub

Public Sub InitializeUMCSearch()

' MonroeMod: This code was in Form_Activate

On Error GoTo InitializeUMCSearchErrorHandler

CallerID = Me.Tag
If CallerID >= 1 And CallerID <= UBound(GelBody) Then UMCDef = GelSearchDef(CallerID).UMCDef
lblGelName.Caption = CompactPathString(GelBody(CallerID).Caption, 75)
' MonroeMod: copy value from .UMCDrawType to .DrawType
GelUMCDraw(CallerID).DrawType = glbPreferencesExpanded.UMCDrawType
cmbUMCDrawType.ListIndex = GelUMCDraw(CallerID).DrawType

With UMCDef
    txtTol.Text = .Tol
    If .UMCType = glUMC_TYPE_FROM_NET Then .UMCType = glUMC_TYPE_INTENSITY
    cmbCountType.ListIndex = .UMCType
    cmbUMCAbu.ListIndex = .ClassAbu
    cmbUMCMW.ListIndex = .ClassMW
    cboChargeStateAbuType.ListIndex = .ChargeStateStatsRepType
    SetCheckBox chkUseMostAbuChargeStateStatsForClassStats, .UMCClassStatsUseStatsFromMostAbuChargeState
    
    optDefScope(.DefScope).Value = True
    optMWField(.MWField - MW_FIELD_OFFSET).Value = True
    Select Case .TolType
    Case gltPPM
      optTolType(0).Value = True
    Case gltABS
      optTolType(1).Value = True
    Case Else
      Debug.Assert False
    End Select
    txtHoleNum.Text = .GapMaxCnt
    txtHoleSize.Text = .GapMaxSize
    If .UMCSharing Then
       chkAllowSharing.Value = vbChecked
    Else
       chkAllowSharing.Value = vbUnchecked
    End If
    If .InterpolateGaps Then
       chkInterpolateMissingIons.Value = vbChecked
    Else
       chkInterpolateMissingIons.Value = vbUnchecked
    End If
    txtInterpolateMaxGapSize.Text = .InterpolateMaxGapSize
    
End With

With glbPreferencesExpanded.UMCAutoRefineOptions
    SetCheckBox chkRemoveLoCnt, .UMCAutoRefineRemoveCountLow
    SetCheckBox chkRemoveHiCnt, .UMCAutoRefineRemoveCountHigh
    SetCheckBox chkRemoveMaxLengthPctAllScans, .UMCAutoRefineRemoveMaxLengthPctAllScans
    
    txtLoCnt = .UMCAutoRefineMinLength
    txtHiCnt = .UMCAutoRefineMaxLength
    txtMaxLengthPctAllScans = .UMCAutoRefineMaxLengthPctAllScans
    txtPercentMaxAbuToUseToGaugeLength = .UMCAutoRefinePercentMaxAbuToUseForLength
    
    SetCheckBox chkRefineUMCLengthByScanRange, .TestLengthUsingScanRange
    txtAutoRefineMinimumMemberCount = .MinMemberCountWhenUsingScanRange
    UpdateDynamicControls
    
    SetCheckBox chkRemoveLoAbu, .UMCAutoRefineRemoveAbundanceLow
    SetCheckBox chkRemoveHiAbu, .UMCAutoRefineRemoveAbundanceHigh
    txtLoAbuPct = .UMCAutoRefinePctLowAbundance
    txtHiAbuPct = .UMCAutoRefinePctHighAbundance
    
    SetCheckBox chkSplitUMCsByExaminingAbundance, .SplitUMCsByAbundance
    With .SplitUMCOptions
        txtSplitUMCsMaximumPeakCount = Trim(.MaximumPeakCountToSplitUMC)
        txtSplitUMCsMinimumDifferenceInAvgPpmMass = Trim(.MinimumDifferenceInAveragePpmMassToSplit)
        txtSplitUMCsPeakDetectIntensityThresholdPercentageOfMax = Trim(.PeakDetectIntensityThresholdPercentageOfMaximum)
        txtSplitUMCsPeakPickingMinimumWidth = Trim(.PeakWidthPointsMinimum)
    End With
End With

With glbPreferencesExpanded.UMCAdvancedStatsOptions
    txtClassAbuTopXMinAbu = .ClassAbuTopXMinAbu
    txtClassAbuTopXMaxAbu = .ClassAbuTopXMaxAbu
    txtClassAbuTopXMinMembers = .ClassAbuTopXMinMembers
    
    txtClassMassTopXMinAbu = .ClassMassTopXMinAbu
    txtClassMassTopXMaxAbu = .ClassMassTopXMaxAbu
    txtClassMassTopXMinMembers = .ClassMassTopXMinMembers
End With

Exit Sub

InitializeUMCSearchErrorHandler:
    Debug.Print "Error in InitializeUMCSearch: " & Err.Description
    Debug.Assert False
    LogErrors Err.Number, "frmUMCSimple->InitializeUMCSearch"
    Resume Next

End Sub

Private Sub cboChargeStateAbuType_Click()
    UMCDef.ChargeStateStatsRepType = cboChargeStateAbuType.ListIndex
End Sub

Private Sub chkAllowSharing_Click()
UMCDef.UMCSharing = (chkAllowSharing.Value = vbChecked)
End Sub

Private Sub chkInterpolateMissingIons_Click()
UMCDef.InterpolateGaps = (chkInterpolateMissingIons.Value = vbChecked)
End Sub

Private Sub chkRemoveMaxLengthPctAllScans_Click()
    glbPreferencesExpanded.UMCAutoRefineOptions.UMCAutoRefineRemoveMaxLengthPctAllScans = cChkBox(chkRemoveMaxLengthPctAllScans)
End Sub

Private Sub chkRefineUMCLengthByScanRange_Click()
    glbPreferencesExpanded.UMCAutoRefineOptions.TestLengthUsingScanRange = cChkBox(chkRefineUMCLengthByScanRange)
    UpdateDynamicControls
End Sub

Private Sub chkRemoveHiAbu_Click()
    glbPreferencesExpanded.UMCAutoRefineOptions.UMCAutoRefineRemoveAbundanceHigh = cChkBox(chkRemoveHiAbu)
End Sub

Private Sub chkRemoveHiCnt_Click()
    glbPreferencesExpanded.UMCAutoRefineOptions.UMCAutoRefineRemoveCountHigh = cChkBox(chkRemoveHiCnt)
End Sub

Private Sub chkRemoveLoAbu_Click()
    glbPreferencesExpanded.UMCAutoRefineOptions.UMCAutoRefineRemoveAbundanceLow = cChkBox(chkRemoveLoAbu)
End Sub

Private Sub chkRemoveLoCnt_Click()
    glbPreferencesExpanded.UMCAutoRefineOptions.UMCAutoRefineRemoveCountLow = cChkBox(chkRemoveLoCnt)
End Sub

Private Sub chkSplitUMCsByExaminingAbundance_Click()
    glbPreferencesExpanded.UMCAutoRefineOptions.SplitUMCsByAbundance = cChkBox(chkSplitUMCsByExaminingAbundance)
End Sub

Private Sub chkUseMostAbuChargeStateStatsForClassStats_Click()
    UMCDef.UMCClassStatsUseStatsFromMostAbuChargeState = cChkBox(chkUseMostAbuChargeStateStatsForClassStats)
End Sub

Private Sub cmbUMCAbu_Click()
UMCDef.ClassAbu = cmbUMCAbu.ListIndex
End Sub

Private Sub cmbUMCDrawType_Click()
GelUMCDraw(CallerID).DrawType = cmbUMCDrawType.ListIndex
glbPreferencesExpanded.UMCDrawType = cmbUMCDrawType.ListIndex
End Sub

Private Sub cmbUMCMW_Click()
UMCDef.ClassMW = cmbUMCMW.ListIndex
End Sub

Private Sub cmdAbortProcessing_Click()
    glAbortUMCProcessing = True
End Sub

Private Sub cmdResetToDefaults_Click()
    ResetToDefaults
End Sub

Private Sub Form_Activate()
    InitializeUMCSearch
End Sub

Private Sub Form_Load()
    ' MonroeMod: The code that was here has been moved to Form_Activate
    '            This was done so that the Statement: UMCDef = GelSearchDef(CallerID).UMCDef
    '             will be encountered before the controls are updated
    FillComboBoxes
    tbsTabStrip.Tab = 0
End Sub

Private Sub cmbCountType_Click()
UMCDef.UMCType = cmbCountType.ListIndex
End Sub

Private Sub cmdCancel_Click()
If Not cmdOK.Visible Then glAbortUMCProcessing = True
Unload Me
End Sub

Private Sub cmdOK_Click()
    StartUMCSearch
End Sub

Private Sub cmdReport_Click()
Me.MousePointer = vbHourglass
Status "Generating UMC report..."
Call ReportUMC(CallerID, "UMC 2003" & vbCrLf & GetUMCDefDescLocal())
Status ""
Me.MousePointer = vbDefault
End Sub

Private Sub optDefScope_Click(Index As Integer)
UMCDef.DefScope = Index
End Sub

Private Sub optTolType_Click(Index As Integer)
If Index = 0 Then
   UMCDef.TolType = gltPPM
Else
   UMCDef.TolType = gltABS
End If
End Sub

Private Sub optMWField_Click(Index As Integer)
UMCDef.MWField = 6 + Index
End Sub

Private Sub txtAutoRefineMinimumMemberCount_LostFocus()
If IsNumeric(txtAutoRefineMinimumMemberCount.Text) Then
    glbPreferencesExpanded.UMCAutoRefineOptions.MinMemberCountWhenUsingScanRange = Abs(CLng(txtAutoRefineMinimumMemberCount.Text))
Else
   MsgBox "This argument should be non-negative integer.", vbOKOnly, glFGTU
   txtAutoRefineMinimumMemberCount.SetFocus
End If
End Sub

Private Sub txtClassAbuTopXMaxAbu_Change()
    UpdateDynamicControls
End Sub

Private Sub txtClassAbuTopXMaxAbu_Lostfocus()
    ValidateTextboxValueDbl txtClassAbuTopXMaxAbu, 0, 1E+300, 0
    glbPreferencesExpanded.UMCAdvancedStatsOptions.ClassAbuTopXMaxAbu = CDblSafe(txtClassAbuTopXMaxAbu)
End Sub

Private Sub txtClassAbuTopXMinAbu_Change()
    UpdateDynamicControls
End Sub

Private Sub txtClassAbuTopXMinAbu_Lostfocus()
    ValidateTextboxValueDbl txtClassAbuTopXMinAbu, 0, 1E+300, 0
    glbPreferencesExpanded.UMCAdvancedStatsOptions.ClassAbuTopXMinAbu = CDblSafe(txtClassAbuTopXMinAbu)
End Sub

Private Sub txtClassAbuTopXMinMembers_Lostfocus()
    ValidateTextboxValueLng txtClassAbuTopXMinMembers, 0, 100000, 3
    glbPreferencesExpanded.UMCAdvancedStatsOptions.ClassAbuTopXMinMembers = CLngSafe(txtClassAbuTopXMinMembers)
End Sub

Private Sub txtClassMassTopXMaxAbu_Change()
    UpdateDynamicControls
End Sub

Private Sub txtClassMassTopXMaxAbu_Lostfocus()
    ValidateTextboxValueDbl txtClassMassTopXMaxAbu, 0, 1E+300, 0
    glbPreferencesExpanded.UMCAdvancedStatsOptions.ClassMassTopXMaxAbu = CDblSafe(txtClassMassTopXMaxAbu)
End Sub

Private Sub txtClassMassTopXMinAbu_Change()
    UpdateDynamicControls
End Sub

Private Sub txtClassMassTopXMinAbu_Lostfocus()
    ValidateTextboxValueDbl txtClassMassTopXMinAbu, 0, 1E+300, 0
    glbPreferencesExpanded.UMCAdvancedStatsOptions.ClassMassTopXMinAbu = CDblSafe(txtClassMassTopXMinAbu)
End Sub

Private Sub txtClassMassTopXMinMembers_Lostfocus()
    ValidateTextboxValueLng txtClassMassTopXMinMembers, 0, 100000, 3
    glbPreferencesExpanded.UMCAdvancedStatsOptions.ClassMassTopXMinMembers = CLngSafe(txtClassMassTopXMinMembers)
End Sub

Private Sub txtHiAbuPct_LostFocus()
If IsNumeric(txtHiAbuPct.Text) Then
   glbPreferencesExpanded.UMCAutoRefineOptions.UMCAutoRefinePctHighAbundance = Abs(CDbl(txtHiAbuPct.Text))
Else
   MsgBox "This argument should be non-negative number.", vbOKOnly, glFGTU
   txtHiAbuPct.SetFocus
End If
End Sub

Private Sub txtHiCnt_LostFocus()
If IsNumeric(txtHiCnt.Text) Then
   glbPreferencesExpanded.UMCAutoRefineOptions.UMCAutoRefineMaxLength = Abs(CLng(txtHiCnt.Text))
Else
   MsgBox "This argument should be non-negative integer.", vbOKOnly, glFGTU
   txtHiCnt.SetFocus
End If
End Sub

Private Sub txtHoleNum_LostFocus()
If IsNumeric(txtHoleNum.Text) Then
   UMCDef.GapMaxCnt = CLng(txtHoleNum.Text)
Else
   MsgBox "This argument should be integer value.", vbOKOnly
   txtHoleNum.SetFocus
End If
End Sub

Private Sub txtHoleSize_LostFocus()
If IsNumeric(txtHoleSize.Text) Then
   UMCDef.GapMaxSize = CLng(txtHoleSize.Text)
Else
   MsgBox "This argument should be integer value.", vbOKOnly
   txtHoleSize.SetFocus
End If
End Sub

Private Sub txtInterpolateMaxGapSize_LostFocus()
If IsNumeric(txtInterpolateMaxGapSize.Text) Then
   UMCDef.InterpolateMaxGapSize = CLng(txtInterpolateMaxGapSize.Text)
Else
   MsgBox "This argument should be integer value.", vbOKOnly
   txtInterpolateMaxGapSize.SetFocus
End If
End Sub

Private Sub txtLoAbuPct_LostFocus()
If IsNumeric(txtLoAbuPct.Text) Then
   glbPreferencesExpanded.UMCAutoRefineOptions.UMCAutoRefinePctLowAbundance = Abs(CDbl(txtLoAbuPct.Text))
Else
   MsgBox "This argument should be non-negative number.", vbOKOnly, glFGTU
   txtLoAbuPct.SetFocus
End If
End Sub

Private Sub txtLoCnt_LostFocus()
If IsNumeric(txtLoCnt.Text) Then
    glbPreferencesExpanded.UMCAutoRefineOptions.UMCAutoRefineMinLength = Abs(CLng(txtLoCnt.Text))
Else
   MsgBox "This argument should be non-negative integer.", vbOKOnly, glFGTU
   txtLoCnt.SetFocus
End If
End Sub

Private Sub txtMaxLengthPctAllScans_Lostfocus()
If IsNumeric(txtMaxLengthPctAllScans.Text) Then
    glbPreferencesExpanded.UMCAutoRefineOptions.UMCAutoRefineMaxLengthPctAllScans = Abs(CLng(txtMaxLengthPctAllScans.Text))
Else
   MsgBox "This argument should be non-negative integer.", vbOKOnly, glFGTU
   txtMaxLengthPctAllScans.SetFocus
End If
End Sub

Private Sub txtPercentMaxAbuToUseToGaugeLength_LostFocus()
If IsNumeric(txtPercentMaxAbuToUseToGaugeLength.Text) Then
    glbPreferencesExpanded.UMCAutoRefineOptions.UMCAutoRefinePercentMaxAbuToUseForLength = Abs(CLng(txtPercentMaxAbuToUseToGaugeLength.Text))
Else
   MsgBox "This argument should be non-negative integer.", vbOKOnly, glFGTU
   txtPercentMaxAbuToUseToGaugeLength.SetFocus
End If
End Sub

Private Sub txtSplitUMCsMaximumPeakCount_LostFocus()
    ValidateTextboxValueLng txtSplitUMCsMaximumPeakCount, 2, 100, 6
    glbPreferencesExpanded.UMCAutoRefineOptions.SplitUMCOptions.MaximumPeakCountToSplitUMC = CLngSafe(txtSplitUMCsMaximumPeakCount)
End Sub

Private Sub txtSplitUMCsMinimumDifferenceInAvgPpmMass_LostFocus()
    ValidateTextboxValueDbl txtSplitUMCsMinimumDifferenceInAvgPpmMass, 0, 10000#, 4
    glbPreferencesExpanded.UMCAutoRefineOptions.SplitUMCOptions.MinimumDifferenceInAveragePpmMassToSplit = CDblSafe(txtSplitUMCsMinimumDifferenceInAvgPpmMass)
End Sub

Private Sub txtSplitUMCsPeakDetectIntensityThresholdPercentageOfMax_LostFocus()
    ValidateTextboxValueLng txtSplitUMCsPeakDetectIntensityThresholdPercentageOfMax, 0, 100, 15
    glbPreferencesExpanded.UMCAutoRefineOptions.SplitUMCOptions.PeakDetectIntensityThresholdPercentageOfMaximum = CLngSafe(txtSplitUMCsPeakDetectIntensityThresholdPercentageOfMax)
End Sub

Private Sub txtSplitUMCsPeakPickingMinimumWidth_LostFocus()
    ValidateTextboxValueLng txtSplitUMCsPeakPickingMinimumWidth, 0, 1000, 4
    glbPreferencesExpanded.UMCAutoRefineOptions.SplitUMCOptions.PeakWidthPointsMinimum = CLngSafe(txtSplitUMCsPeakPickingMinimumWidth)
End Sub

Private Sub txtTol_LostFocus()
If IsNumeric(txtTol.Text) Then
   UMCDef.Tol = txtTol.Text
Else
   MsgBox "Molecular Mass Tolerance should be numeric value.", vbOKOnly
   txtTol.SetFocus
End If
End Sub

Private Sub ResetToDefaults()
    
    With glbPreferencesExpanded
        ResetUMCAdvancedStatsOptions .UMCAdvancedStatsOptions
        ResetUMCAutoRefineOptions .UMCAutoRefineOptions
        
        .UMCDrawType = umcdt_ActualUMC
    End With
    
    SetDefaultUMCDef UMCDef
    
    If CallerID >= 1 And CallerID <= UBound(GelBody) Then
        GelSearchDef(CallerID).UMCDef = UMCDef
    End If
        
    InitializeUMCSearch
    
End Sub

Public Function StartUMCSearch() As Boolean
    ' Returns True if success, False if error or aborted
    
    Dim blnUMCIndicesUpdated As Boolean
    
On Error GoTo UMCSearchErrorHandler
    
    If ((UMCDef.UMCType = glUMC_TYPE_MINCNT) Or (UMCDef.UMCType = glUMC_TYPE_MAXCNT) _
                    Or (UMCDef.UMCType = glUMC_TYPE_UNQAMT)) Then
        If Not glbPreferencesExpanded.AutoAnalysisStatus.Enabled Then
            MsgBox "Selected option is not implemented.", vbOKOnly, glFGTU
        End If
        Exit Function
    End If
    
    Me.MousePointer = vbHourglass
    cmdOK.Visible = False
    cmdCancel.Visible = False
    glAbortUMCProcessing = False
    
    If GelUMC(CallerID).UMCCnt > 0 Then ManageClasses CallerID, UMCManageConstants.UMCMngErase
    If UMCLoadArraysLocal And Not glAbortUMCProcessing Then
       If Not CreateIndMW() Or glAbortUMCProcessing Then GoTo ExitIfFailed
       If Not CreateIndOrder() Or glAbortUMCProcessing Then GoTo ExitIfFailed
       If Not CreateIndScan() Or glAbortUMCProcessing Then GoTo ExitIfFailed
       
       GelUMC(CallerID).def = UMCDef
       Select Case UMCDef.UMCType
       Case glUMC_TYPE_INTENSITY, glUMC_TYPE_FIT
            If Not UMCLocalBreakStandard Or glAbortUMCProcessing Then GoTo ExitIfFailed
       Case glUMC_TYPE_ISHRINKINGBOX, glUMC_TYPE_FSHRINKINGBOX
            If Not UMCLocalBreakShrinkingBox Or glAbortUMCProcessing Then GoTo ExitIfFailed
       Case Else
            ' Invalid search type
            Debug.Assert False
       End Select
       
       AddToAnalysisHistory CallerID, ConstructUMCDefDescription(CallerID, AUTO_ANALYSIS_UMC2003, UMCDef, glbPreferencesExpanded.UMCAdvancedStatsOptions, UMCDef.UMCSharing)
        
       ' Possibly Auto-Refine the UMC's
       blnUMCIndicesUpdated = AutoRefineUMCs(CallerID, Me)
       
       If Not blnUMCIndicesUpdated Then
           ' The following calls CalculateClasses, UpdateIonToUMCIndices, and InitDrawUMC
           If Not UpdateUMCStatArrays(CallerID, False, Me) Then GoTo ExitIfFailed
       End If
       
       ' Note: we need to update GelSearchDef before calling SplitUMCsByAbundance
       GelSearchDef(CallerID).UMCDef = UMCDef
       
       If glbPreferencesExpanded.UMCAutoRefineOptions.SplitUMCsByAbundance Then
            SplitUMCsByAbundance CallerID, Me, False, True
       End If
       
       If GelUMCDraw(CallerID).Visible Then
           GelBody(CallerID).RequestRefreshPlot
           GelBody(CallerID).csMyCooSys.CoordinateDraw
       End If
       
       Status "Number of Unique Mass Classes: " & GelUMC(CallerID).UMCCnt
    Else
       GoTo ExitIfFailed
    End If
    
    cmdOK.Visible = True
    cmdCancel.Visible = True
    glAbortUMCProcessing = False
    Me.MousePointer = vbDefault
    'if there is new UMC count everything done with pairs
    'has to be redone if pairs are UMC pairs
    With GelP_D_L(CallerID)
        If .DltLblType <> ptS_Dlt And .DltLblType <> ptS_Lbl And .DltLblType <> ptS_DltLbl Then
            .SyncWithUMC = False
        End If
    End With
    StartUMCSearch = True
    Exit Function
    
ExitIfFailed:
    Status "Unique Mass Class function failed"
    DestroyStructuresLocal
    cmdOK.Visible = True
    cmdCancel.Visible = True
    glAbortUMCProcessing = False
    Me.MousePointer = vbDefault
    StartUMCSearch = False
    Exit Function

UMCSearchErrorHandler:
    LogErrors Err.Number, "frmUMCSimple->StartUMCSearch"
    Debug.Print "Error in frmUMCSimple->StartUMCSearch: " & Err.Description
    Debug.Assert False
    GoTo ExitIfFailed
End Function
    
Public Sub Status(ByVal StatusText As String)
    lblStatus.Caption = StatusText
    Me.Refresh
    DoEvents
End Sub

Private Sub UpdateDynamicControls()
    ' Update the UMC auto refine length labels
    If glbPreferencesExpanded.UMCAutoRefineOptions.TestLengthUsingScanRange Then
        chkRemoveLoCnt.Caption = "Remove cls. with less than"
        chkRemoveHiCnt.Caption = "Remove cls. with length over"
        lblAutoRefineLengthLabel(0) = "scans"
        lblAutoRefineLengthLabel(1) = "scans"
        lblAutoRefineMinimumMemberCount.Enabled = True
    Else
        chkRemoveLoCnt.Caption = "Remove cls. with less than"
        chkRemoveHiCnt.Caption = "Remove cls. with more than"
        lblAutoRefineLengthLabel(0) = "members"
        lblAutoRefineLengthLabel(1) = "members"
        lblAutoRefineMinimumMemberCount.Enabled = False
    End If

    txtAutoRefineMinimumMemberCount.Enabled = lblAutoRefineMinimumMemberCount.Enabled
    lblPercentMaxAbuToUseToGaugeLength.Enabled = lblAutoRefineMinimumMemberCount.Enabled
    txtPercentMaxAbuToUseToGaugeLength.Enabled = lblAutoRefineMinimumMemberCount.Enabled

    If CDblSafe(txtClassAbuTopXMinAbu) <= 0 And CDblSafe(txtClassAbuTopXMaxAbu) <= 0 Then
        lblClassAbuTopXMinMembers = "Maximum members to include"
    Else
        lblClassAbuTopXMinMembers = "Minimum members to include"
    End If

    If CDblSafe(txtClassMassTopXMinAbu) <= 0 And CDblSafe(txtClassMassTopXMaxAbu) <= 0 Then
        lblClassMassTopXMinMembers = "Maximum members to include"
    Else
        lblClassMassTopXMinMembers = "Minimum members to include"
    End If

End Sub

Private Function GetUMCDefDescLocal() As String
'--------------------------------------------------------------------------
'returns formated unique mass classes definition
'--------------------------------------------------------------------------
Dim sTmp As String
On Error GoTo exit_GetUMCDefDescLocal
With UMCDef
    Select Case .DefScope
    Case glScope.glSc_All
      sTmp = "Unique Mass Classes(UMC) on all data points." & vbCrLf
    Case glScope.glSc_Current
      sTmp = "Unique Mass Classes(UMC) on currently visible data." & vbCrLf
    End Select
    Select Case .UMCType
    Case glUMC_TYPE_INTENSITY
      sTmp = sTmp & "UMC type: Intensity" & vbCrLf
    Case glUMC_TYPE_FIT
      sTmp = sTmp & "UMC type: Fit" & vbCrLf
    Case glUMC_TYPE_MINCNT
      sTmp = sTmp & "UMC type: Minimize count" & vbCrLf
    Case glUMC_TYPE_MAXCNT
      sTmp = sTmp & "UMC type: Maximize count" & vbCrLf
    Case glUMC_TYPE_UNQAMT
      sTmp = sTmp & "UMC type: Unique MT Hits" & vbCrLf
    Case glUMC_TYPE_ISHRINKINGBOX
      sTmp = sTmp & "UMC type: Intensity with shrinking box, "
'      If ShrinkingBox_MW_Average_Type = 1 Then
'        sTmp = sTmp & "Averaging: Weighted on Intensity" & vbCrLf
'      Else
'        sTmp = sTmp & "Averaging: Non-Weighted" & vbCrLf
'      End If
    Case glUMC_TYPE_ISHRINKINGBOX
      sTmp = sTmp & "UMC type: Fit with shrinking box, "
'      If ShrinkingBox_MW_Average_Type = 1 Then
'        sTmp = sTmp & "Averaging: Weighted on Fit" & vbCrLf
'      Else
'        sTmp = sTmp & "Averaging: Non-Weighted" & vbCrLf
'      End If
    End Select
    Select Case .MWField
    Case 6
      sTmp = sTmp & "Molecular mass: Average" & vbCrLf
    Case 7
      sTmp = sTmp & "Molecular mass: Monoisotopic" & vbCrLf
    Case 8
      sTmp = sTmp & "Molecular mass: Most Abundant" & vbCrLf
    End Select
    Select Case .ClassAbu
    Case UMCClassAbundanceConstants.UMCAbuAvg
      sTmp = sTmp & "Class abundance: Average of member abundances" & vbCrLf
    Case UMCClassAbundanceConstants.UMCAbuSum
      sTmp = sTmp & "Class abundance: Sum of member abundances" & vbCrLf
    Case UMCClassAbundanceConstants.UMCAbuRep
      sTmp = sTmp & "Class abundance: Abundance of class representative" & vbCrLf
    Case UMCClassAbundanceConstants.UMCAbuMed
      sTmp = sTmp & "Class abundance: Class median" & vbCrLf
    Case UMCClassAbundanceConstants.UMCAbuMax
      sTmp = sTmp & "Class abundance: Class max abundance" & vbCrLf
    End Select
    Select Case .ClassMW
    Case UMCClassMassConstants.UMCMassAvg
      sTmp = sTmp & "Class molecular mass: Average of member masses" & vbCrLf
    Case UMCClassMassConstants.UMCMassRep
      sTmp = sTmp & "Class molecular mass: Mass of class representative" & vbCrLf
    Case UMCClassMassConstants.UMCMassMed
      sTmp = sTmp & "Class molecular mass: Median of member masses" & vbCrLf
    End Select
    sTmp = sTmp & "Molecular mass tolerance: " & .Tol & " " & GetSearchToleranceUnitText(CInt(.TolType)) & vbCrLf
    sTmp = sTmp & "Number of allowed gaps: " & .GapMaxCnt & vbCrLf
    sTmp = sTmp & "Allowed size of gap: " & .GapMaxSize & vbCrLf
    If .UMCSharing Then
       sTmp = sTmp & "Classes overlap allowed."
    Else
       sTmp = sTmp & "Classes overlap not allowed."
    End If
End With

exit_GetUMCDefDescLocal:
GetUMCDefDescLocal = sTmp
End Function


Private Function UMCLoadArraysLocal() As Boolean
'--------------------------------------------------------------------------------
'load arrays neccessary for unique mass classes and creates neccessary structures
'--------------------------------------------------------------------------------
Dim MaxCnt As Long
Dim CSInd() As Long
Dim ISInd() As Long
Dim i As Long
On Error GoTo err_UMCLoadArraysLocal
Status "Loading arrays"
MaxCnt = GelData(CallerID).CSLines + GelData(CallerID).IsoLines
If MaxCnt > 0 Then
   ReDim O_Index(MaxCnt - 1)
   ReDim O_Type(MaxCnt - 1)
   ReDim O_MW(MaxCnt - 1)
   ReDim O_Abu(MaxCnt - 1)
   ReDim O_Order(MaxCnt - 1)
   ReDim O_Scan(MaxCnt - 1)
   O_Cnt = 0
   With GelData(CallerID)
     CSCnt = GetCSScope(CallerID, CSInd(), UMCDef.DefScope)
     If CSCnt > 0 Then
        For i = 1 To CSCnt
            O_Cnt = O_Cnt + 1
            O_Index(O_Cnt - 1) = CSInd(i)
            O_Type(O_Cnt - 1) = gldtCS
            O_MW(O_Cnt - 1) = .CSData(CSInd(i)).AverageMW
            O_Abu(O_Cnt - 1) = .CSData(CSInd(i)).Abundance
            O_Scan(O_Cnt - 1) = .CSData(CSInd(i)).ScanNumber
            Select Case UMCDef.UMCType
            Case glUMC_TYPE_INTENSITY, glUMC_TYPE_ISHRINKINGBOX
              O_Order(O_Cnt - 1) = .CSData(CSInd(i)).Abundance
            Case glUMC_TYPE_FIT, glUMC_TYPE_FSHRINKINGBOX
              O_Order(O_Cnt - 1) = .CSData(CSInd(i)).MassStDev         'St.Dev. in fact
            Case Else
                ' Invalid type
                Debug.Assert False
            End Select
        Next i
     End If
     ISCnt = GetISScope(CallerID, ISInd(), UMCDef.DefScope)
     If ISCnt > 0 Then
        For i = 1 To ISCnt
            O_Cnt = O_Cnt + 1
            O_Index(O_Cnt - 1) = ISInd(i)
            O_Type(O_Cnt - 1) = gldtIS
            O_MW(O_Cnt - 1) = GetIsoMass(.IsoData(ISInd(i)), UMCDef.MWField)
            O_Abu(O_Cnt - 1) = .IsoData(ISInd(i)).Abundance
            O_Scan(O_Cnt - 1) = .IsoData(ISInd(i)).ScanNumber
            Select Case UMCDef.UMCType
            Case glUMC_TYPE_INTENSITY, glUMC_TYPE_ISHRINKINGBOX
              O_Order(O_Cnt - 1) = .IsoData(ISInd(i)).Abundance
            Case glUMC_TYPE_FIT, glUMC_TYPE_FSHRINKINGBOX
              O_Order(O_Cnt - 1) = .IsoData(ISInd(i)).Fit
            Case Else
                ' Invalid type
                Debug.Assert False
            End Select
        Next i
     End If
   End With
End If
If O_Cnt <= 0 Then Status "No data found in scope"
exit_UMCLoadArraysLocal:
If O_Cnt > 0 Then
   ReDim Preserve O_Index(O_Cnt - 1)
   ReDim Preserve O_Type(O_Cnt - 1)
   ReDim Preserve O_MW(O_Cnt - 1)
   ReDim Preserve O_Abu(O_Cnt - 1)
   ReDim Preserve O_Order(O_Cnt - 1)
   ReDim Preserve O_Scan(O_Cnt - 1)
   'initialize index arrays
   ReDim IndMW(O_Cnt - 1)
   ReDim IndOrder(O_Cnt - 1)
   ReDim IndScan(O_Cnt - 1)
   For i = 0 To O_Cnt - 1
       IndMW(i) = i
       IndOrder(i) = i
       IndScan(i) = i
   Next i
   ReDim IsRep(O_Cnt - 1)
   ReDim IsUsed(O_Cnt - 1)
   UMCLoadArraysLocal = True
Else
   Erase O_Index
   Erase O_Type
   Erase O_MW
   Erase O_Abu
   Erase O_Order
   Erase O_Scan
End If
Exit Function

err_UMCLoadArraysLocal:
O_Cnt = 0               'this will cause everything to be cleared
Resume exit_UMCLoadArraysLocal
Status "Error loading arrays"
End Function

Private Sub DestroyStructuresLocal()
On Error Resume Next
O_Cnt = 0
CSCnt = 0
ISCnt = 0
Erase O_Index
Erase O_Type
Erase O_MW
Erase O_Abu
Erase O_Order
Erase O_Scan
Erase S_MW
Erase IndMW
Erase IndOrder
Erase IndScan
Erase IsRep
Erase IsUsed
Set MWRangeFinder = Nothing
End Sub

Private Function CreateIndMW() As Boolean
'--------------------------------------------------------------
'creates index on molecular mass; sorts its members and creates
'fast search object; returns True if successful
'--------------------------------------------------------------
Dim qsDbl As New QSDouble
On Error GoTo err_CreateIndMW
Status "Creating MW index"
S_MW = O_MW             'array assignment
CreateIndMW = qsDbl.QSAsc(S_MW, IndMW)
Set MWRangeFinder = New MWUtil
If Not MWRangeFinder.Fill(S_MW) Then GoTo err_CreateIndMW

exit_CreateIndMW:
Set qsDbl = Nothing
Exit Function

err_CreateIndMW:
Erase IndMW
Erase S_MW
Resume exit_CreateIndMW
Status "Error creating MW index"
End Function

Private Function CreateIndOrder() As Boolean
'--------------------------------------------------------------
'creates index on order and returns True if successful;
'index means that members on lower index positions are prefered
'to be selected as class representatives
'--------------------------------------------------------------
Dim TmpOrder() As Double
Dim qsDbl As New QSDouble
On Error GoTo err_CreateIndOrder
Status "Creating order index"
TmpOrder = O_Order                    'array assignment
Select Case UMCDef.UMCType
Case glUMC_TYPE_INTENSITY, glUMC_TYPE_ISHRINKINGBOX
    CreateIndOrder = qsDbl.QSDesc(TmpOrder, IndOrder)           'more is better
Case glUMC_TYPE_FIT, glUMC_TYPE_FSHRINKINGBOX
    CreateIndOrder = qsDbl.QSAsc(TmpOrder, IndOrder)            'less is better
Case Else
    Debug.Assert False
End Select

exit_CreateIndOrder:
Set qsDbl = Nothing
Exit Function

err_CreateIndOrder:
Erase IndOrder
Resume exit_CreateIndOrder
Status "Error creating order index"
End Function

Private Function CreateIndScan() As Boolean
'--------------------------------------------------------------
'creates index on scan numbers and returns True if successful
'--------------------------------------------------------------
Dim TmpScan() As Long
Dim qsLng As New QSLong
On Error GoTo err_CreateIndScan
Status "Creating scan index"
TmpScan = O_Scan                    'array assignment
CreateIndScan = qsLng.QSAsc(TmpScan, IndScan)

exit_CreateIndScan:
Set qsLng = Nothing
Exit Function

err_CreateIndScan:
Erase IndScan
Resume exit_CreateIndScan
Status "Error creating scan index"
End Function


Private Function UMCLocalBreakStandard() As Boolean
'------------------------------------------------------------------
'breaks class to unique mass classes and returns True if successful
'------------------------------------------------------------------
Dim bDone As Long
Dim bFoundNext As Boolean
Dim AbsTol As Double
Dim MWRangeMinInd As Long
Dim MWRangeMaxInd As Long
Dim AcceptedCnt As Long
Dim CurrMWRangeScan() As Long       'scan numbers of potential class members
Dim CurrMWRangeResInd() As Long     'indexes of accepted members
Dim MyPattern As New ScanGapPattern
Dim i As Long
On Error GoTo err_UMCLocalBreakStandard
CurrOrderInd = -1
MyPattern.MaxGapCount = UMCDef.GapMaxCnt
MyPattern.MaxGapSize = UMCDef.GapMaxSize
If Not ManageClasses(CallerID, UMCManageConstants.UMCMngInitialize) Then
   Status "Error initializing UMC memory structures."
   Exit Function
End If
With GelUMC(CallerID)
  Do Until bDone
    bFoundNext = False
    Do Until bFoundNext
       CurrOrderInd = CurrOrderInd + 1
       If CurrOrderInd > O_Cnt - 1 Then     'all data has been used
          bDone = True
          Exit Do
       Else
          'already used data can not be class representative
          If Not IsUsed(IndOrder(CurrOrderInd)) Then bFoundNext = True
       End If
    Loop
    If bFoundNext Then      'new class representative = new class
       CurrMW = O_MW(IndOrder(CurrOrderInd))
       CurrScan = O_Scan(IndOrder(CurrOrderInd))
       'find all data points close enough in mass to be potential class members
       Select Case UMCDef.TolType
       Case gltPPM
            AbsTol = UMCDef.Tol * CurrMW * glPPM
       Case gltABS
            AbsTol = UMCDef.Tol
       Case Else
            Debug.Assert False
       End Select
       MWRangeMinInd = 0
       MWRangeMaxInd = O_Cnt - 1
       If MWRangeFinder.FindIndexRange(CurrMW, AbsTol, MWRangeMinInd, MWRangeMaxInd) Then
          If PreparePotentialMWRange(MWRangeMinInd, MWRangeMaxInd) Then
             If CurrMWRangeCnt > 1 Then    'at least one more potential member beside representative
                ReDim CurrMWRangeScan(CurrMWRangeCnt - 1)       'scans
                ReDim CurrMWRangeResInd(CurrMWRangeCnt - 1)     'and indexes that should be accepted
                For i = 0 To CurrMWRangeCnt - 1
                    CurrMWRangeScan(i) = O_Scan(CurrMWRangeInd_O(i))
                Next i
                AcceptedCnt = ProcessScanPatternWrapper(MyPattern, CurrMWRangeScan, CurrScan, CurrMWRangeResInd)
             ElseIf CurrMWRangeCnt = 1 Then
                AcceptedCnt = 1
                ReDim CurrMWRangeResInd(0)
                CurrMWRangeResInd(0) = 0
             Else
                AcceptedCnt = 0
                Erase CurrMWRangeResInd
             End If
             If AcceptedCnt > 0 Then
                'assemble class
                .UMCCnt = .UMCCnt + 1
                If .UMCCnt Mod 25 = 0 Then
                    Status "Assembling class: " & .UMCCnt & " (" & Trim(Format(CurrOrderInd / O_Cnt * 100, "0.0")) & "% done)"
                    If glAbortUMCProcessing Then Exit Do
                End If
                If UBound(.UMCs) + 1 < .UMCCnt Then     'increase size
                   If Not ManageClasses(CallerID, UMCManageConstants.UMCMngAdd) Then GoTo err_UMCLocalBreakStandard
                End If
                With .UMCs(.UMCCnt - 1)
                    .ClassCount = AcceptedCnt
                    ReDim .ClassMInd(AcceptedCnt - 1)
                    ReDim .ClassMType(AcceptedCnt - 1)
                    For i = 0 To AcceptedCnt - 1
                        .ClassMInd(i) = O_Index(CurrMWRangeInd_O(CurrMWRangeResInd(i)))
                        .ClassMType(i) = O_Type(CurrMWRangeInd_O(CurrMWRangeResInd(i)))
                        IsUsed(CurrMWRangeInd_O(CurrMWRangeResInd(i))) = True
                    Next i
                    .ClassRepInd = O_Index(IndOrder(CurrOrderInd))
                    .ClassRepType = O_Type(IndOrder(CurrOrderInd))
                End With
                'mark class representative and class members as being used
                IsRep(IndOrder(CurrOrderInd)) = True
                IsUsed(IndOrder(CurrOrderInd)) = True
             End If
          End If
       End If
    End If
  Loop
End With
Call ManageClasses(CallerID, UMCManageConstants.UMCMngTrim)
Status "Number of classes: " & GelUMC(CallerID).UMCCnt
UMCLocalBreakStandard = True
Exit Function

err_UMCLocalBreakStandard:
Status "Error creating Unique Mass Classes"
End Function

Private Function ProcessScanPatternWrapper(ByRef MyPattern As ScanGapPattern, ByRef Scans() As Long, ByVal CurrScan As Long, ByRef ResInd() As Long)
    
    Dim lngMaxIndex As Long
    Dim lngIndex As Long
    
    Dim RelativeScans() As Long
    Dim CurrScanRelative As Long
    
    ' For LTQ-FT data, there can be gaps between scan numbers due to MS/MS scans interleaved between the MS scans
    ' To account for this, we'll replace the scan numbers in Scans() with their relative position in .ScanInfo()

    lngMaxIndex = UBound(Scans)
    ReDim RelativeScans(lngMaxIndex)
    
    For lngIndex = 0 To lngMaxIndex
        RelativeScans(lngIndex) = LookupScanNumberRelativeIndex(CallerID, Scans(lngIndex))
    Next lngIndex
    
    CurrScanRelative = LookupScanNumberRelativeIndex(CallerID, CurrScan)
    ProcessScanPatternWrapper = MyPattern.ProcessScanPattern(RelativeScans(), CurrScanRelative, ResInd())

End Function

Private Function UMCLocalBreakShrinkingBox() As Boolean
'----------------------------------------------------------------------
'breaks class to unique mass classes and returns True if successful;
'this function is a bit different from original Shrinking Box function
'but practically the results should be the same; the most significant
'difference is in the case of classes with shared elements
'ShrinkingBox description:
'Select class representative as before. Select data closer than 2*MWTol
'from the class representative; score each of potential patterns that
'contain class representative and does not stretch more than 2*MWTol
'----------------------------------------------------------------------
Dim bDone As Long
Dim bFoundNext As Boolean
Dim AbsTol As Double
Dim MWRangeMinInd As Long
Dim MWRangeMaxInd As Long
Dim AcceptedCnt As Long
Dim CurrMWRangeScan() As Long       'scan numbers of potential class members
Dim CurrMWRangeResInd() As Long     'indexes of accepted members
Dim MyPattern As New ScanGapPattern
Dim i As Long, j As Long
Dim BSC As Long
Dim BSCStart As Long
Dim BSCEnd As Long
Dim CurrEnd As Long
Dim EndFound As Boolean
Dim TmpCnt As Long
Dim TmpMWRangeScan() As Long
Dim TmpMWRangeResInd() As Long
Dim TmpAcceptedCnt As Long
On Error GoTo err_UMCLocalBreakShrinkingBox
CurrOrderInd = -1
MyPattern.MaxGapCount = UMCDef.GapMaxCnt
MyPattern.MaxGapSize = UMCDef.GapMaxSize
If Not ManageClasses(CallerID, UMCManageConstants.UMCMngInitialize) Then
   Status "Error initializing UMC memory structures."
   Exit Function
End If
With GelUMC(CallerID)
  Do Until bDone
    DoEvents
    bFoundNext = False
    Do Until bFoundNext
       CurrOrderInd = CurrOrderInd + 1
       If CurrOrderInd > O_Cnt - 1 Then     'all data has been used
          bDone = True
          Exit Do
       Else
          'already used data can not be class representative
          If Not IsUsed(IndOrder(CurrOrderInd)) Then bFoundNext = True
       End If
    Loop
    If bFoundNext Then      'new class representative = new class
       CurrMW = O_MW(IndOrder(CurrOrderInd))
       CurrScan = O_Scan(IndOrder(CurrOrderInd))
       'find all data points close enough in mass to be potential class members
       'note that max mw band width is double of the same parameter in Standard function
       Select Case UMCDef.TolType
       Case gltPPM
            AbsTol = 2 * UMCDef.Tol * CurrMW * glPPM
       Case gltABS
            AbsTol = 2 * UMCDef.Tol
       Case Else
            Debug.Assert False
       End Select
       MWRangeMinInd = 0
       MWRangeMaxInd = O_Cnt - 1
       If MWRangeFinder.FindIndexRange(CurrMW, AbsTol, MWRangeMinInd, MWRangeMaxInd) Then
          If PreparePotentialMWRange(MWRangeMinInd, MWRangeMaxInd) Then
             If CurrMWRangeCnt > 2 Then   'at least two more potential members beside representative
                If (CurrRepMWRangeInd = 0) Or (CurrRepMWRangeInd = CurrMWRangeCnt - 1) Then
                   'if representative is at the edge then everything could be included
                   ReDim CurrMWRangeScan(CurrMWRangeCnt - 1)       'scans
                   For i = 0 To CurrMWRangeCnt - 1
                       CurrMWRangeScan(i) = O_Scan(CurrMWRangeInd_O(i))
                   Next i
                Else    'find all potential scores and note the best for this class
                   BSC = -1
                   For i = 0 To CurrRepMWRangeInd
                       'assume that class starts at position i and see how far it could go with 2*MWTol
                       EndFound = False
                       CurrEnd = CurrMWRangeCnt - 1
                       Do Until EndFound                                'find the end
                          If Abs(O_MW(CurrMWRangeInd_O(CurrEnd)) - O_MW(CurrMWRangeInd_O(i))) <= AbsTol Then
                             EndFound = True
                          Else
                             CurrEnd = CurrEnd - 1
                             If CurrEnd <= CurrRepMWRangeInd Then EndFound = True
                          End If
                       Loop
                       'fill temporary arrays
                       TmpCnt = CurrEnd - i + 1
                       ReDim TmpMWRangeScan(TmpCnt - 1)
                       ReDim TmpMWRangeResInd(TmpCnt - 1) As Long
                       For j = i To CurrEnd
                           TmpMWRangeScan(j - i) = O_Scan(CurrMWRangeInd_O(j))
                       Next j
                       'do patterns to obtain the score
                       TmpAcceptedCnt = ProcessScanPatternWrapper(MyPattern, TmpMWRangeScan, CurrScan, TmpMWRangeResInd)
                       If MyPattern.BestScore > BSC Then        'if more than one this way we will remember
                          BSC = MyPattern.BestScore             'the first one(additional criteria could be
                          BSCStart = i                          'easily added to improve the classes
                          BSCEnd = CurrEnd
                       End If
                   Next i
                   'now prepare the real stuff with best score
                   If BSC > 0 Then
                      CurrMWRangeCnt = BSCEnd - BSCStart + 1
                      If CurrMWRangeCnt > 0 Then
                         ReDim CurrMWRangeScan(CurrMWRangeCnt - 1)
                         For i = 0 To CurrMWRangeCnt - 1            'shift current range left
                             CurrMWRangeInd_O(i) = CurrMWRangeInd_O(i + BSCStart)
                             CurrMWRangeScan(i) = O_Scan(CurrMWRangeInd_O(i))
                         Next i
                         ReDim Preserve CurrMWRangeInd_O(CurrMWRangeCnt - 1)
                      Else
                         Erase CurrMWRangeScan
                         Erase CurrMWRangeInd_O
                      End If
                   End If
                End If
             Else                                               'two or less
                ReDim CurrMWRangeScan(CurrMWRangeCnt - 1)       'scans
                For i = 0 To CurrMWRangeCnt - 1
                    CurrMWRangeScan(i) = O_Scan(CurrMWRangeInd_O(i))
                Next i
             End If
             'finally do the patterns if neccessary
             If CurrMWRangeCnt > 1 Then
                If CurrMWRangeCnt = 2 Then
                   DoEvents
                End If
                ReDim CurrMWRangeResInd(CurrMWRangeCnt - 1)     'indexes that should be accepted
                AcceptedCnt = ProcessScanPatternWrapper(MyPattern, CurrMWRangeScan, CurrScan, CurrMWRangeResInd)
'             ElseIf CurrMWRangeCnt = 2 Then         'class representative and one more - has to be the same class
'                AcceptedCnt = 2
'                ReDim CurrMWRangeResInd(1)
'                CurrMWRangeResInd(0) = 0
'                CurrMWRangeResInd(1) = 1
             ElseIf CurrMWRangeCnt = 1 Then
                AcceptedCnt = 1
                ReDim CurrMWRangeResInd(0)
                CurrMWRangeResInd(0) = 0            'this is not neccessary but to make things clear
             Else
                AcceptedCnt = 0
                Erase CurrMWRangeResInd
             End If
                          
             If AcceptedCnt > 0 Then
                'assemble class
                .UMCCnt = .UMCCnt + 1
                If .UMCCnt Mod 2 = 0 Then
                    Status "Assembling class: " & .UMCCnt & " (" & Trim(Format(CurrOrderInd / O_Cnt * 100, "0.0")) & "% done)"
                    If glAbortUMCProcessing Then Exit Do
                End If
                If UBound(.UMCs) + 1 < .UMCCnt Then     'increase size
                   If Not ManageClasses(CallerID, UMCManageConstants.UMCMngAdd) Then GoTo err_UMCLocalBreakShrinkingBox
                End If
                With .UMCs(.UMCCnt - 1)
                    .ClassCount = AcceptedCnt
                    ReDim .ClassMInd(AcceptedCnt - 1)
                    ReDim .ClassMType(AcceptedCnt - 1)
                    For i = 0 To AcceptedCnt - 1
                        .ClassMInd(i) = O_Index(CurrMWRangeInd_O(CurrMWRangeResInd(i)))
                        .ClassMType(i) = O_Type(CurrMWRangeInd_O(CurrMWRangeResInd(i)))
                        IsUsed(CurrMWRangeInd_O(CurrMWRangeResInd(i))) = True
                    Next i
                    .ClassRepInd = O_Index(IndOrder(CurrOrderInd))
                    .ClassRepType = O_Type(IndOrder(CurrOrderInd))
                End With
                'mark class representative and class members as being used
                IsRep(IndOrder(CurrOrderInd)) = True
                IsUsed(IndOrder(CurrOrderInd)) = True
             End If
          End If
       End If
    End If
  Loop
End With
Call ManageClasses(CallerID, UMCManageConstants.UMCMngTrim)
Status "Number of classes: " & GelUMC(CallerID).UMCCnt
UMCLocalBreakShrinkingBox = True
Exit Function

err_UMCLocalBreakShrinkingBox:
Status "Error creating Unique Mass Classes"
End Function


Private Function PreparePotentialMWRange(MWRangeMinInd As Long, MWRangeMaxInd As Long) As Boolean
'----------------------------------------------------------------------------------------
'prepares arrays of potential class members; if sharing is disallowed eliminates already
'used data points; returns True if positive number of potential class members; False on
'on any error (no class members found is error since at least class rep. should be there)
'----------------------------------------------------------------------------------------
Dim i As Long
Dim IndRange As Long
Dim ThisMWInd As Long               'index in IndMW
Dim bUseThis As Boolean
On Error GoTo err_PreparePotentialMWRange
IndRange = MWRangeMaxInd - MWRangeMinInd + 1
CurrRepMWRangeInd = -1              'index of class representative in current range
If IndRange > 0 Then
   ReDim CurrMWRangeInd_O(IndRange - 1)
   CurrMWRangeCnt = 0
   CurrRepInd_O = -1
   For i = 0 To IndRange - 1
       ThisMWInd = MWRangeMinInd + i
       bUseThis = False
       'always use class representative and remember its position in original array
       If IndOrder(CurrOrderInd) = IndMW(ThisMWInd) Then
          bUseThis = True
          CurrRepInd_O = IndMW(ThisMWInd)
       End If
       'and if sharing is disallowed use only not used data
       If UMCDef.UMCSharing Then
          bUseThis = True
       Else
          If Not IsUsed(IndMW(ThisMWInd)) Then bUseThis = True
       End If
       If bUseThis Then
          CurrMWRangeCnt = CurrMWRangeCnt + 1
          CurrMWRangeInd_O(CurrMWRangeCnt - 1) = IndMW(ThisMWInd)
          If CurrMWRangeInd_O(CurrMWRangeCnt - 1) = CurrRepInd_O Then
             CurrRepMWRangeInd = CurrMWRangeCnt - 1     'remember where the class representative is
          End If                                        'in the CurrMWRangeInd_O array
       End If
   Next i
   If CurrMWRangeCnt > 0 And CurrRepInd_O >= 0 Then
      If CurrMWRangeCnt < IndRange Then
         ReDim Preserve CurrMWRangeInd_O(CurrMWRangeCnt - 1)
      End If
      PreparePotentialMWRange = True
      Exit Function
   End If
End If

err_PreparePotentialMWRange:
Erase CurrMWRangeInd_O
CurrMWRangeCnt = 0
CurrRepInd_O = -1
End Function

