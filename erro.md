
== Gathering artifacts ==

== Publishing artifacts ==

Publishing artifact huanyun_app.ipa
Publishing artifact Runner.app.zip
Publishing huanyun_app.ipa to App Store Connect
> app-store-connect publish --path /Users/builder/clone/build/ios/ipa/huanyun_app.ipa --key-id 2KFMPZC579 --issuer-id 6a9982d2-4fe5-437a-b394-230030787a15 --private-key @env:APP_STORE_CONNECT_PUBLISHER_PRIVATE_KEY

Publish "/Users/builder/clone/build/ios/ipa/huanyun_app.ipa" to App Store Connect
App name: Huanyun App
Bundle identifier: com.huanyun.news
Certificate expires: 2027-02-10T07:24:08.000+0000
Distribution type: App Store
Min OS version: 13.0
Provisioned devices: N/A
Provisions all devices: No
Supported platforms: iPhoneOS
Version code: 1
Version: 1.0.0

Upload "/Users/builder/clone/build/ios/ipa/huanyun_app.ipa" to App Store Connect
Running altool at path '/Applications/Xcode-26.2.app/Contents/SharedFrameworks/ContentDelivery.framework/Resources/altool'...

26.10.1 (171001)
Running altool at path '/Applications/Xcode-26.2.app/Contents/SharedFrameworks/ContentDelivery.framework/Resources/altool'...

2026-02-10 09:12:42.893 ERROR: [ContentDelivery.Uploader.102F1AE40] The provided entity includes an attribute with a value that has already been used (-19232) The bundle version must be higher than the previously uploaded version: ‘1’. (ID: 6ca0e04c-681c-4204-9e44-73033c1ca689)
   NSUnderlyingError : The provided entity includes an attribute with a value that has already been used (-19241) The bundle version must be higher than the previously uploaded version.
      status : 409
      detail : The bundle version must be higher than the previously uploaded version.
      source : 
         pointer : /data/attributes/cfBundleVersion
      id : 6ca0e04c-681c-4204-9e44-73033c1ca689
      code : ENTITY_ERROR.ATTRIBUTE.INVALID.DUPLICATE
      title : The provided entity includes an attribute with a value that has already been used
      meta : 
         previousBundleVersion : 1
   previousBundleVersion : 1
   iris-code : ENTITY_ERROR.ATTRIBUTE.INVALID.DUPLICATE
2026-02-10 09:12:42.894 ERROR: [altool.102F1AE40] Failed to upload package.
{
  "os-version" : "Version 26.2 (Build 25C56)",
  "product-errors" : [
    {
      "code" : -19232,
      "message" : "The provided entity includes an attribute with a value that has already been used",
      "underlying-errors" : [
        {
          "code" : -19241,
          "message" : "The provided entity includes an attribute with a value that has already been used",
          "underlying-errors" : [

          ],
          "user-info" : {
            "NSLocalizedDescription" : "The provided entity includes an attribute with a value that has already been used",
            "NSLocalizedFailureReason" : "The bundle version must be higher than the previously uploaded version.",
            "code" : "ENTITY_ERROR.ATTRIBUTE.INVALID.DUPLICATE",
            "detail" : "The bundle version must be higher than the previously uploaded version.",
            "id" : "6ca0e04c-681c-4204-9e44-73033c1ca689",
            "meta" : "{\n    previousBundleVersion = 1;\n}",
            "source" : "{\n    pointer = \"/data/attributes/cfBundleVersion\";\n}",
            "status" : "409",
            "title" : "The provided entity includes an attribute with a value that has already been used"
          }
        }
      ],
      "user-info" : {
        "NSLocalizedDescription" : "The provided entity includes an attribute with a value that has already been used",
        "NSLocalizedFailureReason" : "The bundle version must be higher than the previously uploaded version: ‘1’. (ID: 6ca0e04c-681c-4204-9e44-73033c1ca689)",
        "NSUnderlyingError" : "Error Domain=IrisAPI Code=-19241 \"The provided entity includes an attribute with a value that has already been used\" UserInfo={status=409, detail=The bundle version must be higher than the previously uploaded version., source={\n    pointer = \"/data/attributes/cfBundleVersion\";\n}, id=6ca0e04c-681c-4204-9e44-73033c1ca689, code=ENTITY_ERROR.ATTRIBUTE.INVALID.DUPLICATE, title=The provided entity includes an attribute with a value that has already been used, meta={\n    previousBundleVersion = 1;\n}, NSLocalizedDescription=The provided entity includes an attribute with a value that has already been used, NSLocalizedFailureReason=The bundle version must be higher than the previously uploaded version.}",
        "iris-code" : "ENTITY_ERROR.ATTRIBUTE.INVALID.DUPLICATE",
        "previousBundleVersion" : "1"
      }
    }
  ],
  "tool-path" : "/Applications/Xcode-26.2.app/Contents/SharedFrameworks/ContentDelivery.framework/Resources",
  "tool-version" : "26.10.1 (171001)"
}

