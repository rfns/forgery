Class Forgery.IO.DeviceInterceptor Extends %RegisteredObject
{

Property DeviceContent As %Stream.FileCharacter [ Private ];

Property OriginalDevice As %String [ InitialExpression = {$io}, Private ];

Property DeviceMnemonic As %String [ InitialExpression = {##class(%Device).GetMnemonicRoutine()}, Private ];

Property DeviceRedirected As %Boolean [ InitialExpression = {##class(%Device).ReDirectIO()}, Private ];

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

Method Intercept(dispatchHandler As Forgery.IDispatchHandler) As %Status
{
  set status = $$$OK

  $$$QuitOnError(..StartInterception())

  try {
    do dispatchHandler.Handle()
  } catch ex {
    do dispatchHandler.PostHandle()    
    set status = ex.AsStatus()
  }

  do ..EndInterception()
  return status
}

Method ChangeTranslateTable(charset As %String) [ Private ]
{
  set ..DeviceContent.TranslateTable = ##class(%Net.Charset).GetTranslateTable(charset)
}

Method ChangeLineTerminator(lineTerminator As %String) [ Private ]
{
  set ..DeviceContent.LineTerminator = lineTerminator
}

Method StartInterception() As %Status [ Private, ProcedureBlock = 0 ]
{
  new status

  $$$QuitOnError(..DeviceContent.Clear())

  set status = $$$OK
  set %forgeryDeviceInterceptedStream = ..DeviceContent

  use $io::("^"_$zname)
  do ##class(%Device).ReDirectIO(1)

  set ..DeviceRedirected = 1

  return $$$OK
}

ClassMethod redirections() [ Internal, Private, ProcedureBlock = 0 ]
{
  quit

wstr(s) do %forgeryDeviceInterceptedStream.Write(s) Quit
wchr(a) do %forgeryDeviceInterceptedStream.Write($char(a)) Quit
wnl do %forgeryDeviceInterceptedStream.Write($char(13,10)) Quit
wff do %forgeryDeviceInterceptedStream.Write($char(13,10,13,10)) Quit
wtab(n) do %forgeryDeviceInterceptedStream.Write($c(9)) Quit
rstr(len,time) Quit ""
rchr(time) Quit ""
}

Method EndInterception() As %Status [ ProcedureBlock = 0 ]
{
  if ..DeviceMnemonic '= "" && (..DeviceMnemonic '= "%X364") {
    use ..OriginalDevice::("^"_..DeviceMnemonic)
  } else {
    use ..OriginalDevice::""
  }

  kill %forgeryDeviceInterceptedStream

  if $isobject(..DeviceContent) do ..DeviceContent.Rewind()
  do ##class(%Device).ReDirectIO(..DeviceRedirected)

  set ..DeviceRedirected = 0

  return $$$OK
}

Method GetInterceptedContent() As %Stream.FileCharacter
{
  return ..DeviceContent
}

}
