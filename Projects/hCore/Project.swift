import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "hCore",
    targets: Set([
        .framework,
        .frameworkResources,
        .tests,
        .example,
        .testing,
    ]),
    externalDependencies: [.flow, .dynamiccolor, .presentation, .snapkit, .apollo, .form, .mixpanel],
    dependencies: ["hGraphQL"],
    sdks: [],
    includesGraphQL: false
)
