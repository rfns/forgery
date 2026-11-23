Class Forgery.IO.DeviceInterceptor Extends %RegisteredObject
{

Property DeviceContent As %Stream.FileCharacter [ Private ];

Property OriginalDevice As %String [ InitialExpression = {$io}, Private ];

Property DeviceMnemonic As %String [ InitialExpression = {##class(%Device).GetMnemonicRoutine()}, Private ];

Property DevicePreviouslyRedirected As %Boolean [ InitialExpression = {##class(%Device).ReDirectIO()}, Private ];

Property TranslateTable As %String [ Private ];

Property LineTerminator As %String [ InitialExpression = {$c(10, 13)}, Private ];

Method %OnNew(charset As %String = "", lineTerminator As %String = "") As %Status
{
  set ..DeviceContent = ##class(%Stream.FileCharacter).%New()
  if charset '= "" do ..ChangeTranslateTable(charset)
  if lineTerminator '= "" do ..ChangeLineTerminator(lineTerminator)
  return $$$OK
}

Method %OnClose() As %Status
{
  return ..EndInterception()
}

Method ChangeTranslateTable(charset As %String) [ Private ]
{
  set ..DeviceContent.TranslateTable = ##class(%Net.Charset).GetTranslateTable(charset)
}

Method ChangeLineTerminator(lineTerminator As %String) [ Private ]
{
  set ..DeviceContent.LineTerminator = lineTerminator
}

Method StartInterception() As %Status [ ProcedureBlock = 0 ]
{
  new status

  $$$QuitOnError(..DeviceContent.Clear())

  set status = $$$OK
  set %forgeryDeviceInterceptedStream = ..DeviceContent

  use ..OriginalDevice::("^"_$zname)
  do ##class(%Device).ReDirectIO($$$YES)

  return $$$OK
}

ClassMethod redirections() [ Internal, Private, ProcedureBlock = 0 ]
{
  #define WriteIfStreamExists(%ch) do:$data(%forgeryDeviceInterceptedStream) %forgeryDeviceInterceptedStream.Write(%ch)
  
  quit

wstr(s) $$$WriteIfStreamExists(s) Quit
wchr(a) $$$WriteIfStreamExists($char(a)) Quit
wnl $$$WriteIfStreamExists($char(13,10)) Quit
wff $$$WriteIfStreamExists($char(13,10,13,10)) Quit
wtab(n) $$$WriteIfStreamExists($c(9)) Quit
rstr(len,time) Quit ""
rchr(time) Quit ""
}

Method EndInterception() As %Status [ ProcedureBlock = 0 ]
{
  do ..RestoreOriginalDevice()

  kill %forgeryDeviceInterceptedStream

  if $isobject(..DeviceContent) do ..DeviceContent.Rewind()
  if ..DevicePreviouslyRedirected '= 1 do ##class(%Device).ReDirectIO($$$NO)

  return $$$OK
}

/// Restores the device captured before interception started. Under Cache,
/// running via csession with output piped (e.g. a CI container), the device
/// snapshotted at construction time stops being reopenable by name once
/// mnemonic redirection has been toggled on it, and the restore fails with
/// <NOTOPEN>. $principal always resolves back to the process's real device
/// regardless of how it got there, so it's used as a fallback instead of
/// letting the whole dispatch fail.
Method RestoreOriginalDevice() [ Private, ProcedureBlock = 0 ]
{
  set hasMnemonic = (..DeviceMnemonic '= "") && (..DeviceMnemonic '= "%X364")
  set restored = 0

  try {
    if hasMnemonic {
      use ..OriginalDevice::("^"_..DeviceMnemonic)
    } else {
      use ..OriginalDevice
    }
    set restored = 1
  } catch {
  }

  if restored return

  if hasMnemonic {
    use $principal::("^"_..DeviceMnemonic)
  } else {
    use $principal
  }
}

Method GetInterceptedContent() As %Stream.FileCharacter
{
  return ..DeviceContent
}

Method Flush() As %Status
{
  if '$data(%forgeryDeviceInterceptedStream) || '$isobject(%forgeryDeviceInterceptedStream) {
    return $$$OK
  }

  return %forgeryDeviceInterceptedStream.Clear()
}

}
