Attribute VB_Name = "MonroeLaVRoutines"
Option Explicit

Public Enum sdcSqlDecimalConstants
    sdcSqlDecimal9x4 = 0
    sdcSqlDecimal9x5 = 1
End Enum

Private Type udtUMCPeakSplitType
    PeakStartPoint As Long
    PeakEndPoint As Long
    MemberIndexStartPoint As Long
    MemberIndexEndPoint As Long
    MedianMass As Double
    StDevMass As Double
    Valid As Boolean
End Type

Public Sub AddOrUpdateCollectionArrayItem(ByRef udtCollectionArray() As udtCollectionArrayType, ByRef lngCollectionArrayCount As Long, strNameToUpdate As String, strValue As String, Optional blnAddIfMissingButDoNotUpdate As Boolean = False)
    ' Look in udtCollectionArray() for an entry with .Name = strNameToUpdate
    ' If found, update the value to strValue
    ' If not found, then add a new entry
    
    Dim lngIndex As Long
    Dim strItemName As String, strNameToUpdateForComparison As String
    Dim blnMatched As Boolean
    
On Error GoTo AddOrUpdateCollectionArrayItemErrorHandler
    
    Dim blnCaseSensitive As Boolean
    blnCaseSensitive = False
    
    If Not blnCaseSensitive Then
        strNameToUpdateForComparison = UCase(strNameToUpdate)
    Else
        strNameToUpdateForComparison = strNameToUpdate
    End If

    For lngIndex = 0 To lngCollectionArrayCount - 1
        
        strItemName = udtCollectionArray(lngIndex).Name
        If Not blnCaseSensitive Then strItemName = UCase(strItemName)
        
        If strItemName = strNameToUpdateForComparison Then
            If Not blnAddIfMissingButDoNotUpdate Then
                udtCollectionArray(lngIndex).Value = strValue
            End If
            blnMatched = True
            Exit For
        End If
    Next lngIndex
        
    If Not blnMatched Then
        If lngCollectionArrayCount < DBSTUFF_COLLECTION_COUNT_MAX Then
            udtCollectionArray(lngCollectionArrayCount).Name = strNameToUpdate
            udtCollectionArray(lngCollectionArrayCount).Value = strValue
            lngCollectionArrayCount = lngCollectionArrayCount + 1
        Else
            ' DBSTUFF_COLLECTION_COUNT_MAX must be too small; need to increase it
            Debug.Assert False
        End If
    End If
    
    Exit Sub
    
AddOrUpdateCollectionArrayItemErrorHandler:
    Debug.Assert False

End Sub

Public Sub AddToAnalysisHistory(lngGelIndex As Long, ByVal strNewHistoryText As String, Optional blnRemoveCrLf As Boolean = True)
    ' Adds a new entry to the Analysis history for Analysis at lngGelIndex
    Dim lngCharLoc As Long
    Dim strHistoryTextFormatted As String
    Dim strTimeStamp As String
    
    If lngGelIndex >= 1 And lngGelIndex <= UBound(GelBody()) Then
        With GelSearchDef(lngGelIndex)
            .AnalysisHistoryCount = .AnalysisHistoryCount + 1
            ReDim Preserve .AnalysisHistory(.AnalysisHistoryCount - 1)
            
            If blnRemoveCrLf Then
                Do
                    lngCharLoc = InStr(strNewHistoryText, vbCrLf)
                    If lngCharLoc > 0 Then
                        If lngCharLoc > 1 Then
                            strHistoryTextFormatted = Left(strNewHistoryText, lngCharLoc - 1)
                        End If
                        strHistoryTextFormatted = strHistoryTextFormatted & "; " & Mid(strNewHistoryText, lngCharLoc + 2)
                        strNewHistoryText = strHistoryTextFormatted
                    End If
                Loop While lngCharLoc > 0
            End If
            
            If glbPreferencesExpanded.AutoAnalysisStatus.Enabled Then
                strTimeStamp = Format(Now(), "Hh:Nn:Ss")
            Else
                strTimeStamp = Format(Now(), "yyyy mmmm dd, Hh:Nn:Ss")
            End If
            
            .AnalysisHistory(.AnalysisHistoryCount - 1) = strTimeStamp & " - " & strNewHistoryText
            
            ' Echo the history action to the Debug window
''            Debug.Print ">> " & Trim(lngGelIndex) & ": " & .AnalysisHistory(.AnalysisHistoryCount - 1)
            
            ' Mark file as Dirty
            GelStatus(lngGelIndex).Dirty = True
        End With
    Else
        ' Invalid lngGelIndex value was sent to this sub
        Debug.Assert False
    End If
End Sub

Public Function AppendToPath(ByVal strFilePath As String, ByVal strAppendText As String) As String
    ' Appends strAppendText to strFilePath
    ' Makes sure strFilePath ends in a backslash before adding strAppendText
    
    Dim fso As New FileSystemObject
    
    strFilePath = fso.BuildPath(strFilePath, strAppendText)
    
    Set fso = Nothing
    
    AppendToPath = strFilePath
End Function

Public Function BinarySearchDblFindNearest(ByRef dblArrayToSearch() As Double, ByVal dblItemToSearchFor As Double, Optional ByVal lngFirstIndex As Long = -1, Optional ByVal lngLastIndex As Long = -1, Optional ByVal blnReturnNextHighestIfMissing As Boolean = True) As Long
    ' Looks through dblArrayToSearch() for dblItemToSearchFor, returning
    '  the index of the item if found
    ' If not found, returns the index of the closest match, returning the next highest if blnReturnNextHighestIfMissing = True, or the next lowest if blnReturnNextHighestIfMissing = false
    ' Assumes dblArrayToSearch() is already sorted
    
    Dim lngMidIndex As Long
    Dim lngCurrentFirst As Long, lngCurrentLast As Long
    Dim lngMatchIndex As Long
    
On Error GoTo BinarySearchDblFindNearestErrorHandler

    If lngFirstIndex < 0 Or lngLastIndex < 0 Then
        lngFirstIndex = LBound(dblArrayToSearch())
        lngLastIndex = UBound(dblArrayToSearch())
    End If
    
    lngCurrentFirst = lngFirstIndex
    lngCurrentLast = lngLastIndex
    
    If lngCurrentFirst > lngCurrentLast Then
        ' Invalid indices were provided
        lngMatchIndex = -1
    ElseIf lngCurrentFirst = lngCurrentLast Then
        ' Search space is only one element long; simply return that element's index
        lngMatchIndex = lngCurrentFirst
    Else
        lngMidIndex = (lngCurrentFirst + lngCurrentLast) \ 2            ' Note: Using Integer division
        If lngMidIndex < lngCurrentFirst Then lngMidIndex = lngCurrentFirst
        
        Do While lngCurrentFirst <= lngCurrentLast And dblArrayToSearch(lngMidIndex) <> dblItemToSearchFor
            If dblItemToSearchFor < dblArrayToSearch(lngMidIndex) Then
                ' Search the lower half
                lngCurrentLast = lngMidIndex - 1
            ElseIf dblItemToSearchFor > dblArrayToSearch(lngMidIndex) Then
                ' Search the upper half
                lngCurrentFirst = lngMidIndex + 1
            End If
            ' Compute the new mid point
            lngMidIndex = (lngCurrentFirst + lngCurrentLast) \ 2
            If lngMidIndex < lngCurrentFirst Then
                lngMidIndex = lngCurrentFirst
                If lngMidIndex > lngCurrentLast Then
                    lngMidIndex = lngCurrentLast
                End If
                Exit Do
            End If
        Loop
        
        lngMatchIndex = -1
        ' See if an exact match has been found
        If lngMidIndex >= lngCurrentFirst And lngMidIndex <= lngCurrentLast Then
            If dblArrayToSearch(lngMidIndex) = dblItemToSearchFor Then
                lngMatchIndex = lngMidIndex
            End If
        End If
        
        If lngMatchIndex = -1 Then
            ' No exact match; find the nearest match
            If dblArrayToSearch(lngMidIndex) < dblItemToSearchFor Then
                If blnReturnNextHighestIfMissing Then
                    lngMatchIndex = lngMidIndex + 1
                    If lngMatchIndex > lngLastIndex Then lngMatchIndex = lngLastIndex
                Else
                    lngMatchIndex = lngMidIndex
                End If
            Else
                ' dblArrayToSearch(lngMidIndex) >= dblItemToSearchFor
                If blnReturnNextHighestIfMissing Then
                    lngMatchIndex = lngMidIndex
                Else
                    lngMatchIndex = lngMidIndex - 1
                    If lngMatchIndex < lngFirstIndex Then lngMatchIndex = lngFirstIndex
                End If
            End If
                
        End If
    End If
    
    BinarySearchDblFindNearest = lngMatchIndex
    Exit Function
    
BinarySearchDblFindNearestErrorHandler:
    Debug.Assert False
    BinarySearchDblFindNearest = -1
    Exit Function
    
End Function

Public Function BinarySearchLng(lngArrayToSearch() As Long, ByVal lngItemToSearchFor As Long, Optional ByVal lngFirstIndex As Long = -1, Optional ByVal lngLastIndex As Long = -1) As Long
    ' Looks through lngArrayToSearch() for lngItemToSearchFor, returning
    '  the index of the item if found, or -1 if not found
    ' Assumes lngArrayToSearch() is already sorted
    ' If lngFirstIndex < 0 or lngLastIndex is < 0 then uses LBound() and UBound() to determine the array range
    
    Dim lngMidIndex As Long
    
On Error GoTo BinarySearchLngErrorHandler

    If lngFirstIndex < 0 Or lngLastIndex < 0 Then
        lngFirstIndex = LBound(lngArrayToSearch())
        lngLastIndex = UBound(lngArrayToSearch())
    End If
    
    lngMidIndex = (lngFirstIndex + lngLastIndex) \ 2            ' Note: Using Integer division
    If lngMidIndex < lngFirstIndex Then lngMidIndex = lngFirstIndex
    
    Do While lngFirstIndex <= lngLastIndex And lngArrayToSearch(lngMidIndex) <> lngItemToSearchFor
        If lngItemToSearchFor < lngArrayToSearch(lngMidIndex) Then
            ' Search the lower half
            lngLastIndex = lngMidIndex - 1
        ElseIf lngItemToSearchFor > lngArrayToSearch(lngMidIndex) Then
            ' Search the upper half
            lngFirstIndex = lngMidIndex + 1
        End If
        ' Compute the new mid point
        lngMidIndex = (lngFirstIndex + lngLastIndex) \ 2
        If lngMidIndex < lngFirstIndex Then Exit Do
    Loop
    
    If lngMidIndex >= lngFirstIndex And lngMidIndex <= lngLastIndex Then
        If lngArrayToSearch(lngMidIndex) = lngItemToSearchFor Then
            BinarySearchLng = lngMidIndex
        Else
            BinarySearchLng = -1
        End If
    Else
        BinarySearchLng = -1
    End If
    Exit Function
    
BinarySearchLngErrorHandler:
    Debug.Assert False
    BinarySearchLng = -1
    Exit Function
End Function

Private Function BinarySearchStr(strArrayToSearch() As String, strItemToSearchFor As String, Optional ByVal lngFirstIndex As Long = -1, Optional ByVal lngLastIndex As Long = -1) As Long
    ' Looks through strArrayToSearch() for strItemToSearchFor, returning
    '  the index of the item if found, or -1 if not found
    ' Assumes strArrayToSearch() is already sorted
    ' If lngFirstIndex < 0 or lngLastIndex is < 0 then uses LBound() and UBound() to determine the array range
    
    Dim lngMidIndex As Long

On Error GoTo BinarySearchStrErrorHandler
    
    If lngFirstIndex < 0 Or lngLastIndex < 0 Then
        lngFirstIndex = LBound(strArrayToSearch())
        lngLastIndex = UBound(strArrayToSearch())
    End If
    
    lngMidIndex = (lngFirstIndex + lngLastIndex) \ 2            ' Note: Using Integer division
    If lngMidIndex < lngFirstIndex Then lngMidIndex = lngFirstIndex
    
    Do While lngFirstIndex <= lngLastIndex And strArrayToSearch(lngMidIndex) <> strItemToSearchFor
        If strItemToSearchFor < strArrayToSearch(lngMidIndex) Then
            ' Search the lower half
            lngLastIndex = lngMidIndex - 1
        ElseIf strItemToSearchFor > strArrayToSearch(lngMidIndex) Then
            ' Search the upper half
            lngFirstIndex = lngMidIndex + 1
        End If
        ' Compute the new mid point
        lngMidIndex = (lngFirstIndex + lngLastIndex) \ 2
        If lngMidIndex < lngFirstIndex Then Exit Do
    Loop
    
    If lngMidIndex >= lngFirstIndex And lngMidIndex <= lngLastIndex Then
        If strArrayToSearch(lngMidIndex) = strItemToSearchFor Then
            BinarySearchStr = lngMidIndex
        Else
            BinarySearchStr = -1
        End If
    Else
        BinarySearchStr = -1
    End If
    Exit Function
    
BinarySearchStrErrorHandler:
    Debug.Assert False
    BinarySearchStr = -1
    Exit Function
End Function

'Private Function BinarySearchLngRecursive(lngArrayToSearchZeroBased() As Long, lngFirstIndex As Long, lngLastIndex As Long, lngItemToSearchFor As Long) As Long
''--------------------------------------------------------------------------
'' THIS FUNCTION IS UNUSED
''
'' I wrote it to compare its execution speed with BinarySearchLng (above)
'' Searching 27000 items 57000 times takes 860 msec with this function, but 750 msec with the above one
''--------------------------------------------------------------------------
'
'    Dim lngMidIndex As Long
'
'    lngMidIndex = (lngFirstIndex + lngLastIndex) \ 2            ' Note: Using Integer Division
'
'    If lngMidIndex = lngFirstIndex Then 'Min and Max next to each other
'        If lngArrayToSearchZeroBased(lngFirstIndex) = lngItemToSearchFor Then
'            lngFirstIndex = lngLastIndex
'            BinarySearchLngRecursive = lngFirstIndex
'        ElseIf lngArrayToSearchZeroBased(lngLastIndex) = lngItemToSearchFor Then
'            lngLastIndex = lngMidIndex
'            BinarySearchLngRecursive = lngLastIndex
'        Else
'            BinarySearchLngRecursive = -1
'        End If
'
'        Exit Function
'    End If
'
'    If lngArrayToSearchZeroBased(lngMidIndex) > lngItemToSearchFor Then        'we are out of range on right
'        lngLastIndex = lngMidIndex
'        lngMidIndex = BinarySearchLngRecursive(lngArrayToSearchZeroBased(), lngFirstIndex, lngLastIndex, lngItemToSearchFor)
'    ElseIf lngArrayToSearchZeroBased(lngMidIndex) < lngItemToSearchFor Then    'we are out of range on left
'        lngFirstIndex = lngMidIndex
'        lngMidIndex = BinarySearchLngRecursive(lngArrayToSearchZeroBased(), lngFirstIndex, lngLastIndex, lngItemToSearchFor)
'    Else                                        'we found the item; nothing to do
'        BinarySearchLngRecursive = lngMidIndex
'    End If
'
'    BinarySearchLngRecursive = lngMidIndex
'
'End Function

Public Function CommandLineContainsAutomationCommand() As Boolean
    Dim strCmdLine As String
    
    strCmdLine = UCase(Trim(Command()))
    
    If InStr(strCmdLine, "/A") > 0 Or InStr(strCmdLine, "/I") > 0 Then
        CommandLineContainsAutomationCommand = True
    Else
        CommandLineContainsAutomationCommand = False
    End If
    
End Function

Public Function ComputeNET(ByVal lngScanNum As Long, ByVal dblNETSlope As Double, ByVal dblNETIntercept As Double) As Double
    ComputeNET = dblNETSlope * lngScanNum + dblNETIntercept
End Function

Private Function ComputeScanNumber(ByVal dblNET As Double, ByVal dblNETSlope As Double, ByVal dblNETIntercept As Double) As Long
    ComputeScanNumber = CLngSafe((dblNET - dblNETIntercept) / dblNETSlope)
End Function

