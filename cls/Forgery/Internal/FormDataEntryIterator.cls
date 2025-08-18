Class Forgery.Internal.FormDataEntryIterator Extends %RegisteredObject
{

Property Iteratee As %DynamicArray [ Private ];

Property Index As %Integer [ InitialExpression = 0, Private ];

Method %OnNew(iteratee As %DynamicArray) As %Status
{
  set ..Iteratee = iteratee
  return $$$OK
}

Method NextEntry(Output entry As %DynamicObject = "") As %Boolean
{
  if ..Index > (..Iteratee.%Size() - 1) {
    return 0
  }

  set entry = ..Iteratee.%Get(..Index)
  set ..Index = ..Index + 1

  return 1
}

}
