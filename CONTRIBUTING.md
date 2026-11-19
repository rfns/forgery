# CONTRIBUTING

In order to contribute to this repository, some few guidelines should be followed.

## When opening issues

Before opening issues, please verify if there's already another issue with a similar subject. Meanwhile, your report could be fixed by another contributor, so it's also recommended to check the [pull requests](https://github.com/rfns/forgery/pulls).

### Issue opening model

When opening a new issue, the title must be short though objective.
And the content must provide the following data:

* __Caché Version__: What's the version you were using when the error ocurred?
* __Operational System__: Normally Windows, but providing the release is a plus.
* __Problem Description__: Detail your problem.
* __Steps to Reproduce__: How could we reproduce the issue?

However you may open an issue to ask or suggest something exclusively related to the development of this project without the need of
fullfiling the requirements above.

## Contributing as a coder

1. [fork](https://github.com/rfns/fogery#fork-destination-box) this project.
2. Make a branch, try to avoid using `master` to prevent confusion.
3. Fix or add new features.
5. Test, test and test again.
6. All your tests passed? Then `commit` your change.
7. Update your fork, `git push origin <your-feature-branch>`.
8. Open a new pull [pull request](https://github.com/rfns/forgery/pulls) for this repo.
7. Standby while your commit is evaluated by the mantainers.
8. When approved, your PR will be merged to the base.
9. Not approved? Uh-oh, something might be missing or breaking the current release. Check the details on your PR.

## Code

* Two spaces.
* English only, though localized documentation is more than welcome.
* New features should preferably be tested with unit tests.

## Staying loadable on Caché

Every release ships two artifacts, and the one without a suffix is exported from
sources that `bin/iris-bc.sh` rewrote. That script covers the mechanical
differences — `%Any`, `%Storage.Persistent`, `[ Language = objectscript ]` — but
not the behavioural ones.

The one that keeps biting: **Caché does not honour an `InitialExpression` of
`{}` or `[]` on a dynamic property.** It compiles, and the property then holds a
`NULLOREF` at runtime, so the failure surfaces far from its cause. Initialise
dynamic properties in `%OnNew` instead:

```objectscript
Property Headers As %DynamicObject [ Private ];

Method %OnNew() As %Status [ Private, ServerOnly = 1 ]
{
  set ..Headers = {}
  return $$$OK
}
```

Scalar initial expressions are fine; this is specific to dynamic objects and
arrays.
