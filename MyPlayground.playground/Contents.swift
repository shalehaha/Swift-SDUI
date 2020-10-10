//
//  Component.swift
//  swift-sdui
//
//  Created by Jiabin Geng on 10/1/20.
//  Copyright © 2020 Adobe. All rights reserved.
//

import Foundation
import SwiftUI

struct PageData: Decodable {
    let children: [Component]
}

struct ColumnData: Decodable {
    let elements: [Component]
}

struct TextData: Decodable {
    let text: String
}

enum  TypeName : String , Decodable  {
     case page
     case column
     case text
}

enum Component: Decodable {
    enum CodingKeys: String, CodingKey {
        case typeName = "type"
    }

    struct Definition<DataType: Decodable>: Decodable {
        let id: String
        let data: DataType
    }

    case page(Definition<PageData>)
    case column(Definition<ColumnData>)
    case text(Definition<TextData>)

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let typeName = try values.decode(TypeName.self, forKey: .typeName)

        switch (typeName) {
        case .page:
            self = .page(try Definition<PageData>(from: decoder))
        case .column:
            self = .column(try Definition<ColumnData>(from: decoder))
        case .text:
            self = .text(try Definition<TextData>(from: decoder))
        }
    }
}

extension Component {
    func render() -> AnyView {
        switch self {
        case .page(let definition): return AnyView(definition.render())
        case .column(let definition): return AnyView(definition.render())
        case .text(let definition): return AnyView(definition.render())
        }
    }
}

// ComponentDefinition+PageData.swift
extension Component.Definition where DataType == PageData {
    func render() -> some View {
        VStack {
            ForEach(data.children, content: { $0.render() })
        }
    }
}

// ComponentDefinition+ColumnData.swift
extension Component.Definition where DataType == ColumnData {
    func render() -> some View {
        VStack {
            ForEach(data.elements, content: { $0.render() })
        }
    }
}

// ComponentDefinition+TextData.swift
extension Component.Definition where DataType == TextData {
    func render() -> some View {
        Text(data.text)
    }
}


extension Component: Identifiable {
    var id: String {
        switch self {
        case .page(let definition): return definition.id
        case .column(let definition): return definition.id
        case .text(let definition): return definition.id
        }
    }
}


struct MySDUIView: View {
    @State var component: Component
    var body: some View {
        component.render()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let json = """
        ...
        """.data(using: .utf8)!
        let component = try! JSONDecoder().decode(Component.self, from: json)
        return MySDUIView(component: component)
    }
}
