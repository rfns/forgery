Class Test.Forgery.Extensions.AssertiveStatus [ Abstract ]
{

Method MatchStatus(assertingStatus As %Status, expectedMessage... As %String) [ Private ]
{
  set statusCode = $System.Status.GetErrorCodes(assertingStatus)
  set statusCount = $length(statusCode, ",")
  set statusMessage = $lfs($System.Status.GetErrorText(assertingStatus), $c(13,10))

  set errorIdRegexp = ##class(%Regex.Matcher).%New("^(?:\s){0,}(ERROR)\s(.*)$")

  for i=1:1:statusCount {
    set errorIdRegexp.Text = $listget(statusMessage, i)
    set messageWithoutCode = errorIdRegexp.ReplaceAll("$2")
    set formattedMessage = ..FormatMessage(messageWithoutCode)
    if formattedMessage '= $get(expectedMessage(i)) {
      return $$$FormatText("Status assertion error: expected status message '%1' but received '%2' instead.", expectedMessage(i), formattedMessage)
    }
  }

  return $$$OK
}

Method FormatMessage(message As %String) As %String
{
  return message
}

}