Public Function ConfirmMassTagsAndInternalStdsLoaded(frmCallingForm As VB.Form, lngGelIndex As Long, blnShowMessages As Boolean, Optional ByRef intConnectAttemptCountReturn As Integer, Optional ByVal blnForceReload As Boolean = False, Optional ByVal blnLoadMTtoORFMapInfo As Boolean = True, Optional ByRef blnAMTsWereLoaded As Boolean = False, Optional ByRef blnDBConnectionError As Boolean = False) As Boolean
    ' Returns True if the Correct MassTags and Internal Standards are loaded
    ' Returns False if not, or if an error
    '
    ' If over MassTagStalenessOptions.MaximumAgeLoadedMassTagsHours has elapsed since the last load, then
    '  changes blnForceReload to True
    ' If (AMTCountWithNulls / AMTCountInDB) is >= MaximumFractionAMTsWithNulls, and (Now() - AMTLoadTime) is >= MinimumTimeBetweenReloadMinutes, then
    '  changes blnForceReload to True
    ' If AMTCountWithNulls >= MaximumCountAMTsWithNulls, and (Now() - AMTLoadTime) is >= MinimumTimeBetweenReloadMinutes, then
    '  changes blnForceReload to True
    '
    ' If the DB connection string is empty but CurrLegacyMTDatabase is defined, then assumes we're using AMTs from a legacy DB (aka an Access DB)
    
    '-----------------------------------------------
    'Load MT tag data from database if necessary;
    'If we determine we need to load MT tags, then we'll also load the internal standards
    '-----------------------------------------------
    Dim MassTagsLoaded As Boolean, ORFsLoaded As Boolean, InternalStandardsLoaded As Boolean
    Dim blnValuesAgree As Boolean
    Dim tmpConnStr As String
    Dim udtFilteringOptions As udtMTFilteringOptionsType
    
    Dim strMissingDBErrorMessage As String
    Dim lngDBConnectionTimoutLength As Long
    Dim fso As FileSystemObject
    
    strMissingDBErrorMessage = "MT tag database search not possible at this moment. " & vbCrLf & "Please define the database using menu option 'Steps->3. Select MT tags' in the main window."
    
    ' Lookup the current MT tags filter options
    LookupMTFilteringOptions lngGelIndex, udtFilteringOptions
    
    On Error GoTo err_LoadMTDB
       
    TraceLog 5, "ConfirmMassTagsAndInternalStdsLoaded", "Check if MT tags are loaded"
       
    ' Set the connection string
    tmpConnStr = GelAnalysis(lngGelIndex).MTDB.cn.ConnectionString

    ' Possibly load data from database if neccessary
    ' First see if new MT tags need to be loaded
    MassTagsLoaded = False
    If AMTCnt > 0 Then                    'if something loaded to AMT arrays
        If Len(CurrMTDatabase) > 0 Or Len(tmpConnStr) > 0 Then    'and it is not legacy database
            ' and desired MT tags are already loaded, then do not load
            With udtFilteringOptions
                If (UCase(CurrMTDatabase) = UCase(tmpConnStr)) And _
                   (CurrMTFilteringOptions.ConfirmedOnly = .ConfirmedOnly) And _
                   (CurrMTFilteringOptions.MinimumHighNormalizedScore = .MinimumHighNormalizedScore) And _
                   (CurrMTFilteringOptions.MinimumPMTQualityScore = .MinimumPMTQualityScore) And _
                   (CurrMTFilteringOptions.NETValueType = .NETValueType) Then
                   
                    blnValuesAgree = False
                    If CurrMTFilteringOptions.MTIncList = "" Or CurrMTFilteringOptions.MTIncList = "-1" Then
                        If .MTIncList = "" Or .MTIncList = "-1" Then
                            ' Functionally equivalent forms of MTIncList
                            blnValuesAgree = True
                        End If
                    Else
                        If UCase(CurrMTFilteringOptions.MTIncList) = UCase(.MTIncList) Then
                            blnValuesAgree = True
                        End If
                    End If
                    
                    If blnValuesAgree And CurrMTSchemaVersion >= 2 Then
                        If (CurrMTFilteringOptions.LimitToPMTsFromDataset = .LimitToPMTsFromDataset) Then
                            If .LimitToPMTsFromDataset Then
                                ' Limiting to MTs from the dataset for the given job; make sure the job number is the same
                                If CurrMTFilteringOptions.CurrentJob <> .CurrentJob Then
                                    blnValuesAgree = False
                                End If
                            End If
                        Else
                            blnValuesAgree = False
                        End If
                    End If

                    If blnValuesAgree Then
                        If CurrMTSchemaVersion < 2 Then
                            ' Schema version 1 (or unknown): examine MTSubsetID, AccurateOnly, and LockersOnly
                            If (CurrMTFilteringOptions.MTSubsetID = .MTSubsetID) And _
                               (CurrMTFilteringOptions.AccurateOnly = .AccurateOnly) And _
                               (CurrMTFilteringOptions.LockersOnly = .LockersOnly) Then
                                blnValuesAgree = True
                            Else
                                blnValuesAgree = False
                            End If
                        End If
                        
                        If CurrMTSchemaVersion < 1 Or CurrMTSchemaVersion >= 2 Then
                            ' Schema version 2; examine MinimumHighDiscriminantScore, MinimumPeptideProphetProbability, ExperimentInclusionFilter, ExperimentExclusionFilter, and InternalStandardExplicit
                            If (CurrMTFilteringOptions.MinimumHighDiscriminantScore = .MinimumHighDiscriminantScore) And _
                               (CurrMTFilteringOptions.MinimumPeptideProphetProbability = .MinimumPeptideProphetProbability) And _
                               (UCase(CurrMTFilteringOptions.ExperimentInclusionFilter) = UCase(.ExperimentInclusionFilter)) And _
                               (UCase(CurrMTFilteringOptions.ExperimentExclusionFilter) = UCase(.ExperimentExclusionFilter)) Then
                                blnValuesAgree = True
                            Else
                                blnValuesAgree = False
                            End If
                        End If
                        
                        MassTagsLoaded = blnValuesAgree
                    End If
                End If
            End With
        ElseIf Len(CurrLegacyMTDatabase) > 0 Then
            If GelData(lngGelIndex).PathtoDatabase = CurrLegacyMTDatabase Then
                MassTagsLoaded = True
            End If
        End If
       
        With glbPreferencesExpanded.MassTagStalenessOptions
            If .MaximumAgeLoadedMassTagsHours = 0 Then .MaximumAgeLoadedMassTagsHours = 8
            
            If Now() - .AMTLoadTime >= .MaximumAgeLoadedMassTagsHours / 24# Then blnForceReload = True
        
            If .AMTCountInDB > 0 Then
                If .AMTCountWithNulls / CDbl(.AMTCountInDB) >= .MaximumFractionAMTsWithNulls Or _
                   .AMTCountWithNulls >= .MaximumCountAMTsWithNulls Then
                    If Now() - .AMTLoadTime >= .MinimumTimeBetweenReloadMinutes / 1440# Then blnForceReload = True
                End If
            End If

        End With
    End If

    ' Now see if new internal standards need to be loaded
    InternalStandardsLoaded = False
    With udtFilteringOptions
        If CurrMTFilteringOptions.InternalStandardExplicit = "" And .InternalStandardExplicit = "" Then
            InternalStandardsLoaded = True
        ElseIf (UCase(CurrMTFilteringOptions.InternalStandardExplicit) = UCase(.InternalStandardExplicit)) And _
            CurrMTFilteringOptions.CurrentJob = .CurrentJob Then
            InternalStandardsLoaded = True
        End If
    End With

    blnAMTsWereLoaded = False
    If Not MassTagsLoaded Or blnForceReload Then
       If blnForceReload Then
            TraceLog 5, "ConfirmMassTagsAndInternalStdsLoaded", "Need to re-load MT tags (force reload)"
       Else
            TraceLog 5, "ConfirmMassTagsAndInternalStdsLoaded", "Need to re-load MT tags (difference found)"
       End If
       
       If Not GelAnalysis(lngGelIndex) Is Nothing Then
          If Len(GelAnalysis(lngGelIndex).MTDB.cn.ConnectionString) > 0 And Not APP_BUILD_DISABLE_MTS Then
            With glbPreferencesExpanded.AutoAnalysisOptions
               intConnectAttemptCountReturn = 0
               Do
                  If intConnectAttemptCountReturn = 0 Then
                      lngDBConnectionTimoutLength = .DBConnectionTimeoutSeconds
                  Else
                      ' On the second attempt (or higher), use of a longer timeout length may be beneficial
                      ' Take times 1.5 on the 2nd try, 2 on the third, 2.5 on the fourth, etc.
                      lngDBConnectionTimoutLength = .DBConnectionTimeoutSeconds * ((intConnectAttemptCountReturn + 2) / 2#)
                      ' Allow a maximum timeout length of 30 minutes
                      If lngDBConnectionTimoutLength > 1800 Then lngDBConnectionTimoutLength = 1800
                  End If
                  
                  MassTagsLoaded = LoadMassTags(lngGelIndex, frmCallingForm, CInt(lngDBConnectionTimoutLength), blnDBConnectionError)
                  If Not MassTagsLoaded And udtFilteringOptions.LimitToPMTsFromDataset Then
                      Exit Do
                  End If
                  
                  intConnectAttemptCountReturn = intConnectAttemptCountReturn + 1
               Loop While Not MassTagsLoaded And Not blnDBConnectionError And intConnectAttemptCountReturn < .DBConnectionRetryAttemptMax
               blnAMTsWereLoaded = MassTagsLoaded
            End With
            
          ElseIf Len(GelData(lngGelIndex).PathtoDatabase) > 0 Then
            MassTagsLoaded = ConnectToLegacyAMTDB(frmCallingForm, lngGelIndex, False, False, False)
            blnAMTsWereLoaded = MassTagsLoaded
          Else
            If blnShowMessages Then
                MsgBox strMissingDBErrorMessage, vbExclamation + vbOKOnly, "Error"
            End If
            MassTagsLoaded = False
          End If
       Else
          If blnShowMessages Then
              MsgBox strMissingDBErrorMessage, vbExclamation + vbOKOnly, "Error"
          End If
          MassTagsLoaded = False
       End If
    End If

    If MassTagsLoaded Then
        If Not InternalStandardsLoaded Or blnForceReload Then
            If blnForceReload Then
                 TraceLog 5, "ConfirmMassTagsAndInternalStdsLoaded", "Need to re-load internal standards (force reload)"
            Else
                 TraceLog 5, "ConfirmMassTagsAndInternalStdsLoaded", "Need to re-load internal standards (difference found)"
            End If
        
            If Not GelAnalysis(lngGelIndex) Is Nothing Then
              If Len(GelAnalysis(lngGelIndex).MTDB.cn.ConnectionString) > 0 And Not APP_BUILD_DISABLE_MTS Then
                With glbPreferencesExpanded.AutoAnalysisOptions
                    intConnectAttemptCountReturn = 0
                    Do
                        InternalStandardsLoaded = LoadInternalStandards(frmCallingForm, lngGelIndex, udtFilteringOptions)
                        intConnectAttemptCountReturn = intConnectAttemptCountReturn + 1
                    Loop While Not InternalStandardsLoaded And intConnectAttemptCountReturn < .DBConnectionRetryAttemptMax
                End With
              End If
            End If
        End If
    End If
    
    If MassTagsLoaded And blnAMTsWereLoaded And blnLoadMTtoORFMapInfo Then
        If Not GelAnalysis(lngGelIndex) Is Nothing Then
          If Len(GelAnalysis(lngGelIndex).MTDB.cn.ConnectionString) > 0 And Not APP_BUILD_DISABLE_MTS Then
            With glbPreferencesExpanded.AutoAnalysisOptions
                intConnectAttemptCountReturn = 0
                Do
                    ORFsLoaded = LoadMassTagToProteinMapping(frmCallingForm, lngGelIndex, False)
                    intConnectAttemptCountReturn = intConnectAttemptCountReturn + 1
                Loop While Not ORFsLoaded And intConnectAttemptCountReturn < .DBConnectionRetryAttemptMax
            End With
          ElseIf Len(GelData(lngGelIndex).PathtoDatabase) > 0 Then
            ' Note: Do not call LegacyDBLoadProteinData() here, since it is called by ConnectToLegacyAMTDB
          End If
        End If
    End If
        
    ConfirmMassTagsAndInternalStdsLoaded = MassTagsLoaded
    Exit Function
    
err_LoadMTDB:
    Debug.Assert False
    Select Case Err.Number
    Case 91         'object variable not set
        If blnShowMessages And Not glbPreferencesExpanded.AutoAnalysisStatus.Enabled Then
            MsgBox strMissingDBErrorMessage, vbExclamation + vbOKOnly, "Error"
        End If
    Case Else
        If blnShowMessages And Not glbPreferencesExpanded.AutoAnalysisStatus.Enabled Then
            MsgBox "An error occurred while loading the MT tags", vbExclamation + vbOKOnly, "Error"
        End If
        LogErrors Err.Number, "MonroeLaVRoutines->ConfirmMassTagsAndInternalStdsLoaded"
    End Select
    ConfirmMassTagsAndInternalStdsLoaded = False
    
End Function

Public Function ConstructUMCIndexList(lngGelIndex As Long, lngIonIndex As Long, intIonType As Integer) As String
    Dim strUMCIndices As String
    Dim lngIndex As Long

On Error GoTo ConstructUMCIndexListErrorHandler

    With GelDataLookupArrays(lngGelIndex)
        Select Case intIonType
        Case glCSType
            With .CSUMCs(lngIonIndex)
                For lngIndex = 0 To .UMCCount - 1
                    If Len(strUMCIndices) > 0 Then strUMCIndices = strUMCIndices & glARG_SEP
                    strUMCIndices = strUMCIndices & Trim(.UMCs(lngIndex))
                Next lngIndex
            End With
        Case glIsoType
            With .IsoUMCs(lngIonIndex)
                For lngIndex = 0 To .UMCCount - 1
                    If Len(strUMCIndices) > 0 Then strUMCIndices = strUMCIndices & glARG_SEP
                    strUMCIndices = strUMCIndices & Trim(.UMCs(lngIndex))
                Next lngIndex
            End With
        End Select
    End With
    
    ConstructUMCIndexList = strUMCIndices

    Exit Function
    
ConstructUMCIndexListErrorHandler:

End Function

Public Function ConstructAnalysisParametersText(lngGelIndex As Long, strUMCSearchMode As String, strMassTagSearchMode As String, Optional strIniFileName As String = "") As String
    ' strUMCSearchMode should be AUTO_ANALYSIS_UMC2003 = "UMC2003" or AUTO_ANALYSIS_UMCIonNet = "UMCIonNet" or something similar
    ' strMassTagSearchMode should be AUTO_SEARCH_EXPORT_UMCS_ONLY, AUTO_SEARCH_ORGANISM_MTDB = "IndividualPeaks" or AUTO_SEARCH_UMC_MTDB = "IndividualPeaksInUMCsWithoutNET" etc.
    
    Dim strParameters As String
    Dim sngMinFit As Single
    Dim strHistoryText As String, strMatch As String
    Dim strFileName As String
    
    sngMinFit = 1E+30
    strHistoryText = FindTextInAnalysisHistory(lngGelIndex, "calculated fit better than")
    If Len(strHistoryText) > 0 Then
        strMatch = Trim(MatchAndSplit(LCase(strHistoryText), "better than", "loaded"))
        If Len(strMatch) > 0 And IsNumeric(Trim(strMatch)) Then
            sngMinFit = CSng(Trim(strMatch))
        End If
    End If
    
    ' See if a filter by fit is defined
    If GelData(lngGelIndex).DataFilter(fltIsoFit, 0) = True Then
        If GelData(lngGelIndex).DataFilter(fltIsoFit, 1) < sngMinFit Then
            sngMinFit = GelData(lngGelIndex).DataFilter(fltIsoFit, 1)
        End If
    End If
    
    If Len(strIniFileName) > 0 Then
        strParameters = "IniFile=" & strIniFileName & vbCrLf
    Else
        strParameters = "IniFile=N/A" & vbCrLf
    End If
    
    If sngMinFit > 1E+29 Then
        AppendToString strParameters, "Fit<=N/A", True
    Else
        AppendToString strParameters, "Fit<=" & Trim(sngMinFit), True
    End If
    
    AppendToString strParameters, "Standard MMA=" & Trim(samtDef.MWTol), True
    AppendToString strParameters, "Standard ET=" & Trim(samtDef.NETTol), True
    AppendToString strParameters, "Standard ET Type=" & Trim(samtDef.NETorRT), True
    
    With GelUMC(lngGelIndex).def
        Select Case .UMCType
        Case glUMC_TYPE_INTENSITY
          strMatch = "Intensity"
        Case glUMC_TYPE_FIT
          strMatch = "Fit"
        Case glUMC_TYPE_MINCNT
          strMatch = "Minimize count"
        Case glUMC_TYPE_MAXCNT
          strMatch = "Maximize count"
        Case glUMC_TYPE_UNQAMT
          strMatch = "Unique AMT Hits"
        Case glUMC_TYPE_ISHRINKINGBOX
          strMatch = "Intensity with shrinking box"
        Case glUMC_TYPE_FSHRINKINGBOX
          strMatch = "Fit with shrinking box"
        Case glUMC_TYPE_FROM_NET
          strMatch = "UMCIonNet search"
        Case Else
            strMatch = "?? (" & Trim(.UMCType) & ")"
        End Select
        
        AppendToString strParameters, "Standard UMC=" & Trim(.Tol) & glARG_SEP & Trim(.GapMaxCnt) & glARG_SEP & Trim(.GapMaxSize) & glARG_SEP & Trim(Round(.GapMaxPct * 100, 0)) & glARG_SEP & strMatch, True
        AppendToString strParameters, UMC_SEARCH_MODE_SETTING_TEXT & "=" & strUMCSearchMode, True
        AppendToString strParameters, "UMC Ion Sharing=" & Trim(CStr(.UMCSharing)), True
        AppendToString strParameters, "UMC Interpolate Gaps=" & Trim(CStr(.InterpolateGaps)) & glARG_SEP & Trim(.InterpolateMaxGapSize), True
        
        AppendToString strParameters, "UMC Class Stats use Stats From Most Abu Charge State=" & Trim(CStr(.UMCClassStatsUseStatsFromMostAbuChargeState)), True
        
        Select Case .ChargeStateStatsRepType
        Case UMCChargeStateGroupConstants.UMCCSGHighestSum: strMatch = "Highest Abundance Sum"
        Case UMCChargeStateGroupConstants.UMCCSGMostAbuMember: strMatch = "Most Abundant Member"
        Case UMCChargeStateGroupConstants.UMCCSGMostMembers: strMatch = "Most Members"
        Case Else: strMatch = "?? (" & Trim(.ChargeStateStatsRepType) & ")"
        End Select
        AppendToString strParameters, "UMC Charge State Rep Type=" & Trim(strMatch), True
        
        AppendToString strParameters, "MT tag Matching Search Mode=" & strMassTagSearchMode, True
        
        Select Case .ClassMW
        Case UMCClassMassConstants.UMCMassAvg: strMatch = "Average"
        Case UMCClassMassConstants.UMCMassRep: strMatch = "Class Rep"
        Case UMCClassMassConstants.UMCMassMed: strMatch = "Median"
        Case Else: strMatch = "?? (" & Trim(.ClassMW) & ")"
        End Select
        AppendToString strParameters, "UMC Mass=" & strMatch, True
        
        Select Case .ClassAbu
        Case UMCClassAbundanceConstants.UMCAbuAvg: strMatch = "Average"
        Case UMCClassAbundanceConstants.UMCAbuSum: strMatch = "Sum"
        Case UMCClassAbundanceConstants.UMCAbuRep: strMatch = "Class Rep"
        Case UMCClassAbundanceConstants.UMCAbuMed: strMatch = "Median"
        Case UMCClassAbundanceConstants.UMCAbuMax: strMatch = "Maximum"
        Case Else: strMatch = "?? (" & Trim(.ClassAbu) & ")"
        End Select
        AppendToString strParameters, "UMC Abundance=" & strMatch, True
        
    End With
    
    With GelUMCNETAdjDef(lngGelIndex)
        If .UseRobustNETAdjustment And .RobustNETAdjustmentMode >= UMCRobustNETModeConstants.UMCRobustNETWarpTime Then
            AppendToString strParameters, "NET Adjustment using Warping; Num Sections=" & Trim(.MSWarpOptions.NumberOfSections) & glARG_SEP & "Max Distortion=" & Trim(.MSWarpOptions.MaxDistortion) & glARG_SEP & "Contraction Factor=" & Trim(.MSWarpOptions.ContractionFactor) & glARG_SEP & "Minimum MT tag Obs Count=" & Trim(.MSWarpOptions.MinimumPMTTagObsCount), True
            AppendToString strParameters, "NET Adjustment Params=" & Trim(.MWTol) & " " & GetSearchToleranceUnitText(CInt(.MWTolType)) & glARG_SEP & Trim(Round(UMCNetAdjDef.MSWarpOptions.NETTol, 4)) & " NET", True
        Else
            AppendToString strParameters, "NET Adjustment UMC Selection=" & Trim(.MinUMCCount) & glARG_SEP & Trim(.MinScanRange) & glARG_SEP & Trim(.MaxScanPct) & glARG_SEP & Trim(.TopAbuPct), True
            AppendToString strParameters, "NET Adjustment Params=" & Trim(.MWTol) & " " & GetSearchToleranceUnitText(CInt(.MWTolType)) & glARG_SEP & Trim(Round(UMCNetAdjDef.NETTolIterative, 4)) & " NET", True
        End If
    End With

    strFileName = LCase(GelData(lngGelIndex).FileName)
    If InStr(strFileName, "_ic.pek") Then
        strMatch = "ic_PEK"
    ElseIf InStr(strFileName, "_s.pek") Then
        strMatch = "s_PEK"
    ElseIf InStr(strFileName, "decal.pek") Or InStr(strFileName, ".pek-3") Then
        strMatch = "decal_PEK"
    ElseIf InStr(strFileName, "_ic.csv") Then
        strMatch = "ic_CSV"
    ElseIf InStr(strFileName, "_s.csv") Then
        strMatch = "s_CSV"
    ElseIf InStr(strFileName, ".csv") Then
        strMatch = "CSV"
    ElseIf InStr(strFileName, ".mzxml") Then
        strMatch = "mzXML"
    ElseIf InStr(strFileName, ".mzdata") Then
        strMatch = "mzData"
    ElseIf InStr(strFileName, ".xml") Then
        strMatch = "mzXML or mzData"
    Else
        strMatch = "PEK"
    End If
     
    AppendToString strParameters, "PEK=" & strMatch, True
    
    ConstructAnalysisParametersText = strParameters
    
End Function

Public Function ConstructConnectionString(strServerName As String, strDBName As String, strModelConnectionString As String) As String

    ' Typical ADODB connection string format:
    '  Provider=sqloledb;Data Source=pogo;Initial Catalog=MT_Deinococcus_P20;User ID=mtuser;Password=mt4fun
    ' Typical .NET connection string format:
    '  Server=pogo;database=MT_Main;uid=mtuser;Password=mt4fun

    Dim strConnStrParts() As String
    Dim strParameterName As String
    Dim strNewConnStr As String
    
    Dim intIndex As Integer
    Dim intCharIndex As Integer
    
    strConnStrParts = Split(strModelConnectionString, ";")
    strNewConnStr = ""
    
    For intIndex = 0 To UBound(strConnStrParts)
        intCharIndex = InStr(strConnStrParts(intIndex), "=")
        If intCharIndex > 0 Then
            strParameterName = Left(strConnStrParts(intIndex), intCharIndex - 1)
            Select Case LCase(Trim(strParameterName))
            Case "data source", "server"
                ' Server name
                strConnStrParts(intIndex) = strParameterName & "=" & strServerName
            Case "initial catalog", "database"
                ' DB name
                strConnStrParts(intIndex) = strParameterName & "=" & strDBName
            Case Else
                ' Ignore this entry
            End Select
        End If
        
        If Len(strNewConnStr) > 0 Then
            strNewConnStr = strNewConnStr & ";"
        End If
        strNewConnStr = strNewConnStr & strConnStrParts(intIndex)
        
    Next intIndex
    
    ConstructConnectionString = strNewConnStr

End Function

Public Function ConstructMassTagModMassDescription(udtMassMods As udtDBSearchMassModificationOptionsType)
    
    Dim strAnalysisHistoryInfo As String
    
    strAnalysisHistoryInfo = ""

    With udtMassMods
        If .PEO Then strAnalysisHistoryInfo = strAnalysisHistoryInfo & "; added PEO (" & glPEO & ")"
        If .ICATd0 Then strAnalysisHistoryInfo = strAnalysisHistoryInfo & "; added D0 ICAT (" & glICAT_Light & ")"
        If .ICATd8 Then strAnalysisHistoryInfo = strAnalysisHistoryInfo & "; added D8 ICAT (" & glICAT_Heavy & ")"
        If .Alkylation Then strAnalysisHistoryInfo = strAnalysisHistoryInfo & "; alkylated cysteines (" & .AlkylationMass & ")"
        If Len(.ResidueToModify) > 0 Then
            strAnalysisHistoryInfo = strAnalysisHistoryInfo & "; added " & Round(.ResidueMassModification, 5) & " Da to " & .ResidueToModify & " residues"
        ElseIf .ResidueMassModification <> 0 Then
            strAnalysisHistoryInfo = strAnalysisHistoryInfo & "; added " & Round(.ResidueMassModification, 5) & " Da to each MT tag"
        End If
        
        If Len(strAnalysisHistoryInfo) > 0 Then
            If .DynamicMods Then
                strAnalysisHistoryInfo = strAnalysisHistoryInfo & "; Mod Type = Dynamic"
            Else
                strAnalysisHistoryInfo = strAnalysisHistoryInfo & "; Mod Type = Fixed"
            End If
        End If
        
        If .N15InsteadOfN14 Then
            strAnalysisHistoryInfo = strAnalysisHistoryInfo & "; N type = N15"
        End If
    End With
    
    If Len(strAnalysisHistoryInfo) > 0 Then
        strAnalysisHistoryInfo = "Used modified MT tag masses" & strAnalysisHistoryInfo
    End If
    
    ConstructMassTagModMassDescription = strAnalysisHistoryInfo
End Function

Public Function ConstructMTStatusText(blnIncludePMTLimitingWarning As Boolean) As String
    Dim strText As String
    
    strText = "MT tag count: " & LongToStringWithCommas(AMTCnt)
    With CurrMTFilteringOptions
        If .LimitToPMTsFromDataset And .CurrentJob <> 0 And blnIncludePMTLimitingWarning Then
            strText = strText & " (Limiting to dataset for job " & Trim(.CurrentJob) & ")"
        End If
    End With
    
    If Not APP_BUILD_DISABLE_MTS Then
        strText = strText & "; Internal Std count: " & LongToStringWithCommas(UMCInternalStandards.Count)
    End If
    
    ConstructMTStatusText = strText
End Function

Public Function ConstructNETFormula(dblSlope As Double, dblIntercept As Double, Optional blnReturnGeneric As Boolean = False) As String

    If blnReturnGeneric Then
        ConstructNETFormula = "(FN-MinFN)/(MaxFN-MinFN)"
    Else
        ConstructNETFormula = Format$(dblSlope, "0.00000000") & " * FN + (" & Format$(dblIntercept, "0.0000000") & ")"
    End If
End Function

Public Function ConstructNETFormulaWithDefaults(udtUMCNetAdjDef As NetAdjDefinition) As String

    With udtUMCNetAdjDef
        If .InitialSlope <> 0 Then
            ConstructNETFormulaWithDefaults = ConstructNETFormula(.InitialSlope, .InitialIntercept)
        Else
            ConstructNETFormulaWithDefaults = ConstructNETFormula(0, 0, True)
        End If
    End With

End Function

Public Function ConstructUMCDefDescription(lngGelIndex As Long, strSearchModeTypeDesc As String, udtUMCDef As UMCDefinition, ByRef udtUMCAdvancedStatsOptions As udtUMCAdvancedStatsOptionsType, blnAllowMemberSharing As Boolean, Optional blnUMCIonNet As Boolean = False) As String
    
    Dim strDesc As String
    Dim strAddnlText As String
    
    On Error GoTo ConstructUMCDefDescriptionErrorHandler
    
    strDesc = ""
    strDesc = strDesc & "Identified UMC's (" & UMC_SEARCH_MODE_SETTING_TEXT & ": " & strSearchModeTypeDesc & ")"
    strDesc = strDesc & "; UMC Count = " & Trim(GelUMC(lngGelIndex).UMCCnt)
    strDesc = strDesc & "; Mass Tolerance = �" & Trim(udtUMCDef.Tol) & " " & GetSearchToleranceUnitText(CInt(udtUMCDef.TolType))
    
    If blnUMCIonNet Then
        strDesc = strDesc & " (max distance at " & Trim(UMC_IONNET_PPM_CONVERSION_MASS) & " Da)"
    Else
        strDesc = strDesc & "; Max # scan holes = " & Trim(udtUMCDef.GapMaxCnt) & "; Max size of holes = " & Trim(udtUMCDef.GapMaxSize) & " scans"
    End If
    
    strDesc = strDesc & "; Allow Member Sharing = " & Trim(blnAllowMemberSharing)
    
    If strSearchModeTypeDesc = AUTO_ANALYSIS_UMCListType2002 Then
        ' Obsolete search mode (July 2004)
        strDesc = strDesc & "; Allowed % of gaps = " & Format(udtUMCDef.GapMaxPct, "#00%")
    End If
    
    strDesc = strDesc & "; Interpolate gaps abundances = " & Trim(udtUMCDef.InterpolateGaps)
    strDesc = strDesc & "; Interpolate max gap size = " & Trim(udtUMCDef.InterpolateMaxGapSize)
    strDesc = strDesc & "; Class Stats use Stats from Most Abu Charge State = " & Trim(udtUMCDef.UMCClassStatsUseStatsFromMostAbuChargeState)
    strDesc = strDesc & "; Most Abu Charge State Group Type = " & Trim(udtUMCDef.ChargeStateStatsRepType)
    
    Select Case udtUMCDef.ClassMW
        Case UMCClassMassConstants.UMCMassAvg: strAddnlText = "Average class mass"
        Case UMCClassMassConstants.UMCMassRep: strAddnlText = "Mass of class representative"
        Case UMCClassMassConstants.UMCMassMed: strAddnlText = "Median"
        Case UMCClassMassConstants.UMCMassAvgTopX, UMCClassMassConstants.UMCMassMedTopX
            If udtUMCDef.ClassMW = UMCClassMassConstants.UMCMassAvgTopX Then
                strAddnlText = "Average of top X members"
            Else
                Debug.Assert udtUMCDef.ClassMW = UMCClassMassConstants.UMCMassMedTopX
                strAddnlText = "Median of top X members"
            End If
            With udtUMCAdvancedStatsOptions
                If .ClassMassTopXMinAbu <= 0 And .ClassMassTopXMaxAbu <= 0 Then
                    strAddnlText = strAddnlText & "; ClassMassTopX MaxMembers = " & Trim(.ClassMassTopXMinMembers)
                Else
                    strAddnlText = strAddnlText & "; ClassMassTopX MinAbu,MaxAbu,MinMembers = " & Trim(.ClassMassTopXMinAbu) & "," & Trim(.ClassMassTopXMaxAbu) & "," & Trim(.ClassMassTopXMinMembers)
                End If
            End With
        Case Else: strAddnlText = "Unknown type"
    End Select
    strDesc = strDesc & "; Class mass = " & strAddnlText
    
    Select Case udtUMCDef.ClassAbu
        Case UMCClassAbundanceConstants.UMCAbuAvg: strAddnlText = "Class average abundance"
        Case UMCClassAbundanceConstants.UMCAbuSum: strAddnlText = "Sum of class abundances"
        Case UMCClassAbundanceConstants.UMCAbuRep: strAddnlText = "Abundance of the class representative"
        Case UMCClassAbundanceConstants.UMCAbuMed: strAddnlText = "Median of class abundances"
        Case UMCClassAbundanceConstants.UMCAbuMax: strAddnlText = "Maximum of class abundances"
        Case UMCClassAbundanceConstants.UMCAbuSumTopX
            strAddnlText = "Sum of top X members"
            With udtUMCAdvancedStatsOptions
                If .ClassAbuTopXMinAbu <= 0 And .ClassAbuTopXMaxAbu <= 0 Then
                    strAddnlText = strAddnlText & "; ClassAbuTopX MaxMembers = " & Trim(.ClassAbuTopXMinMembers)
                Else
                    strAddnlText = strAddnlText & "; ClassAbuTopX MinAbu,MaxAbu,MinMembers = " & Trim(.ClassAbuTopXMinAbu) & "," & Trim(.ClassAbuTopXMaxAbu) & "," & Trim(.ClassAbuTopXMinMembers)
                End If
            End With
        Case Else: strAddnlText = "Unknown type"
    End Select
    strDesc = strDesc & "; Class abundance = " & strAddnlText
    
    ConstructUMCDefDescription = strDesc
    Exit Function
    
ConstructUMCDefDescriptionErrorHandler:
    Debug.Assert False
    LogErrors Err.Number, "ConstructUMCDefDescription"
    Resume Next
End Function

Public Function ConvoluteMass(ByVal dblMassMZ As Double, ByVal intCurrentCharge As Integer, Optional ByVal intDesiredCharge As Integer = 1) As Double
    ' Converts dblMassMZ to the MZ that would appear at the given intDesiredCharge
    ' To return the neutral mass, set intDesiredCharge to 0

    ' Mass of proton is glMASS_CC = 1.00727649               ' Note that this is the mass of hydrogen (1.0078246) minus the mass of one electron

    Dim dblNewMZ As Double

    If intCurrentCharge = intDesiredCharge Then
        dblNewMZ = dblMassMZ
    Else
        If intCurrentCharge = 1 Then
            dblNewMZ = dblMassMZ
        ElseIf intCurrentCharge <= 0 Then
            dblNewMZ = dblMassMZ + glMASS_CC
        Else
            dblNewMZ = (dblMassMZ * intCurrentCharge) - glMASS_CC * (intCurrentCharge - 1)
        End If

        If intDesiredCharge > 1 Then
            dblNewMZ = (dblNewMZ + glMASS_CC * (intDesiredCharge - 1)) / intDesiredCharge
        ElseIf intDesiredCharge = 0 Then
            dblNewMZ = dblNewMZ - glMASS_CC
        End If
    End If

    ConvoluteMass = dblNewMZ

End Function

Public Function DoubleToStringScientific(ByVal dblValue As Double, Optional intDigitsAfterDecimal As Integer = 2) As String
    Dim strZeroes As String
    
    If intDigitsAfterDecimal < 1 Then intDigitsAfterDecimal = 1
    If intDigitsAfterDecimal > 16 Then intDigitsAfterDecimal = 16
    strZeroes = String(intDigitsAfterDecimal, "0")
    
    DoubleToStringScientific = Format(dblValue, "0." & strZeroes & "E+00")
End Function


' Unused Function (July 2003)
'''Public Function ELCountViaMwtWin(strSequenceOneLetter As String, strElementSymbol As String, Optional blnSequenceIsThreeLetterCodes As Boolean = False) As Long
'''    ' Determines the empirical formula for strSequenceOneLetter
'''    ' Looks for strElementSymbol in the empirical formula
'''    ' Note that strElementSymbol must be properly capitalized
'''    ' Returns the number of atoms of the element in the formula
'''    ' Returns 0 if not found (or an error)
'''
'''    Dim strFormula As String, strNewformula As String
'''    Dim lngCharLoc As Long
'''    Dim lngError As Long
'''    Dim intElementID As Integer
'''
'''    If Not gMwtWinLoaded Then
'''        ELCountViaMwtWin = 0
'''        Exit Function
'''    End If
'''
'''    objMwtWin.Peptide.SetSequence strSequenceOneLetter, ntgHydrogen, ctgHydroxyl, blnSequenceIsThreeLetterCodes, True, False
'''
'''    strFormula = objMwtWin.Peptide.GetSequence(True, False, False, True, False)
'''
'''    ' If Xxx is present in strFormula then remove it
'''    Do
'''        lngCharLoc = InStr(strFormula, "Xxx")
'''        If lngCharLoc > 0 Then
'''            If lngCharLoc > 1 Then
'''                strNewformula = Left(strFormula, lngCharLoc - 1)
'''            End If
'''            strNewformula = strNewformula & Mid(strFormula, lngCharLoc + 3)
'''            strFormula = strNewformula
'''        End If
'''    Loop While lngCharLoc > 0
'''
'''    lngError = objMwtWin.Compound.SetFormula(strFormula)
'''
'''    If lngError = 0 Then
'''        If strElementSymbol = "N" Then
'''            intElementID = 7
'''        Else
'''            intElementID = objMwtWin.GetElementID(strElementSymbol)
'''        End If
'''
'''        ELCountViaMwtWin = objMwtWin.Compound.GetAtomCountForElement(intElementID)
'''    Else
'''        ELCountViaMwtWin = 0
'''    End If
'''
'''End Function


Public Function GetMassTagSearchSummaryText(strSearchDescription As String, lngHitCount As Long, sngMTMinimumHighNormalizedScore As Single, sngMTMinimumHighDiscriminantScore As Single, sngMTMinimumPeptideProphetProbability As Single, udtSAmtDef As SearchAMTDefinition, blnIncludeConglomerateNETStatus As Boolean, blnUsingCustomNETs As Boolean) As String
    Dim strScope As String
    Dim strSummary As String
    
    With udtSAmtDef
        If .SearchScope = glScope.glSc_All Then
            strScope = "All"
        Else
            strScope = "Points in View"
        End If
        ' Note: � = +- = + or -
        
        strSummary = Trim(strSearchDescription)
        strSummary = strSummary & "; Scope = " & strScope & "; Hit Count = " & Trim(lngHitCount) & "; Mass tolerance = �" & Trim(.MWTol) & " " & GetSearchToleranceUnitText(CInt(.TolType)) & "; NET Tolerance = �" & Trim(.NETTol)
        strSummary = strSummary & "; MT tag Minimum High Normalized Score = " & Trim(sngMTMinimumHighNormalizedScore)
        strSummary = strSummary & "; MT tag Minimum High Discriminant Score = " & Trim(sngMTMinimumHighDiscriminantScore)
        strSummary = strSummary & "; MT tag Minimum Peptide Prophet Probability = " & Trim(sngMTMinimumPeptideProphetProbability)
        If blnIncludeConglomerateNETStatus Then
            If glbPreferencesExpanded.UseUMCConglomerateNET Then
                strSummary = strSummary & "; ConglomerateNET used = True"
            Else
                strSummary = strSummary & "; ConglomerateNET used = False"
            End If
        End If
        If blnUsingCustomNETs Then
            strSummary = strSummary & "; Using Custom/Optimized NET values"
        Else
            strSummary = strSummary & "; Linear NET formula = " & .Formula
        End If
    End With
    
    GetMassTagSearchSummaryText = strSummary
    
End Function

Public Function GetProgramVersion() As String
    GetProgramVersion = App.major & "." & App.minor & " Build " & App.Revision
End Function
' Unused Function (February 2005)
''Public Function GetPeakAbuCriteria(NETPeakSelectionMode As Long) As String
''
''    Select Case NETPeakSelectionMode
''    Case UMCNetConstants.UMCNetBefore
''        GetPeakAbuCriteria = "BEFORE"
''    Case UMCNetConstants.UMCNetAt
''        GetPeakAbuCriteria = "AT"
''    Case UMCNetConstants.UMCNetAfter
''        GetPeakAbuCriteria = "AFTER"
''    Case UMCNetConstants.UMCNetFirst
''        GetPeakAbuCriteria = "FIRST"
''    Case UMCNetConstants.UMCNetLast
''        GetPeakAbuCriteria = "LAST"
''    Case Else
''        GetPeakAbuCriteria = "??"
''    End Select
''
''End Function

Public Function GetSearchToleranceUnitText(eTolType As glMassToleranceConstants) As String
    Select Case eTolType
    Case gltPPM
        GetSearchToleranceUnitText = "ppm"
    Case gltPct
        GetSearchToleranceUnitText = "percent"
    Case gltABS
        GetSearchToleranceUnitText = "Da"
    Case gltStd
        GetSearchToleranceUnitText = "std dev"
    Case Else
        GetSearchToleranceUnitText = "??"
    End Select
End Function

' Unused function (September 2006)
''Public Sub InitMwtWin()
''    Dim strMwtWinVersion As String
''
''On Error GoTo InitMwtWinErrorHandler
''
''    Set objMwtWin = New MolecularWeightCalculator
''
''    strMwtWinVersion = objMwtWin.AppVersion
''    Debug.Assert CSngSafe(strMwtWinVersion) > 2#
''
''    gMwtWinLoaded = True
''
''    Exit Sub
''
''InitMwtWinErrorHandler:
''
''    If Not CommandLineContainsAutomationCommand() Then
''        If Err.Number = -2147024770 Or Err.Number = 429 Then
''            MsgBox "Error connecting to MwtWinDll.Dll; you probably need to re-install this application or the Molecular Weight Calculator to properly register the DLL", vbExclamation + vbOKOnly, "Error"
''        Else
''            MsgBox "Unknown error while initializing MwtWinDll.Dll: " & Err.Description, vbExclamation + vbOKOnly, "Error"
''        End If
''    End If
''
''    gMwtWinLoaded = False
''
''End Sub

Public Function InitializeSPCommand(cmdSPCommand As ADODB.Command, cnnConnection As ADODB.Connection, strSPName As String) As Boolean
    ' Returns True if success, False if an error
    
On Error GoTo InitializeSPCommandErrorHandler

    TraceLog 3, "InitializeSPCommand", "Set cmdSPCommand.ActiveConnection"
    Set cmdSPCommand.ActiveConnection = cnnConnection
    With cmdSPCommand
        .CommandText = strSPName
        .CommandType = adCmdStoredProc
        .CommandTimeout = glbPreferencesExpanded.AutoAnalysisOptions.DBConnectionTimeoutSeconds
    End With

    InitializeSPCommand = True
    Exit Function

InitializeSPCommandErrorHandler:
    Debug.Print "Error initializing Stored Procedure Command: " & Err.Description
    LogErrors Err.Number, "InitializeSPCommand (command " & strSPName & ")"
    InitializeSPCommand = False

End Function

Public Sub InterpolateChromatogramGaps(ByVal lngGelIndex As Long, ByRef dblRawIntensity() As Double, lngLowIndex As Long, lngHighIndex As Long, lngScanNumberStart As Long)
    
    Dim lngChromIndex As Long
    Dim lngChromIndex2 As Long
    Dim lngChromIndexAdjacent As Long
    
    Dim lngScanNumber As Long
    Dim lngScanNumberAdjacent As Long
    
    Dim dblIntensityDifference As Double
    Dim lngScanDifference As Double
    
    Dim blnMatchFound As Boolean
    
On Error GoTo InterpolateChromatogramGapsErrorHandler

    For lngChromIndex = lngLowIndex To lngHighIndex - 1
        lngScanNumber = lngChromIndex + lngScanNumberStart - 1
        
        ' Lookup the adjacent scan number
        lngScanNumberAdjacent = LookupScanNumberNextPotential(lngGelIndex, lngScanNumber)
        
        If lngScanNumberAdjacent - lngScanNumber > 1 And lngScanNumberAdjacent > 0 Then
            ' Next adjacent scan is more than one scan away; interpolate the gap if
            '  the chromatogram intensity for either scan is non-zero
            lngChromIndexAdjacent = lngScanNumberAdjacent - lngScanNumberStart + 1
            
            If dblRawIntensity(lngChromIndex) > 0 Or dblRawIntensity(lngChromIndexAdjacent) > 0 Then
                ' Yes, definitely do interpolate
                
                dblIntensityDifference = dblRawIntensity(lngChromIndexAdjacent) - dblRawIntensity(lngChromIndex)
                lngScanDifference = lngChromIndexAdjacent - lngChromIndex
                
                For lngChromIndex2 = lngChromIndex + 1 To lngChromIndexAdjacent - 1
                    dblRawIntensity(lngChromIndex2) = dblRawIntensity(lngChromIndex) + dblIntensityDifference * ((lngChromIndex2 - lngChromIndex) / lngScanDifference)
                Next lngChromIndex2
            End If
            
        End If
    Next lngChromIndex
    Exit Sub
    
InterpolateChromatogramGapsErrorHandler:
    Debug.Print "Error in InterpolateChromatogramGaps: " & Err.Description
    Debug.Assert False
    LogErrors Err.Number, "InterpolateChromatogramGaps"
    If Not glbPreferencesExpanded.AutoAnalysisStatus.Enabled Then
        MsgBox "Error while interpolating chromatogram gaps: " & vbCrLf & Err.Description, vbInformation + vbOKOnly, "Error"
    End If
    
End Sub

Public Function LookupCollectionArrayValueByName(ByRef udtThisCollectionArray() As udtCollectionArrayType, ByVal lngArrayCount As Long, ByVal strNameToFind As String, Optional blnCaseSensitive As Boolean = False, Optional strNotFoundIndicator As String = "") As String
    ' Looks for entry in udtThisCollectionArray with .Name = strNameToFind
    ' Returns .Value if found
    ' Returns strNotFoundIndicator if not found, or if an error occurs
    
    Dim lngIndex As Long
    Dim strItemName As String, strValue As String
    Dim blnFound As Boolean
    
On Error GoTo LookupCollectionArrayValueErrorHandler

    If Not blnCaseSensitive Then
        strNameToFind = UCase(strNameToFind)
    End If
    
    For lngIndex = 0 To lngArrayCount - 1
        strItemName = udtThisCollectionArray(lngIndex).Name
        If Not blnCaseSensitive Then strItemName = UCase(strItemName)
        
        If strItemName = strNameToFind Then
            blnFound = True
            strValue = udtThisCollectionArray(lngIndex).Value
            Exit For
        End If
    Next lngIndex
    
    If Not blnFound Then
        LookupCollectionArrayValueByName = strNotFoundIndicator
    Else
        LookupCollectionArrayValueByName = strValue
    End If
    Exit Function

LookupCollectionArrayValueErrorHandler:
    Debug.Assert False
    LookupCollectionArrayValueByName = ""

End Function

Public Function LookupDefaultSeparationCharacter() As String

    Dim strAltSepChar As String
    
    strAltSepChar = glbPreferencesExpanded.AutoAnalysisOptions.OutputFileSeparationCharacter
    
    If Len(strAltSepChar) > 0 Then
        If Len(strAltSepChar) > 1 Then
            ' strAltSepChar probably is <TAB>
            LookupDefaultSeparationCharacter = vbTab
        Else
            LookupDefaultSeparationCharacter = Left(strAltSepChar, 1)
        End If
    Else
        LookupDefaultSeparationCharacter = vbTab
    End If

End Function

Public Function LookupExpressionRatioValue(lngGelIndex As Long, lngIonIndex As Long, Optional blnIsotopicData As Boolean = True, Optional sngValueIfNotDefined As Single = ER_NO_RATIO) As Double
    ' Returns the value in GelData(lngGelIndex).IsoData(lngIonIndex).ExpressionRatio
    '                   or GelData(lngGelIndex).CSData(lngIonIndex).ExpressionRatio
    ' If the value is equal to ER_NO_RATIO, then returns sngValueIfNotDefined
    
    Dim sngER As Single
    
    If blnIsotopicData Then
        sngER = GelData(lngGelIndex).IsoData(lngIonIndex).ExpressionRatio
    Else
        sngER = GelData(lngGelIndex).CSData(lngIonIndex).ExpressionRatio
    End If

    If sngER = ER_NO_RATIO Then
        sngER = sngValueIfNotDefined
    End If
    
    LookupExpressionRatioValue = sngER
End Function

Public Sub LookupMassAndNETErrorPeakStats(ByVal lngGelIndex As Long, ByRef udtMassCalErrorPeakCached As udtErrorPlottingPeakCacheType, ByRef udtNETTolErrorPeakCached As udtErrorPlottingPeakCacheType)
    ' If AutoAnalysis is enabled, then examines the data in glbPreferencesExpanded.AutoAnalysisCachedData to populate the Mass Cal Error and NET Tol Error variables
    ' If it is not enabled, or if the data is invalid, then extracts the relevant values from the analysis history

    Dim lngHistoryIndexOfMatch As Long
    Dim strValues() As String
    
    Dim intIndex As Integer
    
    Dim strEntryInAnalysisHistory As String
    
    Dim blnValidDataFound As Boolean
    
On Error GoTo LookupMassAndNETErrorPeakStatsErrorHandler

    blnValidDataFound = False
    If glbPreferencesExpanded.AutoAnalysisStatus.Enabled Then
         With glbPreferencesExpanded.AutoAnalysisCachedData
            udtMassCalErrorPeakCached = .MassCalErrorPeakCached
            udtNETTolErrorPeakCached = .NETTolErrorPeakCached
                
            blnValidDataFound = True
         End With
    End If

    If Not blnValidDataFound Then
        ' Look up the stats for the mass calibration calibration refinement peak
        strEntryInAnalysisHistory = Trim(FindSettingInAnalysisHistory(lngGelIndex, MASS_CALIBRATION_PEAK_STATS_START, lngHistoryIndexOfMatch, True, "=", MASS_CALIBRATION_PEAK_STATS_END))
        If lngHistoryIndexOfMatch >= 0 Then
            strValues = Split(strEntryInAnalysisHistory, ",")
            
            If UBound(strValues) >= 2 Then
                With udtMassCalErrorPeakCached
                    .Height = CLng(strValues(0))
                    .width = CDbl(strValues(1))
                    .Center = CDbl(strValues(2))
                    .SingleValidPeak = True
                End With
            End If
        End If
        
        ' Look up the stats for the NET tolerance refinement peak
        strEntryInAnalysisHistory = Trim(FindSettingInAnalysisHistory(lngGelIndex, NET_TOL_PEAK_STATS_START, lngHistoryIndexOfMatch, True, "=", NET_TOL_PEAK_STATS_END))
        If lngHistoryIndexOfMatch >= 0 Then
            strValues = Split(strEntryInAnalysisHistory, ",")
            
            If UBound(strValues) >= 2 Then
                With udtNETTolErrorPeakCached
                    .Height = CLng(strValues(0))
                    .width = CDbl(strValues(1))
                    .Center = CDbl(strValues(2))
                    .SingleValidPeak = True
                End With
            End If
        End If
    End If
    
    Exit Sub
    
LookupMassAndNETErrorPeakStatsErrorHandler:
    Debug.Assert False
    LogErrors Err.Number, "LookupMassAndNETErrorPeakStats"
    
End Sub

Public Function LookupNETValueTypeDescription(eNetValueType As nvtNetValueTypeConstants) As String
    Const NET_VALUE_TYPE_DESC_GANET = "Avg Obs NET - from DB"           ' Was previously "GANET - from DB"
    Const NET_VALUE_TYPE_DESC_PNET = "PNET - from DB"
    Const NET_VALUE_TYPE_DESC_THEORETICAL_NET = "Theoretical NET"       ' No longer supported (March 2006)

    Select Case eNetValueType
    Case nvtGANET
        LookupNETValueTypeDescription = NET_VALUE_TYPE_DESC_GANET
    Case nvtPNET
        LookupNETValueTypeDescription = NET_VALUE_TYPE_DESC_PNET
''    Case nvtTheoreticalNET
''        LookupNETValueTypeDescription = NET_VALUE_TYPE_DESC_THEORETICAL_NET
    Case Else
        LookupNETValueTypeDescription = NET_VALUE_TYPE_DESC_GANET
    End Select
    
End Function

Public Function LookupORFNamesForMTIDusingMTDBNamer(ByRef objMTDBNameLookupClass As mtdbMTNames, ByVal lngMassTagID As Long, ByRef ORFNames() As String) As Long
    ' Looks up all of the ORF's containing lngMassTagID, returning their names in ORFNames()
    ' The function returns the number of ORFs in ORFNames()
    
    Dim MTNames() As String
    Dim lngMTNamesCount As Long
    Dim lngMTNameIndex As Long, lngORFNameIndex As Long
    Dim strMTNameBase As String
    Dim lngORFNamesCount As Long
    Dim lngCharLoc As Long
    Dim blnMatched As Boolean
    
    lngMTNamesCount = objMTDBNameLookupClass.GetNamesForMTID(lngMassTagID, MTNames())
    If lngMTNamesCount > 0 Then
        ' Examine the MTNames in MTNames() and fill ORFNames()
        ReDim ORFNames(lngMTNamesCount)
        lngORFNamesCount = 0
        For lngMTNameIndex = LBound(MTNames()) To UBound(MTNames())
            ' Remove the extraneous information from MTNames()
            strMTNameBase = MTNames(lngMTNameIndex)
            lngCharLoc = InStr(strMTNameBase, ".")
            If lngCharLoc > 0 Then
                strMTNameBase = Left(strMTNameBase, lngCharLoc - 1)
            End If
            
            ' Look for strMTNameBase in ORFNames()
            blnMatched = False
            For lngORFNameIndex = 0 To lngORFNamesCount - 1
                If ORFNames(lngORFNameIndex) = strMTNameBase Then
                    blnMatched = True
                    Exit For
                End If
            Next lngORFNameIndex
            
            If Not blnMatched Then
                ORFNames(lngORFNamesCount) = strMTNameBase
                lngORFNamesCount = lngORFNamesCount + 1
            End If
        Next lngMTNameIndex
    End If

    LookupORFNamesForMTIDusingMTDBNamer = lngORFNamesCount
    
End Function

' May 2003: This function has been replaced by LookupORFNamesForMTIDusingMTtoORFMapOptimized
'''Public Function LookupORFNamesForMTIDusingMTtoORFMap(ByVal lngMassTagID As Long, ByRef ORFNameMatches() As String) As Long
'''    ' Looks up all of the ORF's mapped to lngMassTagID, returning their names in ORFNameMatches() -- a 0-based array
'''    ' The function returns the number of ORFs in ORFNameMatches()
'''
'''    Dim ORFIDMatches() As Long                                ' 0-based array holding ORF ref ID's
'''    Dim lngMTIndex As Long, lngORFIndex As Long
'''    Dim lngORFMatchCount As Long
'''    Dim blnMatched As Boolean
'''
'''    lngORFMatchCount = 0
'''    ReDim ORFIDMatches(0)
'''    ReDim ORFNameMatches(0)
'''
'''    ' Note that MTIDMap() and ORFIDMap() and ORFNameMatches() are 1-based arrays
'''    For lngMTIndex = 1 To MTtoORFMapCount
'''        If MTIDMap(lngMTIndex) = lngMassTagID Then
'''            ' See if we already have this entry int ORFIDMatches()
'''            blnMatched = False
'''            For lngORFIndex = 0 To lngORFMatchCount - 1
'''                If ORFIDMatches(lngORFIndex) = ORFIDMap(lngMTIndex) Then
'''                    blnMatched = True
'''                    Exit For
'''                End If
'''            Next lngORFIndex
'''            If Not blnMatched Then
'''                ReDim Preserve ORFIDMatches(lngORFMatchCount + 1)
'''                ReDim Preserve ORFNameMatches(lngORFMatchCount + 1)
'''                ORFIDMatches(lngORFMatchCount) = ORFIDMap(lngMTIndex)
'''                ORFNameMatches(lngORFMatchCount) = ORFRefNames(lngMTIndex)
'''                lngORFMatchCount = lngORFMatchCount + 1
'''            End If
'''        End If
'''    Next lngMTIndex
'''
'''    LookupORFNamesForMTIDusingMTtoORFMap = lngORFMatchCount
'''End Function

Public Function LookupORFNamesForMTIDusingMTtoORFMapOptimized(ByVal lngMassTagID As Long, ByRef ORFNameMatches() As String, ByRef objORFNameFastSearch As FastSearchArrayLong) As Long
    ' Looks up all of the ORF's mapped to lngMassTagID, returning their names in ORFNameMatches() -- a 0-based array
    ' The function returns the number of ORFs in ORFNameMatches()
    ' Requires that objORFNameFastSearch be initialized using .Fill() before calling this function
    
    Dim blnSuccess As Boolean, blnMatched As Boolean
    Dim lngMatchingIndices() As Long
    Dim lngMatchingIndicesCount As Long
    Dim lngIndex As Long
    Dim lngNameIndex As Long
    
    Dim ORFIDMatches() As Long                  ' 0-based array holding ORF ref ID's
                                                ' Used to prevent same ORF from being recorded twice in ORFNameMatches()
                                                ' However, if the ORFID value was Null in the database, then we cannot use this since the ORFID will be 0 in ORFIDMap()
    Dim lngMTIndex As Long, lngORFIndex As Long
    Dim lngORFMatchCount As Long
    
On Error GoTo LookupORFNamesErrorHandler

    ' Find the indices in MTIDMap() that match lngMassTagID
    ' Note that objORFNameFastSearch.Fill() was called previously using MTIDMap()
    blnSuccess = objORFNameFastSearch.FindMatchingIndices(lngMassTagID, lngMatchingIndices(), lngMatchingIndicesCount)
    
    lngORFMatchCount = 0
    ReDim ORFIDMatches(0)
    ReDim ORFNameMatches(0)
    
    If Not blnSuccess Then
        ' No match found; this may be an error
        Debug.Assert False
    Else
        ' At the most, there will be lngMatchingIndicesCount matches
        ReDim ORFIDMatches(lngMatchingIndicesCount)
        ReDim ORFNameMatches(lngMatchingIndicesCount)

        For lngIndex = 0 To lngMatchingIndicesCount - 1
            lngMTIndex = lngMatchingIndices(lngIndex)
        
            ' See if we already have this entry in ORFIDMatches() or in ORFRefNames()
            blnMatched = False
            For lngORFIndex = 0 To lngORFMatchCount - 1
                If ORFIDMatches(lngORFIndex) = ORFIDMap(lngMTIndex) Then
                    ' This will happen if the ORF_ID column in T_ORF_Reference was null
                    ' Perform a second check to see if ORFRefNames(lngMTIndex) is in ORFNameMatches()
                    ' If it is, set blnMatched to True
                    For lngNameIndex = 0 To lngORFMatchCount - 1
                        If ORFNameMatches(lngNameIndex) = ORFRefNames(lngMTIndex) Then
                            ' Will this ever happen?  Probably not.
                            Debug.Assert False
                            blnMatched = True
                            Exit For
                        End If
                    Next lngNameIndex
                End If
            Next lngORFIndex
            If Not blnMatched Then
                ORFIDMatches(lngORFMatchCount) = ORFIDMap(lngMTIndex)
                ORFNameMatches(lngORFMatchCount) = ORFRefNames(lngMTIndex)
                lngORFMatchCount = lngORFMatchCount + 1
            End If
        
        Next lngIndex
        
        If lngORFMatchCount > 1 Then
            ' Sort ORFNameMatches()
            ShellSortString ORFNameMatches(), 0, lngORFMatchCount - 1
        End If
    End If
    
    LookupORFNamesForMTIDusingMTtoORFMapOptimized = lngORFMatchCount
    Exit Function

LookupORFNamesErrorHandler:
    Debug.Assert False
    
End Function

Public Function LookupParallelStringArrayItemByName(ByRef strNameArray() As String, ByRef strValuesArray() As String, lngArrayCount As Long, ByVal strNameToFind As String, Optional blnCaseSensitive As Boolean = False, Optional strNotFoundIndicator As String = "") As String
    ' Looks for entry in strNameArray() matching strNameToFind, returning corresponding value in strValuesArray()
    ' Returns "" if strNameToFind is not found, or if an error occurs
    
    Dim lngIndex As Long
    Dim strItemName As String, strValue As String
    
On Error GoTo LookupParallelStringArrayItemErrorHandler

    strValue = strNotFoundIndicator
    If Not blnCaseSensitive Then
        strNameToFind = UCase(strNameToFind)
    End If
    
    For lngIndex = 0 To lngArrayCount
        strItemName = strNameArray(lngIndex)
        If Not blnCaseSensitive Then strItemName = UCase(strItemName)
        
        If strItemName = strNameToFind Then
            strValue = strValuesArray(lngIndex)
            Exit For
        End If
    Next lngIndex
    
    LookupParallelStringArrayItemByName = strValue
    Exit Function

LookupParallelStringArrayItemErrorHandler:
    Debug.Assert False
    LookupParallelStringArrayItemByName = strNotFoundIndicator

End Function

Public Function LookupScanNumberClosest(ByVal lngGelIndex As Long, ByVal lngScanNumberToFind As Long) As Long
    
    Dim lngMinScanNumber As Long
    Dim lngMaxScanNumber As Long
    
    Dim lngPreviousScanNumber As Long
    Dim lngNextScanNumber As Long
    Dim lngScanNumberNearest As Long
    
On Error GoTo LookupScanNumberClosestErrorHandler:

    With GelData(lngGelIndex)
        lngMinScanNumber = .ScanInfo(1).ScanNumber
        lngMaxScanNumber = .ScanInfo(UBound(.ScanInfo)).ScanNumber
    End With
     
    lngPreviousScanNumber = lngScanNumberToFind - 1
    Do While LookupScanNumberNextPotential(lngGelIndex, lngPreviousScanNumber) = 0 And lngPreviousScanNumber > lngMinScanNumber
        lngPreviousScanNumber = lngPreviousScanNumber - 1
    Loop
    If LookupScanNumberNextPotential(lngGelIndex, lngPreviousScanNumber) = 0 Then
        lngPreviousScanNumber = 0
    End If

    lngNextScanNumber = lngScanNumberToFind + 1
    Do While LookupScanNumberPreviousPotential(lngGelIndex, lngNextScanNumber) = 0 And lngNextScanNumber < lngMaxScanNumber
        lngNextScanNumber = lngNextScanNumber + 1
    Loop
    If LookupScanNumberPreviousPotential(lngGelIndex, lngNextScanNumber) = 0 Then
        lngNextScanNumber = 0
    End If

    If lngPreviousScanNumber > 0 Or lngNextScanNumber > 0 Then
        If Abs(lngScanNumberToFind - lngPreviousScanNumber) < Abs(lngScanNumberToFind - lngNextScanNumber) Then
            If lngPreviousScanNumber > 0 Then
                lngScanNumberNearest = lngPreviousScanNumber
            Else
                lngScanNumberNearest = lngNextScanNumber
            End If
        Else
             If lngNextScanNumber > 0 Then
                lngScanNumberNearest = lngNextScanNumber
            Else
                lngScanNumberNearest = lngPreviousScanNumber
            End If
        End If
    Else
        lngScanNumberNearest = lngScanNumberToFind
    End If
    
    
'''    ' We could, alternatively, use a binary search to find the nearest scan number
'''    ' Note that this code is from BinarySearchDblFindNearest
'''    Dim lngFirstIndex As Long, lngLastIndex As Long
'''    Dim lngMidIndex As Long
'''    Dim lngCurrentFirst As Long, lngCurrentLast As Long
'''    Dim lngMatchIndex As Long
'''
'''    With GelData(lngGelIndex)
'''        lngFirstIndex = 1
'''        lngLastIndex = UBound(.ScanInfo)
'''
'''        lngCurrentFirst = lngFirstIndex
'''        lngCurrentLast = lngLastIndex
'''
'''        If lngCurrentFirst > lngCurrentLast Then
'''            ' Invalid indices were provided
'''            lngMatchIndex = -1
'''        ElseIf lngCurrentFirst = lngCurrentLast Then
'''            ' Search space is only one element long; simply return that element's index
'''            lngMatchIndex = lngCurrentFirst
'''        Else
'''            lngMidIndex = (lngCurrentFirst + lngCurrentLast) \ 2            ' Note: Using Integer division
'''            If lngMidIndex < lngCurrentFirst Then lngMidIndex = lngCurrentFirst
'''
'''            Do While lngCurrentFirst <= lngCurrentLast And .ScanInfo(lngMidIndex).ScanNumber <> lngScanNumberToFind
'''                If lngScanNumberToFind < .ScanInfo(lngMidIndex).ScanNumber Then
'''                    ' Search the lower half
'''                    lngCurrentLast = lngMidIndex - 1
'''                ElseIf lngScanNumberToFind > .ScanInfo(lngMidIndex).ScanNumber Then
'''                    ' Search the upper half
'''                    lngCurrentFirst = lngMidIndex + 1
'''                End If
'''                ' Compute the new mid point
'''                lngMidIndex = (lngCurrentFirst + lngCurrentLast) \ 2
'''                If lngMidIndex < lngCurrentFirst Then
'''                    lngMidIndex = lngCurrentFirst
'''                    If lngMidIndex > lngCurrentLast Then
'''                        lngMidIndex = lngCurrentLast
'''                    End If
'''                    Exit Do
'''                End If
'''            Loop
'''
'''            lngMatchIndex = -1
'''            ' See if an exact match has been found
'''            If lngMidIndex >= lngCurrentFirst And lngMidIndex <= lngCurrentLast Then
'''                If .ScanInfo(lngMidIndex).ScanNumber = lngScanNumberToFind Then
'''                    lngMatchIndex = lngMidIndex
'''                End If
'''            End If
'''
'''            If lngMatchIndex = -1 Then
'''                ' No exact match; find the nearest match
'''                If .ScanInfo(lngMidIndex).ScanNumber < lngScanNumberToFind Then
'''                    If lngMidIndex < lngLastIndex Then
'''                        If Abs(.ScanInfo(lngMidIndex).ScanNumber - lngScanNumberToFind) <= Abs(.ScanInfo(lngMidIndex + 1).ScanNumber - lngScanNumberToFind) Then
'''                            lngMatchIndex = lngMidIndex
'''                        Else
'''                            lngMatchIndex = lngMidIndex + 1
'''                        End If
'''                    Else
'''                        ' lngScanNumberToFind is larger than the final scan number
'''                        lngMatchIndex = lngMidIndex
'''                    End If
'''                Else
'''                    ' .ScanInfo(lngMidIndex).ScanNumber >= lngScanNumberToFind
'''                    If lngMidIndex > lngFirstIndex Then
'''                        If Abs(.ScanInfo(lngMidIndex).ScanNumber - lngScanNumberToFind) <= Abs(.ScanInfo(lngMidIndex - 1).ScanNumber - lngScanNumberToFind) Then
'''                            lngMatchIndex = lngMidIndex
'''                        Else
'''                            lngMatchIndex = lngMidIndex - 1
'''                        End If
'''                    Else
'''                        ' lngScanNumberToFind is smaller than the first scan number
'''                        lngMatchIndex = lngMidIndex
'''                    End If
'''                End If
'''
'''            End If
'''        End If
'''
'''        If lngMatchIndex >= 0 Then
'''            lngScanNumberNearest = .ScanInfo(lngMatchIndex).ScanNumber
'''        Else
'''            lngScanNumberNearest = 0
'''        End If
'''    End With
        
    LookupScanNumberClosest = lngScanNumberNearest
    Exit Function

LookupScanNumberClosestErrorHandler:
    LookupScanNumberClosest = 0
    
End Function

Public Function LookupScanNumberNextPotential(ByVal lngGelIndex As Long, ByVal lngScanNumber As Long) As Long

    On Error Resume Next
    LookupScanNumberNextPotential = GelDataLookupArrays(lngGelIndex).AdjacentScanNumberNext(lngScanNumber)
                
End Function

Public Function LookupScanNumberPreviousPotential(ByVal lngGelIndex As Long, ByVal lngScanNumber As Long) As Long

    On Error Resume Next
    LookupScanNumberPreviousPotential = GelDataLookupArrays(lngGelIndex).AdjacentScanNumberPrevious(lngScanNumber)
                
End Function

Public Function LookupScanNumberRelativeIndex(ByVal lngGelIndex As Long, ByVal lngScanNumber As Long) As Long

    On Error Resume Next
    LookupScanNumberRelativeIndex = GelDataLookupArrays(lngGelIndex).ScanNumberRelativeIndex(lngScanNumber)
                
End Function

Public Function NitrogenCount(ByVal strSequenceOneLetter As String) As Long
    ' Examines the amino acids in strSequenceOneLetter and returns the number of nitrogen atoms
    ' The residue symbols in strSquenceOneLetter must be capital letters
    
    Dim lngNCount As Long
    Dim lngResidueIndex As Long
    Dim strResidueSymbol As String
    
    For lngResidueIndex = 1 To Len(strSequenceOneLetter)
        Select Case Asc(Mid(strSequenceOneLetter, lngResidueIndex, 1))
        Case 65, 67 To 71, 73, 76, 77, 80, 83, 84, 85, 86, 89
            lngNCount = lngNCount + 1       ' A, B, C, D, E, F, G, I, L, M, P, S, T, U, V, Y
                                            ' Note that B means D or N; we'll assume N, and thus 2 N
                                            ' Note that Z means E or Q; we'll assume Q, and thus 2 N
        Case 66: lngNCount = lngNCount + 2      ' B (means D or N)
        Case 72: lngNCount = lngNCount + 3      ' H
        Case 74:                                ' J; ignore
        Case 75: lngNCount = lngNCount + 2      ' K
        Case 78: lngNCount = lngNCount + 2      ' N
        Case 79: lngNCount = lngNCount + 2      ' O
        Case 81: lngNCount = lngNCount + 2      ' Q
        Case 82: lngNCount = lngNCount + 4      ' R
        Case 87: lngNCount = lngNCount + 2      ' W
        Case 88: lngNCount = lngNCount + 2      ' X; Unknown, assume 2 N
        Case 90: lngNCount = lngNCount + 2      ' Z (means E or Q)
        Case Else
            strResidueSymbol = Mid(strSequenceOneLetter, lngResidueIndex, 1)
            If strResidueSymbol <> "*" And strResidueSymbol <> "@" And strResidueSymbol <> "#" Then
                ' Unknown symbol found
                If Left(strSequenceOneLetter, 10) <> "NOSEQUENCE" Then
                    Debug.Assert False
                End If
            End If
        End Select
    Next lngResidueIndex
    
    ' Can confirm the above numbers using ELCountViaMwtWin, but it is much slower than this function
    ' Debug.Assert lngNCount = ELCountViaMwtWin(CurrSeq, "N")       ' Look for nitrogen using objMwtWin
    
    ' Could also confirm the above numbers using objICR2LS.GetMF()
    
    NitrogenCount = lngNCount
    
End Function

Public Function ExtractInputFilePath(lngGelIndex As Long) As String
    Dim strFilePath As String
    Dim lngCharLoc As Long
    
    If lngGelIndex >= 1 And lngGelIndex <= UBound(GelData()) Then
        strFilePath = GelData(lngGelIndex).Fileinfo
        
        lngCharLoc = InStr(strFilePath, ":")
        If lngCharLoc > 0 Then strFilePath = Mid(strFilePath, lngCharLoc + 1)
        
        lngCharLoc = InStr(strFilePath, vbCrLf)
        If lngCharLoc > 0 Then strFilePath = Left(strFilePath, lngCharLoc - 1)
                    
        ExtractInputFilePath = strFilePath
    Else
        ExtractInputFilePath = ""
    End If
    
End Function

Public Sub ExtractMTHitsFromMatchList(ByVal strDBMatchList As String, ByVal blnFindInternalStdRefs As Boolean, ByRef lngCurrIDCnt As Long, ByRef udtCurrIDMatchStats() As udtUMCMassTagMatchStats, ByVal blnIncludeInheritedMatchesInMemberHitCountStat As Boolean)
    ' Note that udtCuHrrIDMatchStats() is a 0-based array

    Dim strRefMark As String, strRefIDEnd As String
    Dim strDBMatchSingle As String
    Dim strMatchID As String, strMassDiffPPM As String
    
    Dim lngMatchID As Long, lngCharLoc As Long

    Dim strSLiCScore As String
    Dim strDelSLiC As String
    
    Dim blnInheritedMatch As Boolean
    
    Dim lngMatchIndex As Long
    
    ' Assure that udtCurrIDMatchStats is initialized
    If lngCurrIDCnt = 0 Then
        ReDim udtCurrIDMatchStats(0)
    End If
    
    
    If blnFindInternalStdRefs Then
        strRefMark = INT_STD_MARK
        strRefIDEnd = INT_STD_IDEnd
    Else
        strRefMark = AMTMark
        strRefIDEnd = AMTIDEnd
    End If


    Do
        lngCharLoc = InStr(strDBMatchList, glARG_SEP)
        If lngCharLoc > 0 Then
            strDBMatchSingle = Left(strDBMatchList, lngCharLoc - 1)
            strDBMatchList = Trim(Mid(strDBMatchList, lngCharLoc + 1))
        Else
            strDBMatchSingle = strDBMatchList
            strDBMatchList = ""
        End If
        
        If Len(strDBMatchSingle) > 0 Then
            strMatchID = Trim(GetIDFromString(strDBMatchSingle, strRefMark, strRefIDEnd))

            If IsNumeric(strMatchID) Then
                blnInheritedMatch = IsAMTMatchInherited(strDBMatchSingle)
                
                lngMatchID = val(strMatchID)
                
                ' This only applies when this function is called for a UMC (from ExtractMTHitsFromUMCMembers, for example)
                For lngMatchIndex = 0 To lngCurrIDCnt - 1
                    If udtCurrIDMatchStats(lngMatchIndex).IDIndex = lngMatchID Then
                        If blnIncludeInheritedMatchesInMemberHitCountStat Or Not blnInheritedMatch Then
                            udtCurrIDMatchStats(lngMatchIndex).MemberHitCount = udtCurrIDMatchStats(lngMatchIndex).MemberHitCount + 1
                        End If
                        Exit For
                    End If
                Next lngMatchIndex
                
                If lngMatchIndex >= lngCurrIDCnt Then
                    ' Match not found
                    ReDim Preserve udtCurrIDMatchStats(lngCurrIDCnt)
                    
                    udtCurrIDMatchStats(lngCurrIDCnt).IDIndex = lngMatchID
                    
                    If blnIncludeInheritedMatchesInMemberHitCountStat Or Not blnInheritedMatch Then
                        udtCurrIDMatchStats(lngCurrIDCnt).MemberHitCount = 1
                    Else
                        udtCurrIDMatchStats(lngCurrIDCnt).MemberHitCount = 0
                    End If
                    
                    If Not blnFindInternalStdRefs Then
                        strSLiCScore = Trim(GetIDFromString(strDBMatchSingle, MTSLiCMark, MTSLiCEnd))
                        If IsNumeric(strSLiCScore) Then
                            udtCurrIDMatchStats(lngCurrIDCnt).SLiCScore = val(strSLiCScore)
                        End If
                        
                        strDelSLiC = Trim(GetIDFromString(strDBMatchSingle, MTDelSLiCMark, MTDelSLiCEnd))
                        If IsNumeric(strDelSLiC) Then
                            udtCurrIDMatchStats(lngCurrIDCnt).DelSLiC = val(strDelSLiC)
                        End If
                        
                        strMassDiffPPM = Trim(GetIDFromString(strDBMatchSingle, MWErrMark, MWErrEnd))
                        If IsNumeric(strMassDiffPPM) Then
                            udtCurrIDMatchStats(lngCurrIDCnt).MassDiffPPM = val(strMassDiffPPM)
                        End If
                    End If
                    
                    lngCurrIDCnt = lngCurrIDCnt + 1
                End If
                
            End If
        End If

    Loop While Len(strDBMatchList) > 0

End Sub

Public Sub ExtractMTHitsFromUMCMembers(ByVal lngGelIndex As Long, ByVal lngUMCIndex As Long, ByVal blnFindInternalStdRefs As Boolean, ByRef udtUMCList() As udtUMCMassTagMatchStats, ByRef lngUMCListCount As Long, ByRef lngUMCListCountDimmed As Long, ByVal blnIncludeFirstMTIDMatchOnly As Boolean, ByVal blnIncludeInheritedMatchesInMemberHitCountStat As Boolean)

    Dim lngCurrIDCnt As Long
    Dim udtCurrIDMatchStats() As udtUMCMassTagMatchStats        ' 0-based array
    
    Dim strDBMatchList As String
    Dim blnNoMatchesForCurrID As Boolean

    Dim lngMemberIndex As Long
    Dim lngMatchIndex As Long
    
    With GelUMC(lngGelIndex).UMCs(lngUMCIndex)
        ' Collect stats on all of the matches for the ions belonging to this UMC
        
        lngCurrIDCnt = 0
        ReDim udtCurrIDMatchStats(0)
        
        For lngMemberIndex = 0 To .ClassCount - 1
            Select Case .ClassMType(lngMemberIndex)
            Case gldtCS
                strDBMatchList = GelData(lngGelIndex).CSData(.ClassMInd(lngMemberIndex)).MTID
            Case gldtIS
                strDBMatchList = GelData(lngGelIndex).IsoData(.ClassMInd(lngMemberIndex)).MTID
            Case Else
                ' This shouldn't happen; ignore it
                Debug.Assert False
            End Select
            ExtractMTHitsFromMatchList strDBMatchList, blnFindInternalStdRefs, lngCurrIDCnt, udtCurrIDMatchStats(), blnIncludeInheritedMatchesInMemberHitCountStat
        Next lngMemberIndex
        
        If lngCurrIDCnt = 0 And Not blnFindInternalStdRefs Then
            ' We want to copy UMC's without matches too
            ' Thus, bump up to 1
            lngCurrIDCnt = 1
            blnNoMatchesForCurrID = True
        Else
            blnNoMatchesForCurrID = False
        End If
        
        If lngCurrIDCnt > 0 Then
            
            ' Add an entry to udtUMCList() for each MTID in lngCurrIDMatchID()
            For lngMatchIndex = 0 To lngCurrIDCnt - 1
            
                udtUMCList(lngUMCListCount).UMCIndex = lngUMCIndex
                udtUMCList(lngUMCListCount).IDIsInternalStd = blnFindInternalStdRefs
                 
                If blnNoMatchesForCurrID Then
                    udtUMCList(lngUMCListCount).IDIndex = 0
                    udtUMCList(lngUMCListCount).MemberHitCount = 0
                    udtUMCList(lngUMCListCount).MultiAMTHitCount = 0
                    udtUMCList(lngUMCListCount).SLiCScore = 0
                    udtUMCList(lngUMCListCount).DelSLiC = 0
                Else
                                       
                    udtUMCList(lngUMCListCount).IDIndex = udtCurrIDMatchStats(lngMatchIndex).IDIndex
                    udtUMCList(lngUMCListCount).MemberHitCount = udtCurrIDMatchStats(lngMatchIndex).MemberHitCount
                    udtUMCList(lngUMCListCount).SLiCScore = udtCurrIDMatchStats(lngMatchIndex).SLiCScore
                    udtUMCList(lngUMCListCount).DelSLiC = udtCurrIDMatchStats(lngMatchIndex).DelSLiC
                    
                    If blnFindInternalStdRefs Then
                        udtUMCList(lngUMCListCount).MultiAMTHitCount = 0
                    Else
                        ' Only update .MultiAMTHitCount for MT tag hits
                        udtUMCList(lngUMCListCount).MultiAMTHitCount = lngCurrIDCnt
                    End If
                End If
                lngUMCListCount = lngUMCListCount + 1
                
                If lngUMCListCount > lngUMCListCountDimmed Then
                    lngUMCListCountDimmed = lngUMCListCountDimmed + 50
                    ReDim Preserve udtUMCList(lngUMCListCountDimmed)
                End If
                
                If blnIncludeFirstMTIDMatchOnly Then
                    Exit For
                End If
            Next lngMatchIndex
            
        End If
    End With

End Sub

Private Function FillArrayUsingCollection(ByRef udtCollectionArray() As udtCollectionArrayType, objCollection As Collection, ByVal lngMaxItemsToCopy As Long) As Long
    ' Returns the number of items copied
    Dim lngItemIndex As Long, lngCollectionCount As Long

On Error GoTo FillArrayUsingCollectionErrorHandler

    lngCollectionCount = objCollection.Count
    
    If lngCollectionCount > lngMaxItemsToCopy Then
        ' This Shouldn't Happen
        Debug.Assert False
        lngCollectionCount = lngMaxItemsToCopy
    End If
    
    Erase udtCollectionArray
    For lngItemIndex = 1 To lngCollectionCount
        ' Note: udtCollectionArray is 0-based, but collections are 1-based
        udtCollectionArray(lngItemIndex - 1).Name = objCollection(lngItemIndex).Name
        udtCollectionArray(lngItemIndex - 1).Value = objCollection(lngItemIndex).Value
    Next lngItemIndex

    FillArrayUsingCollection = lngCollectionCount
    
    Exit Function
    
FillArrayUsingCollectionErrorHandler:
    Debug.Assert False
    FillArrayUsingCollection = 0
    
End Function

Private Sub FillNamesAndValuesArrays(ByRef SourceArray() As udtCollectionArrayType, ByRef lngArrayCount As Long, ByRef strNamesArray() As String, ByRef strValuesArray() As String)
    
    If lngArrayCount = 0 Then
        ReDim strNamesArray(0)
        ReDim strValuesArray(0)
    Else
        ReDim strNamesArray(0 To lngArrayCount - 1)
        ReDim strValuesArray(0 To lngArrayCount - 1)
        
        Dim lngIndex As Long
        
        For lngIndex = 0 To lngArrayCount - 1
            strNamesArray(lngIndex) = SourceArray(lngIndex).Name
            strValuesArray(lngIndex) = SourceArray(lngIndex).Value
        Next lngIndex
    End If
    
End Sub

Public Sub FillDBSettingsUsingAnalysisObject(udtDBSettings As udtDBSettingsType, objGelAnalysis As FTICRAnalysis)
    
    ' Copy the settings from objGelAnalysis to udtDBSettings.Analysisinfo
    FillGelAnalysisInfo udtDBSettings.AnalysisInfo, objGelAnalysis
        
    ' Populate the primary fields in udtDBSettings using udtDBSettings.AnalysisInfo
    FillDBSettingsUsingAnalysisInfoUDT udtDBSettings
    
End Sub

Public Sub FillDBSettingsUsingAnalysisInfoUDT(ByRef udtDBSettings As udtDBSettingsType)

    Const ENTRY_NOT_FOUND = "<<NOT_FOUND>>"
    Dim strValue As String
    
On Error GoTo FillDBSettingsUsingAnalysisInfoUDTErrorHandler

    With udtDBSettings
        If .AnalysisInfo.ValidAnalysisDataPresent Then
            .IsDeleted = False
            .ConnectionString = .AnalysisInfo.MTDB.ConnectionString
            .DatabaseName = ExtractDBNameFromConnectionString(.ConnectionString)
            .DBSchemaVersion = LookupDBSchemaVersionViaCNString(.ConnectionString)
            
            .AMTsOnly = CBoolSafe(LookupCollectionArrayValueByName(.AnalysisInfo.MTDB.DBStuffArray(), .AnalysisInfo.MTDB.DBStuffArrayCount, NAME_ACCURATE_ONLY))
            .ConfirmedOnly = CBoolSafe(LookupCollectionArrayValueByName(.AnalysisInfo.MTDB.DBStuffArray(), .AnalysisInfo.MTDB.DBStuffArrayCount, NAME_CONFIRMED_ONLY))
            .LockersOnly = CBoolSafe(LookupCollectionArrayValueByName(.AnalysisInfo.MTDB.DBStuffArray(), .AnalysisInfo.MTDB.DBStuffArrayCount, NAME_LOCKERS_ONLY))
            .LimitToPMTsFromDataset = CBoolSafe(LookupCollectionArrayValueByName(.AnalysisInfo.MTDB.DBStuffArray(), .AnalysisInfo.MTDB.DBStuffArrayCount, NAME_LIMIT_TO_PMTS_FROM_DATASET))
            
            .MinimumHighNormalizedScore = CSngSafe(LookupCollectionArrayValueByName(.AnalysisInfo.MTDB.DBStuffArray(), .AnalysisInfo.MTDB.DBStuffArrayCount, NAME_MINIMUM_HIGH_NORMALIZED_SCORE))
            .MinimumHighDiscriminantScore = CSngSafe(LookupCollectionArrayValueByName(.AnalysisInfo.MTDB.DBStuffArray(), .AnalysisInfo.MTDB.DBStuffArrayCount, NAME_MINIMUM_HIGH_DISCRIMINANT_SCORE))
            .MinimumPeptideProphetProbability = CSngSafe(LookupCollectionArrayValueByName(.AnalysisInfo.MTDB.DBStuffArray(), .AnalysisInfo.MTDB.DBStuffArrayCount, NAME_MINIMUM_PEPTIDE_PROPHET_PROBABILITY))
            .MinimumPMTQualityScore = CSngSafe(LookupCollectionArrayValueByName(.AnalysisInfo.MTDB.DBStuffArray(), .AnalysisInfo.MTDB.DBStuffArrayCount, NAME_MINIMUM_PMT_QUALITY_SCORE))
            .ExperimentInclusionFilter = CStrSafe(LookupCollectionArrayValueByName(.AnalysisInfo.MTDB.DBStuffArray(), .AnalysisInfo.MTDB.DBStuffArrayCount, NAME_EXPERIMENT_INCLUSION_FILTER))
            .ExperimentExclusionFilter = CStrSafe(LookupCollectionArrayValueByName(.AnalysisInfo.MTDB.DBStuffArray(), .AnalysisInfo.MTDB.DBStuffArrayCount, NAME_EXPERIMENT_EXCLUSION_FILTER))
            .InternalStandardExplicit = CStrSafe(LookupCollectionArrayValueByName(.AnalysisInfo.MTDB.DBStuffArray(), .AnalysisInfo.MTDB.DBStuffArrayCount, NAME_INTERNAL_STANDARD_EXPLICIT))
            .NETValueType = CIntSafe(LookupCollectionArrayValueByName(.AnalysisInfo.MTDB.DBStuffArray(), .AnalysisInfo.MTDB.DBStuffArrayCount, NAME_NET_VALUE_TYPE))
            
            strValue = LookupCollectionArrayValueByName(.AnalysisInfo.MTDB.DBStuffArray(), .AnalysisInfo.MTDB.DBStuffArrayCount, NAME_SUBSET, False, ENTRY_NOT_FOUND)
            If strValue = ENTRY_NOT_FOUND Then
                .MassTagSubsetID = "-1"
            Else
                .MassTagSubsetID = CLngSafe(strValue)
            End If
            
            strValue = LookupCollectionArrayValueByName(.AnalysisInfo.MTDB.DBStuffArray(), .AnalysisInfo.MTDB.DBStuffArrayCount, NAME_INC_LIST, False, ENTRY_NOT_FOUND)
            If strValue = ENTRY_NOT_FOUND Or Len(strValue) = 0 Then
                .ModificationList = "-1"
            Else
                .ModificationList = strValue
            End If
            
            .SelectedMassTagCount = 0
        Else
            .IsDeleted = True
            .AnalysisInfo.MTDB.ConnectionString = ""
            .ConnectionString = ""
            .DatabaseName = ""
            .DBSchemaVersion = 0
            
            .AMTsOnly = False
            .ConfirmedOnly = False
            .LockersOnly = False
            .LimitToPMTsFromDataset = False
            
            .MinimumHighNormalizedScore = 0
            .MinimumHighDiscriminantScore = 0
            .MinimumPeptideProphetProbability = 0
            .MinimumPMTQualityScore = 0
            
            .ExperimentInclusionFilter = ""
            .ExperimentExclusionFilter = ""
            .InternalStandardExplicit = ""
            
            .NETValueType = nvtGANET
            
            .MassTagSubsetID = -1
            .ModificationList = "-1"
            
            .SelectedMassTagCount = 0
        End If
    End With

Exit Sub

FillDBSettingsUsingAnalysisInfoUDTErrorHandler:
    If Not glbPreferencesExpanded.AutoAnalysisStatus.Enabled Then
        MsgBox "Error occured in FillDBSettingsUsingAnalysisObject: " & Err.Description, vbExclamation + vbOKOnly, "Error"
    Else
        Debug.Assert False
        LogErrors Err.Number, "FillDBSettingsUsingAnalysisInfoUDT"
    End If

End Sub

Public Sub FillGelAnalysisInfo(udtGelAnalysisInfo As udtGelAnalysisInfoType, Optional objGelAnalysis As FTICRAnalysis)
    ' Copy data from objGelAnalysis to udtGelAnalysisInfo
    ' If objGelAnalysis Is Nothing, then values are reset to default, blank values
    
    Dim udtGelAnalysisInfoBlank As udtGelAnalysisInfoType
    
On Error GoTo FillGelAnalysisInfoErrorHandler

    If objGelAnalysis Is Nothing Then
        udtGelAnalysisInfoBlank.ValidAnalysisDataPresent = False
        udtGelAnalysisInfo = udtGelAnalysisInfoBlank
    Else
        With objGelAnalysis
            udtGelAnalysisInfo.ValidAnalysisDataPresent = True
            udtGelAnalysisInfo.Analysis_Tool = .Analysis_Tool
            udtGelAnalysisInfo.Created = .Created
            udtGelAnalysisInfo.Dataset = .Dataset
            udtGelAnalysisInfo.Dataset_Folder = .Dataset_Folder
            udtGelAnalysisInfo.Dataset_ID = .Dataset_ID
            udtGelAnalysisInfo.Desc_DataFolder = .Desc_DataFolder
            udtGelAnalysisInfo.Desc_Type = .Desc_Type
            udtGelAnalysisInfo.Duration = .Duration
            udtGelAnalysisInfo.Experiment = .Experiment
            udtGelAnalysisInfo.GANET_Fit = .GANET_Fit
            udtGelAnalysisInfo.GANET_Intercept = .GANET_Intercept
            udtGelAnalysisInfo.GANET_Slope = .GANET_Slope
            udtGelAnalysisInfo.Instrument_Class = .Instrument_Class
            udtGelAnalysisInfo.Job = .Job
            udtGelAnalysisInfo.MD_Date = .MD_Date
            udtGelAnalysisInfo.MD_file = .MD_file
            udtGelAnalysisInfo.MD_Parameters = .MD_Parameters
            udtGelAnalysisInfo.MD_Reference_Job = .MD_Reference_Job
            udtGelAnalysisInfo.MD_State = .MD_State
            udtGelAnalysisInfo.MD_Type = .MD_Type
            
            udtGelAnalysisInfo.MTDB.ConnectionString = .MTDB.cn.ConnectionString
            udtGelAnalysisInfo.MTDB.DBStatus = .MTDB.DBStatus
            
            udtGelAnalysisInfo.MTDB.DBStuffArrayCount = FillArrayUsingCollection(udtGelAnalysisInfo.MTDB.DBStuffArray(), .MTDB.DBStuff, DBSTUFF_COLLECTION_COUNT_MAX)
            
            udtGelAnalysisInfo.NET_Intercept = .NET_Intercept
            udtGelAnalysisInfo.NET_Slope = .NET_Slope
            udtGelAnalysisInfo.NET_TICFit = .NET_TICFit
            udtGelAnalysisInfo.Organism = .Organism
            udtGelAnalysisInfo.Organism_DB_Name = .Organism_DB_Name
            udtGelAnalysisInfo.Parameter_File_Name = .Parameter_File_Name
            
            udtGelAnalysisInfo.ProcessingType = .ProcessingType
            udtGelAnalysisInfo.Results_Folder = .Results_Folder
            udtGelAnalysisInfo.Settings_File_Name = .Settings_File_Name
            udtGelAnalysisInfo.STATE = .STATE
            udtGelAnalysisInfo.Storage_Path = .Storage_Path
            udtGelAnalysisInfo.Total_Scans = .Total_Scans
            udtGelAnalysisInfo.Vol_Client = .Vol_Client
            udtGelAnalysisInfo.Vol_Server = .Vol_Server
        End With
    End If

    Exit Sub

FillGelAnalysisInfoErrorHandler:
    LogErrors Err.Number, "FillGelAnalysisInfo"
    Debug.Print "Error occurred in FillGelAnalysisInfo: " & Err.Description
    Resume Next
    
End Sub

Public Sub FillGelAnalysisObject(objGelAnalysis As FTICRAnalysis, udtGelAnalysisInfo As udtGelAnalysisInfoType, Optional blnUpdateParametersFormControls As Boolean = False, Optional blnUpdateMTDBInfo As Boolean = True)
    ' Copy data from udtGelAnalysisInfo to objGelAnalysis
    
    Dim strNamesArray() As String, strValuesArray() As String
    
    With objGelAnalysis
        .Analysis_Tool = udtGelAnalysisInfo.Analysis_Tool
        .Created = udtGelAnalysisInfo.Created
        .Dataset = udtGelAnalysisInfo.Dataset
        .Dataset_Folder = udtGelAnalysisInfo.Dataset_Folder
        .Dataset_ID = udtGelAnalysisInfo.Dataset_ID
        .Desc_DataFolder = udtGelAnalysisInfo.Desc_DataFolder
        .Desc_Type = udtGelAnalysisInfo.Desc_Type
        .Duration = udtGelAnalysisInfo.Duration
        .Experiment = udtGelAnalysisInfo.Experiment
        .GANET_Fit = udtGelAnalysisInfo.GANET_Fit
        .GANET_Intercept = udtGelAnalysisInfo.GANET_Intercept
        .GANET_Slope = udtGelAnalysisInfo.GANET_Slope
        .Instrument_Class = udtGelAnalysisInfo.Instrument_Class
        .Job = udtGelAnalysisInfo.Job
        .MD_Date = udtGelAnalysisInfo.MD_Date
        .MD_file = udtGelAnalysisInfo.MD_file
        .MD_Parameters = udtGelAnalysisInfo.MD_Parameters
        .MD_Reference_Job = udtGelAnalysisInfo.MD_Reference_Job
        .MD_State = udtGelAnalysisInfo.MD_State
        .MD_Type = udtGelAnalysisInfo.MD_Type
        
        If blnUpdateMTDBInfo Then
            .MTDB.cn.ConnectionString = udtGelAnalysisInfo.MTDB.ConnectionString
            .MTDB.DBStatus = udtGelAnalysisInfo.MTDB.DBStatus
            
            FillNamesAndValuesArrays udtGelAnalysisInfo.MTDB.DBStuffArray(), udtGelAnalysisInfo.MTDB.DBStuffArrayCount, strNamesArray(), strValuesArray()

            ' Make sure the sp_GetDBSchemaVersion entry is present in .DBStuffArray()
            AddOrUpdateCollectionArrayItem udtGelAnalysisInfo.MTDB.DBStuffArray(), udtGelAnalysisInfo.MTDB.DBStuffArrayCount, NAME_GET_DB_SCHEMA_VERSION, "GetDBSchemaVersion"

            ' Make sure the following settings are present in new entitites in .DBStuffArray()
            AddOrUpdateCollectionArrayItem udtGelAnalysisInfo.MTDB.DBStuffArray(), udtGelAnalysisInfo.MTDB.DBStuffArrayCount, NAME_LIMIT_TO_PMTS_FROM_DATASET, "False", True
            AddOrUpdateCollectionArrayItem udtGelAnalysisInfo.MTDB.DBStuffArray(), udtGelAnalysisInfo.MTDB.DBStuffArrayCount, NAME_MINIMUM_HIGH_NORMALIZED_SCORE, "1", True
            AddOrUpdateCollectionArrayItem udtGelAnalysisInfo.MTDB.DBStuffArray(), udtGelAnalysisInfo.MTDB.DBStuffArrayCount, NAME_MINIMUM_PMT_QUALITY_SCORE, "1", True
            AddOrUpdateCollectionArrayItem udtGelAnalysisInfo.MTDB.DBStuffArray(), udtGelAnalysisInfo.MTDB.DBStuffArrayCount, NAME_MINIMUM_HIGH_DISCRIMINANT_SCORE, "0", True
            AddOrUpdateCollectionArrayItem udtGelAnalysisInfo.MTDB.DBStuffArray(), udtGelAnalysisInfo.MTDB.DBStuffArrayCount, NAME_EXPERIMENT_INCLUSION_FILTER, "", True
            AddOrUpdateCollectionArrayItem udtGelAnalysisInfo.MTDB.DBStuffArray(), udtGelAnalysisInfo.MTDB.DBStuffArrayCount, NAME_EXPERIMENT_EXCLUSION_FILTER, "", True
            AddOrUpdateCollectionArrayItem udtGelAnalysisInfo.MTDB.DBStuffArray(), udtGelAnalysisInfo.MTDB.DBStuffArrayCount, NAME_INTERNAL_STANDARD_EXPLICIT, "", True
            
            ' The .SetDBStuff function expects a 0-based array
            .MTDB.SetDBStuff strNamesArray(), strValuesArray()
        End If
        
        .NET_Intercept = udtGelAnalysisInfo.NET_Intercept
        .NET_Slope = udtGelAnalysisInfo.NET_Slope
        .NET_TICFit = udtGelAnalysisInfo.NET_TICFit
        .Organism = udtGelAnalysisInfo.Organism
        .Organism_DB_Name = udtGelAnalysisInfo.Organism_DB_Name
        .Parameter_File_Name = udtGelAnalysisInfo.Parameter_File_Name
                    
        .ProcessingType = udtGelAnalysisInfo.ProcessingType
        .Results_Folder = udtGelAnalysisInfo.Results_Folder
        .Settings_File_Name = udtGelAnalysisInfo.Settings_File_Name
        .STATE = udtGelAnalysisInfo.STATE
        .Storage_Path = udtGelAnalysisInfo.Storage_Path
        .Total_Scans = udtGelAnalysisInfo.Total_Scans
        .Vol_Client = udtGelAnalysisInfo.Vol_Client
        .Vol_Server = udtGelAnalysisInfo.Vol_Server
    
        If blnUpdateParametersFormControls Then
            frmParameters.cmdDummyMTLink.Enabled = False
            frmParameters.lblMTDBAssociation.Caption = .MTDB.cn.ConnectionString
        End If

    End With

End Sub

Public Function ConvertEmfToPng(strEmfFilePath As String, strTargetFilePath As String, Optional lngWidthPixels As Long = 1024, Optional lngHeightPixels As Long = 768) As Long
    ' Returns 0 if success, the error number if an error
    
    Dim strGeometry As String
    Dim strResult As String
    
    Dim fso As FileSystemObject
    Dim objImage As ImageMagickObject.MagickImage
    
On Error GoTo ConvertEmfToPngErrorHandler

    Set objImage = New ImageMagickObject.MagickImage
    Set fso = New FileSystemObject
    
    strTargetFilePath = FileExtensionForce(strTargetFilePath, "png")
    strGeometry = lngWidthPixels & "X" & lngHeightPixels
    
    strResult = objImage.Convert("-size", strGeometry, strEmfFilePath, strTargetFilePath)
    
    If Len(strResult) > 0 Then
        fso.DeleteFile strEmfFilePath
        ConvertEmfToPng = 0
    Else
        ConvertEmfToPng = -1
    End If
    
    Set fso = Nothing
    Set objImage = Nothing
    
    Exit Function
    
ConvertEmfToPngErrorHandler:
    If Not glbPreferencesExpanded.AutoAnalysisStatus.Enabled Then
        MsgBox "Error in ConvertEmfToPng: " & Err.Description
    Else
        LogErrors Err.Number, "ConvertEmfToPng"
    End If
    
    ConvertEmfToPng = Err.Number
End Function

Public Sub CopyCSDataToLegacy(ByRef udtIsotopicData As udtIsotopicDataType, ByRef CSNum() As Double, ByRef CSVar() As Variant, ByVal lngCSIndex As Long)
    
    With udtIsotopicData
        CSNum(lngCSIndex, csfScan) = .ScanNumber
        CSNum(lngCSIndex, csfFirstCS) = .Charge
        CSNum(lngCSIndex, csfCSNum) = .ChargeCount
        CSNum(lngCSIndex, csfAbu) = .Abundance

        CSNum(lngCSIndex, csfMW) = .AverageMW
        CSNum(lngCSIndex, csfStD) = .MassStDev
                
        CSNum(lngCSIndex, csfIsotopicFitRatio) = 0          ' .IsotopicFitRatio
        CSNum(lngCSIndex, csfIsotopicAtomCount) = 0         ' .IsotopicAtomCount
        
        CSVar(lngCSIndex, csvfMTID) = .MTID
    End With

End Sub

Public Sub CopyIsoDataToLegacy(ByRef udtIsotopicData As udtIsotopicDataType, ByRef IsoNum() As Double, ByRef IsoVar() As Variant, ByVal lngIsoIndex As Long)
    
    With udtIsotopicData
        IsoNum(lngIsoIndex, isfScan) = .ScanNumber
        IsoNum(lngIsoIndex, isfCS) = .Charge
        IsoNum(lngIsoIndex, isfAbu) = .Abundance
        
        IsoNum(lngIsoIndex, isfMOverZ) = .MZ
        IsoNum(lngIsoIndex, isfFit) = .Fit
        
        IsoNum(lngIsoIndex, isfMWMono) = .MonoisotopicMW
        IsoNum(lngIsoIndex, isfMWavg) = .AverageMW
        IsoNum(lngIsoIndex, isfMWTMA) = .MostAbundantMW
                
        IsoNum(lngIsoIndex, isfIsotopicFitRatio) = 0            ' .IsotopicFitRatio
        IsoNum(lngIsoIndex, isfIsotopicAtomCount) = 0           ' .IsotopicAtomCount
        
        If UBound(IsoNum, 2) >= isfIReport2DaAbundance Then
            IsoNum(lngIsoIndex, isfIReportMWMonoAbu) = .IntensityMono
            IsoNum(lngIsoIndex, isfIReport2DaAbundance) = .IntensityMonoPlus2
        End If
        
        IsoVar(lngIsoIndex, isvfMTID) = .MTID
        
    End With

End Sub

Public Sub CopyLegacyCSToIsoData(ByRef udtIsotopicData As udtIsotopicDataType, ByRef CSNum() As Double, ByRef CSVar() As Variant, ByVal lngCSIndex As Long)
    
    With udtIsotopicData
        .ScanNumber = CSNum(lngCSIndex, csfScan)
        .Charge = CSNum(lngCSIndex, csfFirstCS)
        .ChargeCount = CSNum(lngCSIndex, csfCSNum)
        .Abundance = CSNum(lngCSIndex, csfAbu)

        .MZ = 0
        .Fit = 0
        
        .MonoisotopicMW = 0
        .AverageMW = CSNum(lngCSIndex, csfMW)
        .MostAbundantMW = 0
        .MassStDev = CSNum(lngCSIndex, csfStD)
        
        .MassShiftCount = 0
        .MassShiftOverallPPM = 0
        
''        .IsotopicFitRatio = CSNum(lngCSIndex, csfIsotopicFitRatio)
''        .IsotopicAtomCount = CSNum(lngCSIndex, csfIsotopicAtomCount)
        
        .IntensityMono = 0
        .IntensityMonoPlus2 = 0
        .FWHM = 0
        .SignalToNoise = 0
        .ExpressionRatio = ER_NO_RATIO
         
        .AdditionalValue1 = 0
        .AdditionalValue2 = 0
        
        On Error Resume Next
        If IsNull(CSVar(lngCSIndex, csvfMTID)) Then
            .MTID = ""
        Else
            .MTID = CStr(CSVar(lngCSIndex, csvfMTID))
        End If
        
    End With

End Sub

Public Sub CopyLegacyIso2005ToCurrentIso(ByRef udtIsotopicData As udtIsotopicDataType, ByRef udtIsotopicDataOld As udtIsotopicDataType2005)
    
    With udtIsotopicData
        .ScanNumber = udtIsotopicDataOld.ScanNumber
        .Charge = udtIsotopicDataOld.Charge
        .ChargeCount = udtIsotopicDataOld.ChargeCount
        .Abundance = udtIsotopicDataOld.Abundance
        
        .MZ = udtIsotopicDataOld.MZ
        .Fit = udtIsotopicDataOld.Fit
        
        .MonoisotopicMW = udtIsotopicDataOld.MonoisotopicMW
        .AverageMW = udtIsotopicDataOld.AverageMW
        .MostAbundantMW = udtIsotopicDataOld.MostAbundantMW
        .MassStDev = udtIsotopicDataOld.MassStDev
        
        .MassShiftCount = 0
        .MassShiftOverallPPM = 0
        
        .IntensityMono = udtIsotopicDataOld.IntensityMono
        .IntensityMonoPlus2 = udtIsotopicDataOld.IntensityMonoPlus2
        
        .FWHM = udtIsotopicDataOld.FWHM
        .SignalToNoise = udtIsotopicDataOld.SignalToNoise
    
        .ExpressionRatio = udtIsotopicDataOld.ExpressionRatio
        .AdditionalValue1 = 0
        .AdditionalValue2 = 0
        
        .MTID = udtIsotopicDataOld.MTID
    End With

End Sub

Public Sub CopyLegacyIsoToIsoData(ByRef udtIsotopicData As udtIsotopicDataType, ByRef IsoNum() As Double, ByRef IsoVar() As Variant, ByVal lngIsoIndex As Long)
    
    With udtIsotopicData
        .ScanNumber = IsoNum(lngIsoIndex, isfScan)
        .Charge = IsoNum(lngIsoIndex, isfCS)
        .ChargeCount = 0
        .Abundance = IsoNum(lngIsoIndex, isfAbu)
        
        .MZ = IsoNum(lngIsoIndex, isfMOverZ)
        .Fit = IsoNum(lngIsoIndex, isfFit)
        
        .MonoisotopicMW = IsoNum(lngIsoIndex, isfMWMono)
        .AverageMW = IsoNum(lngIsoIndex, isfMWavg)
        .MostAbundantMW = IsoNum(lngIsoIndex, isfMWTMA)
        .MassStDev = 0
        
        .MassShiftCount = 0
        .MassShiftOverallPPM = 0
        
''        .IsotopicFitRatio = IsoNum(lngIsoIndex, isfIsotopicFitRatio)
''        .IsotopicAtomCount = IsoNum(lngIsoIndex, isfIsotopicAtomCount)
        
        If UBound(IsoNum, 2) >= isfIReport2DaAbundance Then
            .IntensityMono = IsoNum(lngIsoIndex, isfIReportMWMonoAbu)
            .IntensityMonoPlus2 = IsoNum(lngIsoIndex, isfIReport2DaAbundance)
        Else
            .IntensityMono = 0
            .IntensityMonoPlus2 = 0
        End If
        
        .FWHM = 0
        .SignalToNoise = 0
        
        .ExpressionRatio = ER_NO_RATIO
                 
        .AdditionalValue1 = 0
        .AdditionalValue2 = 0
        
        On Error Resume Next
        If IsNull(IsoVar(lngIsoIndex, isvfMTID)) Then
            .MTID = ""
        Else
            .MTID = CStr(IsoVar(lngIsoIndex, isvfMTID))
        End If
        
    End With

End Sub

Public Function CreateMontageImage(ByVal strFilePathA As String, ByVal strFilePathB As String, ByVal strOutputFilePath As String, blnDeleteSourceFiles As Boolean, Optional lngDefaultMaxWidth As Long = 644, Optional lngDefaultMaxHeight As Long = 279) As Boolean
    ' Returns 0 if success, Error number (or -1) if an error
    ' Note: lngDefaultMaxWidth and lngDefaultMaxHeight are used as the maximum dimensions if the Identify command fails
    
    Const BORDER_WIDTH As Long = 1
    Dim strGeometry As String
    Dim strBorderInfo As String
    Dim strTileInfo As String
    Dim strResult As String
    
    Dim lngValue As Long
    Dim lngMaxWidth As Long
    Dim lngMaxHeight As Long
    
    Dim fso As FileSystemObject
    Dim objImage As ImageMagickObject.MagickImage
    
On Error GoTo CreateMontageImageErrorHandler
    
    Set objImage = New ImageMagickObject.MagickImage
    Set fso = New FileSystemObject
    
    ' Determine the size of the input files (width and height in pixels)
    ' We'll use this size when defining the Geometry switch for the Montage command
    
On Error GoTo CreateMontageImageIdentifyErrorHandler
    
    ' File A
    strResult = objImage.Identify("-format", "%w", strFilePathA)
    lngValue = CLngSafe(strResult)
    If lngValue > lngMaxWidth Then lngMaxWidth = lngValue
    
    Sleep 200
    
    strResult = objImage.Identify("-format", "%h", strFilePathA)
    lngValue = CLngSafe(strResult)
    If lngValue > lngMaxHeight Then lngMaxHeight = lngValue
    
    Sleep 200
    
    ' File B
    strResult = objImage.Identify("-format", "%w", strFilePathB)
    lngValue = CLngSafe(strResult)
    If lngValue > lngMaxWidth Then lngMaxWidth = lngValue
    
    Sleep 200
    
    strResult = objImage.Identify("-format", "%h", strFilePathB)
    lngValue = CLngSafe(strResult)
    If lngValue > lngMaxHeight Then lngMaxHeight = lngValue
    
    Sleep 200
    
On Error GoTo CreateMontageImageErrorHandler

CreateMontageImageContinue:
    strGeometry = Trim(lngMaxWidth) & "X" & Trim(lngMaxHeight) & "+" & Trim(BORDER_WIDTH) & "+" & Trim(BORDER_WIDTH)

    TraceLog 5, "CreateMontageImage", "Creating montage of " & strFilePathA & " and " & strFilePathB
    strResult = objImage.Montage("-tile", "1x2", "-geometry", strGeometry, "-borderwidth", Trim(BORDER_WIDTH), "-bordercolor", "black", strFilePathA, strFilePathB, strOutputFilePath)
    
    If Len(strResult) > 0 Then
        If blnDeleteSourceFiles And gTraceLogLevel = 0 Then
            ' Note: Only delete the source files if the trace log level is 0
            On Error Resume Next
            fso.DeleteFile strFilePathA
            fso.DeleteFile strFilePathB
        End If
        CreateMontageImage = 0
    Else
        CreateMontageImage = -1
    End If
    
    Set fso = Nothing
    Set objImage = Nothing
    
    Exit Function
    
CreateMontageImageErrorHandler:
    If Not glbPreferencesExpanded.AutoAnalysisStatus.Enabled Then
        MsgBox "Error in CreateMontageImage: " & Err.Description
    Else
        Debug.Assert False
        LogErrors Err.Number, "CreateMontageImage", Err.Description
    End If
    If Err.Number <> 0 Then
        CreateMontageImage = Err.Number
    Else
        CreateMontageImage = -1
    End If
    Exit Function
    
CreateMontageImageIdentifyErrorHandler:
    ' Call to identify failed; use the default max width and height values
    Debug.Assert False
    
    If Not glbPreferencesExpanded.AutoAnalysisStatus.Enabled Then
        MsgBox "Error in CreateMontageImage during Identify: " & Err.Description
    Else
        Debug.Assert False
        LogErrors Err.Number, "CreateMontageImage->Identify", Err.Description & "; will use default values of MaxWidth = " & Trim(lngDefaultMaxWidth) & " and MaxHeight = " & Trim(lngDefaultMaxHeight)
    End If
     
    lngMaxWidth = lngDefaultMaxWidth
    lngMaxHeight = lngDefaultMaxHeight
    
    Resume CreateMontageImageContinue
End Function

Public Sub DefineDefaultElutionTimes(udtScanInfo() As udtScanInfoType, Optional ByVal sngNETStart As Single = 0, Optional ByVal sngNETEnd As Single = 1)

    Dim lngIndex As Long
    Dim lngMaxIndex As Long
    
    Dim lngMaxScanNumber As Long
    Dim sngNETRange As Single
    
On Error GoTo DefineDefaultElutionTimesErrorHandler

    sngNETRange = sngNETEnd - sngNETStart
    
    lngMaxIndex = UBound(udtScanInfo)
    If lngMaxIndex > 0 Then
        lngMaxScanNumber = udtScanInfo(lngMaxIndex).ScanNumber
        
        For lngIndex = 1 To lngMaxIndex
            With udtScanInfo(lngIndex)
                .ElutionTime = .ScanNumber / lngMaxScanNumber * sngNETRange + sngNETStart
            End With
        Next lngIndex
    End If
    
    Exit Sub

DefineDefaultElutionTimesErrorHandler:
    Debug.Assert False
    LogErrors Err.Number, "DefineDefaultElutionTimes"
    
End Sub

Public Function DetermineSourceDataRawFileType(ByVal lngGelIndex As Long, ByVal blnForceUpdate As Boolean) As Boolean
    ' Attempts to determine the source raw data file type
    ' This involves looking for a .Raw file in the folder specified by GelData().PathtoDataFiles
    ' If a .Raw file isn't found, then looks for s*.zip files
    '
    ' Returns true if success, false if failure
    ' Does not look for any files if blnForceUpdate = False and .SourceDataRawFileType <> rfcUnknown
    
    Dim fso As New FileSystemObject
    Dim strTargetFilePath As String
    Dim strFileMatch As String
    
    Dim blnSuccess As Boolean

On Error GoTo DetermineSourceDataRawFileTypeErrorHandler

    If Not blnForceUpdate And GelStatus(lngGelIndex).SourceDataRawFileType <> rfcUnknown Then
        blnSuccess = True
    Else
        If fso.FolderExists(GelData(lngGelIndex).PathtoDataFiles) Then
            ' Look for a .Raw file in the source data folder, having the same name as the .Pek, .CSV, .mzXML, or .mzData file
            strTargetFilePath = fso.GetBaseName(GelData(lngGelIndex).FileName)
            strTargetFilePath = strTargetFilePath & ".Raw"
            
            strTargetFilePath = fso.BuildPath(GelData(lngGelIndex).PathtoDataFiles, strTargetFilePath)
            If fso.FileExists(strTargetFilePath) Then
                GelStatus(lngGelIndex).SourceDataRawFileType = rfcFinniganRaw
                GelStatus(lngGelIndex).FinniganRawFilePath = strTargetFilePath
                blnSuccess = True
            Else
                ' No .Raw file found
                ' See if any s*.zip files are present
                strTargetFilePath = fso.BuildPath(GelData(lngGelIndex).PathtoDataFiles, "s*.zip")
                strFileMatch = Dir(strTargetFilePath)
                If Len(strFileMatch) > 0 Then
                    GelStatus(lngGelIndex).SourceDataRawFileType = rfcZippedSFolders
                    GelStatus(lngGelIndex).FinniganRawFilePath = ""
                    blnSuccess = True
                Else
                    ' Zipped S folders don't exist, unable to determine raw file type
                    blnSuccess = False
                End If
            End If
        Else
            ' Folder doesn't exist, unable to determine raw file type
            blnSuccess = False
        End If
    End If
    
    DetermineSourceDataRawFileType = blnSuccess
    Exit Function

DetermineSourceDataRawFileTypeErrorHandler:
    Debug.Assert False
    LogErrors Err.Number, "DetermineSourceDataRawFileType"
    DetermineSourceDataRawFileType = False
    
End Function

Public Function ExtractDBNameFromConnectionString(ByVal strConnectionString As String) As String
    Const CATALOG_STRING = "catalog="
    Dim intCharLoc As Integer, strDBName As String
    
    intCharLoc = InStr(LCase(strConnectionString), CATALOG_STRING)
    
    strDBName = "Unknown"
    If intCharLoc > 0 Then
        strDBName = Mid(strConnectionString, intCharLoc + Len(CATALOG_STRING))
        intCharLoc = InStr(strDBName, ";")
        
        If intCharLoc > 0 Then
            strDBName = Left(strDBName, intCharLoc - 1)
        End If
    End If

    ExtractDBNameFromConnectionString = strDBName
    
End Function

Private Function FindTextInAnalysisHistory(ByVal lngGelIndex As Long, ByVal strTextToFind As String, Optional ByRef lngHistoryIndexOfMatch As Long, Optional lngAnalysisHistoryIndexStartSearch As Long = 0) As String
    ' Looks in the AnalysisHistory for lngGelIndex for strTextToFind (case insensitive search)
    ' If found, returns the history text and sets lngHistoryIndexOfMatch to the HistoryIndex of the match
    ' If not found, returns "", and sets lngHistoryIndexOfMatch to -1
    
    Dim lngIndex As Long
    Dim strMatchText As String
    
    strTextToFind = UCase(strTextToFind)
    
    strMatchText = ""
    lngHistoryIndexOfMatch = -1
    
    If lngGelIndex >= 1 And lngGelIndex <= UBound(GelSearchDef()) Then
        With GelSearchDef(lngGelIndex)
            For lngIndex = lngAnalysisHistoryIndexStartSearch To .AnalysisHistoryCount - 1
                If InStr(UCase(.AnalysisHistory(lngIndex)), strTextToFind) Then
                    strMatchText = .AnalysisHistory(lngIndex)
                    lngHistoryIndexOfMatch = lngIndex
                    Exit For
                End If
            Next lngIndex
        End With
    End If

    FindTextInAnalysisHistory = strMatchText
    
End Function

Public Sub FindMWExtremes(ByRef udtIsoData As udtIsotopicDataType, ByRef MinMW As Double, ByRef MaxMW As Double, ByRef MaxMZ As Double)

    Dim TestMZ As Double

    With udtIsoData
        If .AverageMW < MinMW Then MinMW = .AverageMW
        If .AverageMW > MaxMW Then MaxMW = .AverageMW
        
        If .MonoisotopicMW < MinMW Then MinMW = .MonoisotopicMW
        If .MonoisotopicMW > MaxMW Then MaxMW = .MonoisotopicMW
        
        If .MostAbundantMW < MinMW Then MinMW = .MostAbundantMW
        If .MostAbundantMW > MaxMW Then MaxMW = .MostAbundantMW
        
        If .Charge > 0 Then
            TestMZ = (.AverageMW + .Charge) / .Charge
            If TestMZ > MaxMZ Then MaxMZ = TestMZ
        
            TestMZ = (.MonoisotopicMW + .Charge) / .Charge
            If TestMZ > MaxMZ Then MaxMZ = TestMZ
        
            TestMZ = (.MostAbundantMW + .Charge) / .Charge
            If TestMZ > MaxMZ Then MaxMZ = TestMZ
        Else
            ' Charge state is 0; this is probably an error in the .Pek, .CSV, .mzXML, or .mzData file
            Debug.Assert False
        End If
    End With

End Sub

Public Function FindSettingInAnalysisHistory(ByVal lngGelIndex As Long, ByVal strSettingToFind As String, Optional ByRef lngHistoryIndexOfMatch As Long, Optional ByVal blnFindLastOccurrence As Boolean = True, Optional ByVal strValueDelimeter As String = "=", Optional ByVal strSettingDelimeter As String = ";") As String
    ' Looks in AnalysisHistory for lngGelIndex for strSettingToFind
    ' If found, looks for the first strValueDelimeter after the match (though does not look past strSettingDelimeter)
    ' If strValueDelimeter is found, returns the text between strValueDelimeter and strSettingDelimeter
    '   and sets lngHistoryIndexOfMatch to the HistoryIndex of the match
    ' If not found, returns "", and sets lngHistoryIndexOfMatch to -1
    '
    ' If blnFindLastOccurrence = False, then returns the first occurrence of a match
    ' If blnFindLastOccurrence = True, then returns the last occurrence of a match
    '
    ' For example if .AnalysisHistory(5) contains "UMC Peaks in tolerance = 2654; UMC Peaks with DB hits = 46"
    '   and this function is called with strSettingToFind = "UMC Peaks in tolerance" and strValueDelimeter = "="
    '   and strSettingDelimeter = ";", then the match will be found in entry 5 and "2654" will be returned
    ' If blnFindLastOccurrence = True, and .AnalysisHistory(25) contains "UMC Peaks in tolerance = 3803; UMC Peaks with DB hits = 184"
    '   then "3803" will be returned instead

    Dim lngHistoryIndexLastMatch As Long, lngAnalysisHistoryIndexStartSearch As Long
    Dim lngHistoryIndexTest As Long
    Dim lngCharIndex As Long
    Dim strMatchFull As String, strValueForSetting As String
    
    strValueForSetting = ""
    lngHistoryIndexOfMatch = -1
        
    If lngGelIndex >= 1 And lngGelIndex <= UBound(GelSearchDef()) Then
        With GelSearchDef(lngGelIndex)
            lngAnalysisHistoryIndexStartSearch = 0
            lngHistoryIndexLastMatch = -1
            Do
                FindTextInAnalysisHistory lngGelIndex, strSettingToFind, lngHistoryIndexTest, lngAnalysisHistoryIndexStartSearch
            
                If lngHistoryIndexTest >= 0 Then
                    lngHistoryIndexLastMatch = lngHistoryIndexTest
                    lngAnalysisHistoryIndexStartSearch = lngHistoryIndexTest + 1
                    If Not blnFindLastOccurrence Then Exit Do
                End If
            Loop While lngHistoryIndexTest >= 0
            
            If lngHistoryIndexLastMatch >= 0 Then
                ' Find the specific location of strSettingToFind in .AnalysisHistory(lngHistoryIndexLastMatch
                lngCharIndex = Trim(InStr(UCase(.AnalysisHistory(lngHistoryIndexLastMatch)), UCase(strSettingToFind)))
                
                ' Copy the setting from .AnalysisHistory()
                strMatchFull = Mid(.AnalysisHistory(lngHistoryIndexLastMatch), lngCharIndex)
                
                ' Remove any settings following the given one
                lngCharIndex = InStr(strMatchFull, strSettingDelimeter)
                If lngCharIndex > 0 Then
                    strMatchFull = Trim(Left(strMatchFull, lngCharIndex - 1))
                End If
                
                ' Isolate the value after the setting
                lngCharIndex = InStr(strMatchFull, strValueDelimeter)
                If lngCharIndex > 0 Then
                    strValueForSetting = Trim(Mid(strMatchFull, lngCharIndex + 1))
                End If
                
                ' Update lngHistoryIndexOfMatch
                lngHistoryIndexOfMatch = lngHistoryIndexLastMatch
            End If
        End With
    End If
    
    FindSettingInAnalysisHistory = strValueForSetting
    
End Function

Public Function FormatCurrentPosition(X1 As Double, Y1 As Double, Optional blnYAxisIsMass As Boolean = True, Optional ByRef blnTimeAxisIsFN As Boolean = True) As String
    
    Dim lngXAxisDecDigits As Long, lngYAxisDecDigits As Long
    
    If blnYAxisIsMass Then
        If blnTimeAxisIsFN Then lngXAxisDecDigits = 0 Else lngXAxisDecDigits = 3
        lngYAxisDecDigits = 4
    Else
        If blnTimeAxisIsFN Then lngYAxisDecDigits = 0 Else lngYAxisDecDigits = 3
        lngXAxisDecDigits = 4
    End If
    
    FormatCurrentPosition = Round(X1, lngXAxisDecDigits) & ", " & Round(Y1, lngYAxisDecDigits)
    
End Function

Public Function GANETToScan(ByVal lngGelIndex As Long, ByVal dblNET As Double) As Long
    Dim dblSlope As Double, dblIntercept As Double
    Dim lngScanNumberMin As Long, lngScanNumberMax As Long
    
    Dim lngFirstIndex As Long, lngLastIndex As Long
    Dim lngMidIndex As Long
    Dim lngCurrentFirst As Long, lngCurrentLast As Long
    Dim lngMatchIndex As Long
        
On Error GoTo GANETToScanErrorHandler
     
    If GelData(lngGelIndex).CustomNETsDefined Then
        ' Need to find the scan closest to the given NET value
        ' Since scans should have increasing NET values, we can use a binary search
        ' Note that this code is from BinarySearchDblFindNearest
   
        With GelData(lngGelIndex)
            lngFirstIndex = 1
            lngLastIndex = UBound(.ScanInfo)
        
            lngCurrentFirst = lngFirstIndex
            lngCurrentLast = lngLastIndex
            
            If lngCurrentFirst > lngCurrentLast Then
                ' Invalid indices were provided
                lngMatchIndex = -1
            ElseIf lngCurrentFirst = lngCurrentLast Then
                ' Search space is only one element long; simply return that element's index
                lngMatchIndex = lngCurrentFirst
            Else
                lngMidIndex = (lngCurrentFirst + lngCurrentLast) \ 2            ' Note: Using Integer division
                If lngMidIndex < lngCurrentFirst Then lngMidIndex = lngCurrentFirst
                
                Do While lngCurrentFirst <= lngCurrentLast And .ScanInfo(lngMidIndex).CustomNET <> dblNET
                    If dblNET < .ScanInfo(lngMidIndex).CustomNET Then
                        ' Search the lower half
                        lngCurrentLast = lngMidIndex - 1
                    ElseIf dblNET > .ScanInfo(lngMidIndex).CustomNET Then
                        ' Search the upper half
                        lngCurrentFirst = lngMidIndex + 1
                    End If
                    ' Compute the new mid point
                    lngMidIndex = (lngCurrentFirst + lngCurrentLast) \ 2
                    If lngMidIndex < lngCurrentFirst Then
                        lngMidIndex = lngCurrentFirst
                        If lngMidIndex > lngCurrentLast Then
                            lngMidIndex = lngCurrentLast
                        End If
                        Exit Do
                    End If
                Loop
                
                lngMatchIndex = -1
                ' See if an exact match has been found
                If lngMidIndex >= lngCurrentFirst And lngMidIndex <= lngCurrentLast Then
                    If .ScanInfo(lngMidIndex).CustomNET = dblNET Then
                        lngMatchIndex = lngMidIndex
                    End If
                End If
                
                If lngMatchIndex = -1 Then
                    ' No exact match; find the nearest match
                    If .ScanInfo(lngMidIndex).CustomNET < dblNET Then
                        If lngMidIndex < lngLastIndex Then
                            If Abs(.ScanInfo(lngMidIndex).CustomNET - dblNET) <= Abs(.ScanInfo(lngMidIndex + 1).CustomNET - dblNET) Then
                                lngMatchIndex = lngMidIndex
                            Else
                                lngMatchIndex = lngMidIndex + 1
                            End If
                        Else
                            ' dblNET is larger than the NET of the final scan
                            lngMatchIndex = lngMidIndex
                        End If
                    Else
                        ' .ScanInfo(lngMidIndex).CustomNET >= dblNET
                        If lngMidIndex > lngFirstIndex Then
                            If Abs(.ScanInfo(lngMidIndex).CustomNET - dblNET) <= Abs(.ScanInfo(lngMidIndex - 1).CustomNET - dblNET) Then
                                lngMatchIndex = lngMidIndex
                            Else
                                lngMatchIndex = lngMidIndex - 1
                            End If
                        Else
                            ' dblNET is smaller than the NET of the first scan
                            lngMatchIndex = lngMidIndex
                        End If
                    End If
                        
                End If
            End If
        End With
        
        If lngMatchIndex >= lngFirstIndex Then
            GANETToScan = GelData(lngGelIndex).ScanInfo(lngMatchIndex).ScanNumber
        Else
            GANETToScan = 0
        End If
       
    Else
        If Not GelAnalysis(lngGelIndex) Is Nothing Then
            ' Populate .GANETVals()
            dblSlope = GelAnalysis(lngGelIndex).GANET_Slope
            dblIntercept = GelAnalysis(lngGelIndex).GANET_Intercept
        End If
        
        If dblSlope = 0 Then
            ' Populate .GANETVals() with generic NET values
            GetScanRange lngGelIndex, lngScanNumberMin, lngScanNumberMax, 0
            dblSlope = 1 / (lngScanNumberMax - lngScanNumberMin + 1)
            dblIntercept = 0
        End If
    
        GANETToScan = ComputeScanNumber(dblNET, dblSlope, dblIntercept)
    End If

    Exit Function

GANETToScanErrorHandler:
    Debug.Assert False
    GANETToScan = 0

End Function

Public Function GetZoomBoxDimensions(ZoomX1 As Double, ZoomY1 As Double, ZoomX2 As Double, ZoomY2 As Double, blnIncludePPMMassDifference As Boolean, Optional blnYAxisIsMass As Boolean = True, Optional blnTimeAxisIsFN As Boolean) As String
    Dim strReturn As String
    Dim lngXAxisDecDigits As Long, lngYAxisDecDigits As Long
    Dim dblMassAverage As Double, dblMassDiff As Double
    
    If blnYAxisIsMass Then
        If blnTimeAxisIsFN Then lngXAxisDecDigits = 0 Else lngXAxisDecDigits = 3
        lngYAxisDecDigits = 4
    Else
        If blnTimeAxisIsFN Then lngYAxisDecDigits = 0 Else lngYAxisDecDigits = 3
        lngXAxisDecDigits = 4
    End If
    
    strReturn = Round(ZoomX1, lngXAxisDecDigits) & " to " & Round(ZoomX2, lngXAxisDecDigits) & ", " & Round(ZoomY1, lngYAxisDecDigits) & " to " & Round(ZoomY2, lngYAxisDecDigits)
    
    If blnIncludePPMMassDifference Then
        If blnYAxisIsMass Then
            dblMassAverage = (ZoomY1 + ZoomY2) / 2
            dblMassDiff = Abs(ZoomY1 - ZoomY2)
        Else
            dblMassAverage = (ZoomX1 + ZoomX2) / 2
            dblMassDiff = Abs(ZoomX1 - ZoomX2)
        End If
        If dblMassAverage > 0 Then strReturn = strReturn & " (" & Round(MassToPPM(dblMassDiff, dblMassAverage), 1) & " ppm window = " & Round(dblMassDiff, 4) & " Da)"
    End If
    
    GetZoomBoxDimensions = strReturn
    
End Function

Public Sub HideMTConnectionClassForm(objMTConnectionObject As DummyAnalysisInitiator)
    Dim hwnd As Long
    Const NULLCHAR = 0&
    Const WM_SYSCOMMAND = &H112
    Const SC_CLOSE = &HF060&

' Hide the "Select MT Database For Out" window if necessary
On Error Resume Next
    If Not objMTConnectionObject Is Nothing Then
        hwnd = FindWindowCaption(SELECT_MT_DATABASE_MASSTAGS_ACCESS_CAPTION)
        If hwnd > 0 Then
            ' The CloseWindow() API only minimizes the window, so use SendMessage to close it more forcefully
            hwnd = SendMessage(hwnd, WM_SYSCOMMAND, SC_CLOSE, NULLCHAR)
        End If
    
        Set objMTConnectionObject = Nothing
    End If
On Error GoTo 0

End Sub

Public Function GetIsoDescription(intIsoField As Integer) As String
    Select Case intIsoField
    Case isfMWavg
        GetIsoDescription = "Average mass"
    Case isfMWMono
        GetIsoDescription = "Monoisotopic mass"
    Case isfMWTMA
        GetIsoDescription = "Most abundant monoiso mass"
    Case Else
        GetIsoDescription = "?? MW"
    End Select
End Function

Public Function GetIsoMass(ByRef udtIsoData As udtIsotopicDataType, intIsoDataField As Integer) As Double
    'Const isfMWMono = 7           'monoisotopic molecular mass
    'Const isfMWavg = 6            'average molecular mass
    'Const isfMWTMA = 8            'the most abundant mol.mass
    
    Select Case intIsoDataField
    Case 7: GetIsoMass = udtIsoData.MonoisotopicMW
    Case 6: GetIsoMass = udtIsoData.AverageMW
    Case 8: GetIsoMass = udtIsoData.MostAbundantMW
    Case Else
        ' Unknown value for intIsoDataField; return the monoisotopic mass
        Debug.Assert False
        GetIsoMass = udtIsoData.MonoisotopicMW
    End Select
End Function

Public Sub SetIsoMass(ByRef udtIsoData As udtIsotopicDataType, intIsoDataField As Integer, dblNewMass As Double)
    Select Case intIsoDataField
    Case 7: udtIsoData.MonoisotopicMW = dblNewMass
    Case 6: udtIsoData.AverageMW = dblNewMass
    Case 8: udtIsoData.MostAbundantMW = dblNewMass
    Case Else
        ' Unknown value for intIsoDataField; do not update anything
        Debug.Assert False
    End Select
End Sub

Public Function GetMassTagMatchCount(ByRef udtDBSettings As udtDBSettingsType, ByVal lngCurrentJob As Long, ByRef frmCallingForm As VB.Form) As Long
    ' Retrieves a count of the MT tags that would be returned by the connection values
    '  stored in udtDBSettings
    ' This function does not take into account specific filters for static or dynamic modifications

    ' Returns the count if successful, 0 if no matching records, and 0 if an error

    Dim intDBConnectionTimeOutSeconds As Integer
    Dim cnnConnection As ADODB.Connection
    Dim rstRecordset As New ADODB.Recordset

    Dim sngDBSchemaVersion As Single

    Dim sCommand As String
    Dim cmdGetMassTagMatchCount As New ADODB.Command

    ' Stored procedure parameters
    Dim prmMTsubsetID As ADODB.Parameter
    Dim prmAMTsOnly As ADODB.Parameter
    Dim prmConfirmedOnly As ADODB.Parameter
    Dim prmLockersOnly As ADODB.Parameter
    Dim prmMinimumPMTQualityScore As ADODB.Parameter
    Dim prmMinimumHighNormalizedScore As ADODB.Parameter
    Dim prmMinimumHighDiscriminantScore As ADODB.Parameter
    Dim prmExperimentInclusionFilter As ADODB.Parameter
    Dim prmExperimentExclusionFilter As ADODB.Parameter
    Dim prmJobToFilterOnByDataset As ADODB.Parameter
    Dim prmMinimumPeptideProphetProbability As ADODB.Parameter
    
    Dim strConnectionString As String
    Dim strCaptionSaved As String
    Dim strCaptionBase As String
    Dim strProgressDots As String

    Dim strMTSubsetID As String
    Dim lngMTSubsetID As Long
    Dim blnConfirmedOnly As Boolean
    Dim blnAccurateOnly As Boolean
    Dim blnLockersOnly As Boolean
    Dim blnLimitToPMTsFromDataset As Boolean
    
    Dim sngMinimumHighNormalizedScore As Single
    Dim sngMinimumHighDiscriminantScore As Single
    Dim sngMinimumPeptideProphetProbability As Single
    Dim sngMinimumPMTQualityScore As Single
    Dim strExperimentInclusionFilter As String
    Dim strExperimentExclusionFilter As String
    
    Dim lngMassTagMatchCount As Long
    
On Error GoTo GetMassTagMatchCountErrorHandler

    If APP_BUILD_DISABLE_MTS Then
        GetMassTagMatchCount = 0
        Exit Function
    End If
    
    strConnectionString = udtDBSettings.AnalysisInfo.MTDB.ConnectionString
    If strConnectionString = "" Then
        GetMassTagMatchCount = 0
        Exit Function
    End If

    sCommand = glbPreferencesExpanded.MTSConnectionInfo.spGetMassTagMatchCount
    If Len(sCommand) <= 0 Then
        Debug.Assert False
        sCommand = "GetMassTagMatchCount"
    End If

    strCaptionSaved = frmCallingForm.Caption
    strCaptionBase = "Counting number of matching MT tags: Connecting to database"
    frmCallingForm.Caption = strCaptionBase
        
    If Not EstablishConnection(cnnConnection, strConnectionString, False) Then
        Debug.Assert False
        frmCallingForm.Caption = strCaptionSaved
        GetMassTagMatchCount = 0
        Exit Function
    End If
    
    ' Lookup the DB Schema Version
    sngDBSchemaVersion = LookupDBSchemaVersion(cnnConnection)

    With udtDBSettings
        blnConfirmedOnly = CBoolSafe(LookupCollectionArrayValueByName(.AnalysisInfo.MTDB.DBStuffArray(), .AnalysisInfo.MTDB.DBStuffArrayCount, NAME_CONFIRMED_ONLY))

        If sngDBSchemaVersion < 2 Then
            blnAccurateOnly = CBoolSafe(LookupCollectionArrayValueByName(.AnalysisInfo.MTDB.DBStuffArray(), .AnalysisInfo.MTDB.DBStuffArrayCount, NAME_ACCURATE_ONLY))
            blnLockersOnly = CBoolSafe(LookupCollectionArrayValueByName(.AnalysisInfo.MTDB.DBStuffArray(), .AnalysisInfo.MTDB.DBStuffArrayCount, NAME_LOCKERS_ONLY))
        End If

        sngMinimumHighNormalizedScore = CSngSafe(LookupCollectionArrayValueByName(.AnalysisInfo.MTDB.DBStuffArray(), .AnalysisInfo.MTDB.DBStuffArrayCount, NAME_MINIMUM_HIGH_NORMALIZED_SCORE))
        sngMinimumHighDiscriminantScore = CSngSafe(LookupCollectionArrayValueByName(.AnalysisInfo.MTDB.DBStuffArray(), .AnalysisInfo.MTDB.DBStuffArrayCount, NAME_MINIMUM_HIGH_DISCRIMINANT_SCORE))
        sngMinimumPeptideProphetProbability = CSngSafe(LookupCollectionArrayValueByName(.AnalysisInfo.MTDB.DBStuffArray(), .AnalysisInfo.MTDB.DBStuffArrayCount, NAME_MINIMUM_PEPTIDE_PROPHET_PROBABILITY))
        sngMinimumPMTQualityScore = CSngSafe(LookupCollectionArrayValueByName(.AnalysisInfo.MTDB.DBStuffArray(), .AnalysisInfo.MTDB.DBStuffArrayCount, NAME_MINIMUM_PMT_QUALITY_SCORE))

        strExperimentInclusionFilter = CStrSafe(LookupCollectionArrayValueByName(.AnalysisInfo.MTDB.DBStuffArray(), .AnalysisInfo.MTDB.DBStuffArrayCount, NAME_EXPERIMENT_INCLUSION_FILTER))
        strExperimentExclusionFilter = CStrSafe(LookupCollectionArrayValueByName(.AnalysisInfo.MTDB.DBStuffArray(), .AnalysisInfo.MTDB.DBStuffArrayCount, NAME_EXPERIMENT_EXCLUSION_FILTER))
        
        ' Note: .NETValueType is not considered when estimating the MT tag match count

        If sngDBSchemaVersion < 2 Then
            strMTSubsetID = LookupCollectionArrayValueByName(.AnalysisInfo.MTDB.DBStuffArray(), .AnalysisInfo.MTDB.DBStuffArrayCount, NAME_SUBSET)
            If Len(strMTSubsetID) > 0 Then
                lngMTSubsetID = CLngSafe(strMTSubsetID)
            Else
                lngMTSubsetID = -1
            End If
        Else
            blnLimitToPMTsFromDataset = CBoolSafe(LookupCollectionArrayValueByName(.AnalysisInfo.MTDB.DBStuffArray(), .AnalysisInfo.MTDB.DBStuffArrayCount, NAME_LIMIT_TO_PMTS_FROM_DATASET))
        End If
    End With
    
    ' Initialize the SP
    InitializeSPCommand cmdGetMassTagMatchCount, cnnConnection, sCommand
    
    If sngDBSchemaVersion < 2 Then
        Set prmMTsubsetID = cmdGetMassTagMatchCount.CreateParameter("MTSubSetID", adInteger, adParamInput, , lngMTSubsetID)
        cmdGetMassTagMatchCount.Parameters.Append prmMTsubsetID
        
        Set prmAMTsOnly = cmdGetMassTagMatchCount.CreateParameter("AmtsOnly", adTinyInt, adParamInput, , BoolToTinyInt(blnAccurateOnly))
        cmdGetMassTagMatchCount.Parameters.Append prmAMTsOnly
    End If

    Set prmConfirmedOnly = cmdGetMassTagMatchCount.CreateParameter("ConfirmedOnly", adTinyInt, adParamInput, , BoolToTinyInt(blnConfirmedOnly))
    cmdGetMassTagMatchCount.Parameters.Append prmConfirmedOnly
    
    If sngDBSchemaVersion < 2 Then
        Set prmLockersOnly = cmdGetMassTagMatchCount.CreateParameter("LockersOnly", adTinyInt, adParamInput, , BoolToTinyInt(blnLockersOnly))
        cmdGetMassTagMatchCount.Parameters.Append prmLockersOnly
    End If
    
    Set prmMinimumHighNormalizedScore = cmdGetMassTagMatchCount.CreateParameter("MinimumHighNormalizedScore", adSingle, adParamInput, , sngMinimumHighNormalizedScore)
    cmdGetMassTagMatchCount.Parameters.Append prmMinimumHighNormalizedScore
    
    Set prmMinimumPMTQualityScore = cmdGetMassTagMatchCount.CreateParameter("MinimumPMTQualityScore", adDecimal, adParamInput)
    With prmMinimumPMTQualityScore
        .precision = 9
        .NumericScale = 5
        .Value = ValueToSqlDecimal(sngMinimumPMTQualityScore, sdcSqlDecimal9x5)
    End With
    cmdGetMassTagMatchCount.Parameters.Append prmMinimumPMTQualityScore
    
    If sngDBSchemaVersion >= 2 Then
        Set prmMinimumHighDiscriminantScore = cmdGetMassTagMatchCount.CreateParameter("MinimumHighDiscriminantScore", adSingle, adParamInput, , sngMinimumHighDiscriminantScore)
        cmdGetMassTagMatchCount.Parameters.Append prmMinimumHighDiscriminantScore
        
        Set prmExperimentInclusionFilter = cmdGetMassTagMatchCount.CreateParameter("ExperimentFilter", adVarChar, adParamInput, 64, strExperimentInclusionFilter)
        cmdGetMassTagMatchCount.Parameters.Append prmExperimentInclusionFilter
        
        Set prmExperimentExclusionFilter = cmdGetMassTagMatchCount.CreateParameter("ExperimentExclusionFilter", adVarChar, adParamInput, 64, strExperimentExclusionFilter)
        cmdGetMassTagMatchCount.Parameters.Append prmExperimentExclusionFilter
            
        Set prmJobToFilterOnByDataset = cmdGetMassTagMatchCount.CreateParameter("JobToFilterOnByDataset", adInteger, adParamInput, , 0)
        If blnLimitToPMTsFromDataset Then
            prmJobToFilterOnByDataset.Value = lngCurrentJob
        End If
        cmdGetMassTagMatchCount.Parameters.Append prmJobToFilterOnByDataset
    
        Set prmMinimumPeptideProphetProbability = cmdGetMassTagMatchCount.CreateParameter("MinimumPeptideProphetProbability", adSingle, adParamInput, , sngMinimumPeptideProphetProbability)
        cmdGetMassTagMatchCount.Parameters.Append prmMinimumPeptideProphetProbability
    End If
    
    
    ' Procedure 0 if successful, error number if an error
    intDBConnectionTimeOutSeconds = glbPreferencesExpanded.AutoAnalysisOptions.DBConnectionTimeoutSeconds
    If intDBConnectionTimeOutSeconds = 0 Then intDBConnectionTimeOutSeconds = 300
    cmdGetMassTagMatchCount.CommandTimeout = intDBConnectionTimeOutSeconds
    
    strCaptionBase = "Counting number of matching MT tags: Retrieving data"
    
    Set rstRecordset = cmdGetMassTagMatchCount.Execute(, , adAsyncExecute)
    Do While (cmdGetMassTagMatchCount.STATE And adStateExecuting)
        Sleep 500
        strProgressDots = strProgressDots & "."
        If Len(strProgressDots) > 30 Then strProgressDots = "."
        frmCallingForm.Caption = strCaptionBase & " " & strProgressDots
        DoEvents
    Loop

    ' Retrieve the value from the SP
    If Not rstRecordset.EOF Then
        lngMassTagMatchCount = FixNullLng(rstRecordset.Fields(0).Value)
    Else
        lngMassTagMatchCount = 0
    End If
    rstRecordset.Close
       
    
GetMassTagMatchCountCleanup:
    On Error Resume Next
    If rstRecordset.STATE <> adStateClosed Then rstRecordset.Close
    If cnnConnection.STATE <> adStateClosed Then cnnConnection.Close
    Set rstRecordset = Nothing
    Set cnnConnection = Nothing

    frmCallingForm.Caption = strCaptionSaved
    GetMassTagMatchCount = lngMassTagMatchCount
    
    Exit Function

GetMassTagMatchCountErrorHandler:
    MsgBox "Error while determining count of MT tags matching the given parameters (sub GetMassTagMatchCount): " & vbCrLf & Err.Description, vbExclamation + vbOKOnly, "Error"
    lngMassTagMatchCount = 0
    Resume GetMassTagMatchCountCleanup
    
 End Function

Public Sub InitializePairMatchStats(ByRef udtPairMatchStats As udtPairMatchStatsType, Optional ByVal dblValueIfERNotDefined As Double = ER_NO_RATIO)
    udtPairMatchStats.PairIndex = -1
    udtPairMatchStats.ExpressionRatio = dblValueIfERNotDefined
End Sub

Public Function LongToStringWithCommas(ByVal lngNumber As Long) As String
    LongToStringWithCommas = Format(lngNumber, "#,###,##0")
End Function

Public Function MassToPPM(dblMassToConvert As Double, dblCurrentMZ As Double) As Double
    ' Converts dblMassToConvert to ppm, based on the value of dblCurrentMZ
    
    MassToPPM = dblMassToConvert * 1000000# / dblCurrentMZ
End Function

Public Function MonoMassToMZ(dblMonoisotopicMass As Double, intCharge As Integer) As Double
    MonoMassToMZ = ConvoluteMass(dblMonoisotopicMass + glMASS_CC, 1, intCharge)
End Function

Public Function PairIndexLookupInitialize(lngGelIndex As Long, objP1IndFastSearch As FastSearchArrayLong, objP2IndFastSearch As FastSearchArrayLong) As Boolean
    ' Initializes objP1IndFastSearch and objP2IndFastSearch with the .P1() and .P2() arrays
    '  in GelP_D_L for the gel specified by lngGelIndex
    ' Returns True if pairs are present; returns False otherwise
    
    Dim blnPairsPresent As Boolean
    
    Dim lngIndex As Long
    Dim lngPairIndices() As Long
    
On Error GoTo InitializePairIndexLookupObjectsErrorHandler

    blnPairsPresent = PairsPresent(lngGelIndex)
    If blnPairsPresent Then
        With GelP_D_L(lngGelIndex)
            Set objP1IndFastSearch = New FastSearchArrayLong
            Set objP2IndFastSearch = New FastSearchArrayLong
    
            ' When using the .Fill function we need to send an array of longs
            ' However, since .Pairs() is a UDT array, we need to copy the data from .Pairs().P1 into lngPairIndices()
            ReDim lngPairIndices(UBound(.Pairs))
            For lngIndex = 0 To UBound(.Pairs)
                lngPairIndices(lngIndex) = .Pairs(lngIndex).P1
            Next lngIndex
            
            blnPairsPresent = objP1IndFastSearch.Fill(lngPairIndices())
        
            If blnPairsPresent Then
                
                For lngIndex = 0 To UBound(.Pairs)
                    lngPairIndices(lngIndex) = .Pairs(lngIndex).P2
                Next lngIndex
                
                blnPairsPresent = objP2IndFastSearch.Fill(lngPairIndices())
            End If
        End With
    End If
    
    PairIndexLookupInitialize = blnPairsPresent
    Exit Function

InitializePairIndexLookupObjectsErrorHandler:
    Debug.Assert False
    LogErrors Err.Number, "PairIndexLookupInitialize"
    PairIndexLookupInitialize = False
    
End Function

Public Function PairsPresent(lngGelIndex As Long) As Boolean
    ' Returns True if pairs are present

On Error GoTo PairsPresentErrorHandler

    With GelP_D_L(lngGelIndex)
        If .PCnt > 0 Then
            PairsPresent = True
        Else
            PairsPresent = False
        End If
    End With
    
    Exit Function

PairsPresentErrorHandler:
    PairsPresent = False

End Function

Public Function PairIndexLookupSearch(lngGelIndex As Long, lngUMCIndex As Long, objP1IndFastSearch As FastSearchArrayLong, objP2IndFastSearch As FastSearchArrayLong, blnReturnAllPairInstances As Boolean, blnFavorHeavy As Boolean, ByRef lngPairMatchCount As Long, ByRef udtPairMatchStats() As udtPairMatchStatsType, Optional dblValueIfERNotDefined As Double = ER_NO_RATIO) As Long
    ' Returns the index in GelP_D_L(lngGelIndex).P1() or GelP_D_L(lngGelIndex).P2() that contains lngUMCIndex
    ' In addition, returns various stats in udtPairMatchStats()
    '
    ' Returns -1 if not found or an error; will set the Expression ratio to dblValueIfERNotDefined in this case
    '
    ' Since a UMC can be a member of several pairs, this function returns the index of the "best" matching pair by
    '  looking for the pair with the closest ER value to that stored in the UMC
    ' This can be problematic, and isn't always desired, therefore this function has been updated to return arrays
    '  of the various stats, including an array of all of the pair indices that the UMC belongs to, with
    '  the caveate that if blnReturnAllPairInstances = False, then the array only contains the pairs for which the UMC
    ' is the light member (if blnFavorHeavy = False) or for which the UMC is the heavy member (if blnFavorHeavy = True)
    ' If blnReturnAllPairInstances = True, then returns all instances of the UMC in all pairs, regardless of
    '  whether it is a light or a heavy member
    
    Dim lngMatchingIndices() As Long
    Dim lngMatchingIndicesAddnl() As Long
    
    Dim lngMatchCount As Long, lngMatchCountAddnl As Long
    Dim lngMatchIndex As Long, lngMatchIndexCompare As Long
    Dim lngMatchIndexOfBestPair As Long
    
    Dim lngBestPairIndex As Long
    Dim dblERFromIDString As Double, dblBestERDiff As Double, dblTestERDiff As Double
    
    Dim blnUnexpectedMatch As Boolean
    Dim blnDuplicateFound As Boolean
    
On Error GoTo PairIndexLookupSearchErrorHandler

    blnUnexpectedMatch = False
    
    lngPairMatchCount = 0
    ReDim udtPairMatchStats(0)
    InitializePairMatchStats udtPairMatchStats(0), dblValueIfERNotDefined
    
    If blnReturnAllPairInstances Then
        If Not objP1IndFastSearch.FindMatchingIndices(lngUMCIndex, lngMatchingIndices(), lngMatchCount) Then
            ReDim lngMatchingIndices(0)
        End If
        
        If objP2IndFastSearch.FindMatchingIndices(lngUMCIndex, lngMatchingIndicesAddnl(), lngMatchCountAddnl) Then
            ' Append the pair indices in lngMatchingIndicesAddnl to lngMatchingIndices
            For lngMatchIndex = 0 To lngMatchCountAddnl - 1
                blnDuplicateFound = False
                For lngMatchIndexCompare = 0 To lngMatchCount - 1
                    If lngMatchingIndices(lngMatchIndexCompare) = lngMatchingIndicesAddnl(lngMatchIndex) Then
                        blnDuplicateFound = True
                        Exit For
                    End If
                Next lngMatchIndexCompare
                
                If Not blnDuplicateFound Then
                    ReDim Preserve lngMatchingIndices(lngMatchCount)
                    lngMatchingIndices(lngMatchCount) = lngMatchingIndicesAddnl(lngMatchIndex)
                    lngMatchCount = lngMatchCount + 1
                End If
            Next lngMatchIndex
        End If
    Else
        If blnFavorHeavy Then
            ' Favor the heavy member: Search lngP2Ind first, if no match, search lngP1Ind
            If objP2IndFastSearch.FindMatchingIndices(lngUMCIndex, lngMatchingIndices(), lngMatchCount) Then
                ' Match found
            Else
                If objP1IndFastSearch.FindMatchingIndices(lngUMCIndex, lngMatchingIndices(), lngMatchCount) Then
                    ' Match found
                    blnUnexpectedMatch = True
                End If
            End If
        Else
            ' Favor the light member: Search lngP1Ind first, if no match, search lngP2Ind
            If objP1IndFastSearch.FindMatchingIndices(lngUMCIndex, lngMatchingIndices(), lngMatchCount) Then
                ' Match found
            Else
                If objP2IndFastSearch.FindMatchingIndices(lngUMCIndex, lngMatchingIndices(), lngMatchCount) Then
                    ' Match found
                    blnUnexpectedMatch = True
                End If
            End If
        End If
    
    End If
    
    If lngMatchCount = 1 Then
        lngBestPairIndex = lngMatchingIndices(0)
        lngMatchIndexOfBestPair = 0
    ElseIf lngMatchCount > 1 Then
        ' Need to find the best match
        
        With GelUMC(lngGelIndex).UMCs(lngUMCIndex)
            dblERFromIDString = LookupExpressionRatioValue(lngGelIndex, .ClassRepInd, (.ClassRepType = glIsoType))
        End With
        
        lngBestPairIndex = lngMatchingIndices(0)
        lngMatchIndexOfBestPair = 0
        dblBestERDiff = Abs(dblERFromIDString - GelP_D_L(lngGelIndex).Pairs(lngBestPairIndex).ER)
        For lngMatchIndex = 1 To lngMatchCount - 1
            dblTestERDiff = Abs(dblERFromIDString - GelP_D_L(lngGelIndex).Pairs(lngMatchingIndices(lngMatchIndex)).ER)
            If dblTestERDiff < dblBestERDiff Then
                lngBestPairIndex = lngMatchingIndices(lngMatchIndex)
                lngMatchIndexOfBestPair = lngMatchIndex
                dblBestERDiff = dblTestERDiff
            End If
        Next lngMatchIndex
    Else
        lngBestPairIndex = -1
    End If
    
    If lngBestPairIndex >= 0 Then
        If blnUnexpectedMatch Then
            ' Only return one entry since an unexpected match was found
            lngMatchingIndices(0) = lngMatchingIndices(lngMatchIndexOfBestPair)
            lngMatchCount = 1
        End If
        
        ' Populate udtPairMatchStats() from the pairs given by lngMatchingIndices()
        lngPairMatchCount = lngMatchCount
        If lngPairMatchCount >= 1 Then
            ReDim udtPairMatchStats(lngPairMatchCount - 1)
        End If
        
        For lngMatchIndex = 0 To lngMatchCount - 1
            With GelP_D_L(lngGelIndex).Pairs(lngMatchingIndices(lngMatchIndex))
                udtPairMatchStats(lngMatchIndex).PairIndex = lngMatchingIndices(lngMatchIndex)
                udtPairMatchStats(lngMatchIndex).ExpressionRatio = .ER
                udtPairMatchStats(lngMatchIndex).ExpressionRatioStDev = .ERStDev
                udtPairMatchStats(lngMatchIndex).ExpressionRatioChargeStateBasisCount = .ERChargeStateBasisCount
                udtPairMatchStats(lngMatchIndex).ExpressionRatioMemberBasisCount = .ERMemberBasisCount
            End With
        
        Next lngMatchIndex
        
        PairIndexLookupSearch = lngBestPairIndex
    Else
        PairIndexLookupSearch = -1
    End If
    Exit Function
    
PairIndexLookupSearchErrorHandler:
    Debug.Assert False
    LogErrors Err.Number, "PairIndexLookupSearch"

    lngPairMatchCount = 0
    ReDim udtPairMatchStats(0)
    udtPairMatchStats(0).PairIndex = -1
    udtPairMatchStats(0).ExpressionRatio = dblValueIfERNotDefined

    PairIndexLookupSearch = -1
    
End Function

Public Sub ParseCommandLine()
    Const MAX_SWITCH_COUNT = 15
    Const SWITCH_START_CHAR = "/"
    Const SWITCH_PARAMETER_CHAR = ":"
    
    Dim fso As New FileSystemObject
    Dim ts As TextStream
    
    Dim strCmdLine As String
    Dim intSwitchCount As Integer
    Dim intIndex As Integer
    Dim strParameterFilePath As String
    Dim strSwitches(MAX_SWITCH_COUNT) As String             ' 0-based array
    Dim strSwitchParameters(MAX_SWITCH_COUNT) As String     ' 0-based array, parallel with strSwitches()
    
    Dim strLineIn As String
    Dim strKeyName As String, strKeyValue As String
    Dim lngCharLoc As Long, lngNextCharLoc As Long
    Dim blnAutoProcess As Boolean, blnExitProgramWhenDone As Boolean
    Dim blnPRISMAutomationMode As Boolean
    
    Dim blnGenerateIndexHtmlFiles As Boolean
    Dim blnOverwriteExistingFiles As Boolean
    Dim strIndexHtmlFilesFolderPath As String
    
    Dim blnShowHelp As Boolean
    Dim strMessage As String
    
    Dim strInputFilePathSingle As String
    Dim strIniFilePath As String, strLogFilePath As String, strOutputFolderPath As String
    Dim intInputFilePathCount As Integer
    Dim strInputFilePath() As String
    
    Dim eFileType As ifmInputFileModeConstants
        
    Dim strDataSetID() As String
    Dim strJobNumber() As String
    Dim udtAutoParams As udtAutoAnalysisParametersType
    
On Error GoTo ParseCommandLineErrorHandler

    ' Sample command line:
    ' Viper.exe ParameterFilePath.par
    '   or
    ' Viper.Exe /I:D:\Gels\InputFile.pek /N:D:\Gels\LaV2DGSettings.ini
    '   or
    ' Viper.Exe /I:D:\Gels\InputFile.csv /N:D:\Gels\LaV2DGSettings.ini
    '   or
    ' Viper.Exe /I:D:\Gels\InputFile.mzXML /N:D:\Gels\LaV2DGSettings.ini
    '   or
    ' Viper.Exe /I:D:\Gels\InputFile.mzData /N:D:\Gels\LaV2DGSettings.ini
    '   or
    ' Viper.Exe /I:D:\Gels\InputFile_mzData.xml /N:D:\Gels\LaV2DGSettings.ini
    '   or
    ' Viper.Exe /I:D:\Gels\InputFile_mzXML.xml /N:D:\Gels\LaV2DGSettings.ini
    '   or
    ' Viper.Exe /I:D:\Gels\InputFile.gel /N:D:\Gels\LaV2DGSettings.ini
    
    strCmdLine = Trim(Command())
    
    ' Examine strCmdLine
    ' It may or may not contain a parameter file path, and may or may not contain switches
    ' A switch starts with SWITCH_START_CHAR then has 1 or more letters
    ' In addition, the switch may be followed by SWITCH_PARAMETER_CHAR and a parameter for the switch
    ' Parameters with spaces can be surrounded by quotation marks, but do not have to be
    lngCharLoc = InStr(strCmdLine, SWITCH_START_CHAR)
    If lngCharLoc > 0 Then
        strParameterFilePath = Trim(Left(strCmdLine, lngCharLoc - 1))
    Else
        strParameterFilePath = Trim(strCmdLine)
    End If
    
    intSwitchCount = 0
    Do While Len(strCmdLine) > 0
        lngCharLoc = InStr(strCmdLine, SWITCH_START_CHAR)
        If lngCharLoc > 0 Then
            strCmdLine = Mid(strCmdLine, lngCharLoc + 1)
            lngNextCharLoc = InStr(strCmdLine, SWITCH_START_CHAR)
            
            If lngNextCharLoc > 0 Then
                strSwitches(intSwitchCount) = Trim(Left(strCmdLine, lngNextCharLoc - 1))
                strCmdLine = Mid(strCmdLine, lngNextCharLoc)
            Else
                strSwitches(intSwitchCount) = Trim(strCmdLine)
                strCmdLine = ""
            End If
            
            ' Look for SWITCH_PARAMETER_CHAR in strSwitches()
            lngCharLoc = InStr(strSwitches(intSwitchCount), SWITCH_PARAMETER_CHAR)
            If lngCharLoc > 0 Then
                strSwitchParameters(intSwitchCount) = Trim(Mid(strSwitches(intSwitchCount), lngCharLoc + 1))
                
                ' Remove any starting and ending quotation marks
                If Left(strSwitchParameters(intSwitchCount), 1) = Chr(34) Then
                    strSwitchParameters(intSwitchCount) = Mid(strSwitchParameters(intSwitchCount), 2)
                End If
                
                If Right(strSwitchParameters(intSwitchCount), 1) = Chr(34) Then
                    strSwitchParameters(intSwitchCount) = Left(strSwitchParameters(intSwitchCount), Len(strSwitchParameters(intSwitchCount)) - 1)
                End If
                
                strSwitches(intSwitchCount) = Left(strSwitches(intSwitchCount), lngCharLoc - 1)
            Else
                strSwitchParameters(intSwitchCount) = ""
            End If
            
            intSwitchCount = intSwitchCount + 1
            If intSwitchCount = MAX_SWITCH_COUNT Then Exit Do
        Else
            strCmdLine = ""
        End If
    Loop
    
    blnExitProgramWhenDone = True
    If intSwitchCount > 0 Then
        ' Parse the switches
        For intIndex = 0 To intSwitchCount - 1
            Select Case UCase(strSwitches(intIndex))
            Case "I"
                strInputFilePathSingle = strSwitchParameters(intIndex)
                blnAutoProcess = True
            Case "N"
                strIniFilePath = strSwitchParameters(intIndex)
            Case "R"
                ' Do not exit the program when done auto processing (Remain Open)
                blnExitProgramWhenDone = False
            Case "A"
                If Not APP_BUILD_DISABLE_MTS Then
                    blnPRISMAutomationMode = True
                End If
            Case "T"
                If IsNumeric(strSwitchParameters(intIndex)) Then
                    SetTraceLogLevel val(strSwitchParameters(intIndex))
                End If
            Case "G"
                strIndexHtmlFilesFolderPath = strSwitchParameters(intIndex)
                If Len(strIndexHtmlFilesFolderPath) > 0 Then
                    blnGenerateIndexHtmlFiles = True
                Else
                    blnShowHelp = True
                End If
            Case "O"
                blnOverwriteExistingFiles = True
            Case Else
                ' Includes "?", "HELP"
                blnShowHelp = True
                Exit For
            End Select
        Next intIndex
    End If
    
    If Len(strParameterFilePath) > 0 Then
        If Len(strInputFilePathSingle) = 0 Then
            blnShowHelp = True
        Else
            ' Make sure strInputFilePathSingle points to a known file type
            If Not DetermineFileType(strInputFilePathSingle, eFileType) Then
                blnShowHelp = True
            Else
                ' Make sure strParameterFilePath points to a valid file
                If FileExists(strParameterFilePath) Then
                    blnAutoProcess = True
                Else
                    MsgBox "Parameter file not found: " & strParameterFilePath, vbInformation + vbOKOnly, "File not Found"
                    blnShowHelp = True
                End If
            End If
        End If
    End If
    
    If blnShowHelp Then
        strMessage = "Syntax:" & vbCrLf
        If Not APP_BUILD_DISABLE_MTS Then
            strMessage = strMessage & App.EXEName & " /A [/T:TraceLogLevel]" & vbCrLf
            strMessage = strMessage & "   or" & vbCrLf
        End If
        
        strMessage = strMessage & App.EXEName & " ParameterFilePath.Par /R [/T:TraceLogLevel]" & vbCrLf
        strMessage = strMessage & "   or" & vbCrLf
        strMessage = strMessage & App.EXEName & " /I:InputFilePath.xxx /N:IniFilePath.Ini /R [/T:TraceLogLevel]" & vbCrLf
        strMessage = strMessage & "   or" & vbCrLf
        strMessage = strMessage & App.EXEName & " /G:FolderStartPath /O" & vbCrLf & vbCrLf
        
        If Not APP_BUILD_DISABLE_MTS Then
            strMessage = strMessage & "Use of /A will initiate fully automated PRISM automation mode.  The database will be queried periodically to look for available jobs." & vbCrLf & vbCrLf
        End If
        strMessage = strMessage & "A parameter file can be used to list the input file path and JobNumber for auto analysis, along with other paths.  Example parameter file:" & vbCrLf
        strMessage = strMessage & vbCrLf
            strMessage = strMessage & "InputFilePath=C:\Inp\InFile.PEK" & vbCrLf
            strMessage = strMessage & "JobNumber=823" & vbCrLf
            strMessage = strMessage & "OutputFolderPath=C:\Out" & vbCrLf
            strMessage = strMessage & "IniFilePath=C:\Param\Settings.ini" & vbCrLf
            strMessage = strMessage & "LogFilePath=C:\Logs\LogFile.log" & vbCrLf
        strMessage = strMessage & vbCrLf
    
        strMessage = strMessage & "The file extension for the input file can be " & KNOWN_FILE_EXTENSIONS & " "
        strMessage = strMessage & "Multiple PEK/CSV/mzXML/mzData files can be listed on the InputFilePath line, separating them using a vertical bar |.  In this case, also separate the JobNumber values using the vertical bar.  A speed advantage exists when processing multiple files in one call to this program, since the MT database data need only be loaded once." & vbCrLf & vbCrLf
        
        strMessage = strMessage & "Alternatively, use /I and /N for auto analysis without using a parameter file.  The /I switch specifies a .Pek, .CSV, etc. file to automatically process. "
        strMessage = strMessage & "If /N is missing, the options listed in " & INI_FILENAME & " will be used. "
        strMessage = strMessage & "/R is optional and means to not exit the program when done auto-processing (Remain Open). " & vbCrLf & vbCrLf
        
        strMessage = strMessage & "/T can be used to set the trace log level, for example /T:5  Higher numbers mean less logging /T:0 means off.  The default is off. " & vbCrLf & vbCrLf
        strMessage = strMessage & "/G instructs the program to examine the folder given by FolderStartPath and generate Index.html files for navigation, looking for Viper results folders containing Index.html files to determine the datafile names.  Unless /R is present, the program will exit when done."
        
        strMessage = strMessage & vbCrLf & vbCrLf & "-----------------------------------------------------------------" & vbCrLf
        
        strMessage = strMessage & "Program written by Matthew Monroe and Nikola Tolic for the Department of Energy (PNNL, Richland, WA) in 2000-2006" & vbCrLf & vbCrLf
        
        strMessage = strMessage & "This is version " & GetProgramVersion & " (" & APP_BUILD_DATE & ")" & vbCrLf & vbCrLf
        
        strMessage = strMessage & "E-mail: matthew.monroe@pnl.gov or matt@alchemistmatt.com" & vbCrLf
        strMessage = strMessage & "Website: http://ncrr.pnl.gov/ or http://www.sysbio.org/resources/staff/" & vbCrLf & vbCrLf
        
        strMessage = strMessage & "Licensed under the Apache License, Version 2.0; you may not use this file except in compliance with the License.  "
        strMessage = strMessage & "You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0" & vbCrLf & vbCrLf
        
        strMessage = strMessage & "Notice: This computer software was prepared by Battelle Memorial Institute, "
        strMessage = strMessage & "hereinafter the Contractor, under Contract No. DE-AC05-76RL0 1830 with the "
        strMessage = strMessage & "Department of Energy (DOE).  All rights in the computer software are reserved "
        strMessage = strMessage & "by DOE on behalf of the United States Government and the Contractor as "
        strMessage = strMessage & "provided in the Contract.  NEITHER THE GOVERNMENT NOR THE CONTRACTOR MAKES ANY "
        strMessage = strMessage & "WARRANTY, EXPRESS OR IMPLIED, OR ASSUMES ANY LIABILITY FOR THE USE OF THIS "
        strMessage = strMessage & "SOFTWARE.  This notice including this sentence must appear on any copies of "
        strMessage = strMessage & "this computer software." & vbCrLf
        
        With frmComment
            MDIForm1.Visible = False
            .Caption = "VIPER (Visual Inspection of Peak/Elution Relationships) Program Syntax"
            .Tag = -1
            .cmdCancel.Visible = False
            .cmdOK.Cancel = True
            .cmdOK.Default = True
            
            With .txtComment
                .Text = strMessage
                .Locked = True
                .Font.Name = "Courier"
                .Font.Size = 10
            End With
            .ScaleMode = vbTwips
            .width = 850 * Screen.TwipsPerPixelX
            .Height = 600 * Screen.TwipsPerPixelY
            .Show vbModal
        End With
        
        blnExitProgramWhenDone = True
    
    ElseIf blnPRISMAutomationMode Then
        blnExitProgramWhenDone = False
        MDIForm1.InitiatePRISMAutomation True
    ElseIf blnAutoProcess Then
    
        If Len(strParameterFilePath) > 0 Then
            ' Using a Parameter file
            ' Open the file and parse it
            
            intInputFilePathCount = 0
            
            ReDim strInputFilePath(0)
            ReDim strDataSetID(0)
            ReDim strJobNumber(0)
            
            Set ts = fso.OpenTextFile(strParameterFilePath, ForReading)
            Do While Not ts.AtEndOfStream
                strLineIn = ts.ReadLine()
                
                ' Comment lines start with a ; so Ignore them
                If Len(strLineIn) > 0 And Left(strLineIn, 1) <> ";" Then
                    lngCharLoc = InStr(strLineIn, "=")
                    If lngCharLoc > 0 Then
                        strKeyName = Trim(Left(strLineIn, lngCharLoc - 1))
                        strKeyValue = Trim(Mid(strLineIn, lngCharLoc + 1))
                        
                        Select Case UCase(strKeyName)
                        Case "INPUTFILEPATH"
                            strInputFilePath = Split(strKeyValue, "|")
                            intInputFilePathCount = UBound(strInputFilePath) + 1
                        Case "DATASETID"
                            strDataSetID = Split(strKeyValue, "|")
                        Case "JOBNUMBER"
                            strJobNumber = Split(strKeyValue, "|")
                        Case "OUTPUTFOLDERPATH"
                            strOutputFolderPath = strKeyValue
                        Case "INIFILEPATH"
                            strIniFilePath = strKeyValue
                        Case "LOGFILEPATH"
                            strLogFilePath = strKeyValue
                        Case Else
                            ' Ignore it
                        End Select
                        
                    End If
                End If
            Loop
            ts.Close
            Set ts = Nothing
            Set fso = Nothing
        
            If Len(strOutputFolderPath) > 0 Then
                If Not fso.FolderExists(strOutputFolderPath) Then
                    MsgBox "Output Folder does not exist: " & strOutputFolderPath & vbCrLf & "Will attempt to use: " & fso.GetParentFolderName(strInputFilePath(intIndex)), vbInformation + vbOKOnly, "Error"
                    strOutputFolderPath = fso.GetParentFolderName(strInputFilePath(intIndex))
                End If
            End If
            
            If Len(strIniFilePath) > 0 Then
                If Not fso.FileExists(strIniFilePath) Then
                    MsgBox "Ini file does not exist: " & strIniFilePath & vbCrLf & "Will use the default options (probably not what you want).", vbInformation + vbOKOnly, "Error"
                    strIniFilePath = ""
                End If
            End If
            
            For intIndex = 0 To intInputFilePathCount - 1
                InitializeAutoAnalysisParameters udtAutoParams
                
                With udtAutoParams
                    If intIndex <= UBound(strDataSetID) Then
                        .DatasetID = CLngSafe(Trim(strDataSetID(intIndex)))
                    Else
                        .DatasetID = -1
                    End If
                    
                    If intIndex <= UBound(strJobNumber) Then
                        .JobNumber = CLngSafe(Trim(strJobNumber(intIndex)))
                    Else
                        .JobNumber = -1
                    End If
                    
                    If .DatasetID = 0 And .JobNumber = 0 Then
                        .DatasetID = -1
                        .JobNumber = -1
                    End If
                    
                    With .FilePaths
                        .InputFilePath = strInputFilePath(intIndex)
                        .OutputFolderPath = strOutputFolderPath
                        .IniFilePath = strIniFilePath
                        .LogFilePath = strLogFilePath
                    End With
                    
                    .ShowMessages = False
                    .AutoCloseFileWhenDone = blnExitProgramWhenDone
                End With
                
                ' Note that AutoAnalysisStart will log an error to strLogFilePath if strInputFilePath does not exist
                AutoAnalysisStart udtAutoParams
                
                If udtAutoParams.ExitViperASAP Then
                    blnExitProgramWhenDone = True
                    Exit For
                End If
                
            Next intIndex
        
        Else
            ' Analyzing a single .Pek, .CSV, .mzXML, or .mzData file
            InitializeAutoAnalysisParameters udtAutoParams
            With udtAutoParams
                .FilePaths.InputFilePath = strInputFilePathSingle
                .FilePaths.IniFilePath = strIniFilePath
                .AutoCloseFileWhenDone = blnExitProgramWhenDone
            End With
            AutoAnalysisStart udtAutoParams
        End If
    ElseIf blnGenerateIndexHtmlFiles Then
        GenerateAutoAnalysisHtmlFiles strIndexHtmlFilesFolderPath, "", blnOverwriteExistingFiles, 0, 0, False
        frmProgress.HideForm
    Else
        blnExitProgramWhenDone = False
    End If
    
    If blnExitProgramWhenDone Then
        Unload MDIForm1
    End If
    
Exit Sub

ParseCommandLineErrorHandler:
    MsgBox "An error has occurred in sub ParseCommandLine: " & Err.Description, vbExclamation + vbOKOnly, "Error"
    
End Sub

Public Function PPMToMass(dblPPMToConvert As Double, dblCurrentMZ As Double) As Double
    ' Converts dblPPMToConvert to a mass value, which is dependent on dblCurrentMZ
    
    PPMToMass = dblPPMToConvert / 1000000# * dblCurrentMZ
End Function

' The following function has been replaced by ConstructConnectionString
''Public Function ReplaceDBNameInConnectionString(ByVal strConnectionString As String, ByVal strNewDatabaseName As String) As String
''    ' Replaces the existing database name in strConnectionString with the one given by strNewData
''    ' If 'catalog= is not found, then appends it to the connection string
''
''    Const CATALOG_STRING = "catalog="
''    Dim intCharLoc As Integer, strNewConnectionString As String
''
''    intCharLoc = InStr(LCase(strConnectionString), CATALOG_STRING)
''
''    If intCharLoc > 0 Then
''        strNewConnectionString = Left(strConnectionString, intCharLoc + Len(CATALOG_STRING) - 1)
''
''        strConnectionString = Mid(strConnectionString, intCharLoc + Len(CATALOG_STRING))
''        intCharLoc = InStr(strConnectionString, ";")
''
''        strNewConnectionString = strNewConnectionString & strNewDatabaseName
''        If intCharLoc > 0 Then
''            strNewConnectionString = strNewConnectionString & Mid(strConnectionString, intCharLoc)
''        End If
''
''    ElseIf Len(strConnectionString) > 0 Then
''        strNewConnectionString = strConnectionString & ";" & CATALOG_STRING & strNewDatabaseName
''    End If
''
''    ReplaceDBNameInConnectionString = strNewConnectionString
''
''End Function

Public Function ScanToGANET(ByVal lngGelIndex As Long, ByVal lngScanNumber As Long) As Double
    Dim dblSlope As Double, dblIntercept As Double
    Dim lngScanNumberMin As Long, lngScanNumberMax As Long
    Dim lngScanIndex As Long
    
On Error GoTo ScanToGANETErrorHandler

    If GelData(lngGelIndex).CustomNETsDefined Then
        lngScanIndex = LookupScanNumberRelativeIndex(lngGelIndex, lngScanNumber)
        If lngScanIndex = 0 Then
            lngScanNumber = LookupScanNumberClosest(lngGelIndex, lngScanNumber)
            lngScanIndex = LookupScanNumberRelativeIndex(lngGelIndex, lngScanNumber)
        End If
        
        ScanToGANET = GelData(lngGelIndex).ScanInfo(lngScanIndex).CustomNET
    Else
        If Not GelAnalysis(lngGelIndex) Is Nothing Then
            ' Populate .GANETVals()
            dblSlope = GelAnalysis(lngGelIndex).GANET_Slope
            dblIntercept = GelAnalysis(lngGelIndex).GANET_Intercept
        End If
        
        If dblSlope = 0 Then
            ' Populate .GANETVals() with generic NET values
            GetScanRange lngGelIndex, lngScanNumberMin, lngScanNumberMax, 0
            dblSlope = 1 / (lngScanNumberMax - lngScanNumberMin + 1)
            dblIntercept = 0
        End If
    
        ScanToGANET = ComputeNET(lngScanNumber, dblSlope, dblIntercept)
    End If
    Exit Function
    
ScanToGANETErrorHandler:
    Debug.Assert False
    ScanToGANET = 0
    
End Function

Public Sub SetEditCopyEMFOptions(blnIncludeFileNameAndDate As Boolean, blnIncludeTextLabels As Boolean)
    
    Dim lngIndex As Long
    
    glbPreferencesExpanded.GraphicExportOptions.CopyEMFIncludeFilenameAndDate = blnIncludeFileNameAndDate
    glbPreferencesExpanded.GraphicExportOptions.CopyEMFIncludeTextLabels = blnIncludeTextLabels
    
    On Error Resume Next
    For lngIndex = 1 To UBound(GelBody())
        GelBody(lngIndex).mnuEditCopyEMFIncludeFileNameAndTime.Checked = glbPreferencesExpanded.GraphicExportOptions.CopyEMFIncludeFilenameAndDate
        GelBody(lngIndex).mnuEditCopyEMFIncludeTextLabels.Checked = glbPreferencesExpanded.GraphicExportOptions.CopyEMFIncludeTextLabels
    Next lngIndex

End Sub

Public Sub SetTraceLogLevel(Optional intTraceLogLevel As Integer = 10, Optional blnShowPrompt As Boolean = False)
    Dim strResponse As String
    
    If blnShowPrompt Then
        strResponse = InputBox("Please enter the new trace log level.  Range is 0 to 10.  0 means off, 1 means the most logging, 10 means the least logging.", "Trace Log Level", gTraceLogLevel)
        If IsNumeric(strResponse) Then
            If val(strResponse) <= 0 Then
                gTraceLogLevel = 0
            ElseIf val(strResponse) >= 10 Then
                gTraceLogLevel = 10
            Else
                gTraceLogLevel = Int(val(strResponse))
            End If
        End If
    Else
        gTraceLogLevel = intTraceLogLevel
    End If
End Sub

Public Sub SmoothViaMovingAverage(dblArray() As Double, lngLowIndex As Long, lngHighIndex As Long, lngWindowSize As Long, Optional intSmoothsToPerform As Integer = 1)
    ' Smooth dblArray() using a moving average
    ' If intSmoothsToPerform is > 1, then repeats the smooth multiple times
    
    Dim intIteration As Integer
    Dim x As Long, y As Long
    Dim lngDataCount As Long
    
    Dim lngWindowHalfWidth As Long
    
    Dim dblSmoothedData() As Double
    Dim dblSum As Double
    
On Error GoTo SmoothViaMovingAverageErrorHandler

    lngDataCount = UBound(dblArray) - LBound(dblArray) + 1
    ReDim SmoothedBPI(LBound(dblArray) To UBound(dblArray))

    If lngDataCount < 3 Then Exit Sub
    If intSmoothsToPerform < 1 Then intSmoothsToPerform = 1
    
    If lngWindowSize < 3 Then lngWindowSize = 3
    ' Make sure lngWindowSize is odd
    If lngWindowSize Mod 2 = 0 Then
        lngWindowSize = lngWindowSize + 1
    End If
    
    lngWindowHalfWidth = (lngWindowSize - 1) / 2
    
    ' Copy data from dblArray() to dblSmoothedData()
    dblSmoothedData() = dblArray()
    
    For intIteration = 1 To intSmoothsToPerform
        ' Smooth the first few points before a full window of points is available
        SmoothUsingMovingAverageEdgeMath dblArray, True, lngLowIndex, lngHighIndex, dblSmoothedData(), lngWindowSize
        
        ' Perform the smooth on the vast majority of points
        For x = lngLowIndex + lngWindowHalfWidth To lngHighIndex - lngWindowHalfWidth
            dblSum = 0
            For y = 0 To lngWindowSize - 1
                dblSum = dblSum + dblArray(x - lngWindowHalfWidth + y)
            Next y
            dblSmoothedData(x) = dblSum / lngWindowSize
        Next x
        
        ' Smooth the last few points after a full window of points is available
        SmoothUsingMovingAverageEdgeMath dblArray, False, lngLowIndex, lngHighIndex, dblSmoothedData(), lngWindowSize
        
        For x = lngLowIndex To lngHighIndex
            ' Copy smoothed array to actual dblArray
            dblArray(x) = dblSmoothedData(x)
        Next x
    Next intIteration
    
    Exit Sub

SmoothViaMovingAverageErrorHandler:
    LogErrors Err.Number, "SmoothViaMovingAverage"
    Debug.Print "Error in SmoothViaMovingAverage: " & Err.Description
    Debug.Assert False
    
End Sub

Private Sub SmoothUsingMovingAverageEdgeMath(dblArray() As Double, blnSmoothBeginningEdge As Boolean, lngLowIndex As Long, lngHighIndex As Long, dblSmoothedData() As Double, lngWindowSize As Long)
    
    Dim StartIndex As Long, FinishIndex As Long
    Dim lngWindowHalfWidth As Long
    
    Dim x As Long, y As Long, lngPointToUse As Long
    Dim dblSum As Double, PointsUsed As Integer
    
    lngWindowHalfWidth = (lngWindowSize - 1) / 2
    
    If blnSmoothBeginningEdge Then
        StartIndex = lngLowIndex
        FinishIndex = lngLowIndex + lngWindowHalfWidth - 1
    Else
        StartIndex = lngHighIndex - lngWindowHalfWidth + 1
        FinishIndex = lngHighIndex
    End If
    
    
    ' Performs a shortened smooth at the beginning and end of a set of points
    For x = StartIndex To FinishIndex
        dblSum = 0
        PointsUsed = 0
        For y = 0 To lngWindowSize - 1
            lngPointToUse = x - lngWindowHalfWidth + y
            If lngPointToUse >= lngLowIndex And lngPointToUse <= lngHighIndex Then
                dblSum = dblSum + dblArray(lngPointToUse)
            Else
                If blnSmoothBeginningEdge Then
                    dblSum = dblSum + dblArray(StartIndex)
                Else
                    dblSum = dblSum + dblArray(FinishIndex)
                End If
            End If
            PointsUsed = PointsUsed + 1
        Next y
        If PointsUsed > 0 Then
            dblSmoothedData(x) = dblSum / PointsUsed
        End If
    Next x

End Sub

Public Sub SplitUMCsByAbundance(lngGelIndex As Long, frmCallingForm As VB.Form, Optional blnShowMessages As Boolean = True, Optional blnUseStatusFunctionOnCallingForm As Boolean = False)
    
    ' Examines the intensities of the ions in each UMC
    ' Looks for UMC's that have two or more distinct peaks in a localized TIC plot (total ion chromatogram)
    ' If multiple members in a UMC are in the same scan, then can either combine their intensities, or use the intensity of the highest ion
    ' If a UMC is found to have two or more peaks, then splits the UMC into 2 (or more parts), proportioning
    '  the members along a scan-based division point
    ' Note: Be sure the UMC Statistics are up to date (by calling UpdateUMCStatArrays) before calling this function
    ' If blnUseStatusFunctionOnCallingForm = True, then calls frmCallingForm.Status for the status messages
    '
    ' In addition, if .GapMaxSize is > 0, then will also split UMC's with gaps larger than .GapMaxSize, regardless of intensity or mass
    
    Dim lngUMCCountAtStart As Long
    Dim lngUMCIndex As Long
    Dim lngScanIndex As Long
    Dim lngCompareIndex As Long
    
    Dim lngMemberScanNumbersRelative() As Long      ' Scan numbers of the members of each UMC (relative, since we call LookupScanNumberRelativeIndex() to lookup the index in .ScanInfo())
    Dim lngClassMemberCount As Long
    
    Dim dblXData() As Double        ' Scan numbers: note, the peak finder algorithm expects evenly spaced data; thus, must use zero's for scans without data
    Dim dblYData() As Double        ' Sum of the intensity of all of the ions falling in the given scan
    Dim lngDataCount As Long
    
    Dim lngMinimumClassCountToCheck As Long
    Dim lngPeakHalfWidthPoints As Long
    
    Dim lngPeakCount As Long
    Dim lngPeakLocations() As Long                  ' 0-based array
    Dim lngPeakEdgesLeft() As Long                  ' 0-based array, parallel with lngPeakLocations(); Not used in this function, though we pass it to objPeakFinder.DetectPeaks
    Dim lngPeakEdgesRight() As Long                 ' 0-based array, parallel with lngPeakLocations(); Not used in this function, though we pass it to objPeakFinder.DetectPeaks
    Dim dblPeakAreas() As Double                    ' 0-based array, parallel with lngPeakLocations(); Not used in this function, though we pass it to objPeakFinder.DetectPeaks
    Dim udtPeakLocs() As udtUMCPeakSplitType        ' 0-based array, parallel with lngPeakLocations()
    
    Dim lngPeakIndex As Long, lngSubIndex As Long
    Dim lngSwapVal As Long
    
    Dim blnSuccess As Boolean
    Dim lngUMCsSplit As Long, lngUMCsAdded As Long
    
    Dim strMessage As String
    Dim strCaptionSaved As String
    
    Dim udtOptions As udtSplitUMCsByAbundanceOptionsType
    Dim objPeakFinder As New clsPeakDetection
    
On Error GoTo SplitUMCsByAbundanceErrorHandler

    ' Validate some of the peak-picking parameters
    With glbPreferencesExpanded.UMCAutoRefineOptions.SplitUMCOptions
        If .PeakWidthPointsMinimum < 3 Then .PeakWidthPointsMinimum = 4
        If .PeakWidthInSigma < 1 Then .PeakWidthInSigma = 3
        
        If .PeakDetectIntensityThresholdPercentageOfMaximum < 1 Then .PeakDetectIntensityThresholdPercentageOfMaximum = 1
        
        If .MaximumPeakCountToSplitUMC < 2 Then .MaximumPeakCountToSplitUMC = 2
    
        lngPeakHalfWidthPoints = CInt(.PeakWidthPointsMinimum / 2#)
    End With
    
    ' Copy the settings to udtOptions (to make the code a bit cleaner)
    udtOptions = glbPreferencesExpanded.UMCAutoRefineOptions.SplitUMCOptions
    
    ' Minimum UMC size must be at least udtOptions.PeakWidthPointsMinimum * 2
    lngMinimumClassCountToCheck = udtOptions.PeakWidthPointsMinimum * 2
    
    lngUMCCountAtStart = GelUMC(lngGelIndex).UMCCnt
    lngUMCsAdded = 0
    lngUMCsSplit = 0
    
    strCaptionSaved = frmCallingForm.Caption
    strMessage = "Finding UMC's needing to be split: 0 / " & Trim(lngUMCCountAtStart)
    If blnUseStatusFunctionOnCallingForm Then
        frmCallingForm.Status strMessage
    Else
        frmCallingForm.Caption = strMessage
    End If
    
    
    If GelSearchDef(lngGelIndex).UMCDef.GapMaxSize > 0 And _
       glbPreferencesExpanded.UMCAutoRefineOptions.SplitUMCOptions.ScanGapBehavior <> susgIgnoreScanGaps Then
        ' First split any UMC's with gaps that are too large
        ' This should only affect UMC's found using UMCIonNet, and not UMCListType2002 or UMC2003
        For lngUMCIndex = 0 To lngUMCCountAtStart - 1
            If GelUMC(lngGelIndex).UMCs(lngUMCIndex).ClassCount > GelSearchDef(lngGelIndex).UMCDef.GapMaxSize Then
                SplitUMCsPopulateArrays lngGelIndex, lngUMCIndex, dblXData(), dblYData(), lngDataCount, lngMemberScanNumbersRelative(), lngClassMemberCount
                    
                ' Look for gaps
                ' Record their presence by recording each group as a peak in udtPeakLocs
                
                ' At most, there will be lngClassMemberCount peaks
                ReDim udtPeakLocs(0 To lngClassMemberCount - 1)
                
                ' The scan gap based peak finder doesn't use lngPeakLocations
                ' However, we'll populate it anyway for completeness since SplitUMCsComputeMedianMass needs to be passed the array
                ReDim lngPeakLocations(0 To lngClassMemberCount - 1)
                
                lngPeakCount = 0
                    
                For lngScanIndex = 0 To lngDataCount - 2
                    lngCompareIndex = lngScanIndex + 1
                    Do While dblYData(lngCompareIndex) = 0
                        lngCompareIndex = lngCompareIndex + 1
                    Loop
                    
                    If lngCompareIndex - lngScanIndex - 1 > GelSearchDef(lngGelIndex).UMCDef.GapMaxSize Then
                        If lngPeakCount = 0 Then
                            ' Need to add the first peak
                            With udtPeakLocs(0)
                                .PeakStartPoint = 0
                            End With
                            lngPeakCount = 1
                        End If
                        
                        With udtPeakLocs(lngPeakCount - 1)
                            .PeakEndPoint = lngCompareIndex - 1
                            ' Define the peak location to be half way between .PeakStartPoint and lngScanIndex,
                            '  since the data between lngScanIndex + 1 and lngCompareIndex all has an intensity of 0
                            lngPeakLocations(lngPeakCount - 1) = (.PeakStartPoint + lngScanIndex) / 2
                        End With
                        
                        udtPeakLocs(lngPeakCount).PeakStartPoint = lngCompareIndex
                        lngPeakCount = lngPeakCount + 1
                        lngScanIndex = lngCompareIndex - 1
                    End If
                Next lngScanIndex
                
                If lngPeakCount > 1 Then
                    With udtPeakLocs(lngPeakCount - 1)
                        .PeakEndPoint = lngDataCount - 1
                        lngPeakLocations(lngPeakCount - 1) = (.PeakEndPoint + .PeakStartPoint) / 2
                    End With
                    
                    ' I believe only UMC Ion Net will produce UMC's that need to be split using scan gaps
                    ' Still, if .def.UMCType is not glUMC_TYPE_FROM_NET, then that is OK too
                    Debug.Assert GelUMC(lngGelIndex).def.UMCType = glUMC_TYPE_FROM_NET
                    
                    ' Now expand the peaks until their StartPoint and EndPoint values touch
                    SplitUMCsWidenAdjacentPeaks udtPeakLocs(), lngPeakCount, dblYData()
                    
                    SplitUMCsLookupMemberIndices udtPeakLocs(), lngPeakCount, dblXData(), lngMemberScanNumbersRelative(), lngClassMemberCount
                    
                    If glbPreferencesExpanded.UMCAutoRefineOptions.SplitUMCOptions.ScanGapBehavior = susgSplitIfMassDifference Then
                        ' Combine the peaks that have similar masses

                        ' Now compute the average mass of the points in each sub-peak
                        SplitUMCsComputeMedianMass lngGelIndex, lngUMCIndex, udtPeakLocs(), lngPeakCount, lngPeakLocations(), udtOptions.MinimumDifferenceInAveragePpmMassToSplit
                        If lngPeakCount > 0 Then
                            Debug.Assert udtPeakLocs(lngPeakCount - 1).MemberIndexEndPoint = lngClassMemberCount - 1
                        End If
                    End If
                    
                    ' Actually split the UMC
                    If SplitUMCsDoSplitting(lngGelIndex, lngUMCIndex, udtPeakLocs(), lngPeakCount, lngMemberScanNumbersRelative, lngUMCsAdded) Then
                        lngUMCsSplit = lngUMCsSplit + 1
                    End If
                End If
                
            End If
        Next lngUMCIndex
    End If
    
    ' Now see if any of the UMC's need to be split due to subregions with differing abundances and mass
    For lngUMCIndex = 0 To lngUMCCountAtStart - 1
        If GelUMC(lngGelIndex).UMCs(lngUMCIndex).ClassCount >= lngMinimumClassCountToCheck Then
            
            SplitUMCsPopulateArrays lngGelIndex, lngUMCIndex, dblXData(), dblYData(), lngDataCount, lngMemberScanNumbersRelative(), lngClassMemberCount
            
            With udtOptions
                lngPeakCount = objPeakFinder.DetectPeaks(dblXData(), dblYData(), lngDataCount, _
                                                        .PeakDetectIntensityThresholdAbsoluteMinimum, _
                                                        .PeakWidthPointsMinimum, _
                                                        lngPeakLocations(), lngPeakEdgesLeft(), lngPeakEdgesRight(), _
                                                        dblPeakAreas(), _
                                                        .PeakDetectIntensityThresholdPercentageOfMaximum, _
                                                        .PeakWidthInSigma, False, True)
            End With
            
            If lngPeakCount > 1 And lngPeakCount <= udtOptions.MaximumPeakCountToSplitUMC Then
            
                ' Possibly Split the UMC into multiple UMC's
                ' First, find the start and end of each peak
                ' Next, find the average mass of the points in each peak
                ' Then, find those peaks that have average masses significantly different than the adjacent peak
                
                ReDim udtPeakLocs(0 To lngPeakCount - 1)
                
                For lngPeakIndex = lngPeakCount - 1 To 1 Step -1
                    ' Make sure this peak and the previous peak are at least udtOptions.PeakWidthPointsMinimum scans apart
                    ' In addition, make sure this peak's apex still points to a valid index in the
                    '  current UMC; this could happen to one of the internal peaks if one of the other peaks included it as part of a split
                    
                    udtPeakLocs(lngPeakIndex).Valid = False
                    If (lngPeakLocations(lngPeakIndex) - lngPeakLocations(lngPeakIndex - 1) >= udtOptions.PeakWidthPointsMinimum) Then
                    
                        If lngPeakIndex = lngPeakCount - 1 Then
                            udtPeakLocs(lngPeakIndex).Valid = True
                            udtPeakLocs(lngPeakIndex).PeakEndPoint = lngClassMemberCount - 1
                        Else
                            If lngPeakLocations(lngPeakIndex) < udtPeakLocs(lngPeakIndex + 1).PeakStartPoint Then
                                udtPeakLocs(lngPeakIndex).Valid = True
                                udtPeakLocs(lngPeakIndex).PeakEndPoint = udtPeakLocs(lngPeakIndex + 1).PeakStartPoint - 1
                            Else
                                udtPeakLocs(lngPeakIndex).Valid = False
                            End If
                        End If
                    
                        If udtPeakLocs(lngPeakIndex).Valid Then
                            ' Define the start point for this peak
                            udtPeakLocs(lngPeakIndex).PeakStartPoint = lngPeakLocations(lngPeakIndex) - lngPeakHalfWidthPoints
                            
                            ' Define the end point for the next peak to the left of this peak
                            udtPeakLocs(lngPeakIndex - 1).PeakEndPoint = lngPeakLocations(lngPeakIndex - 1) + lngPeakHalfWidthPoints
                            
                            If udtPeakLocs(lngPeakIndex - 1).PeakEndPoint > udtPeakLocs(lngPeakIndex).PeakStartPoint Then
                                ' The peaks overlap
                                ' Swap the start and end indices
                                lngSwapVal = udtPeakLocs(lngPeakIndex).PeakStartPoint
                                udtPeakLocs(lngPeakIndex).PeakStartPoint = udtPeakLocs(lngPeakIndex - 1).PeakEndPoint
                                udtPeakLocs(lngPeakIndex - 1).PeakEndPoint = lngSwapVal
                            ElseIf udtPeakLocs(lngPeakIndex - 1).PeakEndPoint = udtPeakLocs(lngPeakIndex).PeakStartPoint Then
                                udtPeakLocs(lngPeakIndex).PeakStartPoint = udtPeakLocs(lngPeakIndex).PeakStartPoint + 1
                            End If
                        End If
                    End If
                Next lngPeakIndex
                
                With udtPeakLocs(0)
                    .PeakStartPoint = 0
                    If .PeakEndPoint = 0 Then
                        .PeakEndPoint = lngPeakLocations(0) + lngPeakHalfWidthPoints
                        For lngSubIndex = 1 To lngPeakCount - 1
                            If udtPeakLocs(lngSubIndex).PeakStartPoint > 0 Then
                                If .PeakEndPoint >= udtPeakLocs(lngSubIndex).PeakStartPoint Then
                                    udtPeakLocs(lngSubIndex).PeakStartPoint = .PeakEndPoint + 1
                                End If
                                Exit For
                            End If
                        Next lngSubIndex
                    End If
                    .Valid = True
                End With
                
                lngPeakIndex = 1
                Do While lngPeakIndex <= lngPeakCount - 1
                    If Not udtPeakLocs(lngPeakIndex).Valid Then
                        ' Remove this peak from lngPeakLocations() and udtPeakLocs()
                        For lngSubIndex = lngPeakIndex To lngPeakCount - 2
                            lngPeakLocations(lngSubIndex) = lngPeakLocations(lngSubIndex + 1)
                            udtPeakLocs(lngSubIndex) = udtPeakLocs(lngSubIndex + 1)
                        Next lngSubIndex
                        lngPeakCount = lngPeakCount - 1
                        
                        If lngPeakIndex <= lngPeakCount - 1 Then
                            With udtPeakLocs(lngPeakIndex)
                                ' Expand the peak to start one point to the right of the next peak to the left
                                .PeakStartPoint = udtPeakLocs(lngPeakIndex - 1).PeakEndPoint + 1
                            End With
                        End If
                    Else
                        lngPeakIndex = lngPeakIndex + 1
                    End If
                Loop
                
                If lngPeakCount > 1 Then
                    
                    ' Now expand the peaks until their StartPoint and EndPoint values touch
                    SplitUMCsWidenAdjacentPeaks udtPeakLocs(), lngPeakCount, dblYData()
                    
                    SplitUMCsLookupMemberIndices udtPeakLocs(), lngPeakCount, dblXData(), lngMemberScanNumbersRelative(), lngClassMemberCount
                                            
                    ' Now compute the average mass of the points in each sub-peak
                    SplitUMCsComputeMedianMass lngGelIndex, lngUMCIndex, udtPeakLocs(), lngPeakCount, lngPeakLocations(), udtOptions.MinimumDifferenceInAveragePpmMassToSplit
                    If lngPeakCount > 0 Then
                        Debug.Assert udtPeakLocs(lngPeakCount - 1).MemberIndexEndPoint = lngClassMemberCount - 1
                    End If
                    
                    If lngPeakCount > 1 Then
                        ' Actually split the UMC
                        If SplitUMCsDoSplitting(lngGelIndex, lngUMCIndex, udtPeakLocs(), lngPeakCount, lngMemberScanNumbersRelative, lngUMCsAdded) Then
                            lngUMCsSplit = lngUMCsSplit + 1
                        End If
                    End If
                End If
                
            End If
        End If
        
        If lngUMCIndex Mod 50 = 0 Then
            strMessage = "Finding UMC's needing to be split: " & Trim(lngUMCIndex) & " / " & Trim(lngUMCCountAtStart)
            If blnUseStatusFunctionOnCallingForm Then
                frmCallingForm.Status strMessage
            Else
                frmCallingForm.Caption = strMessage
            End If
        End If
    Next lngUMCIndex
    
    If lngUMCsAdded > 0 Or lngUMCsSplit > 0 Then
        ' Need to recompute the UMC Statistic arrays and store the updated Class Representative Mass
        blnSuccess = UpdateUMCStatArrays(lngGelIndex, False, frmCallingForm)
        Debug.Assert blnSuccess
    
        frmCallingForm.Caption = strCaptionSaved

        strMessage = "Split UMC's with separate regions; UMC Count before splitting = " & lngUMCCountAtStart & "; UMC's split = " & lngUMCsSplit & "; UMC's Added = " & lngUMCsAdded
        If Not glbPreferencesExpanded.AutoAnalysisStatus.Enabled And blnShowMessages Then
            MsgBox strMessage, vbInformation + vbOKOnly, "Done"
        End If
        AddToAnalysisHistory lngGelIndex, strMessage
    
        ' Possibly Auto-Refine the UMC's
        AutoRefineUMCs lngGelIndex, frmCallingForm
    
    Else
        frmCallingForm.Caption = strCaptionSaved
        If Not glbPreferencesExpanded.AutoAnalysisStatus.Enabled And blnShowMessages Then
            MsgBox "No UMC's were found that needed splitting.", vbInformation + vbOKOnly, "Done"
        End If
    End If
    
    Set objPeakFinder = Nothing
    
    Exit Sub
    
SplitUMCsByAbundanceErrorHandler:
    Debug.Print "Error in SplitUMCsByAbundance: " & Err.Description
    Debug.Assert False
    LogErrors Err.Number, "SplitUMCsBybundance"

End Sub

Private Sub SplitUMCsComputeMedianMass(lngGelIndex As Long, lngUMCIndex As Long, ByRef udtPeakLocs() As udtUMCPeakSplitType, ByRef lngPeakCount As Long, lngPeakLocations() As Long, dblMinimumDifferenceInMedianPpmMassToSplit As Double)

    Dim lngPeakIndex As Long
    Dim lngSubIndex As Long
    
    Dim lngMemberIndex As Long
    Dim lngPeakMemberCount As Long
    
    Dim dblMassSum As Double, dblMassDiff As Double

    Dim blnProceed As Boolean
    Dim blnCombinePeaks As Boolean
    
    Dim objStats As New StatDoubles
    Dim dblMassData() As Double
    
On Error GoTo SplitUMCsComputeAverageMassErrorHandler

    ' Only split if the median mass is at least dblMinimumDifferenceInMedianPpmMassToSplit away from the previous peak
    ' Also make sure the mass difference is at least as large as the StDev of the masses in each peak
    Do
        blnProceed = True
        ' Compute the median mass and StDev in mass for each peak
        With GelUMC(lngGelIndex).UMCs(lngUMCIndex)
            For lngPeakIndex = 0 To lngPeakCount - 1
                dblMassSum = 0
                
                lngPeakMemberCount = udtPeakLocs(lngPeakIndex).MemberIndexEndPoint - udtPeakLocs(lngPeakIndex).MemberIndexStartPoint + 1
                
                If lngPeakIndex > 0 Then
                    Debug.Assert udtPeakLocs(lngPeakIndex).MemberIndexStartPoint = udtPeakLocs(lngPeakIndex - 1).MemberIndexEndPoint + 1
                End If
                
                ReDim dblMassData(lngPeakMemberCount - 1)
                For lngMemberIndex = udtPeakLocs(lngPeakIndex).MemberIndexStartPoint To udtPeakLocs(lngPeakIndex).MemberIndexEndPoint
                    Select Case .ClassMType(lngMemberIndex)
                    Case gldtCS
                        dblMassData(lngMemberIndex - udtPeakLocs(lngPeakIndex).MemberIndexStartPoint) = GelData(lngGelIndex).CSData(.ClassMInd(lngMemberIndex)).AverageMW
                    Case gldtIS
                        dblMassData(lngMemberIndex - udtPeakLocs(lngPeakIndex).MemberIndexStartPoint) = GetIsoMass(GelData(lngGelIndex).IsoData(.ClassMInd(lngMemberIndex)), GelData(lngGelIndex).Preferences.IsoDataField)
                    Case Else
                        ' This shouldn't happen; ignore it
                        Debug.Assert False
                    End Select
                Next lngMemberIndex
                
                ' Compute the median and StDev
                If objStats.Fill(dblMassData) Then
                    udtPeakLocs(lngPeakIndex).MedianMass = objStats.Median
                    udtPeakLocs(lngPeakIndex).StDevMass = objStats.StDev
                End If
            
            Next lngPeakIndex
        End With
        
        ' Compare the computed median mass of each peak to the adjacent peak
        ' If the mass differences are too small, combine the peaks, then set blnProceed = False
        '  so that the median masses are re-computed
        lngPeakIndex = 0
        Do While lngPeakIndex <= lngPeakCount - 2
            dblMassDiff = Abs(udtPeakLocs(lngPeakIndex).MedianMass - udtPeakLocs(lngPeakIndex + 1).MedianMass)
            
            If MassToPPM(dblMassDiff, udtPeakLocs(lngPeakIndex).MedianMass) < dblMinimumDifferenceInMedianPpmMassToSplit Then
                ' Mass difference is too small; combine the peaks
                blnCombinePeaks = True
            Else
                ' Make sure mass difference is at least as large as the StDev in mass of each peak
                If dblMassDiff < udtPeakLocs(lngPeakIndex).StDevMass Or dblMassDiff < udtPeakLocs(lngPeakIndex + 1).StDevMass Then
                    ' Mass difference is too small to be significant, compared to the StDev values
                    ' Combine the peaks
                    blnCombinePeaks = True
                Else
                    ' Split the peaks
                    blnCombinePeaks = False
                End If
            End If
            
            If blnCombinePeaks Then
                With udtPeakLocs(lngPeakIndex)
                    .PeakEndPoint = udtPeakLocs(lngPeakIndex + 1).PeakEndPoint
                    .MemberIndexEndPoint = udtPeakLocs(lngPeakIndex + 1).MemberIndexEndPoint
                End With
                
                For lngSubIndex = lngPeakIndex + 1 To lngPeakCount - 2
                    lngPeakLocations(lngSubIndex) = lngPeakLocations(lngSubIndex + 1)
                    udtPeakLocs(lngSubIndex) = udtPeakLocs(lngSubIndex + 1)
                Next lngSubIndex
                lngPeakCount = lngPeakCount - 1
                
                ' Set blnProceed to false, then Exit the Do Loop and re-compute the median masses
                blnProceed = False
                Exit Do
            Else
                lngPeakIndex = lngPeakIndex + 1
            End If
        Loop
        
    Loop While Not blnProceed And lngPeakCount > 1
    
    Exit Sub
    
SplitUMCsComputeAverageMassErrorHandler:
    Debug.Print "Error in SplitUMCsComputeMedianMass: " & Err.Description
    Debug.Assert False
    LogErrors Err.Number, "SplitUMCsComputeMedianMass"

End Sub

Private Function SplitUMCsDoSplitting(ByVal lngGelIndex As Long, ByVal lngUMCIndex As Long, ByRef udtPeakLocs() As udtUMCPeakSplitType, lngPeakCount As Long, ByRef lngMemberScanNumbersRelative() As Long, ByRef lngUMCsAdded As Long) As Boolean

    Dim lngPeakIndex As Long
    Dim lngSplitIndexMemberIndex As Long
    Dim udtNewUMC As udtUMCType

    Dim lngMemberIndex As Long
    Dim lngTargetIndex As Long
    Dim lngClassRepIndexInUMC As Long
    Dim intUMCRepresentativeType As Integer
    
    Dim eClassRepIonType As glDistType
    
    Dim blnProceed As Boolean
    Dim blnClassSplit As Boolean
    
On Error GoTo SplitUMCsDoSplittingErrorHandler

    blnClassSplit = False
    intUMCRepresentativeType = glbPreferencesExpanded.UMCIonNetOptions.UMCRepresentative
    
    ' Work from right to left
    ' If lngPeakCount is just 1, then nothing will happen
    For lngPeakIndex = lngPeakCount - 1 To 1 Step -1
    
        blnProceed = False
        
        With GelUMC(lngGelIndex).UMCs(lngUMCIndex)
            lngSplitIndexMemberIndex = udtPeakLocs(lngPeakIndex).MemberIndexStartPoint
            If lngSplitIndexMemberIndex > 0 Then
                ' Move the members from the current UMC to udtNewUMC
                
                udtNewUMC.ClassCount = .ClassCount - lngSplitIndexMemberIndex
                ReDim udtNewUMC.ClassMInd(0 To udtNewUMC.ClassCount - 1)
                ReDim udtNewUMC.ClassMType(0 To udtNewUMC.ClassCount - 1)
                
                ' Set these to 0 for now
                udtNewUMC.ClassAbundance = 0
                udtNewUMC.ClassMW = 0
                udtNewUMC.ClassMWStD = 0
                udtNewUMC.ClassRepInd = 0
                udtNewUMC.ClassRepType = gldtIS
                
                udtNewUMC.MinMW = 0
                udtNewUMC.MaxMW = 0
                udtNewUMC.MinScan = 0       ' The scan numbers recorded here will be relative scan numbers, not actual ones
                udtNewUMC.MaxScan = 0       ' The scan numbers recorded here will be relative scan numbers, not actual ones
                
                ' Set .ClassStatusBits = UMC_INDICATOR_BIT_SPLIT_UMC = 16 to record that this was a split UMC
                udtNewUMC.ClassStatusBits = UMC_INDICATOR_BIT_SPLIT_UMC
                
                For lngMemberIndex = lngSplitIndexMemberIndex To .ClassCount - 1
                    lngTargetIndex = lngMemberIndex - lngSplitIndexMemberIndex
                    
                    udtNewUMC.ClassMInd(lngTargetIndex) = .ClassMInd(lngMemberIndex)
                    udtNewUMC.ClassMType(lngTargetIndex) = .ClassMType(lngMemberIndex)
                    
                    If lngMemberIndex = lngSplitIndexMemberIndex Then
                        udtNewUMC.MinScan = lngMemberScanNumbersRelative(lngMemberIndex)
                        udtNewUMC.MaxScan = udtNewUMC.MinScan
                    Else
                        If lngMemberScanNumbersRelative(lngMemberIndex) < udtNewUMC.MinScan Then udtNewUMC.MinScan = lngMemberScanNumbersRelative(lngMemberIndex)
                        If lngMemberScanNumbersRelative(lngMemberIndex) > udtNewUMC.MaxScan Then udtNewUMC.MaxScan = lngMemberScanNumbersRelative(lngMemberIndex)
                    End If
                Next lngMemberIndex
                    
                blnProceed = True
            Else
                ' This shouldn't happen
                Debug.Assert False
            End If
            
            If blnProceed Then
                ' Remove the points from the current UMC
                .ClassCount = lngSplitIndexMemberIndex
                
                ' Update the MaxScan value
                ' Need to dereference from the relative value to the true value using .ScanInfo()
                .MaxScan = GelData(lngGelIndex).ScanInfo(lngMemberScanNumbersRelative(lngSplitIndexMemberIndex - 1)).ScanNumber
                
                ReDim Preserve .ClassMInd(0 To .ClassCount - 1)
                ReDim Preserve .ClassMType(0 To .ClassCount - 1)
                
                ' Reset the various stats for this UMC
                .ClassAbundance = 0
                .ClassMW = 0
                .ClassMWStD = 0
                .ClassRepInd = 0
                .ClassRepType = gldtIS
                
                ' Set .ClassStatusBits = UMC_INDICATOR_BIT_SPLIT_UMC = 16 to record that this was a split UMC
                .ClassStatusBits = UMC_INDICATOR_BIT_SPLIT_UMC
                
                .MinMW = 0
                .MaxMW = 0
                
                ' The class was split, so set this to true
                blnClassSplit = True
                
            End If
        End With
        
        If blnProceed Then
            ' If using UMCIonNet searching, and if .MakeSingleMemberClasses = False, then make sure .MemberCount is not 1
            If GelUMC(lngGelIndex).def.UMCType = glUMC_TYPE_FROM_NET And Not glbPreferencesExpanded.UMCIonNetOptions.MakeSingleMemberClasses Then
                If udtNewUMC.ClassCount = 1 Then
                    blnProceed = False
                End If
            End If
            
            ' If auto-refining is turned on, then see if the new UMC is too short
            If glbPreferencesExpanded.UMCAutoRefineOptions.UMCAutoRefineRemoveCountLow Then
                If glbPreferencesExpanded.UMCAutoRefineOptions.TestLengthUsingScanRange Then
                    If udtNewUMC.ClassCount < glbPreferencesExpanded.UMCAutoRefineOptions.MinMemberCountWhenUsingScanRange Then
                        blnProceed = False
                    ElseIf udtNewUMC.MaxScan - udtNewUMC.MinScan + 1 < glbPreferencesExpanded.UMCAutoRefineOptions.UMCAutoRefineMinLength Then
                        blnProceed = False
                    End If
                Else
                    If udtNewUMC.ClassCount < glbPreferencesExpanded.UMCAutoRefineOptions.UMCAutoRefineMinLength Then
                        blnProceed = False
                    End If
                End If
            End If
            
        End If
        
        If blnProceed Then
            With GelUMC(lngGelIndex)
                ' Add udtNewUMC to .UMCs()
                ' Need to update .MinScan and .MaxScan to be the correct scan numbers
                udtNewUMC.MinScan = GelData(lngGelIndex).ScanInfo(udtNewUMC.MinScan).ScanNumber
                udtNewUMC.MaxScan = GelData(lngGelIndex).ScanInfo(udtNewUMC.MaxScan).ScanNumber
                
                ReDim Preserve .UMCs(.UMCCnt)
                .UMCs(.UMCCnt) = udtNewUMC
                .UMCCnt = .UMCCnt + 1
            End With
            
            ' Find the index of the class representative
            lngClassRepIndexInUMC = FindUMCClassRepIndex(lngGelIndex, GelUMC(lngGelIndex).UMCCnt - 1, intUMCRepresentativeType, eClassRepIonType)
            
            With GelUMC(lngGelIndex).UMCs(GelUMC(lngGelIndex).UMCCnt - 1)
                .ClassRepInd = .ClassMInd(lngClassRepIndexInUMC)
                .ClassRepType = eClassRepIonType
            End With
            
            lngUMCsAdded = lngUMCsAdded + 1
            blnClassSplit = True
        End If
                            
    Next lngPeakIndex

    If blnClassSplit Then
        ' Need to re-determine the class representative for this UMC
        lngClassRepIndexInUMC = FindUMCClassRepIndex(lngGelIndex, lngUMCIndex, intUMCRepresentativeType, eClassRepIonType)
        With GelUMC(lngGelIndex).UMCs(lngUMCIndex)
            .ClassRepInd = .ClassMInd(lngClassRepIndexInUMC)
            .ClassRepType = eClassRepIonType
        End With
    End If
    
    SplitUMCsDoSplitting = blnClassSplit
    Exit Function

SplitUMCsDoSplittingErrorHandler:
    Debug.Assert False
    LogErrors Err.Number, "SplitUMCsDoSplitting"
    Debug.Print "Error in SplitUMCsDoSplitting: " & Err.Description
    SplitUMCsDoSplitting = False

End Function

Private Sub SplitUMCsLookupMemberIndices(ByRef udtPeakLocs() As udtUMCPeakSplitType, ByVal lngPeakCount As Long, ByRef dblXData() As Double, ByRef lngMemberScanNumbersRelative() As Long, ByVal lngClassMemberCount As Long)
    
    Dim lngPreviousPeakMemberIndexStart As Long
    Dim lngPeakIndex As Long
    Dim lngMemberIndex As Long
    
    Dim blnSuccess As Boolean
    
    ' Determine the member indices corresponding to .PeakStartPoint and .PeakEndPoint in each peak
    ' Initialize lngPreviousPeakMemberIndexStart to be 1 more than the last valid member index (i.e. equal to lngClassMemberCount)
    lngPreviousPeakMemberIndexStart = lngClassMemberCount
    For lngPeakIndex = lngPeakCount - 1 To 1 Step -1
    
        With udtPeakLocs(lngPeakIndex)
            .MemberIndexEndPoint = lngPreviousPeakMemberIndexStart - 1
            
            blnSuccess = False
            For lngMemberIndex = 0 To .MemberIndexEndPoint
                If lngMemberScanNumbersRelative(lngMemberIndex) >= dblXData(.PeakStartPoint) Then
                    .MemberIndexStartPoint = lngMemberIndex
                    blnSuccess = True
                    Exit For
                End If
            Next lngMemberIndex
            
            If Not blnSuccess Then
                ' This shouldn't happen
                Debug.Assert False
                .MemberIndexStartPoint = 0
            End If
            
            lngPreviousPeakMemberIndexStart = .MemberIndexStartPoint
        End With
        
        If lngPreviousPeakMemberIndexStart <= 0 Then
            Debug.Assert False
            Exit For
        End If
    Next lngPeakIndex
    
    With udtPeakLocs(0)
        .MemberIndexStartPoint = 0
        .MemberIndexEndPoint = udtPeakLocs(1).MemberIndexStartPoint - 1
    End With
    
End Sub

Private Sub SplitUMCsPopulateArrays(ByVal lngGelIndex As Long, ByVal lngUMCIndex As Long, ByRef dblXData() As Double, ByRef dblYData() As Double, ByRef lngDataCount As Long, ByRef lngMemberScanNumbersRelative() As Long, ByRef lngClassMemberCount As Long)

    Dim lngScanIndex As Long
    Dim lngMemberIndex As Long
    
    Dim lngScanNumberStart As Long
    Dim lngCurrentScanNumber As Long
    Dim dblCurrentIntensity As Double


    With GelUMC(lngGelIndex).UMCs(lngUMCIndex)
        
        lngClassMemberCount = .ClassCount
        
        ' For LTQ-FT data, there can be gaps between scan numbers due to MS/MS scans interleaved between the MS scans
        ' To account for this, we'll lookup the relative index for each scan number and use it, rather than the actual scan number
        lngScanNumberStart = LookupScanNumberRelativeIndex(lngGelIndex, .MinScan)
        lngDataCount = LookupScanNumberRelativeIndex(lngGelIndex, .MaxScan) - lngScanNumberStart + 1
        
        ' At most, we'll need space for lngDataCount scans
        ReDim dblXData(0 To lngDataCount - 1)
        ReDim dblYData(0 To lngDataCount - 1)
        
        ' Initialize dblXData()
        For lngScanIndex = 0 To lngDataCount - 1
            dblXData(lngScanIndex) = lngScanNumberStart + lngScanIndex
        Next lngScanIndex
        
        ' Initialize lngMemberScanNumbersRelative()
        ReDim lngMemberScanNumbersRelative(0 To .ClassCount - 1)
        
        For lngMemberIndex = 0 To .ClassCount - 1
            Select Case .ClassMType(lngMemberIndex)
            Case gldtCS
                lngCurrentScanNumber = GelData(lngGelIndex).CSData(.ClassMInd(lngMemberIndex)).ScanNumber
                dblCurrentIntensity = GelData(lngGelIndex).CSData(.ClassMInd(lngMemberIndex)).Abundance
            Case gldtIS
                lngCurrentScanNumber = GelData(lngGelIndex).IsoData(.ClassMInd(lngMemberIndex)).ScanNumber
                dblCurrentIntensity = GelData(lngGelIndex).IsoData(.ClassMInd(lngMemberIndex)).Abundance
            Case Else
                ' This shouldn't happen; ignore it
                Debug.Assert False
                lngCurrentScanNumber = -1
            End Select
            
            ' Add this ion's intensity to the appropriate index of dblXData() and dblYData()
            If lngCurrentScanNumber >= 0 Then
                lngCurrentScanNumber = LookupScanNumberRelativeIndex(lngGelIndex, lngCurrentScanNumber)
                
                lngScanIndex = lngCurrentScanNumber - lngScanNumberStart
                Debug.Assert dblXData(lngScanIndex) = lngCurrentScanNumber
                If dblCurrentIntensity < 0 Then
                    ' Does this ever happen?  I doubt it (January 2004)
                    ' We don't want to allow negative intensities since we determine whether any data
                    '  is present in the given scan by checking if dblYData() > 0
                    Debug.Assert False
                    dblCurrentIntensity = Abs(dblCurrentIntensity)
                ElseIf dblCurrentIntensity = 0 Then
                    ' Does this ever happen?  I doubt it (January 2004)
                    ' We don't want to allow intensities of 0 since we determine whether any data
                    '  is present in the given scan by checking if dblYData() > 0
                    dblCurrentIntensity = 1
                End If
                    
                dblYData(lngScanIndex) = dblYData(lngScanIndex) + dblCurrentIntensity
                
                lngMemberScanNumbersRelative(lngMemberIndex) = lngCurrentScanNumber
            End If
        Next lngMemberIndex
    End With

End Sub

Private Sub SplitUMCsWidenAdjacentPeaks(ByRef udtPeakLocs() As udtUMCPeakSplitType, lngPeakCount As Long, ByRef dblYData() As Double)
        
    Dim lngPeakIndex As Long
    Dim lngScanIndex As Long
    Dim lngSplitIndexScan As Long
    
    For lngPeakIndex = 0 To lngPeakCount - 2
        
        If udtPeakLocs(lngPeakIndex).PeakEndPoint >= udtPeakLocs(lngPeakIndex + 1).PeakStartPoint - 1 Then
            If udtPeakLocs(lngPeakIndex).PeakEndPoint = udtPeakLocs(lngPeakIndex + 1).PeakStartPoint - 1 Then
                ' The peaks already touch
            Else
                ' This peak overlaps the next one; this shouldn't happen
                ' There must be a problem with the code in the above For Loop (before the Do loop)
                Debug.Assert False
                udtPeakLocs(lngPeakIndex).PeakEndPoint = udtPeakLocs(lngPeakIndex + 1).PeakStartPoint - 1
            End If
        Else
            ' Look for the minimum between udtPeakLocs(lngPeakIndex).PeakEndPoint and udtPeakLocs(lngPeakIndex + 1).PeakStartPoint
            
            lngSplitIndexScan = udtPeakLocs(lngPeakIndex).PeakEndPoint
            For lngScanIndex = udtPeakLocs(lngPeakIndex).PeakEndPoint + 1 To udtPeakLocs(lngPeakIndex + 1).PeakStartPoint
                If dblYData(lngScanIndex) <= dblYData(lngSplitIndexScan) Then
                    lngSplitIndexScan = lngScanIndex
                End If
            Next lngScanIndex
            
            ' Update this peak to end at lngSplitIndexScan and the next to start at lngSplitIndexScan + 1
            udtPeakLocs(lngPeakIndex).PeakEndPoint = lngSplitIndexScan
            udtPeakLocs(lngPeakIndex + 1).PeakStartPoint = lngSplitIndexScan + 1
        End If
        
    Next lngPeakIndex

End Sub

Public Sub TextBoxLimitNumberLength(ByRef txtThisTextBox As VB.TextBox, Optional lngMaxLength As Long = 12, Optional blnUseScientificWhenTooLong As Boolean = True)
    Dim strZeroes As String
    
    If Len(txtThisTextBox) > lngMaxLength Then
        If blnUseScientificWhenTooLong Then
            If lngMaxLength < 5 Then lngMaxLength = 5
            
            strZeroes = String(lngMaxLength - 5, "0")
            txtThisTextBox = Format(val(txtThisTextBox), "0." & strZeroes & "E+00")
        Else
            If lngMaxLength < 3 Then lngMaxLength = 3
            txtThisTextBox = Round(val(txtThisTextBox), lngMaxLength - 2)
        End If
    End If
End Sub

Public Sub TraceLog(intTraceLogLevel As Integer, strFunctionName As String, strMessage As String)
    ' High values of intTraceLogLevel will get logged more often (e.g. 5 or 10)
    ' Lower values of intTraceLogLevel will get logged less often (e.g. 3)
    
    Dim fso As FileSystemObject
    Dim tsOutfile As TextStream
    Dim strTraceFilePath As String
    Dim intTraceLogLevelSaved As Integer
    
On Error GoTo TraceLogErrorHandler

    If gTraceLogLevel > 0 And intTraceLogLevel >= gTraceLogLevel Then
    
        Set fso = New FileSystemObject
    
        strTraceFilePath = fso.BuildPath(App.Path, Format(Now(), "yyyy-mm-dd") & "_ViperTrace.txt")
    
        Set tsOutfile = fso.OpenTextFile(strTraceFilePath, ForAppending, True)
        
        tsOutfile.WriteLine (Now() & vbTab & intTraceLogLevel & vbTab & strFunctionName & vbTab & strMessage)
        tsOutfile.Close
        
        Set tsOutfile = Nothing
        Set fso = Nothing
        
    End If

Exit Sub

TraceLogErrorHandler:
    intTraceLogLevelSaved = gTraceLogLevel
    gTraceLogLevel = 0
    
    LogErrors Err.Number, "MonroeLaVRoutines->TraceLog"
    
    gTraceLogLevel = intTraceLogLevelSaved

End Sub

Public Sub UpdateGelAdjacentScanPointerArrays(Optional ByVal GelIndexToUpdate As Long = -1)
    ' Updates the adjacent scan pointer arrays for GelIndexToUpdate
    ' If GelIndexToUpdate is < 1 or > UBound(GelBody()) then updates all loaded gels
    
    Const MAX_ALLOWED_SCAN_NUMBER As Long = 1000000
    
    Dim lngGelIndex As Long
    Dim lngGelIndexStart As Long, lngGelIndexEnd As Long
    
    Dim lngMasterScanIndex As Long
    Dim lngIndexCompare As Long
    
    Dim lngScanInfoCount As Long
    Dim lngMaxScanNumber As Long
    
    Dim lngScanNumber As Long
    Dim lngPreviousScanNumber As Long
    Dim lngNextScanNumber As Long
    
On Error GoTo UpdateGelAdjacentScanPointerArraysErrorHandler
    
    lngGelIndexEnd = UBound(GelBody())
    If GelIndexToUpdate < 1 Or GelIndexToUpdate > lngGelIndexEnd Then
        lngGelIndexStart = 1
    Else
        lngGelIndexStart = GelIndexToUpdate
        lngGelIndexEnd = GelIndexToUpdate
    End If
    
    For lngGelIndex = lngGelIndexStart To lngGelIndexEnd
        With GelData(lngGelIndex)
        
            lngScanInfoCount = UBound(.ScanInfo)
            lngMaxScanNumber = .ScanInfo(UBound(.ScanInfo)).ScanNumber
            If lngMaxScanNumber < .ScanInfo(lngScanInfoCount).ScanNumber Then
                lngMaxScanNumber = .ScanInfo(lngScanInfoCount).ScanNumber
            End If
            If lngMaxScanNumber > MAX_ALLOWED_SCAN_NUMBER Then lngMaxScanNumber = MAX_ALLOWED_SCAN_NUMBER
            
            ReDim GelDataLookupArrays(lngGelIndex).AdjacentScanNumberPrevious(lngMaxScanNumber)
            ReDim GelDataLookupArrays(lngGelIndex).AdjacentScanNumberNext(lngMaxScanNumber)
            ReDim GelDataLookupArrays(lngGelIndex).ScanNumberRelativeIndex(lngMaxScanNumber)
            
            For lngMasterScanIndex = 1 To lngScanInfoCount
                lngPreviousScanNumber = 0
                lngNextScanNumber = 0
            
                If .ScanInfo(lngMasterScanIndex).ScanNumber < MAX_ALLOWED_SCAN_NUMBER Then
                    If lngMasterScanIndex > 1 Then
                         For lngIndexCompare = lngMasterScanIndex - 1 To 1 Step -1
                             If .ScanInfo(lngMasterScanIndex).ScanType = .ScanInfo(lngIndexCompare).ScanType Then
                                 lngPreviousScanNumber = .ScanInfo(lngIndexCompare).ScanNumber
                                 Exit For
                             End If
                         Next lngIndexCompare
                     End If
                     
                     If lngMasterScanIndex < lngScanInfoCount Then
                         For lngIndexCompare = lngMasterScanIndex + 1 To lngScanInfoCount
                             If .ScanInfo(lngMasterScanIndex).ScanType = .ScanInfo(lngIndexCompare).ScanType Then
                                 lngNextScanNumber = .ScanInfo(lngIndexCompare).ScanNumber
                                 Exit For
                             End If
                         Next lngIndexCompare
                     End If
                     
                     lngScanNumber = .ScanInfo(lngMasterScanIndex).ScanNumber
                     GelDataLookupArrays(lngGelIndex).AdjacentScanNumberPrevious(lngScanNumber) = lngPreviousScanNumber
                     GelDataLookupArrays(lngGelIndex).AdjacentScanNumberNext(lngScanNumber) = lngNextScanNumber
                     GelDataLookupArrays(lngGelIndex).ScanNumberRelativeIndex(lngScanNumber) = lngMasterScanIndex
                End If
            Next lngMasterScanIndex
            
        End With
        
    Next lngGelIndex

    Exit Sub
    
UpdateGelAdjacentScanPointerArraysErrorHandler:
    Debug.Assert False
    If Not glbPreferencesExpanded.AutoAnalysisStatus.Enabled Then
        MsgBox "An error occurred while updating the adjacent scan pointer arrays: " & Err.Description, vbExclamation + vbOKOnly, glFGTU
    Else
        LogErrors Err.Number, "UpdateGelAdjacentScanPointerArrays"
    End If
    
End Sub

Private Sub UpdateIonToUMCIndices(Optional ByVal GelIndexToUpdate As Long = -1, Optional blnUseProgressForm As Boolean = False, Optional frmCallingForm As VB.Form)
    ' Updates the UMC indexing arrays for GelIndexToUpdate
    ' If GelIndexToUpdate is < 1 or > UBound(GelBody()) then updates all loaded gels
    
    Dim lngGelIndex As Long
    Dim lngGelIndexStart As Long, lngGelIndexEnd As Long
    Dim lngUMCIndex As Long, lngMemberIndex As Long
    Dim lngIonIndex As Long, lngNewUMCCount As Long
    Dim lngCSLines As Long, lngIsoLines As Long
    Dim strCaptionSaved As String
    Dim blnShowProgressUsingFormCaption As Boolean
    
On Error GoTo UpdateIonToUMCIndicesErrorHandler
    
    lngGelIndexEnd = UBound(GelBody())
    If GelIndexToUpdate < 1 Or GelIndexToUpdate > lngGelIndexEnd Then
        lngGelIndexStart = 1
    Else
        lngGelIndexStart = GelIndexToUpdate
        lngGelIndexEnd = GelIndexToUpdate
    End If
    
    If blnUseProgressForm Then
        If lngGelIndexStart = lngGelIndexEnd Then
            frmProgress.InitializeSubtask "Updating Ion to UMC Indices", 0, 1
        Else
            frmProgress.InitializeSubtask "Updating Ion to UMC Indices (0 of " & lngGelIndexEnd - lngGelIndexStart + 1 & ")", 0, 1
        End If
    Else
        If Not frmCallingForm Is Nothing Then
            blnShowProgressUsingFormCaption = True
            strCaptionSaved = frmCallingForm.Caption
        End If
    End If
    
    For lngGelIndex = lngGelIndexStart To lngGelIndexEnd
        With GelData(lngGelIndex)
            ReDim GelDataLookupArrays(lngGelIndex).CSUMCs(.CSLines)
            lngCSLines = .CSLines
            
            ReDim GelDataLookupArrays(lngGelIndex).IsoUMCs(.IsoLines)
            lngIsoLines = .IsoLines
        End With
        
        With GelUMC(lngGelIndex)
            If lngGelIndexStart = lngGelIndexEnd Then
                frmProgress.InitializeSubtask "Updating Ion to UMC Indices", 0, .UMCCnt
            Else
                frmProgress.InitializeSubtask "Updating Ion to UMC Indices (" & Trim(lngGelIndex - lngGelIndexStart + 1) & " of " & lngGelIndexEnd - lngGelIndexStart + 1 & ")", 0, .UMCCnt
            End If
                
            For lngUMCIndex = 0 To .UMCCnt - 1
                With .UMCs(lngUMCIndex)
                    For lngMemberIndex = 0 To .ClassCount - 1
                        lngIonIndex = .ClassMInd(lngMemberIndex)
                        
                        Select Case .ClassMType(lngMemberIndex)
                        Case glCSType
                            If lngIonIndex <= lngCSLines Then
                                lngNewUMCCount = GelDataLookupArrays(lngGelIndex).CSUMCs(lngIonIndex).UMCCount + 1
                                If lngNewUMCCount = 1 Then
                                    ReDim GelDataLookupArrays(lngGelIndex).CSUMCs(lngIonIndex).UMCs(0)
                                Else
                                    ReDim Preserve GelDataLookupArrays(lngGelIndex).CSUMCs(lngIonIndex).UMCs(lngNewUMCCount - 1)
                                End If
                            
                                GelDataLookupArrays(lngGelIndex).CSUMCs(lngIonIndex).UMCs(lngNewUMCCount - 1) = lngUMCIndex
                                GelDataLookupArrays(lngGelIndex).CSUMCs(lngIonIndex).UMCCount = lngNewUMCCount
                            Else
                                ' Invalid index; ignore it
                                Debug.Assert False
                            End If
                        Case glIsoType
                            If lngIonIndex <= lngIsoLines Then
                                lngNewUMCCount = GelDataLookupArrays(lngGelIndex).IsoUMCs(lngIonIndex).UMCCount + 1
                                If lngNewUMCCount = 1 Then
                                    ReDim GelDataLookupArrays(lngGelIndex).IsoUMCs(lngIonIndex).UMCs(0)
                                Else
                                    ReDim Preserve GelDataLookupArrays(lngGelIndex).IsoUMCs(lngIonIndex).UMCs(lngNewUMCCount - 1)
                                End If
                                
                                GelDataLookupArrays(lngGelIndex).IsoUMCs(lngIonIndex).UMCs(lngNewUMCCount - 1) = lngUMCIndex
                                GelDataLookupArrays(lngGelIndex).IsoUMCs(lngIonIndex).UMCCount = lngNewUMCCount
                            Else
                                ' Invalid index; ignore it
                                Debug.Assert False
                            End If
                        End Select
                    Next lngMemberIndex
                End With
                
                If lngUMCIndex Mod 500 = 0 Then
                   If blnShowProgressUsingFormCaption Then
                       frmCallingForm.Caption = "Updating Ion to UMC Indices: " & Trim(lngUMCIndex) & " / " & (.UMCCnt)
                   ElseIf blnUseProgressForm Then
                       frmProgress.UpdateSubtaskProgressBar lngUMCIndex
                   End If
                End If
                
            Next lngUMCIndex
        End With
        
    Next lngGelIndex

    If blnShowProgressUsingFormCaption Then frmCallingForm.Caption = strCaptionSaved
    
    Exit Sub
    
UpdateIonToUMCIndicesErrorHandler:
    Debug.Assert False
    If Not glbPreferencesExpanded.AutoAnalysisStatus.Enabled Then
        MsgBox "An error occurred while updating the Ion <--> UMC Indices: " & Err.Description, vbExclamation + vbOKOnly, glFGTU
    Else
        LogErrors Err.Number, "UpdateIonToUMCIndices"
    End If
    On Error Resume Next
    If blnShowProgressUsingFormCaption Then frmCallingForm.Caption = strCaptionSaved
    
End Sub

' Unused function (February 2005)
''Public Sub UpdateMasterScanOrder(ByRef udtScanInfo() As udtScanInfoType, ByVal lngNewScanNumber As Long, ByVal sngElutionTime As Single, ByVal blnAssumeSequentialOrdering As Boolean)
''    ' Appends lngNewScanNumber to udtScanInfo() if it is larger than the value at udtScanInfo(lngMasterScanInfoCount)
''    ' If blnAssumeSequentialOrdering = False, and if lngNewScanNumber is less than the value at udtScanInfo(lngMasterScanInfoCount), then
''    '  inserts lngNewScanNumber into the appropriate position in udtScanInfo()
''    ' Note that udtScanInfo() is a 1-based array
''
''    Dim lngIndex As Long
''    Dim lngIndex2 As Long
''    Dim lngMasterScanInfoCount As Long
''    Dim blnAlreadyPresent As Boolean
''
''    lngMasterScanInfoCount = UBound(udtScanInfo)
''
''    If lngMasterScanInfoCount <= 0 Then
''        lngMasterScanInfoCount = 1
''        ReDim udtScanInfo(lngMasterScanInfoCount)
''        With udtScanInfo(lngMasterScanInfoCount)
''            .ScanNumber = lngNewScanNumber
''            .ElutionTime = sngElutionTime
''            .ScanType = 1
''        End With
''    Else
''        If udtScanInfo(lngMasterScanInfoCount).ScanNumber < lngNewScanNumber Then
''            lngMasterScanInfoCount = lngMasterScanInfoCount + 1
''            ReDim Preserve udtScanInfo(lngMasterScanInfoCount)
''            With udtScanInfo(lngMasterScanInfoCount)
''                .ScanNumber = lngNewScanNumber
''                .ElutionTime = sngElutionTime
''                .ScanType = 1
''            End With
''        ElseIf Not blnAssumeSequentialOrdering Then
''            If udtScanInfo(lngMasterScanInfoCount).ScanNumber > lngNewScanNumber Then
''                ' Need to insert lngNewScanNumber into udtScanInfo
''                For lngIndex = 1 To lngMasterScanInfoCount
''                    If udtScanInfo(lngIndex).ScanNumber > lngNewScanNumber Then
''                        ' Insert the value at lngIndex
''                        Exit For
''                    End If
''                Next lngIndex
''
''                If lngIndex > lngMasterScanInfoCount Then
''                    ' Match not found; this is unexpected
''                    Debug.Assert False
''                    lngMasterScanInfoCount = lngMasterScanInfoCount + 1
''                    ReDim Preserve udtScanInfo(lngMasterScanInfoCount)
''                    With udtScanInfo(lngMasterScanInfoCount)
''                        .ScanNumber = lngNewScanNumber
''                        .ElutionTime = sngElutionTime
''                        .ScanType = 1
''                    End With
''                Else
''                    ' Insert lngNewScanNumber, provided it isn't already present
''                    blnAlreadyPresent = False
''                    If lngIndex > 1 Then
''                        If udtScanInfo(lngIndex - 1).ScanNumber = lngNewScanNumber Then
''                            ' lngNewScanNumber isn't actually new
''                            blnAlreadyPresent = True
''                        End If
''                    End If
''
''                    If Not blnAlreadyPresent Then
''                        ' Shift the items items in udtScanInfo() up one position, then insert lngNewScanNumber
''                        lngMasterScanInfoCount = lngMasterScanInfoCount + 1
''                        ReDim Preserve udtScanInfo(lngMasterScanInfoCount)
''
''                        For lngIndex2 = lngMasterScanInfoCount To lngIndex + 1 Step -1
''                            udtScanInfo(lngIndex2) = udtScanInfo(lngIndex2 - 1)
''                        Next lngIndex2
''                        With udtScanInfo(lngIndex)
''                            .ScanNumber = lngNewScanNumber
''                            .ElutionTime = sngElutionTime
''                            .ScanType = 1
''                        End With
''                    End If
''                End If
''
''            End If
''        End If
''    End If
''
''End Sub

Public Sub UpdateNetAdjRangeStats(udtUMCNetAdjDef As NetAdjDefinition, lblNetAdjInitialNETStats As Label)
    Dim strMessage As String
    
    Dim lngScanMin As Long, lngScanMax As Long
    Dim dblNETMin As Double, dblNETMax As Double
    
    On Error GoTo UpdateNetAdjRangeStatsErrorHandler
    lngScanMin = 0
    lngScanMax = 5000
    dblNETMin = lngScanMin * udtUMCNetAdjDef.InitialSlope + udtUMCNetAdjDef.InitialIntercept
    dblNETMax = lngScanMax * udtUMCNetAdjDef.InitialSlope + udtUMCNetAdjDef.InitialIntercept
    
    strMessage = ""
    strMessage = strMessage & "Scan to NET examples:" & vbCrLf
    strMessage = strMessage & Trim(lngScanMin) & " to " & Trim(lngScanMax) & " -> NET "
    strMessage = strMessage & Round(dblNETMin, 3) & " to " & Round(dblNETMax, 3) & vbCrLf
    
    lngScanMin = 0
    lngScanMax = 20000
    dblNETMin = lngScanMin * udtUMCNetAdjDef.InitialSlope + udtUMCNetAdjDef.InitialIntercept
    dblNETMax = lngScanMax * udtUMCNetAdjDef.InitialSlope + udtUMCNetAdjDef.InitialIntercept
    
    strMessage = strMessage & Trim(lngScanMin) & " to " & Trim(lngScanMax) & " -> NET "
    strMessage = strMessage & Round(dblNETMin, 3) & " to " & Round(dblNETMax, 3)
    
    lblNetAdjInitialNETStats = strMessage
    
    Exit Sub
    
UpdateNetAdjRangeStatsErrorHandler:
    lblNetAdjInitialNETStats = "Error computing Scan to NET examples"
End Sub

Public Function UpdateUMCStatArrays(lngGelIndex As Long, Optional blnUseProgressForm As Boolean = False, Optional frmCallingForm As VB.Form) As Boolean
    ' Returns True if success, False otherwise
    
    Dim blnSuccess As Boolean
    
    If Not glAbortUMCProcessing Then
        ' Update the UMC Classes info
        blnSuccess = CalculateClasses(lngGelIndex, blnUseProgressForm, frmCallingForm)
    End If
    
    If blnSuccess And Not glAbortUMCProcessing Then
        ' Update the IonToUMC Indices
        UpdateIonToUMCIndices lngGelIndex, blnUseProgressForm, frmCallingForm
    End If
    
    If blnSuccess And Not glAbortUMCProcessing Then
        ' Initialize the UMC drawing
        blnSuccess = InitDrawUMC(lngGelIndex)
    End If
    
    If blnSuccess And Not glAbortUMCProcessing Then
        UpdateUMCStatArrays = True
    Else
        UpdateUMCStatArrays = False
    End If
    
End Function

Public Function LookupValueInStringByKey(ByVal strContainer As String, ByVal strKey As String, Optional ByRef blnMatchFound As Boolean = False, Optional strEntryDelimeter As String = ";", Optional strSettingDelimeter As String = "=") As String
    
    Const MAX_SETTING_COUNT = 100000
    
    Dim strSettings() As String
    Dim strCompare As String, strValue As String
    Dim lngSettingCount As Long, lngIndex As Long, lngMatchIndex As Long
    Dim lngCharLoc As Long
    
    lngSettingCount = ParseString(strContainer, strSettings(), MAX_SETTING_COUNT, strEntryDelimeter, "", True, False, False)
    
    ' Find the desired setting
    lngMatchIndex = -1
    For lngIndex = 0 To lngSettingCount - 1
        lngCharLoc = InStr(strSettings(lngIndex), strSettingDelimeter)
        If lngCharLoc = 0 Then
            strCompare = strSettings(lngIndex)
        Else
            strCompare = Left(strSettings(lngIndex), lngCharLoc - 1)
        End If
        
        If LCase(strCompare) = LCase(strKey) Then
            lngMatchIndex = lngIndex
            Exit For
        End If
    Next lngIndex
    
    
    If lngMatchIndex < 0 Then
        ' Setting not found, return ""
        strValue = ""
        blnMatchFound = False
    Else
        ' Find the location of the setting delimeter
        lngCharLoc = InStr(strSettings(lngMatchIndex), strSettingDelimeter)
        If lngCharLoc = 0 Then
            ' Setting not found, return ""
            strValue = ""
            blnMatchFound = False
        Else
            strValue = Mid(strSettings(lngMatchIndex), lngCharLoc + 1)
            blnMatchFound = True
        End If
    End If
    
    LookupValueInStringByKey = strValue
    
End Function

Public Function UpdateValueInStringByKey(ByVal strContainer As String, ByVal strKey As String, ByVal strNewValue As String, Optional strEntryDelimeter As String = ";", Optional strSettingDelimeter As String = "=") As String

    Const MAX_SETTING_COUNT = 100000
    
    Dim strSettings() As String
    Dim strCompare As String
    Dim lngSettingCount As Long, lngIndex As Long, lngMatchIndex As Long
    Dim lngCharLoc As Long
    
    lngSettingCount = ParseString(strContainer, strSettings(), MAX_SETTING_COUNT, strEntryDelimeter, "", True, False, False)
    
    ' Find the desired setting
    lngMatchIndex = -1
    For lngIndex = 0 To lngSettingCount - 1
        lngCharLoc = InStr(strSettings(lngIndex), strSettingDelimeter)
        If lngCharLoc = 0 Then
            strCompare = strSettings(lngIndex)
        Else
            strCompare = Left(strSettings(lngIndex), lngCharLoc - 1)
        End If
        
        If LCase(strCompare) = LCase(strKey) Then
            lngMatchIndex = lngIndex
            Exit For
        End If
    Next lngIndex
    
    ' Add the setting if not found
    If lngMatchIndex < 0 Then
        lngSettingCount = lngSettingCount + 1
        ReDim Preserve strSettings(0 To lngSettingCount - 1)
        lngMatchIndex = lngSettingCount - 1
        strSettings(lngMatchIndex) = strKey & strSettingDelimeter
    End If
    
    ' Find the location of the setting delimeter
    ' Add it if missing
    lngCharLoc = InStr(strSettings(lngMatchIndex), strSettingDelimeter)
    If lngCharLoc = 0 Then
        strSettings(lngMatchIndex) = strSettings(lngMatchIndex) & strSettingDelimeter
        lngCharLoc = Len(strSettings(lngMatchIndex))
    End If
    
    ' Assign the new value for the setting
    strSettings(lngMatchIndex) = Left(strSettings(lngMatchIndex), lngCharLoc) & strNewValue
    
    strContainer = ""
    For lngIndex = 0 To lngSettingCount - 1
        If Len(strContainer) > 0 Then strContainer = strContainer & strEntryDelimeter
        strContainer = strContainer & strSettings(lngIndex)
    Next lngIndex
    
    UpdateValueInStringByKey = strContainer
    
End Function

Public Sub CustomNETsClear(ByVal lngGelIndex As Long)
    
    Dim lngIndex As Long
    
On Error GoTo CustomNETsClearErrorHandler
    
    If lngGelIndex < 0 Or lngGelIndex > UBound(GelData()) Then
        ' Invalid Gel Index
        Exit Sub
    End If

    GelData(lngGelIndex).CustomNETsDefined = False
    With GelData(lngGelIndex)
        For lngIndex = 1 To UBound(.ScanInfo)
            .ScanInfo(lngIndex).CustomNET = 0
        Next lngIndex
    End With

    Exit Sub
    
CustomNETsClearErrorHandler:
    Debug.Assert False
    LogErrors Err.Number, "MonroeLaVRoutines->CustomNETsClear"

End Sub

Public Sub CustomNETsValidateStatus(ByVal lngGelIndex As Long)

    Dim lngIndex As Long

On Error GoTo CustomNETsValidateStatusErrorHandler

    If lngGelIndex < 0 Or lngGelIndex > UBound(GelData()) Then
        ' Invalid Gel Index
        Exit Sub
    End If

    ' Set this to false for now
    GelData(lngGelIndex).CustomNETsDefined = False

    ' See if 1 or more scans in .ScanInfo() contain a non-zero .CustomNET value
    With GelData(lngGelIndex)
        For lngIndex = 1 To UBound(.ScanInfo)
            If .ScanInfo(lngIndex).CustomNET <> 0 Then
                GelData(lngGelIndex).CustomNETsDefined = True
                Exit For
            End If
        Next lngIndex
    End With

    Exit Sub

CustomNETsValidateStatusErrorHandler:
    Debug.Assert False
    LogErrors Err.Number, "MonroeLaVRoutines->CustomNETsValidateStatus"

End Sub

Public Sub ValidateMTMinimimumHighNormalizedScore(ByRef udtAMTData() As udtAMTDataType, ByVal lngIndexStart As Long, ByVal lngIndexEnd As Long, ByRef sngMTMinimumHighNormalizedScore As Single, Optional ByVal lngMinMatchCount As Long = 1)
    ' Make sure at least lngMinMatchCount of the loaded MT tags have score values >= mMTMinimumHighNormalizedScore
    ' If not, divide by 2 (or subtract 0.5), and test again
    ' If any errors occur, set sngMTMinimumHighNormalizedScore to 0
    
    Dim lngIndex As Long
    Dim lngMatchCount As Long
    
    On Error GoTo ValidateScoreErrorHandler

    Do
        lngMatchCount = 0
        For lngIndex = lngIndexStart To lngIndexEnd
            If udtAMTData(lngIndex).HighNormalizedScore >= sngMTMinimumHighNormalizedScore Then lngMatchCount = lngMatchCount + 1
            If lngMatchCount >= lngMinMatchCount Then Exit Do
        Next lngIndex
        
        ' Not enough matching MT tags
        ' If score is > 2, then divide by 2; otherwise, subtract 0.5
        If sngMTMinimumHighNormalizedScore > 2 Then
            sngMTMinimumHighNormalizedScore = sngMTMinimumHighNormalizedScore / 2
        Else
            sngMTMinimumHighNormalizedScore = sngMTMinimumHighNormalizedScore - 0.5
        End If
        If sngMTMinimumHighNormalizedScore < 0 Then sngMTMinimumHighNormalizedScore = 0
    Loop While sngMTMinimumHighNormalizedScore > 0

    Exit Sub

ValidateScoreErrorHandler:
    Debug.Assert False
    LogErrors Err.Number, "MonroeLaVRoutines->ValidateMTMinimimumHighNormalizedScore"
    sngMTMinimumHighNormalizedScore = 0
    
End Sub

Public Sub ValidateMTMinimumDiscriminantAndPepProphet(ByRef udtAMTData() As udtAMTDataType, ByVal lngIndexStart As Long, ByVal lngIndexEnd As Long, ByRef sngMTMinimumHighDiscriminantScore As Single, ByRef sngMTMinimumPeptideProphetProbability As Single, ByRef sngMTMinimumHighNormalizedScore As Single, Optional ByVal lngMinMatchCount As Long = 1)
    ' Make sure at least lngMinMatchCount of the loaded MT tags have score values >= sngMTMinimumHighDiscriminantScore and >= sngMinimumPeptideProphetProbability and >= sngMTMinimumHighNormalizedScore
    ' If not, subtract 0.1 from the discriminant score or the peptide prophet score (favoring the higher score), then test again
    ' If any errors occur, set sngMTMinimumHighDiscriminantScore to 0 and set sngMTMinimumPeptideProphetProbability to 0
    
    Const DECREASE_AMOUNT As Single = 0.1
    Const MAX_ITERATIONS As Integer = 25
    
    Dim lngIndex As Long
    Dim lngMatchCount As Long
    Dim intRepeatCount As Integer
    Dim intIterationCount As Integer
    
    On Error GoTo ValidateScoreErrorHandler

    ' We should have, at most, 2*(1/DECREASE_AMOUNT) = 20 iterations since we're decrementing Discriminant Score or Peptide Prophet probability by 0.1 on each loop
    intIterationCount = 0

    intRepeatCount = 0
    Do
        lngMatchCount = 0
        For lngIndex = lngIndexStart To lngIndexEnd
            If udtAMTData(lngIndex).HighDiscriminantScore >= sngMTMinimumHighDiscriminantScore And _
               udtAMTData(lngIndex).PeptideProphetProbability >= sngMTMinimumPeptideProphetProbability And _
               udtAMTData(lngIndex).HighNormalizedScore >= sngMTMinimumHighNormalizedScore Then
                lngMatchCount = lngMatchCount + 1
            End If
            If lngMatchCount >= lngMinMatchCount Then
                Exit Do
            End If
        Next lngIndex
        
        ' Not enough matching MT tags; try lowering the thresholds
        If sngMTMinimumHighDiscriminantScore > 0 And sngMTMinimumHighDiscriminantScore >= sngMTMinimumPeptideProphetProbability Then
            ' Discriminant is larger than Peptide Prophet; decrease discriminant threshold
            sngMTMinimumHighDiscriminantScore = sngMTMinimumHighDiscriminantScore - 0.1
            If sngMTMinimumHighDiscriminantScore < 0 Then sngMTMinimumHighDiscriminantScore = 0
        ElseIf sngMTMinimumPeptideProphetProbability > 0 Then
            ' Discriminant is zero, or Discriminant is less than Peptide Prophet; decrease Peptide Prophet threshold
            sngMTMinimumPeptideProphetProbability = sngMTMinimumPeptideProphetProbability - 0.1
            If sngMTMinimumPeptideProphetProbability < 0 Then sngMTMinimumPeptideProphetProbability = 0
        Else
            intRepeatCount = intRepeatCount + 1
        End If
        
        intIterationCount = intIterationCount + 1
    Loop While intRepeatCount < 2 And intIterationCount <= MAX_ITERATIONS

    If intIterationCount > MAX_ITERATIONS Then
        ' This code should never be reached
        Debug.Assert False
    End If
    
    Exit Sub

ValidateScoreErrorHandler:
    Debug.Assert False
    LogErrors Err.Number, "MonroeLaVRoutines->ValidateMTMinimumDiscriminantAndPepProphet"
    sngMTMinimumHighDiscriminantScore = 0
    sngMTMinimumPeptideProphetProbability = 0
    
End Sub

Public Function ValueToSqlDecimal(ByVal dblValue As Double, ByVal eSqlDecimalType As sdcSqlDecimalConstants) As Double
    Dim dblMinimum As Double
    Dim dblMaximum As Double
    
    If eSqlDecimalType = sdcSqlDecimal9x4 Then
        dblMaximum = 99999
        dblMinimum = -dblMaximum
    Else
        ' Assume eSqlDecimalType = sdcSqlDecimal9x5 Then
        dblMaximum = 9999
        dblMinimum = -dblMaximum
    End If

    If dblValue < dblMinimum Then
        dblValue = dblMinimum
    ElseIf dblValue > dblMaximum Then
        dblValue = dblMaximum
    End If
    
    ValueToSqlDecimal = dblValue
End Function

Public Sub ViewAnalysisHistory(lngGelIndex As Long)
    Dim strFilePath As String
    Dim intFileNum As Integer
    Dim lngHistoryIndex As Long
    
On Error GoTo ViewAnalysisHistoryError

    intFileNum = FreeFile()
    strFilePath = GetTempFolder() & RawDataTmpFile
    
    Open strFilePath For Output As intFileNum
    Print #intFileNum, "Analysis History Log" & vbCrLf
    
    With GelSearchDef(lngGelIndex)
        For lngHistoryIndex = 0 To .AnalysisHistoryCount - 1
            Print #intFileNum, .AnalysisHistory(lngHistoryIndex)
        Next lngHistoryIndex
    End With
    
    Close intFileNum
    DoEvents
    frmDataInfo.Tag = "ANALYSIS_HISTORY"
    DoEvents
    frmDataInfo.Show vbModal

    Exit Sub

ViewAnalysisHistoryError:
    Close intFileNum
    MsgBox "Error writing output file (" & strFilePath & ") with the info to be displayed:" & Err.Description, vbExclamation + vbOKOnly, "Error"
    
End Sub

' Checks to see if ThisNumber is within ThisTolerance from CompareNumber
' This means that the total window size is 2 x ThisTolerance
Public Function WithinToleranceDbl(ThisNumber As Double, CompareNumber As Double, ThisTolerance As Double) As Boolean
    If ThisNumber <= CompareNumber + ThisTolerance And ThisNumber >= CompareNumber - ThisTolerance Then
        WithinToleranceDbl = True
    Else
        WithinToleranceDbl = False
    End If
End Function

Public Sub ZoomGelToDimensions(lngGelIndex As Long, ByRef sngScanNumberMin As Single, ByRef dblMassMin As Double, ByRef sngScanNumberMax As Single, ByRef dblMassMax As Double)
    ' Zoom the gel to the given dimension
    ' If dblMassMin and dblMassMax are 0, then leaves the mass range untouched and updates dblMassMin and dblMassMax with the current mass range
    ' If sngscanNumberMin and sngScanNumberMax are 0, then leaves the scan range untouched and updates sngscanNumberMin and sngScanNumberMax with the current scan range
    
    Dim lngEffectiveScanNumber1 As Long, lngEffectiveScanNumber2 As Long
    Dim lngScanNumberMin As Long, lngScanNumberMax As Long
    
    On Error GoTo ZoomGelToDimensionsErrorHandler
    
    If lngGelIndex < 0 Or lngGelIndex > UBound(GelBody()) Then
        ' Invalid Gel Index
        Exit Sub
    End If
    
    If sngScanNumberMin <= 0 And sngScanNumberMax <= 0 Then
        GetScanRangeCurrent lngGelIndex, lngScanNumberMin, lngScanNumberMax
        sngScanNumberMin = lngScanNumberMin
        sngScanNumberMax = lngScanNumberMax
    End If
    
    If dblMassMin <= 0 And dblMassMax <= 0 Then
        GetMassRangeCurrent lngGelIndex, dblMassMin, dblMassMax
    End If
    
    ' The following code is from frmZoomIn.cmdOK_Click, though I updated the Log computation to use Log10()
    If GelBody(lngGelIndex).csMyCooSys.csYScale = glVAxisLog Then
        dblMassMin = Log10(dblMassMin)
        dblMassMax = Log10(dblMassMax)
    End If

    Select Case GelBody(lngGelIndex).csMyCooSys.csType
    Case glFNCooSys, glNETCooSys
        GelBody(lngGelIndex).csMyCooSys.ZoomInR CLng(sngScanNumberMin), dblMassMin, CLng(sngScanNumberMax), dblMassMax
    Case glPICooSys
        lngEffectiveScanNumber1 = MaxpIToFN(lngGelIndex, sngScanNumberMax)
        lngEffectiveScanNumber2 = MinpIToFN(lngGelIndex, sngScanNumberMin)
        If lngEffectiveScanNumber1 < 0 Or lngEffectiveScanNumber2 < 0 Then Exit Sub
        If lngEffectiveScanNumber1 >= lngEffectiveScanNumber2 Then lngEffectiveScanNumber2 = lngEffectiveScanNumber1 + 1
        GelBody(lngGelIndex).csMyCooSys.ZoomInR lngEffectiveScanNumber1, dblMassMin, lngEffectiveScanNumber2, dblMassMax
    End Select
    
    Exit Sub

ZoomGelToDimensionsErrorHandler:
    Debug.Assert False
    LogErrors Err.Number, "ZoomGelToDimensions"

End Sub

Public Sub ZoomGelToDimensionsScanOrNET(dblMassMin As Double, dblMassMax As Double, sngScanOrNETMin As Single, sngScanOrNETMax As Single, blnUseNET As Boolean, lngGelIndex As Long)
    Dim lngScanNumberMin As Long, lngScanNumberMax As Long
    
On Error GoTo ZoomGelToDimensionsScanOrNETErrorHandler

    If lngGelIndex < 1 Or lngGelIndex > UBound(GelBody()) Then
        ' Invalid Gel Index
        Exit Sub
    End If
    
    If blnUseNET Then
        lngScanNumberMin = GANETToScan(lngGelIndex, CDbl(sngScanOrNETMin))
        lngScanNumberMax = GANETToScan(lngGelIndex, CDbl(sngScanOrNETMax))
    Else
        lngScanNumberMin = CLng(sngScanOrNETMin)
        lngScanNumberMax = CLng(sngScanOrNETMax)
    End If
    
    ZoomGelToDimensions lngGelIndex, CSng(lngScanNumberMin), dblMassMin, CSng(lngScanNumberMax), dblMassMax

    Exit Sub

ZoomGelToDimensionsScanOrNETErrorHandler:
    Debug.Assert False
    LogErrors Err.Number, "ZoomGelToDimensions"

End Sub

Public Sub WarnUserInvalidLegacyDBPath()
   Dim strMessage As String

   strMessage = "Path to legacy MT tag database (Access DB) not found." & vbCrLf & _
                "Close this dialog and use menu option 'Steps->3. Select MT tags' in the main window to define a legacy database."
        
   MsgBox strMessage, vbOKOnly, glFGTU

End Sub

Public Sub WarnUserNotConnectedToDB(ByVal lngGelIndex As Long, ByVal blnInformLoadLegacyDB As Boolean)

    Dim strMessage As String
    Dim eResponse As VbMsgBoxResult
    
    strMessage = "Current display is not associated with a MT tag database." & vbCrLf & _
                 "Close this dialog and use menu option 'Steps->3. Select MT tags' " & _
                 "in the main window to connect to a database or define a legacy database (Access DB file)."
    
    If blnInformLoadLegacyDB Then
        If Len(GelData(lngGelIndex).PathtoDatabase) > 0 Then
            strMessage = strMessage & "  Alternatively, select MT tags->Load Legacy MT DB " & _
                                      "on this dialog to load data from a legacy database."
        End If
    End If
                 
 
    eResponse = MsgBox(strMessage, vbOKOnly, glFGTU)

End Sub

Public Function WarnUserUnknownMassTags(ByVal lngGelIndex As Long, Optional blnShowYesNoCancel As Boolean = False) As VbMsgBoxResult

    Dim strMessage As String
    Dim eResponse As VbMsgBoxResult
    
    strMessage = "Current display is not associated with a specific MT tag database." & vbCrLf & _
                 "However, MT tags are present in memory (from a previous data load)." & vbCrLf & _
                 "If search should be performed on different MT tag DB you should " & _
                 "close this dialog and establish a link to another DB using menu " & _
                 "option 'Steps->3. Select MT tags' in the main window"
                 
    If Len(GelData(lngGelIndex).PathtoDatabase) > 0 Then
        strMessage = strMessage & " or select 'MT tags->Load Legacy MT DB' on this dialog to load data " & _
                                  "from a legacy database (Access DB file)."
    Else
        strMessage = strMessage & ".  To define a legacy database (Access DB file), use " & _
                                  "'Steps->3. Select MT tags' in the main window."
    End If
                 
    If blnShowYesNoCancel Then
        eResponse = MsgBox(strMessage, vbYesNoCancel + vbDefaultButton3, glFGTU)
    Else
        eResponse = MsgBox(strMessage, vbOKOnly, glFGTU)
    End If

End Function
