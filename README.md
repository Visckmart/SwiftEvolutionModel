# Swift Evolution Model

This is a Swift Package that implements a model of a Swift Evolution proposal, allowing apps to more easily load and decode the proposals [available on the official website](https://download.swift.org/swift-evolution/v1/evolution.json) and allowing developers to build solutions on top of it.

[Proposal Monitor](https://apps.apple.com/br/app/proposal-monitor/id6449445305) is an app I built myself that is now built on top of this Swift Package.

## Context

The [Swift programming language](https://swift.org) has an [open evolution process](https://www.swift.org/swift-evolution/) that enables the community to participate in the discussions that help shape the language.

A fundamental building block of that process is a proposal. A proposal is a piece of well-documented intents, along with their context, motivation and other related information, that serve as an important guidance for the community discussions.

Recently, the [Swift Website Workgroup](https://www.swift.org/website-workgroup/) has [made changes to the Swift Evolution metadata schema](https://forums.swift.org/t/swift-evolution-metadata-proposed-changes/70779), while also making a JSON file conforming to that schema with all of the Swift Evolution proposals available at the [official Swift website](https://download.swift.org/swift-evolution/v1/evolution.json).

### Example Usage

```swift
import SwiftEvolutionModel

let url = URL(string: "https://download.swift.org/swift-evolution/v1/evolution.json")!
let data = try Data(contentsOf: url)
let evolutionFile = try decoder.decode(EvolutionFile.self, from: data)

print(evolutionFile)
print(evolutionFile.proposals.first)
print(evolutionFile.proposals.first!.authors.map(\.name))
```
