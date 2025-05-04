# roblox-wep-api-library

An effort to port the official Roblox web apis on both npm and wally.

## coverage

There are many APIs, and frankly I will never use most of them - especially on the legacy side. Here's a summary:

- Open Cloud V1: all of em!
- Open Cloud V2: all of the universe ones
- Legacy: nothing!

This will change over time, but the legacy ones probably will never be fully ported.

## sub-packages

Default type complexity errors make it impractical to publish this all as a single package. To keep type-safety it is published as sub-packages. They can be found on wally / npm.

- `nightcycle/rbx-api-cloud-v1-universes`
- `nightcycle/rbx-api-cloud-v1-assets`
- `nightcycle/rbx-api-cloud-v2-universes`

As trees increase / decrease in complexity + there are improvements in the luau type engine, expect the specific splitting to change. Ideally all of this would be in one package, but we're not going to sacrifice type safety to do it.

## authentication

This library uses env variables, in Roblox it will first attempt to find the key with `HttpService:GetSecret`, if that doesn't work it will look for it in _G.

- `RBX_OPEN_CLOUD_API_KEY`: used for all open cloud APIs
- `ROBLOSECURITY`: used for all legacy APIs

## doesn't open cloud not work in roblox?

Not yet, but [soon-ish](https://devforum.roblox.com/t/use-open-cloud-via-httpservice-without-proxies-alpha-launch/3587807)

## what are options, futures, and results?

They're classes I ported from rust that I've found make for better coding practices. You can download them from wally / npm:

- option: `nightcycle/option`
- result: `nightcycle/result`
- future: `nightcycle/future`

My hope in building with them, I can encourage safer practices in the dev community. If you don't like using these, I recommend you fork and maintain a version without - there will certainly be demand for it, it's just not something I wish to do. They're pretty simple single-script classes - until I get proper documentation set up, I would honestly just recommend reading the code + the rust documentation.

## contribution

Contributions are appreciated, especially porting APIs. Here are the requirements:

- no nulls except for partial forms (like update masks)
- stick to the established conventions
- always return a future + result combo
- file naming / directory hierarchy should match the url path
- all methods require a test under the tests directory

That being said, so long as it has a test and it works, I'm happy to polish things up so don't stress too much.