//
//  ResourceFileStructGenerator.swift
//  R.swift
//
//  Created by Mathijs Kadijk on 10-12-15.
//  From: https://github.com/mac-cain13/R.swift
//  License: MIT License
//

import Foundation

struct ResourceFileStructGenerator: ExternalOnlyStructGenerator {
  private let resourceFiles: [ResourceFile]

  init(resourceFiles: [ResourceFile]) {
    self.resourceFiles = resourceFiles
  }

  func generatedStruct(at externalAccessLevel: AccessLevel, prefix: SwiftIdentifier) -> Struct {
    let structName: SwiftIdentifier = "file"
    let qualifiedName = prefix + structName
    let localized = resourceFiles.grouped(by: { $0.fullname })
    let groupedLocalized = localized.grouped(bySwiftIdentifier: { $0.0 })

    groupedLocalized.printWarningsForDuplicatesAndEmpties(source: "resource file", result: "file")

    // For resource files, the contents of the different locales don't matter, so we just use the first one
    let firstLocales = groupedLocalized.uniques.map { ($0.0, Array($0.1.prefix(1))) }

    return Struct(
      availables: [],
      comments: ["This `\(qualifiedName)` struct is generated, and contains static references to \(firstLocales.count) files."],
      accessModifier: externalAccessLevel,
      type: Type(module: .host, name: structName),
      implements: [],
      typealiasses: [],
      properties: firstLocales.flatMap { propertiesFromResourceFiles(resourceFiles: $0.1, at: externalAccessLevel) },
      functions: [],
      structs: [],
      classes: [],
      os: []
    )
  }

  private func propertiesFromResourceFiles(resourceFiles: [ResourceFile], at externalAccessLevel: AccessLevel) -> [Let] {

    return resourceFiles
      .map {
        return Let(
          comments: [],
          accessModifier: externalAccessLevel,
          isStatic: true,
          name: SwiftIdentifier(name: $0.fullname),
          typeDefinition: .inferred(Type.FileResource),
          value: "Bundle.main.url(forResource: \"\($0.filename)\", withExtension: \"\($0.pathExtension)\")"
        )
    }
  }
}
