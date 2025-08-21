/// A helper for iterating over each FormData entry.
Class Forgery.Internal.FormDataEntryIterator Extends %RegisteredObject
{

/// The list being interated over.
Property Iteratee As %DynamicArray [ Private ];

/// The index indicating the current iteration position in the list.
Property Index As %Integer [ InitialExpression = 0, Private ];

Method %OnNew(iteratee As %DynamicArray) As %Status
{
  set ..Iteratee = iteratee
  return $$$OK
}

/// Retrieves the next entry and returns 1 if there's a next one.
/// When the list reaches the end, returns 0.
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
