# Preview signing key

`preview.keystore` signs the test builds that CI publishes as the
[`preview` release](https://github.com/manul-wizard/interval-apps/releases/tag/preview).
It is public on purpose — store password, key alias and key password are all
`preview` — so that every preview installs over the previous one.

Preview builds get a `.preview` application id and a "Preview" label, so they
sit next to the store versions instead of replacing them. Nothing signed with
this key may ever be uploaded to a store.
