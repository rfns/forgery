Class Test.Forgery.FormDataTest Extends %UnitTest.TestCase
{

Method TestFormDataAcceptRepeatedKeysAndCanIterateOver()
{
  set formData = ##class(Forgery.FormData).%New()
  do formData.Append("key", "value1")
  do formData.Append("key", "value2")

  set iterator = formData.GetEntryIterator()
  set entries = []

  while iterator.NextEntry(.entry) {
    do entries.%Push(entry)
  }

  do $$$AssertEquals(entries.%Get(0).name, "key")
  do $$$AssertEquals(entries.%Get(1).name, "key")

  do $$$AssertEquals(entries.%Get(0).value, "value1")
  do $$$AssertEquals(entries.%Get(1).value, "value2")
}

}
