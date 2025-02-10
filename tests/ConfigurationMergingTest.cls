Class Test.Forgery.ConfigurationMergingTest Extends %UnitTest.TestCase
{

Property Merger As Forgery.Internal.ConfigurationMerger;

Method OnBeforeOneTest() As %Status
{
  set ..Merger = ##class(Forgery.Internal.ConfigurationMerger).%New()
  return $$$OK
}

Method TestMergeTwoProperties()
{
  set source1 = { "a": "b" }
  set source2 = { "c": "d" }

  set result = ..Merger.Merge(source1, source2)

  do $$$AssertEquals(result.a, "b")
  do $$$AssertEquals(result.c, "d")
}

Method TestDontMergeArrays()
{
  set source1 = [1,2,3]
  set source2 = [4,5,6]

  set result = ..Merger.Merge(source1, source2)

  do $$$AssertEquals(result.%Size(), 3)
}

Method TestDontOverwriteKeys()
{
  set source1 = { "a": "b" }
  set source2 = { "a": "c" }

  set result = ..Merger.Merge(source1, source2)

  do $$$AssertEquals(result.a, "b")
}

Method TestDoMergeNestedObjects()
{
  set source1 = { "a": { "b": "c" } }
  set source2 = { "a": { "b": "c", "d": { "e": 1 } }}

  set result = ..Merger.Merge(source1, source2)
  do $$$AssertTrue($isobject(result.a))
  do $$$AssertEquals(result.a.b, "c")
  do $$$AssertEquals(result.a.d.e, 1)
}

}