Running altool at path '/Applications/Xcode-26.2.app/Contents/SharedFrameworks/ContentDelivery.framework/Resources/altool'...

2026-02-10 09:12:42.893 ERROR: [ContentDelivery.Uploader.102F1AE40] The provided entity includes an attribute with a value that has already been used (-19232) The bundle version must be higher than the previously uploaded version: ‘1’. (ID: 6ca0e04c-681c-4204-9e44-73033c1ca689)
   NSUnderlyingError : The provided entity includes an attribute with a value that has already been used (-19241) The bundle version must be higher than the previously uploaded version.
      status : 409
      detail : The bundle version must be higher than the previously uploaded version.
      source : 
         pointer : /data/attributes/cfBundleVersion
      id : 6ca0e04c-681c-4204-9e44-73033c1ca689
      code : ENTITY_ERROR.ATTRIBUTE.INVALID.DUPLICATE
      title : The provided entity includes an attribute with a value that has already been used
      meta : 
         previousBundleVersion : 1
   previousBundleVersion : 1
   iris-code : ENTITY_ERROR.ATTRIBUTE.INVALID.DUPLICATE
2026-02-10 09:12:42.894 ERROR: [altool.102F1AE40] Failed to upload package.
{
  "os-version" : "Version 26.2 (Build 25C56)",
  "product-errors" : [
    {
      "code" : -19232,
      "message" : "The provided entity includes an attribute with a value that has already been used",
      "underlying-errors" : [
        {
          "code" : -19241,
          "message" : "The provided entity includes an attribute with a value that has already been used",
          "underlying-errors" : [

          ],
          "user-info" : {
            "NSLocalizedDescription" : "The provided entity includes an attribute with a value that has already been used",
            "NSLocalizedFailureReason" : "The bundle version must be higher than the previously uploaded version.",
            "code" : "ENTITY_ERROR.ATTRIBUTE.INVALID.DUPLICATE",
            "detail" : "The bundle version must be higher than the previously uploaded version.",
            "id" : "6ca0e04c-681c-4204-9e44-73033c1ca689",
            "meta" : "{\n    previousBundleVersion = 1;\n}",
            "source" : "{\n    pointer = \"/data/attributes/cfBundleVersion\";\n}",
            "status" : "409",
            "title" : "The provided entity includes an attribute with a value that has already been used"
          }
        }
      ],
      "user-info" : {
        "NSLocalizedDescription" : "The provided entity includes an attribute with a value that has already been used",
        "NSLocalizedFailureReason" : "The bundle version must be higher than the previously uploaded version: ‘1’. (ID: 6ca0e04c-681c-4204-9e44-73033c1ca689)",
        "NSUnderlyingError" : "Error Domain=IrisAPI Code=-19241 \"The provided entity includes an attribute with a value that has already been used\" UserInfo={status=409, detail=The bundle version must be higher than the previously uploaded version., source={\n    pointer = \"/data/attributes/cfBundleVersion\";\n}, id=6ca0e04c-681c-4204-9e44-73033c1ca689, code=ENTITY_ERROR.ATTRIBUTE.INVALID.DUPLICATE, title=The provided entity includes an attribute with a value that has already been used, meta={\n    previousBundleVersion = 1;\n}, NSLocalizedDescription=The provided entity includes an attribute with a value that has already been used, NSLocalizedFailureReason=The bundle version must be higher than the previously uploaded version.}",
        "iris-code" : "ENTITY_ERROR.ATTRIBUTE.INVALID.DUPLICATE",
        "previousBundleVersion" : "1"
      }
    }
  ],
  "tool-path" : "/Applications/Xcode-26.2.app/Contents/SharedFrameworks/ContentDelivery.framework/Resources",
  "tool-version" : "26.10.1 (171001)"
}

Failed to upload archive at "/Users/builder/clone/build/ios/ipa/huanyun_app.ipa":
The provided entity includes an attribute with a value that has already been used
Failed to publish /Users/builder/clone/build/ios/ipa/huanyun_app.ipa

Failed to publish huanyun_app.ipa to App Store Connect.

Build failed :|


Publishing failed :|
Failed to publish huanyun_app.ipa to App Store Connect.