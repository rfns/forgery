/// Interface class for creating FormData-like objects which can be provided as payload to the agent.
Class Forgery.IFormData [ Abstract ]
{

/// Appends the data to the matching key.
Method Append(key As %String, value As %Any) [ Abstract ]
{
  $$$ThrowStatus($$$ERROR($$$MethodNotImplemented, "Append"))
}

/// Exposes object for iterating over every entry.
Method GetEntryIterator() As Forgery.Internal.FormDataEntryIterator
{
  $$$ThrowStatus($$$ERROR($$$MethodNotImplemented, "ToPlainObject"))
}

}
