# .NET Runtime

[1[Build Status](https://dev.azure.com/dnceng-public/public/_apis/build/status/dotnet/runtime/runtime?branchName=main)](https://dev.azure.com/dnceng-public/public/_build/latest?definitionId=129&branchName=main)
[2[Help Wanted](https://img.shields.io/github/issues/dotnet/runtime/help%20wanted?style=flat-square&color=%232EA043&label=help%20wanted)](https://github.com/dotnet/runtime/labels/help%20wanted)
[3[Good First Issue](https://img.shields.io/github/issues/dotnet/runtime/good%20first%20issue?style=flat-square&color=%232EA043&label=good%20first%20issue)](https://github.com/dotnet/runtime/labels/good%20first%20issue)
[4[Discord](https://img.shields.io/discord/732297728826277939?style=flat-square&label=Discord&logo=discord&logoColor=white&color=7289DA)](https://aka.ms/dotnet-discord)

* [What is .NET?](#what-is-net)
* [How can I contribute?](#how-can-i-contribute)
* [Reporting security issues and security bugs](#reporting-security-issues-and-security-bugs)
* [Filing issues](#filing-issues)
* [Useful Links](#useful-links)
* [.NET Foundation](#net-foundation)
* [License](#license)

This repo contains the code to build the .NET runtime, libraries and shared host (`dotnet`) installers for
all supported platforms, as well as the sources to .NET runtime and libraries.

## What is .NET?

Official Starting Page: <https://dotnet.microsoft.com>

* [How to use .NET](https://learn.microsoft.com/dotnet/core/get-started) (with VS, VS Code, command-line CLI)
  * [Install official releases](https://dotnet.microsoft.com/download)
  * [Documentation](https://learn.microsoft.com/dotnet/core) (Get Started, Tutorials, Porting from .NET Framework, API reference, ...)
    * [Deploying apps](https://learn.microsoft.com/dotnet/core/deploying)
* [Support](https://github.com/dotnet/core/blob/main/support.md) (Releases, OS Versions, ...)
* [Roadmap](https://github.com/dotnet/core/blob/main/roadmap.md)

## How can I contribute?

We welcome contributions! Many people all over the world have helped make this project better.

* [Contributing](CONTRIBUTING.md) explains what kinds of contributions we welcome
* [Workflow Instructions](docs/workflow/README.md) explains how to build and test
* [Dogfooding .NET](docs/project/dogfooding.md) explains how to get nightly builds of the runtime and its libraries to test them in your own projects.

## Reporting security issues and security bugs

Security issues and bugs should be reported privately, via email, to the Microsoft Security Response Center (MSRC) <secure@microsoft.com>. You should receive a response within 24 hours. If for some reason you do not, please follow up via email to ensure we received your original message. Further information, including the MSRC PGP key, can be found in the [Security TechCenter](https://www.microsoft.com/msrc/faqs-report-an-issue). You can also find these instructions in this repo's [Security doc](SECURITY.md).

Also see info about related [Microsoft .NET Bounty Program](https://www.microsoft.com/msrc/bounty-dot-net-core).

## Filing issues

This repo should contain issues that are tied to the runtime, the class libraries and frameworks, the installation of the `dotnet` binary (sometimes known as the `muxer`) and the installation of the .NET runtime and libraries.

For other issues, please file them to their appropriate sibling repos. We have links to many of them on [our new issue page](https://github.com/dotnet/runtime/issues/new/choose).

## Useful Links

* [.NET source index](https://source.dot.net) / [.NET Framework source index](https://referencesource.microsoft.com)
* [API Reference docs](https://learn.microsoft.com/dotnet/api)
* [.NET API Catalog](https://apisof.net) (incl. APIs from daily builds and API usage info)
* [API docs writing guidelines](https://github.com/dotnet/dotnet-api-docs/wiki) - useful when writing /// comments
* [.NET Discord Server](https://aka.ms/dotnet-discord) - a place to discuss the development of .NET and its ecosystem

## .NET Foundation

.NET Runtime is a [.NET Foundation](https://www.dotnetfoundation.org/projects) project.

There are many .NET related projects on GitHub.

* [.NET home repo](https://github.com/Microsoft/dotnet) - links to 100s of .NET projects, from Microsoft and the community.
* [ASP.NET Core home](https://learn.microsoft.com/aspnet/core) - the best place to start learning about ASP.NET Core.

This project has adopted the code of conduct defined by the [Contributor Covenant](https://contributor-covenant.org) to clarify expected behavior in our community. For more information, see the [.NET Foundation Code of Conduct](https://www.dotnetfoundation.org/code-of-conduct).

General .NET OSS discussions: [.NET Foundation Discussions](https://github.com/dotnet-foundation/Home/discussions)

## License

.NET (including the runtime repo) is licensed under the [MIT](LICENSE.TXT) license.
